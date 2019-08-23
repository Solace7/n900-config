
# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export ZSH_TMUX_AUTOSTART=true
export ZSH_TMUX_AUTOQUIT=true
export ZSH_TMUX_AUTOCONNECT=false

ZSH_THEME="duellj"
#ZSH_THEME="af-magic"
#ZSH_THEME="nanotech"

plugins=(
  git
  tmux
)

source $ZSH/oh-my-zsh.sh

# User configuration

#export TERM=screen-256color
if [[ $TERM == xterm-termite ]]; then
  . /etc/profile.d/vte.sh
  __vte_osc7

else
    export TERM="screen-256color"
fi

source ~/.profile
#replaced autojump with fasd
#source /usr/share/autojump/autojump.zsh
#eval "$(fasd --init zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install)"
#source /usr/share/doc/pkgfile/command-not-found.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
