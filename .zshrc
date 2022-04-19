# ===== oh-my-zsh configuration =====
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git docker docker-compose z)

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
export BASE_PROMPT=$PS1
function precmd {
  PYENV_VER=$(pyenv version-name)                                       # capture version name in variable
  if [[ "${PYENV_VER}" != "$(pyenv global | paste -sd ':' -)" ]]; then  # MODIFIED: "system" -> "$(pyenv global | paste -sd ':' -)"
    export PS1="(${PYENV_VER%%:*}) "$BASE_PROMPT                        # grab text prior to first ':' character
  else
    export PS1=$BASE_PROMPT
  fi
}
# End https://github.com/pyenv/pyenv-virtualenv/issues/135
# ===== end pyenv config =====

# ===== nvm config =====
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# ===== end nvm config =====

# ===== custom aliases for most systems =====
alias pwdc='pwd | pbcopy'
alias zshrc='vim ~/.zshrc; exec zsh'
alias vimrc='vim ~/.vimrc'
alias tmuxrc='vim ~/.tmux.conf; tmux source ~/.tmux.conf'
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

date_for_filename() {date '+%Y%m%dT%H%M%S'}
# ===== End Custom functions =====

# ===== Aliases for commands I always want to time =====
alias ansible-playbook="time ansible-playbook"
# ===== End Aliases for commands I always want to time =====

# ===== Allow for local zshrc with device-specific config =====
[ -f ~/zshrc-local.zsh ] && source ~/zshrc-local.zsh
# ===== End Allow for local zshrc with device-specific config =====
