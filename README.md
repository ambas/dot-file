# dot-file

Personal dotfiles. This repo currently manages a Vim setup with modular config files, Vim-Plug plugins, ALE linting/fixing, fzf, NERDTree, and LSP support for Elixir, Swift, Python, JavaScript, and TypeScript.

This setup is primarily tested on macOS. The core Vim config should load anywhere Vim and the configured plugins are available, but a few optional language tools are platform-specific.

## Prerequisites

On macOS, install Apple's command line tools first:

```sh
xcode-select --install
```

Make sure these commands are available:

```sh
git --version
vim --version
```

For the remote one-shot install, `curl` must also be available.

## Quick Install

Run the interactive installer:

```sh
mkdir -p ~/Developer/configs
git clone git@github.com:ambas/dot-file.git ~/Developer/configs/dot-file
cd ~/Developer/configs/dot-file
./install.sh
```

If SSH is not set up yet, use HTTPS instead:

```sh
git clone https://github.com/ambas/dot-file.git ~/Developer/configs/dot-file
cd ~/Developer/configs/dot-file
./install.sh
```

The installer asks before it:

- Moves existing `~/.vimrc` or `~/.vim` into a timestamped backup directory.
- Creates Vim symlinks.
- Runs Vim-Plug plugin installation.
- Installs optional language tooling.

## Remote One-Shot Install

Use this on a new machine after Git, Vim, and curl are available:

```sh
curl -fsSL https://raw.githubusercontent.com/ambas/dot-file/main/install.sh -o /tmp/dot-file-install.sh
sh /tmp/dot-file-install.sh
```

The script will ask before cloning this repo into `~/Developer/configs/dot-file`.

## Installer Options

Run only selected top-level tasks by setting `INSTALL_TASKS`:

```sh
INSTALL_TASKS="vim_config vim_plugins" ./install.sh
```

Run only selected language-tool tasks by setting `LANGUAGE_TOOL_TASKS`:

```sh
LANGUAGE_TOOL_TASKS="python_tools" ./install.sh
```

To add more config areas later, add a new task name to `install_tasks` in `install.sh`, then map it in `task_title` and `run_task`.

## Manual Install

Back up any existing Vim config:

```sh
backup_dir="$HOME/.dotfile-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"

[ -e "$HOME/.vimrc" ] && mv "$HOME/.vimrc" "$backup_dir/.vimrc"
[ -e "$HOME/.vim" ] && mv "$HOME/.vim" "$backup_dir/.vim"
```

Create the symlinks:

```sh
ln -sfn "$HOME/Developer/configs/dot-file/vim/vimrc" "$HOME/.vimrc"
ln -sfn "$HOME/Developer/configs/dot-file/vim" "$HOME/.vim"
```

Install or update Vim plugins. This step requires network access:

```sh
vim +PlugInstall +qall
```

## Optional Tooling

The Vim config works without all language tools installed, but these commands enable the configured completion, linting, and formatting features.

### JavaScript and TypeScript

```sh
npm install -g typescript typescript-language-server eslint prettier
```

### Python

```sh
python3 -m pip install --user python-lsp-server
```

### Elixir

Install Elixir and the tools used by ALE:

```sh
mix local.hex --force
mix archive.install hex credo --force
```

This repo also includes an Expert language server binary for macOS Apple Silicon at:

```text
vim/lsp/expert_darwin_arm64
```

On Intel macOS, Linux, or other architectures, replace that binary with a compatible Expert build or skip it. The Vim config only registers Expert when the binary is executable.

### Swift

Install Xcode or the Swift toolchain so `sourcekit-lsp` is available.

## Updating

Pull the latest dotfiles and update Vim plugins:

```sh
cd ~/Developer/configs/dot-file
git pull
vim +PlugUpdate +qall
```

## Layout

```text
vim/vimrc                 Main Vim entry point
vim/appearance.vim        Theme and visual settings
vim/editor.vim            Editing defaults
vim/mappings.vim          Key mappings
vim/plugins.vim           Vim-Plug plugin list
vim/ale.vim               Linting and formatting config
vim/nerdtree.vim          NERDTree config
vim/encoding_syntax.vim   Encoding and syntax settings
vim/lsp/                  Local language server binaries
```

## Notes

- The main `vim/vimrc` sources files from `~/.vim`, so linking the whole `vim` directory to `~/.vim` is required.
- Existing Vim settings are moved into a timestamped `~/.dotfile-backup-*` directory during the install steps above.
- Plugin source checkouts are intentionally ignored by Git. Run `:PlugInstall` or `:PlugUpdate` on each machine after setup.
