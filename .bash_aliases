# File related
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias nano="micro"
alias backup="cp -v"
alias docs="cd ~/Documents"
alias dwn="cd ~/Downloads"
alias dsktp="cd ~/Desktop"
alias assessments="cd ~/Documents/assessments"
alias pentesttools="cd ~/Documents/pentest-tools"

########################################################################################################################

# Clipboard
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

########################################################################################################################

# Pipeline manipulation
alias gips="grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort -u -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4"
alias orderips="sort -u -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4"
alias countips="wc -l"

########################################################################################################################

# etc
## Add an "alert" alias for long running commands.  Use like so:  sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias reload="source ~/.bashrc"

########################################################################################################################

# Code related
alias python='python3'
alias py='python3'
alias venv="source .venv/bin/activate"
alias pipup="pip install --upgrade pip"
alias reqs="pip freeze > requirements.txt"
alias installreqs="pip install -r requirements.txt"

########################################################################################################################

# Docker related
alias dockerc-down-nuke='docker compose down -v --rmi all'
alias dockerc-down='docker compose down'
alias dockerc-downv='docker compose down -v'
alias dockerc-up='docker compose up -d'
alias dockerc-up-new='docker compose up -d --build --force-recreate'
alias dockerc-reset='dockerc-downv && dockerc-up-new'

########################################################################################################################
