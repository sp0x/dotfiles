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

macos: sudo core-macos packages nvim-$(OS) link

linux: core-linux nvim-$(OS) zsh-$(OS) dotnet-$(OS) pip3-$(OS) python-$(OS) link

core-linux:
	sudo apt-get update || sudo apt-get install curl zsh vim stow \
				|| true

stow-linux: core-linux

nvim-linux:
				@set -euo pipefail; \
				arch="$$(uname -m)"; \
				case "$$arch" in \
					x86_64|amd64) archive="nvim-linux-x86_64.tar.gz" ;; \
					aarch64|arm64) archive="nvim-linux-arm64.tar.gz" ;; \
					*) echo "Unsupported architecture for Neovim install: $$arch" >&2; exit 1 ;; \
				esac; \
				tmp_dir="$$(mktemp -d)"; \
				trap 'rm -rf "$$tmp_dir"' EXIT; \
				tarball="$$tmp_dir/nvim.tar.gz"; \
				curl -fL "https://github.com/neovim/neovim/releases/latest/download/$$archive" -o "$$tarball"; \
				tar -xzf "$$tarball" -C "$$tmp_dir"; \
				extracted_dir="$$tmp_dir/$${archive%.tar.gz}"; \
				[ -d "$$extracted_dir" ] || { echo "Failed to extract Neovim archive" >&2; exit 1; }; \
				sudo rm -rf /opt/nvim; \
				sudo mv "$$extracted_dir" /opt/nvim; \
				sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim; \
				echo "Installed latest Neovim to /opt/nvim"

nvim-macos:
				is-executable nvim || brew install neovim

zsh-linux:
				is-executable zsh || \
							  (sudo apt install -y curl zsh \
								&& sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
								&& git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
								&& chsh -s `which zsh`)

dotnet-linux:
				is-executable dotnet || \
								$$(wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
								&& sudo dpkg -i packages-microsoft-prod.deb \
								&& rm packages-microsoft-prod.deb \
								&& sudo apt-get update \
								&& sudo apt-get install -y apt-transport-https \
								&& sudo apt-get update \
								&& sudo apt-get install -y dotnet-sdk-{8}.0)

python-linux:
	curl -LsSf https://astral.sh/uv/install.sh | sh \
		&& sudo apt install -y python3-venv \
		&& sudo apt install -y python3-pip \
		&& sudo apt install -y python3-dev \
		&& sudo apt install -y python3-setuptools \
		&& sudo apt install -y python3-wheel

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
	bin/link-llm link

unlink: stow-$(OS)
	stow --delete -t $(HOME) runcom
	stow --delete -t $(XDG_CONFIG_HOME) config
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE.bak ]; then \
		mv -v $(HOME)/$$FILE.bak $(HOME)/$${FILE%%.bak}; fi; done
	bin/link-llm unlink
