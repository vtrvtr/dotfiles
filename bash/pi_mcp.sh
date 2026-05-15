# Tokens for pi's MCP servers (read by pi-mcp-connector via ~/.pi/agent/mcp.json).
#
# GitHub: bearer token resolved fresh from gh at shell start.
# Confluence (Atlassian): OAuth access token kept alive by refreshing the
#   rotating refresh token. Atlassian only authorises known OAuth clients for
#   animallogic.atlassian.net, so we reuse Claude Code's approved client/token,
#   seeded once from ~/.claude/.credentials.json then maintained in our own
#   state file (the refresh token rotates on every use).

# --- GitHub ---
if command -v gh >/dev/null 2>&1; then
	__gh_tok="$(gh auth token 2>/dev/null)"
	[ -n "${__gh_tok}" ] && export GITHUB_MCP_TOKEN="${__gh_tok}"
	unset __gh_tok
fi

# --- Confluence / Atlassian ---
__confluence_tok="$("${HOME}/.vtr_bash/pi_confluence_token.sh" 2>/dev/null)"
[ -n "${__confluence_tok}" ] && export CONFLUENCE_MCP_TOKEN="${__confluence_tok}"
unset __confluence_tok
