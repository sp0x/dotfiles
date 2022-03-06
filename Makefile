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

linux: core-linux link

core-linux:
	sudo apt-get update



stow-linux: core-linux
				is-executable stow || apt-get -y install stow

vim-linux:
				is-executable vim || apt-get install -y vim

zsh-linux:
				is-executable zsh || apt-get install -y zsh

install-vim:
				is-dir "$(HOME)/.vim" || \
				 $$(mkdir -p ~/.vim/autoload ~/.vim/bundle \
				 && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim \
				 && git clone https://github.com/preservim/nerdtree.git $(HOME)/.vim/bundle/nerdtree \
		     && git clone https://github.com/arcticicestudio/nord-vim.git $(HOME)/.vim/bundle/nord-vim)
				

link: stow-$(OS) vim-$(OS) zsh-$(OS) install-vim
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
