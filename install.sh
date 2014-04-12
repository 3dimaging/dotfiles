#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  .install.sh
#
#         USAGE:  ./.install.sh
#
#   DESCRIPTION:  Install common packages
#
#       OPTIONS:  ---
#  REQUIREMENTS:  At the very least, need python including dev headers
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Sean Farley
#       COMPANY:
#       CREATED:  01/19/2012 01:09:43 AM CST
#      REVISION:  ---
#===============================================================================

LOC=$HOME/.local
CURL="curl -k -C - -L -O"
LOCPY=$LOC/lib/python$(python -c 'import sys; print("%i.%i" % (sys.version_info[0],sys.version_info[1]))')/site-packages

[[ -z "$(which curl 2>/dev/null)" ]] && CURL="wget -c"

[[ -z "$SANDBOX" ]] && SANDBOX=$HOME/sandbox

[[ -d "$SANDBOX" || ! -L "$SANDBOX" ]] && mkdir -p $SANDBOX

# first argument is type
# second is URL
# third is configure options or filename to save-as for 'script'
function install() {

  PACKAGE=$(basename $2)
  PDIR='$(echo $PACKAGE)'
  EXT=""
  GET="$CURL"
  EXTRACT="true"

  if [[ $2 == git* ]]; then
    GET="git clone"
    PACKAGE=$(basename $PACKAGE .git)
  elif [[ $PACKAGE == *\.tar* ]]; then
    # Making this too general is crazy at this point, so just assume
    # everything is .tar.* for tarballs

    EXT=".tar.${PACKAGE##*.}"
    PDIR='$(tar -tf $PACKAGE | head -n2 | tail -n1 | xargs dirname)'

    # Testing for zip type? ugh.
    EXTRACT="tar zxf"
    if [[ -n $(echo $EXT | grep b) ]]; then
      EXTRACT="tar jxf"
    fi
  else
    GET="hg clone"
  fi

  # set the commands for downloading so they can be overloaded
  DL='cd $SANDBOX; rm -rf $PACKAGE; $GET $2; $EXTRACT $(basename $2); cd "$(eval echo $PDIR)"'

  if [[ -n "$DEBUG" ]]; then
    echo "Type: $1"
    echo "URL: $2"
    echo "Package: $PACKAGE"
    echo "Extension: $EXT"
    echo "Exract: $EXTRACT"
    echo "Get: $GET"
    echo "DL: $DL"
  fi

  case $1 in
    python)
      eval $DL
      python setup.py install --prefix=$LOC
      ;;
    gnu)
      eval $DL
      [ -e ./configure ] || autoreconf -i
      ./configure --prefix=$LOC $3
      make install PREFIX=$LOC HGEXTDIR=$LOC/lib/python2.7/site-packages/hgext
      ;;
    script)
      # sigh
      # stupid, stupid code duplication!
      # just download the script then exit
      GET="curl -k -o"
      if [[ -z $(which curl 2>/dev/null) ]]; then
        GET="wget -O"
      fi
      $GET $3 $2
      ;;
  esac
}

# default packages to install unless a command-line option is given
PACKAGES="hg git histedit hgsubversion hg-git hg-remotebranches evolve hg-keyring fast-hg-prompt global bash-completion pss emacs chg watchman"
[[ -n "$@" ]] && PACKAGES="$@"

[[ -d $LOC/lib/python ]] && export PYTHONPATH=$LOC/lib/python/site-packages:$PYTHONPATH
export PYTHONPATH=$LOCPY:$PYTHONPATH
export PATH=$HOME/.local:$PATH

if [[ $PACKAGES == hg || $PACKAGES == *hg[!-a-zA-Z]* || $PACKAGES == *merc* ]]; then
  install python http://hg.intevation.org/mercurial/crew/archive/tip.tar.gz
fi

if [[ $PACKAGES == *chg* ]]; then
  install gnu https://bitbucket.org/yuja/chg
fi

if [[ $PACKAGES == git || $PACKAGES == *[!-a-zA-Z]git* ]]; then
  install gnu http://git-core.googlecode.com/files/git-1.8.5.1.tar.gz
fi

if [[ $PACKAGES == *hgsub* ]]; then
  install python https://bitbucket.org/seanfarley/hgsubversion
fi

if [[ $PACKAGES == *remot* ]]; then
  install python https://bitbucket.org/durin42/hg-remotebranches
fi

if [[ $PACKAGES == *evolve* ]]; then
  install python https://bitbucket.org/marmoute/mutable-history
  cp $LOCPY/hgext/evolve.py $LOCPY/hgevolve.py
  cp $LOCPY/hgext/evolve.pyc $LOCPY/hgevolve.pyc
fi

if [[ $PACKAGES == *watch* ]]; then
  install gnu git://github.com/facebook/watchman.git
  install python https://bitbucket.org/facebook/hgwatchman
fi

if [[ $PACKAGES == *ring* ]]; then
  install python https://bitbucket.org/Mekk/mercurial_keyring
fi

if [[ $PACKAGES == *hg-git* ]]; then
  install python git://github.com/jelmer/dulwich.git
  install python https://bitbucket.org/durin42/hg-git
fi

if [[ $PACKAGES == *fast* ]]; then
  install gnu https://bitbucket.org/seanfarley/fast-hg-prompt
fi

if [[ $PACKAGES == *global* ]]; then
  install gnu http://tamacom.com/global/global-6.2.9.tar.gz
fi

if [[ $PACKAGES == bc || $PACKAGES == *bc[!-a-zA-Z]* || $PACKAGES == *bash-comp* || $PACKAGES == *bashcomp* ]]; then
  install gnu git://git.debian.org/git/bash-completion/bash-completion.git
  # after bash-completion is installed, get the mercurial and git scripts
  install script http://selenic.com/hg/raw-file/tip/contrib/bash_completion $LOC/etc/bash_completion.d/mercurial
  cp $LOC/etc/bash_completion.d/mercurial $LOC/etc/bash_completion.d/hg
  install script https://raw.github.com/gitster/git/master/contrib/completion/git-completion.bash $LOC/etc/bash_completion.d/git
fi

if [[ $PACKAGES == *pss* ]]; then
  install python http://pypi.python.org/packages/source/p/pss/pss-0.35.tar.gz
fi

if [[ $PACKAGES == *emac* ]]; then
  install gnu http://ftp.gnu.org/gnu/emacs/emacs-24.3.tar.gz "--without-x --without-jpeg --without-gif --without-sound"
fi
