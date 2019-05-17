#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# make sure we are in the directory of the script so relative paths work
cd "$DIR"

function ensure_link {
  local DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  local NEW="$2"
  local is_diff=0
  test -z "$NEW" && NEW=".$1"

  if [[ -f "$HOME/$NEW" ]]; then
    diff -u "$DIR/$1" "$HOME/$NEW" || is_diff=1
    if [[ is_diff -ne 0 ]]
    then
      cat <<-EOF


>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
Please check the diff! Either remove the target file $HOME/$NEW or copy the changes to the dotfiles repo.
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EOF
      exit 2
    else
      rm -f "$HOME/$NEW"
    fi
  fi

  test -d "$HOME/$NEW" && rm -r "$HOME/$NEW"
  # special-case authorized_keys because some systems don't like it being a
  # symlink; but we keep it in this function so we can check the diff
  if [[ "$NEW" != ".ssh/authorized_keys" ]]; then
    test -L "$HOME/$NEW" || ln -s "$DIR/$1" "$HOME/$NEW"
  else
    cp "$DIR/$1" "$HOME/$NEW"
    chmod 600 "$HOME/$NEW"
  fi
}

test -d $HOME/.hg && echo "$HOME is still a repo, please check and remove" && exit 1

mkdir -p ~/projects
mkdir -p ~/sandbox
mkdir -p ~/.ipython
mkdir -p ~/.ssh
mkdir -p ~/.config/karabiner
mkdir -p ~/.pastebin.d
mkdir -p ~/.hammerspoon
mkdir -p ~/.config/pass-git-helper

[[ ! -d "$HOME/projects/doom-emacs" ]] && echo "doom not cloned yet" && exit 128

ensure_link "aliases"
ensure_link "aspell.en.prepl"
ensure_link "aspell.en.pws"
ensure_link "bash_prompt"
ensure_link "ctags"
ensure_link "dir_colors"
ensure_link "$HOME/projects/doom" ".emacs.d"
ensure_link "doom" ".doom.d"
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
ensure_link "mbsyncrc"
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
ensure_link "vpnc-script" ".vpnc-script"
ensure_link "pwclient"
ensure_link "docker-bash"
ensure_link "karabiner.json" ".config/karabiner/karabiner.json"
ensure_link "hammerspoon.lua" ".hammerspoon/init.lua"
ensure_link "git-pass-mapping.ini" ".config/pass-git-helper/git-pass-mapping.ini"
ensure_link "gpg-agent.conf" ".gnupg/gpg-agent.conf"
ensure_link "gpg.conf" ".gnupg/gpg.conf"

[[ ! -f "$HOME/.ssh/id_rsa" ]] && echo "No ssh id_rsa!" && exit 3

# need this for the gpg agent device io error
export GPG_TTY=$(tty)

if gpg --list-keys | grep -q "\[ultimate\] keybase.io/smf"; then
  echo "Already trusted owner key"
else
  # import public gpg keys from keybase
  keybase pgp export | gpg --import

  # import my own secret
  keybase pgp export --secret | gpg --import --allow-secret-key-import

  # trust my own key
  cat << EOF | gpg --import-ownertrust
5D05F69E60DE8F3E519240C3FFD8DC399F9F3BD6:6:
EOF
fi

# ensure that the gpg agent reloads
gpgconf --kill gpg-agent

# generic apps that have the same installation on all systems

# python
pip install --user cython
pip install --user flake8
pip install --user hg-evolve
pip install --user pipenv
pip install --user sphinx

exit 0
