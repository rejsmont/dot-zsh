if [[ `uname -a` == *'Darwin'* ]]; then
    type "gdircolors" > /dev/null 2>&1 && alias dircolors='gdircolors'
    type "gls" > /dev/null 2>&1 && alias ls='gls --color=auto'
    type "ggrep" > /dev/null 2>&1 && alias grep='ggrep --color=auto'
    type "gtar" > /dev/null 2>&1 && alias tar='gtar'
elif [[ `uname -a` == *'Linux'* ]]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    `ls --color /dev/null > /dev/null 2>&1` && alias ls='ls --color=auto'
    `ip -c a > /dev/null 2>&1` && alias ip='ip -c'
    `grep --color '' /dev/null > /dev/null 2>&1` && alias grep='grep --color=auto'
fi
