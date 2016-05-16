# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

ssh-key-add() {
    export SSH_AUTH_SOCK="$HOME/.ssh-agent-$(tty | tr '/' '\n' | tail -n1)"
    ssh-agent -a "$SSH_AUTH_SOCK" -D &>/dev/null & 
    while [ ! -S "$SSH_AUTH_SOCK" ]; do
        sleep 0.1
    done
    ssh-add
}

# Add git branch if its present to PS1
git_prompt() {
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\$ '
    
    GITROOT=$(git rev-parse --show-toplevel 2>/dev/null)

    if [ "$GITROOT" == "" ]; then
        return 1
    fi

    if ! ssh-add -L &>/dev/null; then
        ssh-key-add
    fi

    (git fetch origin &>/dev/null &)

    RNAME=$(basename 2>/dev/null $GITROOT)

    DIR=$(pwd)
    SUBDIR=$(expr substr $DIR $(($(expr length $GITROOT) + 2)) $(expr length $DIR))
    if [ "$SUBDIR" != "" ]; then
        SUBDIR="\[\033[01;35m\]/$SUBDIR"
    fi


    BNAME=$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/')

    COLOR="\[\033[0;33m\]"

    # if [ "$BNAME" != "(master)" ]; then
    #     COLOR="\[\033[01;32m\]"
    # fi

    STATUS="$(git status)"
    COMMITS=$(git status | head -n2 | tail -n1 | grep -sEo '[1-9]{1}')
    CMSG="\[\033[00m\][0]"
    if git status | head -n2 | tail -n1 | grep -Eo "behind" &>/dev/null; then
        CMSG="\[\033[00;31m\][-$COMMITS]"
    elif git status | head -n2 | tail -n1 | grep -Eo "ahead" &>/dev/null; then
        CMSG="\[\033[00;32m\][+$COMMITS]"
    elif git status | head -n2 | tail -n1 | grep -Eo "diverged" &>/dev/null; then
        AHEAD=$(echo "$COMMITS" | head -n1)
        BEHIND=$(echo "$COMMITS" | tail -n1)
        CMSG="\[\033[00;32m\][+$AHEAD] \[\033[00;31m\][-$BEHIND]"
    fi

    PS1=''$PS1'\[\033[01;34m\]$RNAME'$SUBDIR' '$COLOR'$BNAME '$CMSG'\[\033[00m\] '
}
export PROMPT_COMMAND=git_prompt

sshc() {
    ssh trea@access.cs.clemson.edu -t "ssh joey22"
}

vip() {
    ifconfig enp0s3 | grep 'inet' | sed 's/        //g' | tr ' ' '\n' | head -n2 | tail -n1
}

subl() {
	(sublime "$@" &>/dev/null &)
}

subls() {
    if pgrep -G root sublime
    then
        su -c "(sublime "$@" &>/dev/null &)"
    else
        printf "sudo "
        su -c "(sublime "$@" &>/dev/null &)"
    fi

}

bgr() {
    ("$@" &>/dev/null &)
}

bgrs() {
    su -c "($1 ${@:2} &>/dev/null &)"
}

alias sk=ssh-key-add
alias glist="git ls-tree --full-tree -r HEAD"
alias bs="source ~/.bashrc"
