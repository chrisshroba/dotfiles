#===== oh-my-zsh configuration =====
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git docker docker-compose z kubectl helm)

source $ZSH/oh-my-zsh.sh
# ===== end oh-my-zsh configuration =====

# ===== customizing zsh settings =====
HISTSIZE=10000000
SAVEHIST=10000000
# ===== end customizing zsh settings =====

# ===== pyenv config =====
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Source: a comment in https://github.com/pyenv/pyenv-virtualenv/issues/135
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
# export BASE_PROMPT=$PS1
# function precmd {
#   PYENV_VER=$(pyenv version-name)                                       # capture version name in variable
#   if [[ "${PYENV_VER}" != "$(pyenv global | paste -sd ':' -)" ]]; then  # MODIFIED: "system" -> "$(pyenv global | paste -sd ':' -)"
#     export PS1="(${PYENV_VER%%:*}) "$BASE_PROMPT                        # grab text prior to first ':' character
#   else
#     export PS1=$BASE_PROMPT
#   fi
# }

# PS1="%%_: %_
# %%/: %/
# %%c: %c
# %%.: %.
# %%C: %C
# %%!: %!
# %%j: %j
# %%x: %x
# %%L: %L
# %%D: %D
# %%D: %D
# %%T: %T
# %%t: %t
# %%@: %@
# %%*: %*
# %%w: %w
# %%W: %W
# %%l: %l
# %%M: %M
# %%m: %m
# %%n: %n
# %%y: %y
# %%?: %?
# %%B: %B
# "
PS1="
%B%(0?:%F{green}:%F{red}%?)⟩$reset_color %B%F{cyan}%/%F{reset}%b $(git_prompt_info)
➜ "

# End https://github.com/pyenv/pyenv-virtualenv/issues/135
# ===== end pyenv config =====

# ===== nvm config =====
export NVM_DIR="$HOME/.nvm"
# TODO: figure out why this is using `\.` instead of `.`
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# ===== end nvm config =====

# ===== custom aliases for most systems =====
alias pwdc='pwd | pbcopy'
alias zshrc='vim ~/.zshrc; exec zsh'
alias vimrc='vim ~/.vimrc'
alias tmuxrc='vim ~/.tmux.conf; tmux source ~/.tmux.conf'
alias k=kubectl
alias history='fc -iDl 0'
alias trim='cut -c1-$COLUMNS'
alias kubectl="kubecolor"
# ===== end custom aliases for most systems =====

# ===== Adjusting PATH =====
add_to_PATH_highest_priority() {
  export PATH="$1:$PATH"
}
add_to_PATH_lowest_priority() {
  export PATH="$PATH:$1"
}

add_to_PATH_highest_priority "$HOME/dev/bin"
add_to_PATH_highest_priority "$HOME/.bin"

# This is where pipx installs tools to.
add_to_PATH_lowest_priority "$HOME/.local/bin"
# ===== End Adjusting PATH =====

# ===== Custom functions =====
retain-header () {
  OUTPUT=$(cat -)
  echo $OUTPUT | head -n 1 >&2
  echo $OUTPUT | tail -n +2
}

datetime_for_filename() {date '+%Y%m%dT%H%M%S'}

csv_to_json () {
  python -c 'import csv, json, sys; print(json.dumps([dict(r) for r in csv.DictReader(sys.stdin)]))' | jq .
}

function plist_xml_to_json() {
  python -c 'import plistlib,sys,json,base64; print(json.dumps(plistlib.loads(sys.stdin.read().encode("utf-8")), default=lambda o:"base64:"+base64.b64encode(o).decode("ascii")))'
}

function wrap_json_data_in_json_with_when() {
  jq '{when: now, data: .}'
}

function wrap_unjson_data_in_json_with_when() {
  jq -Rs '{when: now, data: .}'
}

# TODO: gate this on macos
function power() {
  # ioreg -rw0 -c AppleSmartBattery -a | python -c 'import plistlib,sys,json; print(json.dumps(plistlib.loads(sys.stdin.read().encode("utf-8")), default=lambda o:"<not serializable>"))' | jq .
  ioreg -rw0 -c AppleSmartBattery -a | plist_xml_to_json | jq .
}

function t() {
  if [ $# -eq 0 ]
  then
    tmux attach 2>/dev/null || tmux
  else
    tmux $@
  fi
}

venv-shebang() {
  printf '#!%s' $(pyenv which python) | pbcopy
  printf 'Copied shebang: "#!%s"' $(pyenv which python)
}

function preexec() {
  timer=${timer:-$SECONDS}
}

function hgrep() {
  IFS=$'\n' read -r header
  echo "$header"
  grep "$@"
}

shai () {
  ai "Please write a zsh command or script to do the follow task on macOS, outputted in a triple backtick codeblock: $1" | tee /tmp/shai.tmp
  python -c "$(cat <<-'EOF'
import sys
flag = False
with open(sys.argv[1], 'r') as f:
  for line in f:
    if '```' in line:
      flag = not flag
    elif flag:
      print(line, end='')
EOF
)" /tmp/shai.tmp > /tmp/shai_code.tmp
  print -z "$(cat /tmp/shai_code.tmp)"
}
# ===== End Custom functions =====


# ===== Aliases for commands I always want to time =====
alias ansible-playbook="time ansible-playbook"
# ===== End Aliases for commands I always want to time =====


# ===== Allow for local zshrc with device-specific config =====
[ -f ~/zshrc-local.zsh ] && source ~/zshrc-local.zsh
# ===== End Allow for local zshrc with device-specific config =====


# ===== Configuration for tools =====
export LESS='-R --mouse'
compdef kubecolor=kubectl
export BAT_THEME=1337
# ===== End configuration for tools =====


# ===== Zsh hooks =====
# function precmd() {
#   if [ $timer ]; then
#     timer_show=$(($SECONDS - $timer))
#     if [ $timer_show -gt 3 ]; then
#       export RPROMPT="%F{cyan}${timer_show}s %{$reset_color%}"
#     else
#       export RPROMPT=""
#     fi
#     unset timer
#   fi
# }
function precmd() {
  if [ $timer ]; then
    timer_show=$(($SECONDS - $timer))
    unset timer
    if [ $timer_show -gt 3 ]; then
      if [ $timer_show -gt 86400 ]; then
        days=$(($timer_show/86400))
        hours=$(($timer_show%86400/3600))
        minutes=$(($timer_show%3600/60))
        seconds=$(($timer_show%60))
        export RPROMPT="%F{cyan}${days}d${hours}h${minutes}m${seconds}s %{$reset_color%}"
      elif [ $timer_show -gt 3600 ]; then
        hours=$(($timer_show/3600))
        minutes=$(($timer_show%3600/60))
        seconds=$(($timer_show%60))
        export RPROMPT="%F{cyan}${hours}h${minutes}m${seconds}s %{$reset_color%}"
      elif [ $timer_show -gt 60 ]; then
        minutes=$(($timer_show/60))
        seconds=$(($timer_show%60))
        export RPROMPT="%F{cyan}${minutes}m${seconds}s %{$reset_color%}"
      else
        export RPROMPT="%F{cyan}${timer_show}s %{$reset_color%}"
      fi
    else
      export RPROMPT=""
    fi
  fi
}

# ===== End zsh hooks =====

[ -s ~/.zshrc-local ] && source ~/.zshrc-local
[ -s ~/.zshrc-secrets ] && source ~/.zshrc-secrets
