zmodload zsh/datetime

ZLE_RPROMPT_INDENT=0

# Formatting:
#  Color: %F{red} %f
#   Options: black red green yellow blue magenta cyan white default
#   Or by number: 0-255
#  Background: %K{red} %k
#  Underline: $U $u
#  Bold: $B $b
# Other docs: http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html

prompt_git_info() {
  local gs=$(git status --porcelain=v2 --branch 2> /dev/null)
  if [[ -z $gs ]]; then echo "%F{black}[not git]%f"; return ; fi

  local branch=$(grep '^# branch.head' <<< "$gs" | cut -c 15-)
  if [[ $branch == '(detached)' ]]; then
    branch=$(grep '^# branch.oid' <<< "$gs" | cut -c 14-21);
  fi

  local staged=$(grep    -c '^. M.' <<< "$gs")
  local modified=$(grep  -c '^. .M' <<< "$gs")
  local deleted=$(grep   -c '^. .D' <<< "$gs")
  local untracked=$(grep -c '^?' <<< "$gs")

  local info="%F{green}[$branch%f"
  (( staged )) && info+="%F{green}+$staged%f"
  (( deleted )) && info+="%F{red}-$deleted%f"
  (( modified )) && info+="%F{yellow}!$modified%f"
  (( untracked )) && info+="%F{yellow}?$untracked%f"

  echo "$info%F{green}]%f"
}

LAST_COMMAND_DURATION=0
LAST_PROMPT_TIME=$EPOCHSECONDS
prompt_exec_time() {
  if ((LAST_COMMAND_DURATION > 0)); then
    # TODO split out mins
    echo "took $LAST_COMMAND_DURATION sec "
  fi
}

prompt_dir_name () { echo "%F{cyan}%1~%f" }
prompt_path()      { echo "%F{cyan}%~%f" }
prompt_time()      { echo "%F{yellow}%D{%L:%M%p}%f" }
prompt_exit_code() { echo "%F{red}%(?..(%?%))%f" }
prompt_bg_jobs()   { echo "%F{white}%(1j.[bg jobs: %j].)%f" }
prompt_char()      { echo "%F{magenta}$ %f" }

# This supports three propmpt positions
#   upper
#   lower       right
# Support for upper-right is complicated but could look like: https://gist.github.com/romkatv/2a107ef9314f0d5f76563725b42f7cab

UPPER_PROMPT='$(prompt_dir_name) $(prompt_git_info) $(prompt_path)'
LOWER_PROMPT='$(prompt_exit_code)$(prompt_bg_jobs)$(prompt_char)'
RIGHT_PROMPT='$(prompt_exec_time)$(prompt_time)'
LOGGED_PROPMT='$(prompt_dir_name) $(prompt_time) $(prompt_char)'

precmd() {
  local NEWLINE=$'\n'
  # Reset prompts modified when accepting line
  LAST_COMMAND_DURATION=$((EPOCHSECONDS - LAST_PROMPT_TIME))
  PROMPT="${NEWLINE}${UPPER_PROMPT}${NEWLINE}${LOWER_PROMPT}"
  RPROMPT=$RIGHT_PROMPT

  # Unset the tab title when displaying a new prompt. ie, clears ssh connection info
  print -Pn "\e]2;%1/\a"
}

reset-prompt-and-accept-line() {
  PROMPT=$LOGGED_PROPMT
  RPROMPT=''
  LAST_PROMPT_TIME=$EPOCHSECONDS

  zle reset-prompt
  zle accept-line
}
zle -N reset-prompt-and-accept-line
bindkey '^m' reset-prompt-and-accept-line

# TODO modify other prompts? 2,3,4,spelling ? http://zsh.sourceforge.net/Doc/Release/Parameters.html
