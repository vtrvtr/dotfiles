# gh auth token reads local state only; gh auth status would hit the network on every shell.
if command -v gh >/dev/null && vtr_gh_token=$(gh auth token 2>/dev/null); then
  export GITHUB_MCP_TOKEN=$vtr_gh_token
fi
unset vtr_gh_token
