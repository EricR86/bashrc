# BASHRC SILLY RULES ARE THE FOLLOWING:
# https://github.com/justinmk/config/blob/master/.bashrc#L1-L6
# "the best way to hadnle it is to do everything in .bashrc, and source .bashrc
# from .bash_profile, but abort .bashrc if non-interactive"
# TODO: Get more settings from there

# Bash sourcing rules:
# In interactive mode, [bash shells] accept input typed from the keyboard. When
# executing non-interactively, [bash shells] execute commands read from a file.
# A login shell is the first process opened under your used ID

# e.g. SSH: - login interactive shell
# e.g. opening a terminal from a window manager: - non-login interactive shell
# e.g. bash script as a command to SSH: - login non-interactive shell
# e.g. running a bash script locally: - non-login non-interactive shell

# Login shell sourcing rules:
# /etc/profile then *only the first one it finds* of the following:
#   - ~/.bash_profile
#   - ~/.bash_login
#   - ~/.profile

# Interactive non-login sourcing rules:
# *Only* reads ~/.bashrc

# The idea is interactive shells started at login reads in a "global"
# environment, then all subsequent interactive shells use ~/.bashrc

# However it's far more typical that you want ~/.bashrc sourced even on a login
# shell. The manual suggests the following in ~/.bash_profile: 
# if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

# If you start bash with the 'sh' command it tries to ignore .bashrc rules and
# skip the ".bash*" resource files altogether and use /etc/profile and .profile
# instead

### General export or not to export rules:
# If a program running from this environment needs a variable, export it
# If a program doesn't (e.g. shell variables like PS1, PROMPT_COMMAND, etc), do
# not export it, just set it here. This will be loaded by every interactive
# (and probably non-interactive if sourced from .bash_profile) shell.

function hg_branch() {
    local branchName=$(hg branch 2> /dev/null)
    if [[ -n "$branchName" ]]
    then
        echo "on $branchName"
    else
        false
    fi
}

function conda_env_prompt() {
    if [[ -n $CONDA_PREFIX ]]
    then
        conda_env=`basename $CONDA_PREFIX`
        conda_env="(${conda_env})"
        echo $conda_env' '
    fi
}

# create a $fill of all screen width minus the time string and a space:
__fill="--- "
# from https://github.com/emilis/emilis-config/blob/master/.bash_ps1
function set_fill_prompt_line {

 let fillsize=$(tput cols)-9
 __fill=""
 while [ "$fillsize" -gt "0" ]
 do
 __fill="-${__fill}" # fill with underscores to work on
 let fillsize=${fillsize}-1
 done

 # If this is an xterm set the title to user@host:dir
 # case "$TERM" in
 # xterm*|rxvt*)
 # bname=`basename "${PWD/$HOME/~}"`
 # echo -ne "\033]0;${bname}: ${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"
 # ;;
 # *)
 # ;;
 # esac

}

function __prompt_command {
    # ERROR_STATUS_SMILEY="if [[ \$? == 0 ]]; then echo \":)\"; else echo \":(\"; fi"
    if [ $? -ne 0 ]; then
        ERROR_STATUS_SMILEY=":("
    else
        ERROR_STATUS_SMILEY=":)"
    fi

    set_fill_prompt_line
}

function prepend_to_path {
    if [[ ! "$PATH" == *${1}* ]]; then
      export PATH="${1}:${PATH}"
    fi
}

function add_to_library_path {
    export LD_LIBRARY_PATH=${1}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
}

# Tarball download, extract, and del
function tardlext() {
    output="tardlext.tmp"
    wget $1 -O $output
    tar -xf $output
    rm $output
}

# Automatically check working window size after every command
shopt -s checkwinsize
# Change to a directory if only the directory is specified (no cd needed)
shopt -s autocd


# See https://unix.stackexchange.com/questions/18212/bash-history-ignoredups-and-erasedups-setting-conflict-with-common-history/18443#18443
# Remove all duplicates in history and keep it synced across all terminals
shopt -s histappend
# Erase duplicates in bash history
# Ignore commands with leading space
# ignoredups only ignores _consecutive_ duplicates
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE='startx:exit:cd *:ls *:rm *:man *:echo *:bg:fg:history*:f:fd'
# Unlimited bash history (may want to truncate ocassionally?)
HISTFILESIZE=
HISTSIZE=
HISTTIMEFORMAT="%F %T: "

# TODO: Fix the fact that tput and conda_env_prompt will always return a good exit status
# This sets the $__fill variable and ERROR_STATUS_SMILEY
PROMPT_COMMAND=__prompt_command
PS1='$__fill \t\n$(tput sgr0)'"\$(conda_env_prompt)\u@\h\${ERROR_STATUS_SMILEY} \w \$(hg_branch)\n$ "
#PS1="${RESET}${YELLOW}\u@\h${NORMAL} \`${SELECT}\` ${YELLOW}\w $(__git_ps1) >${NORMAL} "

# TODO: Put $TERM checking earlier?
# NB: gnome-terminal reports xterm-256color which is technically incorrect and
# behaves strangely with certain programs. Older versions of gnome-terminal set
# COLORTERM. Newer versions set VTE_VERSION
if [[ $VTE_VERSION -ge 3803 ]]
then
    # gnome-256color is equivalent to vte-256color
    export TERM=gnome-256color
    # initialize this terminal with these new terminfo settings
    tput init
    tput reset
fi

# bash completion (fix when not sourced for some reason)
if [ -f /usr/local/etc/bash_completion ]; then
    source /usr/local/etc/bash_completion
elif [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    source /etc/bash_completion
fi

# LS Colors
LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=01;05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.tbz=01;31:*.tbz2=01;31:*.bz=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=01;36:*.au=01;36:*.flac=01;36:*.mid=01;36:*.midi=01;36:*.mka=01;36:*.mp3=01;36:*.mpc=01;36:*.ogg=01;36:*.ra=01;36:*.wav=01;36:*.axa=01;36:*.oga=01;36:*.spx=01;36:*.xspf=01;36:"
alias ls="ls --color=auto"
