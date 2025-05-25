export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="clean"
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
plugins=(
	git
	npm
	zsh-autosuggestions
	history
	emoji
	encode64
)

source $ZSH/oh-my-zsh.sh
source ${HOME}/.profile &&  echo "sourced profile"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
skip_global_compinit=1