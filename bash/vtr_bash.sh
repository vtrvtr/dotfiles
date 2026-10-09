[[ ${VTR_BASH_INITIALIZED-} == true ]] && return 0

[ -f ~/.vtr_bash/ld_preload_guard.sh ] && source ~/.vtr_bash/ld_preload_guard.sh
source ~/.vtr_bash/devbox.sh
source ~/.vtr_bash/devbox_flake_update.sh
[[ $(type -t __zoxide_hook) == "function" ]] || source ~/.vtr_bash/zoxide.sh
source ~/.vtr_bash/aliases.sh
source ~/.vtr_bash/jj_gh_stack.sh
[[ $(type -t starship_precmd) == "function" ]] || source ~/.vtr_bash/starship.sh
[[ ${__atuin_initialized-} == true ]] || source ~/.vtr_bash/atuin.sh
[[ $(type -t tv_smart_autocomplete) == "function" ]] || source ~/.vtr_bash/tv.sh

tw() {
    local target
    target=$(tv workspaces --inline) || return
    target=${target#$'\e[?u\e[c'}
    [[ -n "$target" ]] && builtin cd -- "$target"
}

[ -f ~/.vtr_bash/pi_mcp.sh ] && source ~/.vtr_bash/pi_mcp.sh

VTR_BASH_INITIALIZED=true
