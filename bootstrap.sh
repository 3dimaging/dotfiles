#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# make sure we are in the directory of the script so relative paths work
cd "$DIR"

function ensure_link {
  local DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  local NEW="$2"
  test -z "$NEW" && NEW=".$1"
  rm -f "$HOME/$NEW"
  test -d "$HOME/$NEW" && rm -r "$HOME/$NEW"
  test -L "$HOME/$NEW" || ln -s "$DIR/$1" "$HOME/$NEW"
}

test -d $HOME/.hg && echo "$HOME is still a repo, please check and remove" && exit 1

mkdir -p ~/projects
mkdir -p ~/sandbox
mkdir -p ~/.ipython
mkdir -p ~/.ssh
mkdir -p ~/.config/karabiner
mkdir -p ~/.pastebin.d
mkdir -p ~/.hammerspoon

rm -f ~/.bootstrap.sh
rm -f ~/.emacs
rm -f ~/.emacs.sh
rm -f ~/.eudc-options
rm -f ~/.hgfilter.py*
rm -f ~/.install.sh
rm -f ~/.sudo-batch.sh
rm -f ~/.notmuch-config
rm -f ~/.tmux.conf

ensure_link "aliases"
ensure_link "aspell.en.prepl"
ensure_link "aspell.en.pws"
ensure_link "bash_prompt"
ensure_link "ctags"
ensure_link "debugshell.py"
ensure_link "dir_colors"
ensure_link "emacs" ".emacs.d"
ensure_link "edit.sh"
ensure_link "exports"
ensure_link "functions"
ensure_link "gdbinit"
ensure_link "gitconfig"
ensure_link "globalrc"
ensure_link "hgrc"
ensure_link "hgignore"
ensure_link "inputrc"
ensure_link "ipython/profile_default"
ensure_link "latexmkrc"
ensure_link "lynx.lss"
ensure_link "lynxrc"
ensure_link "offlineimap.py"
ensure_link "offlineimaprc"
ensure_link "mail.crt"
ensure_link "port-rdependents.py"
ensure_link "profile"
ensure_link "ssh/authorized_keys"
ensure_link "ssh/config"
ensure_link "ssh/environment"
ensure_link "flake8" ".config/flake8"
ensure_link "profile" ".bashrc"
ensure_link "hgignore" ".gitignore"
ensure_link "pastebin.d/bpaste.net.conf"
ensure_link "pastebinit.xml"
ensure_link "imapnotify.js" ".config/imapnotify.js"
ensure_link "maildir-notmuch-sync.sh" ".config/maildir-notmuch-sync.sh"
ensure_link "notmuch-config"
ensure_link "vpnc-script" ".vpnc-script"
ensure_link "pwclient"
ensure_link "docker-bash"
ensure_link "karabiner.json" ".config/karabiner/karabiner.json"
ensure_link "hammerspoon.lua" ".hammerspoon/init.lua"

if [[ ! -f emacs/init.el ]]
then
   echo "Tangling init"
   emacs --batch --eval "(progn
(setq vc-follow-symlinks nil)
(find-file \"emacs/README.org\")
(require 'ob-tangle)
(org-babel-tangle nil \"init.el\")
(byte-compile-file \"init.el\")
)"
   echo "Finished tangling"
fi
