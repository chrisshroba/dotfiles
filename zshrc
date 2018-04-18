# Welcome to my Zshrc!
# This is my default zshrc, which applies to all
# machines I use.  At the end of this file, I
# source a local zshrc if one is present at
# $HOME/.zshrc.local.zsh.  This is for anything
# that is specific to a single machine.
#
# This file is broken into the following sections:
#  - Setting up Environment Variables
#  - Setting up third-party tools
#  - Defining functions
#  - Defining aliases
#
# I've labeled anything that requires external
# dependencies with what those dependencies are,
# and you can see the setup_shell.sh script, which
# installs everything necessary.
#
# I hope you find some useful tricks and shortcuts
# here!

# Sometimes things can get weird with current directory, especially when you're
# in a virtual filesystem. cd'ing to the current directory usually fixes the
# issue.
cd $PWD

## A few things this zshrc depends on:

# Functions to determine if this is a linux or mac system.  Useful for
# determining which command to run when the command is different between linux
# and mac.
function is_linux() {
  uname -s | grep Linux >/dev/null
}
function is_mac() {
  uname -s | grep Darwin >/dev/null
}


################################################################################
############################## Third Party Tools ###############################
################################################################################

# (Mac-only) Add the Homebrew bin to my PATH
if is_mac
then
  export PATH=$PATH:$HOME/.brew/bin
fi

### Oh My Zsh Configuration
# Set up Oh My Zsh, which has SO many awesome features, including:
# TODO: fill this out with Oh My Zsh features.
# Check out zshthem.es for an interactive Oh My Zsh theme explorer
ZSH_THEME="robbyrussell"
# Don't ask me every two weeks if I want to update Oh My Zsh
DISABLE_AUTO_UPDATE="false"
# Disallow automatically correcting typos
ENABLE_CORRECTION="false"
# Show three red dots when it's working on autocomplete
COMPLETION_WAITING_DOTS="false"
# List of plugins to enable:
#  - git: Provides tons of git-related aliases (i.e. gst=git status)
#  - zsh-syntax-highlighting: Adds syntax highlighting as you type into the
#    shell. Invalid commands are red, valid ones are green, quoted strings
#    are yellow.
plugins=(git zsh-syntax-highlighting)
# Start up Oh My Zsh with above configuration
source $ZSH/oh-my-zsh.sh

# Setup Autojump for quickly jumping to directories
# Dependency: Autojump (https://github.com/wting/autojump)
if is_mac
then
  source $(brew --prefix)/etc/profile.d/autojump.sh
elif is_linux
then
  source /usr/share/autojump/autojump.zsh
fi

# Enable kv-bash (A simple global key-val store)
# Dependency: kv-bash (https://github.com/damphat/kv-bash)
source $HOME/kv-bash.sh

# Enable fzf in zsh.
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Don't require any special string at the end of the zsh input to activate fzf.
export FZF_COMPLETION_TRIGGER=''
# Ctrl-t to activate fzf for argument completion.
bindkey '^T' fzf-completion
# Don't use fzf completion for normal tab completion.
bindkey '^I' $fzf_default_completion

# TODO: Revisit this in a week or so and see if it's necessary
#export XDG_CONFIG_HOME=$HOME/.config

################################################################################
################################## Functions ###################################
################################################################################

# When I change directory, run the function activate_virtual_env
# Dependency: activate_virtual_env (defined in this file)
chpwd () {
  activate_virtual_env
}

# If you run `tmux` with no arguments, and an existing tmux session is already
# running, attach to it. Otherwise run tmux normally.
tmux () {
  if [[ $# -eq 0 ]]
  then
    command tmux attach || command tmux
  else
    command tmux $@
  fi
}

# Check if a command exists.  Works for executables on
# your path, aliases, and functions.
command_exists () {
    type "$1" &> /dev/null ;
}

# Source a file if it exists, otherwise no-op
source_if_exists() {
    [[ -f $1 ]] && source $@
}

# Scan the current pane for URLs, and open one.  If no argument is specified,
# the last URL will be opened. Otherwise, the nth to last (1-indexed) URL will
# be opened. Note: only works in tmux
# Dependency: google-chrome terminal command. (Might already exist, otherwise
#             just stick an alias in your local zshrc file to wherever your
#             Google Chrome binary is.)
o() {
  tmux capture-pane -p | \
    grep -oE "https?://[^ \t'>]*" | \
    tail -n ${1:-1} | \
    head -n 1 | \
    xargs google-chrome
}

# (Mac-only) Search Messages messages with pretty datetime
if is_mac
then
  t() {
    sqlite3 ~/Library/Messages/chat.db \
      "SELECT \
        is_from_me, \
        datetime(date + strftime('%s','2001-01-01'), 'unixepoch'), \
        handle.id, \
        text \
       FROM \
        message, \
        handle \
       WHERE \
        handle_id=handle.rowid \
       AND \
        text LIKE '%$*%';"
  }
fi

# Put the image that is currently on the clipboard on imgur
# Dependency: pngpaste (https://github.com/jcsalterego/pngpaste)
# Dependency: imguru (https://github.com/FigBug/imguru)
imgurp () {
        FILEPATH=$(mktemp).png
        pngpaste $FILEPATH
        imguru $FILEPATH
        rm $FILEPATH
}

# Download a URL and save it as the same name as the file on the server
curls () {
    curl $1 > $(echo $1 | rev | cut -d "/" -f 1 | rev)
}

# Forward port $1 to shrobaserver, accessible at http://remote.shroba.io
# This makes it so that if I have a local server running on port 1234, say,
# running `remote 1234` will set up an SSH tunnel to my server, and all
# requests to http://remote.shroba.io will be passed through to my local
# server while the tunnel is open.  Useful for showing somebody something
# I'm working on, or for accessing a webapp from my phone.
remote () {
    ssh -nNTR 4100:localhost:$1 shroba
}

# Send a file to shrobaserver to be served out of http://sdrop.shroba.io/
# (secretish because no auto_index)
sdrop () {
    scp $1 chris@shroba.io:/var/www/html/sdrop/
    ssh shroba.io "find /var/www/html/sdrop/* -exec chmod +r {} \;"
}

# Send a file to shrobaserver to be served out of http://drop.shroba.io/
drop () {
    scp $1 shroba:/var/www/html/drop/
    ssh shroba.io "find /var/www/html/drop/* -exec chmod +r {} \;"
}

# Get the directory this script resides in
get_dir_of_this_script() {
    # This is a zsh thing. $0 is the path
    # of this script, :a is a modifier to
    # get the absolute path of the
    # preceding variable, and :h is a
    # modifier to get the directory in
    # which the preceding variable
    # resides. For more info, run:
    # `info -f zsh -n Modifiers`
    echo ${0:a:h}
}

# A util for extracting a capture group from a regex. Grep is fantastic, but you
# can't specify capture groups, and you don't always want the entire output. For
# example, if you have the string "My name is chris", grep can't be used to
# extract the name, but you can use this regex utility to extract the name:
# `regex 'My name is (\w+)\.' 'My name is chris.'`, which returns 'chris`
# TODO: Fix the function to work properly
# TODO: Make the function work on mac and linux
# TODO: Verify that the example above works
function regex {
  gawk 'match($0,/'$1'/, ary) {print ary[1]}'
}

# Generate a cryptographic pseudorandom alphanumeric string.
# Usage: rand <length>
# length defaults to 32 if not specified.
rand () {
    cat /dev/urandom | tr -dc A-Za-z0-9 | head -c ${1:-32}
    echo
}

# When this is set to run on directory change, it will automatically activate
# a virtual env if you are in a directory which contains or has a parent that
# contains a venv directory for a virtualenv.  It will also automatically
# deactivate when you leave such a directory.
function activate_virtual_env() {
  unset VENV_DIR
  # Apparently *some* virtual filesystems (cough cough google) will say that
  # every possible directory exists in certain directory, but it doesn't seem
  # to be recursive, so checking for existence of the venv dir returns some
  # false positives, but checking for a subdirectory of venv (i.e. venv/bin)
  # looks like it's correct.
  [[ -d ../../../../../../../venv/bin ]] && VENV_DIR=../../../../../../../venv
  [[ -d ../../../../../../venv/bin ]] && VENV_DIR=../../../../../../venv
  [[ -d ../../../../../venv/bin ]] && VENV_DIR=../../../../../venv
  [[ -d ../../../../venv/bin ]] && VENV_DIR=../../../../venv
  [[ -d ../../../venv/bin ]] && VENV_DIR=../../../venv
  [[ -d ../../venv/bin ]] && VENV_DIR=../../venv
  [[ -d ../venv/bin ]] && VENV_DIR=../venv
  [[ -d venv/bin ]] && VENV_DIR=venv
  [[ -v VENV_DIR ]] && source $VENV_DIR/bin/activate
  if which deactivate > /dev/null && [[ ! -v VENV_DIR ]]
  then
    deactivate
  fi
}
################################################################################
################################### Aliases ####################################
################################################################################

# Make it easier to clear my screen.
alias cl=clear

# Clear scrollback. This works even in tmux.
alias c="tput reset; [ -v TMUX ] && tmux clear-history"

# Easier editing of config files, with automatic reloading of the ones that need
# it.
alias zshrc="vim ~/.zshrc && exec zsh"
alias vimrc="vim ~/.vimrc"
alias hgrc="vim ~/.hgrc"
alias tmuxrc="vim ~/.tmux.conf && \
              tmux source-file ~/.tmux.conf && \
              blue 'Sourced tmux conf file.'"

# Despite my main PAGER being less, I usually want hg to just cat its output, so
# I set PAGER for hg calls.
alias hg="PAGER=cat hg"

# Easier navigation up and down the tree in hg.
# TODO: Make an hg alias for 'hg xl' if not defined.
alias hgup='hg up -r.^; hg xl'
alias hgup2='hg up -r.^^; hg xl'
alias hgup3='hg up -r.^^^; hg xl'
alias hgup4='hg up -r.^^^^; hg xl'
alias hgbottom="hg update -r tip; hg xl"

# (Zsh-specific) Nicer looking history, and doesn't pollute my scrollback
# because it uses less.  The +G flag makes less jump to the end so that I can
# start by looking at the most recent commands.
alias hist='fc -lt "%D %r" 0 | less +G'

# Print history without timestamps. Useful for grepping or tailing for commands
# to pipe into a file.
alias history="fc -nl 0"

# Inverts the colors of the screen. Useful for signaling when something is done
# when I don't want to miss it (hard to miss your entire screen changing
# colors!)
# TODO: Make this platform agnostic; currently only works in an X session, so
# pretty much only on Linux.
alias invert="xcalib -a -i"

# Invert the screen and then turn it back for a gentler notification.
alias flash="invert; sleep .1; invert"

# (Linux-only) Make pbcopy, pbpaste, open work like they do on Mac.
if is_linux
then
  alias pbcopy='xsel --clipboard --input'
  alias pbpaste='xsel --clipboard --output'
  alias open='xdg-open'
fi

# Print all executables in the current PATH.  Useful for grepping for a command
# when you know it follows a certain pattern but can't think of the specific
# command.
alias allpath='echo $PATH | sed "s/:/\n/g" | xargs ls -1'
# Print all directories in the PATH on separate lines. Useful for seeing what
# directories are on your PATH in a more easy-to-read way.
alias allpathdirs='echo $PATH | tr ":" "\n"'

# When watching a command, refresh every 0.1s, and don't suppress color.
# Dependency: watch (pre-installed on linux, `brew install watch` on mac)
alias watch="watch -n.1 --color"
# Sometimes a program enables mouse reporting and exits without disabling it,
# so whenever you move your mouse or click in the terminal, you'll see lots
# of gibberish.  `mose_reporting_off` will turn this off and fix your
# terminal.  `mouse_reporting_on` does the opposite, which is pretty much
# never what you want.
alias mouse_reporting_on='echo -e "\x1b[?1005h";echo -e "\x1b[?1003h"'
alias mouse_reporting_off='echo -e "\x1b[?1005l";echo -e "\x1b[?1003l"'

# Always color ag, even when piping to another command.  This is good for
# when piping output to less, or when using watch to watch the output.
alias ag="ag --color"

# A better (really, just more colorful) ls, written in Rust.
# Dependency: exa (cargo install exa)
alias ls=exa

# ccat ensures that color is enabled, even when piping to another command.
# Useful for when I'm piping to something like less.
alias ccat="command ccat --color=always"

# This is okay because ccat automatically detects if its output is not being
# piped to a terminal, and doesn't colorize in that case, so this shouldn't
# break anything that can't handle color.
alias cat="command ccat"

# Colorized less.  This works for less'ing a file or piping uncolored output
# into less and having it be colored.
function cless() {
  ccat $@ | less -R
}

# When we want to pipe colored output from hg into another command, we have to
# explicitly let it know.  I've made this a different command from hg (instead
# of just always colorizing hg) because sometimes I pipe output from hg into a
# file or xargs, and I don't want have to remember to uncolorize that output.
alias hgc='hg --color=always'

# Open Google Chrome to a tmux cheat sheet of commands.
# Dependency: google-chrome terminal command. (Might already exist, otherwise
#             just stick an alias in your local zshrc file to wherever your
#             Google Chrome binary is.)
alias tmux-cheat="google-chrome 'https://gist.github.com/MohamedAlaa/2961058'"

# Sometimes I want to clear the screen but have the prompt appear a bit down the
# screen as opposed to at the very top.  These commands clear the screen and
# then put the prompt halfway, a third of the way, or a quarter way down the
# screen, respectively.
alias clear-half='clear; yes " " | head -n $((LINES/2))'
alias clear-third='clear; yes " " | head -n $((LINES/3))'
alias clear-fourth='clear; yes " " | head -n $((LINES/4))'
alias cl2=clear-half
alias cl3=clear-third
alias cl4=clear-fourth

# Open my local To Do list file in vim.  I suggest the
# 'aserebryakov/vim-todo-lists' vim plugin for handling To Do lists.
alias todo='vim ~/today.todo'

# Copy the current path to clipboard
# Dependency: alias pbcopy, if supporting linux (defined in this file)
alias pwdc='pwd | pbcopy'

# (Mac-only) When the MacBook camera stops working, this should fix it
if is_mac
then
  alias fixcamera='sudo killall VDCAssistant'
fi

################################################################################
############################ Environment Variables #############################
################################################################################

### PATH modifications
# TODO: Comment what each of these is for.
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.cargo/bin

# Let $DOTFILES_DIR be the directory of this script.  Useful for sourcing other
# files in this directory.
export DOTFILES_DIR=$(get_dir_of_this_script)

# The directory that contains my version controlled dotfiles
# Dependency: get_dir_of_this_script function (defined in this file)
DOTFILES_DIR=get_dir_of_this_script

# Many command line programs will use the value of the EDITOR variable to
# choose what editor to use (i.e. crontab -e).
export EDITOR='vim'

# Many command line programs will use the value of the PAGER variable to
# choose what pager to use (i.e. man).
export PAGER='less'

# Default options that are passed to less and any programs using less (i.e.
# man):
#  - '-j .2' says that when you perform a search in less, scroll the page
#    such that the currently displayed result is shown .2 of the way down
#    the page instead of at the very top. Change this to an absolute number
#    instead of a decimal to specify the exact line instead of a relative
#    position.
#  - '-R' makes less retain color escape codes, so if a command with
#    colored output is piped into less, it will still be colored.  Note
#    that most commands that have colored output automatically switch off
#    colored output when it detects it's being piped into another command,
#    so you'll probably have to set a flag to force color (i.e.
#    `hg --color=always status | less`)
export LESS='-j .2 -R'

################################################################################
#################################### Other #####################################
################################################################################

source_if_exists $HOME/.zshrc.local.zsh

