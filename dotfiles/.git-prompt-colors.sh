override_git_prompt_colors() {
  GIT_PROMPT_THEME_NAME="Custom"

  DateTime="\$(date +'%Y-%m-%d %H:%M')"
  KubeCluster="\$(kubectl config current-context 2> /dev/null)"
  Ochre="\033[38;5;95m"
  GIT_PROMPT_START_USER="\n${Ochre}bosh: ${GoBoshTarget} | ☸️ : ${KubeCluster} (\h) ${ResetColor}\n${Yellow}${PathShort}${ResetColor}"
  GIT_PROMPT_END_USER=" ${Cyan}${GIT_PAIR}${ResetColor}\n$ "
  GIT_PROMPT_END_ROOT="\n# "

  GIT_PROMPT_PREFIX="|"
  GIT_PROMPT_SUFFIX="|"
  GIT_PROMPT_SEPARATOR=" "

  #GIT_PROMPT_BRANCH="${Magenta}"
  GIT_PROMPT_STAGED="${Green}S:"
  GIT_PROMPT_CONFLICTS="${Red}C:"
  GIT_PROMPT_CHANGED="${Blue}U:"
  GIT_PROMPT_UNTRACKED="${Red}?:"
}

reload_git_prompt_colors "Custom"
