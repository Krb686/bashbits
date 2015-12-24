# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias exd='exportDisplay'
alias la='listAliases'
alias rb='source ~/.bashrc'

function exportDisplay(){
	printf "$1 = $1\n"
}

function listAliases(){
	printf "Useful aliases\n"

	printf "%s\n" "		..	:	cd .."
	printf "%s\n" "		...	:	cd ../.."
	printf "%s\n" "		....	:	cd ../../.."

}
