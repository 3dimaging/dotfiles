
for file in exports bash_prompt aliases functions extra; do
  file="$HOME/.$file"
  [ -e "$file" ] && source "$file"
done

for file in /opt/local/etc/bash_completion $HOME/local/etc/bash_completion $HOME/.bashrc; do
  [ -e "$file" ] && source "$file"
done

if [[ BASH_VERSINFO -ge 4 ]]; then
  shopt -s globstar
fi

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Don't save commands that start with a space
HISTCONTROL=ignorespace

# Get ctrl-s to work in bash searching
stty stop undef
