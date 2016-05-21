COLOR_OFF='\001\033[0m\002'
RED='\001\033[0;31m\002'
GREEN='\001\033[0;32m\002'
LGREEN='\001\033[0;32m\002'
LYELLOW='\001\033[0;33m\002'
CYAN='\001\033[1;36m\002'
LCYAN='\001\033[0;36m\002'
BLUE='\001\033[1;34m\002'
LBLUE='\001\033[0;34m\002'
MAGENTA='\001\033[0;35m\002'
HAZARD=☣
SKULL=☠
LIGHTNING=⚡
RADIOACTIVE=☢
WARNING=⚠

#source ~/.bash/colors
source ~/.bash/symbols
source ~/.bash/gitprompt

# Aliases
alias ll="ls -FlaG"

# Show git branch in terminal
#parse_git_branch() {
#    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/' | sed -e $'s/(HEAD detached at \([a-z0-9]*\))/'"$WARNING"' \1/'
#}
#export PS1="$GREEN\u$LCYAN@$GREEN\h$CYAN:$GREEN\w$RED\$(parse_git_branch)$LCYAN$ $COLOR_OFF"

setup_git_ps1

# PATH
export PATH=$PATH:/Users/esaron/bin
