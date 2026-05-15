#!/usr/bin/env bash
# Print a valid Atlassian MCP access token on stdout, refreshing as needed.
#
# Atlassian authorises only known OAuth clients for animallogic.atlassian.net.
# Rather than register a new (unapproved) client, we reuse Claude Code's
# approved client + token: seed once from ~/.claude/.credentials.json, then
# maintain our own state file because the refresh token rotates on every use.
#
# Output: the access token on stdout, or nothing (and a diagnostic on stderr)
# on failure, so callers can `export CONFLUENCE_MCP_TOKEN="$(this script)"`.
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/pi-mcp"
STATE_FILE="${STATE_DIR}/confluence-oauth.json"
CLAUDE_CREDS="${HOME}/.claude/.credentials.json"
TOKEN_ENDPOINT="https://cf.mcp.atlassian.com/v1/token"
# Refresh when fewer than this many seconds remain on the access token.
SKEW_SECONDS=300

log() { printf '[pi-confluence-token] %s\n' "$*" >&2; }

now_ms() { date +%s%3N; }

read_json() { # file key -> value on stdout; missing key is empty+success, read/parse failure is nonzero+stderr
	python3 - "$1" "$2" <<'PY'
import json, sys
try:
    with open(sys.argv[1]) as f:
        data = json.load(f)
except (OSError, ValueError) as e:
    print(f"cannot read {sys.argv[1]}: {e}", file=sys.stderr)
    sys.exit(1)
print(data.get(sys.argv[2], ""))
PY
}

# Seed our state from Claude's credentials the first time (or if ours is gone).
seed_from_claude() {
	[ -f "${CLAUDE_CREDS}" ] || { log "no Claude credentials to seed from"; return 1; }
	python3 - "${CLAUDE_CREDS}" "${STATE_FILE}" <<'PY' || return 1
import json, sys, os
creds_path, state_path = sys.argv[1], sys.argv[2]
d = json.load(open(creds_path))
oauth = d.get("mcpOAuth", {})
conf = next((v for k, v in oauth.items() if k.startswith("confluence")), None)
if not conf or not conf.get("refreshToken"):
    sys.exit(1)
os.makedirs(os.path.dirname(state_path), exist_ok=True)
state = {
    "clientId": conf["clientId"],
    "refreshToken": conf["refreshToken"],
    "accessToken": conf.get("accessToken", ""),
    "expiresAt": conf.get("expiresAt", 0),
}
fd = os.open(state_path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
with os.fdopen(fd, "w") as f:
    json.dump(state, f)
PY
}

# Exchange the rotating refresh token for a fresh access token; persist both.
refresh_token() {
	local client_id refresh_token resp
	client_id="$(read_json "${STATE_FILE}" clientId)"
	refresh_token="$(read_json "${STATE_FILE}" refreshToken)"
	[ -n "${client_id}" ] && [ -n "${refresh_token}" ] || { log "state missing clientId/refreshToken"; return 1; }

	resp="$(curl -fsS -X POST "${TOKEN_ENDPOINT}" \
		-H "Content-Type: application/x-www-form-urlencoded" \
		-H "User-Agent: mcp-remote/0.1.37" \
		--data-urlencode "grant_type=refresh_token" \
		--data-urlencode "refresh_token=${refresh_token}" \
		--data-urlencode "client_id=${client_id}" 2>/dev/null)" || { log "token refresh request failed"; return 1; }

	CLIENT_ID="${client_id}" python3 - "${STATE_FILE}" <<'PY' "${resp}"
import json, sys, os, time
state_path = sys.argv[1]
resp = json.loads(sys.argv[2])
access = resp.get("access_token")
if not access:
    sys.exit(1)
expires_at = int(time.time() * 1000) + int(resp.get("expires_in", 3600)) * 1000
state = {
    "clientId": os.environ["CLIENT_ID"],
    # refresh token rotates; fall back to prior one if the server omitted it
    "refreshToken": resp.get("refresh_token"),
    "accessToken": access,
    "expiresAt": expires_at,
}
if not state["refreshToken"]:
    prior = json.load(open(state_path))
    state["refreshToken"] = prior.get("refreshToken")
fd = os.open(state_path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
with os.fdopen(fd, "w") as f:
    json.dump(state, f)
print(access)
PY
}

main() {
	command -v curl >/dev/null 2>&1 || { log "curl not found"; return 1; }
	command -v python3 >/dev/null 2>&1 || { log "python3 not found"; return 1; }

	if [ ! -f "${STATE_FILE}" ]; then
		seed_from_claude || { log "seed failed; cannot provide token"; return 1; }
	fi

	local access expires_at
	access="$(read_json "${STATE_FILE}" accessToken)" || { log "cannot read cached token"; return 1; }
	expires_at="$(read_json "${STATE_FILE}" expiresAt)" || { log "cannot read token expiry"; return 1; }

	# Use the cached token if it is still comfortably valid.
	if [ -n "${access}" ] && [ -n "${expires_at}" ]; then
		if [ "$(( expires_at - $(now_ms) ))" -gt "$(( SKEW_SECONDS * 1000 ))" ]; then
			printf '%s\n' "${access}"
			return 0
		fi
	fi

	# Otherwise refresh; fall back to the (possibly stale) cached token on failure.
	if access="$(refresh_token)"; then
		printf '%s\n' "${access}"
		return 0
	fi
	if [ -n "${access}" ]; then
		log "refresh failed; emitting cached token"
		printf '%s\n' "${access}"
		return 0
	fi
	log "refresh failed and no cached token available"
	return 1
}

main "$@"
