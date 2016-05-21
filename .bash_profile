HAZARD=☣
SKULL=☠
LIGHTNING=⚡
RADIOACTIVE=☢
WARNING=⚠

source ~/.bash/colors
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
setup_git_promptcommand

# PATH
export PATH=$PATH:/Users/esaron/bin
