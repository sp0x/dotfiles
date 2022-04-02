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