if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
  GITHUB_MCP_TOKEN=$(gh auth token)
  export GITHUB_MCP_TOKEN
fi
