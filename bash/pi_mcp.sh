# Tokens for pi's MCP servers (read by pi-mcp-connector via ~/.pi/agent/mcp.json).
#
# GitHub: bearer token resolved fresh from gh at shell start.
#
# Confluence/Atlassian needs nothing here: mcp-remote owns that OAuth flow and
# refreshes in-process. An env var would snapshot a token at shell start and
# 401 for the rest of the session once it expired.

# --- GitHub ---
if command -v gh >/dev/null 2>&1; then
	__gh_tok="$(gh auth token 2>/dev/null)"
	[ -n "${__gh_tok}" ] && export GITHUB_MCP_TOKEN="${__gh_tok}"
	unset __gh_tok
fi
