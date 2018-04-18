# Welcome to my Zshrc!
# This is my default zshrc, which I use on all machines
# I use.  At the end, I conditionally source a 
# Mac-specific or Linux-specific zshrc depending on 
# which OS I'm on, and then I source a local zshrc,
# which contains anything that is specific to the
# particular machine.
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


cd .



################################################################################
############################## Third Party Tools ###############################
################################################################################

export PATH=$PATH:/Users/chrisshroba/.brew/bin
# Set up Oh My Zsh, which has SO many awesome features, including 
# TODO: make this only run on mac
source $ZSH/oh-my-zsh.sh
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh
# TODO: make this only run on linux
. /usr/share/autojump/autojump.zsh


# Enable kv-bash (A simple global key-val store)
# Dependency: kv-bash (https://github.com/damphat/kv-bash)
source $HOME/kv-bash.sh

################################################################################
################################## Functions ###################################
################################################################################

# When I change directory, run the function activate_virtual_env
# Dependency: activate_virtual_env (defined in this file)
chpwd () {
  activate_virtual_env
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

# Search Messages messages with pretty datetime
t() {
    sqlite3 ~/Library/Messages/chat.db "select is_from_me, datetime(date + strftime('%s','2001-01-01'), 'unixepoch'), handle.id, text from message, handle where handle_id=handle.rowid and text like '%$*%';"
}

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
# I'm working on, or for accesing a webapp from my phone.
remote () {
    ssh -nNTR 4100:localhost:$1 shroba
}

# Send a file to shrobaserver to be served out of http://sdrop.shroba.io/
# (secretish because no auto_index)
sdrop () {
    scp $1 chris@shroba.io:/var/www/html/sdrop/
    ssh shroba "find /var/www/html/sdrop/* -exec chmod +r {} \;"
}

# Send a file to shrobaserver to be served out of http://drop.shroba.io/
drop () {
    scp $1 shroba:/var/www/html/drop/
    ssh shroba "find /var/www/html/drop/* -exec chmod +r {} \;"
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
alias invert_screen="xcalib -a -i"

# Invert the screen and then turn it back for a gentler notification.
alias flash_screen="invert_screen; sleep .2; invert_screen"

# TODO: move these to linux zshrc.
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
alias open='xdg-open'

# Print all executables in the current PATH.  Useful for grepping for a command
# when you know it follows a certain pattern but can't think of the specific
# command.
alias allpath=echo $PATH | sed "s/:/\n/g" | xargs ls -1

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

################################################################################
############################ Environment Variables #############################
################################################################################
export DOTFILES_DIR=get_dir_of_this_script

### Oh My Zsh Configuration
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

# Source platform specific zshrc's
# If OS name is Darwin, we're on Mac
if uname -s | grep Darwin >/dev/null
then
    source_if_exists $DOTFILES_DIR/zshrc.mac.zsh
# If OS name is Linux, we're on Linux
elif uname -s | grep Linux >/dev/null
then
    source_if_exists $DOTFILES_DIR/zshrc.linux.zsh
fi
