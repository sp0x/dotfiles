SHELL = /bin/bash
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
OS := $(shell bin/is-supported bin/is-macos macos linux)
PATH := $(DOTFILES_DIR)/bin:$(PATH)
HOMEBREW_PREFIX := $(shell bin/is-supported bin/is-arm64 /opt/homebrew /usr/local)
export XDG_CONFIG_HOME = $(HOME)/.config
export STOW_DIR = $(DOTFILES_DIR)
export ACCEPT_EULA=Y

.PHONY: test

all: $(OS)

macos: sudo core-macos packages link

linux: core-linux vim-$(OS) zsh-$(OS) install-vim dotnet-$(OS) pip3-$(OS) link

core-linux:
	sudo apt-get update || true



stow-linux: core-linux
				is-executable stow || sudo apt install -y stow

vim-linux:
				is-executable vim || sudo apt install -y vim

zsh-linux:
				is-executable zsh || \
								$$(sudo apt install -y zsh \
								&& sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
								&& chsh -s $(which zsh))

dotnet-linux:
				is-executable dotnet || \
								$$(wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
								&& sudo dpkg -i packages-microsoft-prod.deb \
								&& rm packages-microsoft-prod.deb \
								&& sudo apt-get update \
								&& sudo apt-get install -y apt-transport-https \
								&& sudo apt-get update \
								&& sudo apt-get install -y dotnet-sdk-{8}.0)

pip3-linux:
				is-executable pip3 || sudo apt install -y python3-pip

install-vim:
				(is-dir "$(HOME)/.vim" && is-dir "$(HOME)/.vim/autoload") || \
				 $$(mkdir -p ~/.vim/autoload ~/.vim/bundle \
				 && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim \
				 && git clone https://github.com/preservim/nerdtree.git $(HOME)/.vim/bundle/nerdtree \
		     		 && git clone https://github.com/arcticicestudio/nord-vim.git $(HOME)/.vim/bundle/nord-vim)
				

link: stow-$(OS)
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE -a ! -h $(HOME)/$$FILE ]; then \
		mv -v $(HOME)/$$FILE{,.bak}; fi; done
	mkdir -p $(XDG_CONFIG_HOME)
	stow -t $(HOME) runcom
	stow -t $(XDG_CONFIG_HOME) config

unlink: stow-$(OS)
	stow --delete -t $(HOME) runcom
	stow --delete -t $(XDG_CONFIG_HOME) config
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE.bak ]; then \
		mv -v $(HOME)/$$FILE.bak $(HOME)/$${FILE%%.bak}; fi; done
