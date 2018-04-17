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

[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

################################################################################
################################## Functions ###################################
################################################################################

# Check if a command exists.  Works for executables on
# your path, aliases, and functions.
command_exists () {
    type "$1" &> /dev/null ;
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

################################################################################
################################### Aliases ####################################
################################################################################


################################################################################
############################ Environment Variables #############################
################################################################################
export DOTFILES_DIR=get_dir_of_this_script


################################################################################
#################################### Other #####################################
################################################################################

# Source platform specific zshrc's
# If OS name is Darwin, we're on Mac
if uname -s | grep Darwin >/dev/null
then
    source $DOTFILES_DIR/zshrc.mac.zsh
# If OS name is Linux, we're on Linux
elif uname -s | grep Linux >/dev/null
then
    source $DOTFILES_DIR/zshrc.linux.zsh
fi
