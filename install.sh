#!/usr/bin/env sh

set -u

repo_url="https://github.com/ambas/dot-file.git"
install_dir="${DOTFILE_DIR:-$HOME/Developer/configs/dot-file}"

# Add future top-level installers here, then map them in task_title and run_task.
install_tasks="${INSTALL_TASKS:-vim_config karabiner_config vim_plugins nerd_font language_tools}"
language_tool_tasks="${LANGUAGE_TOOL_TASKS:-javascript_typescript_tools python_tools elixir_tools}"
nerd_font_url="${NERD_FONT_URL:-https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip}"
symbols_nerd_font_url="${SYMBOLS_NERD_FONT_URL:-https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip}"

say() {
  printf '%s\n' "$*" >&2
}

confirm() {
  prompt="$1"
  printf '%s [y/N] ' "$prompt" >&2
  read -r answer

  case "$answer" in
    y|Y|yes|YES|Yes) return 0 ;;
    *) return 1 ;;
  esac
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

script_dir() {
  cd "$(dirname "$0")" >/dev/null 2>&1 && pwd
}

find_repo_dir() {
  local_dir="$(script_dir)"

  if [ -f "$local_dir/vim/vimrc" ]; then
    printf '%s\n' "$local_dir"
    return 0
  fi

  if [ -f "$install_dir/vim/vimrc" ]; then
    printf '%s\n' "$install_dir"
    return 0
  fi

  return 1
}

ensure_repo() {
  if repo_dir="$(find_repo_dir)"; then
    printf '%s\n' "$repo_dir"
    return 0
  fi

  say "Dotfiles were not found locally."
  say "Target install directory: $install_dir"

  if ! has_command git; then
    say "Git is required before this installer can clone the repo."
    return 1
  fi

  if confirm "Clone $repo_url into $install_dir?"; then
    mkdir -p "$(dirname "$install_dir")"
    git clone "$repo_url" "$install_dir" || return 1
    printf '%s\n' "$install_dir"
    return 0
  fi

  say "Skipped clone."
  return 1
}

make_backup_dir() {
  backup_dir="$HOME/.dotfile-backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$backup_dir"
  printf '%s\n' "$backup_dir"
}

backup_path() {
  path="$1"
  backup_dir="$2"
  name="$(basename "$path")"

  if [ -e "$path" ] || [ -L "$path" ]; then
    mv "$path" "$backup_dir/$name"
    say "Moved $path to $backup_dir/$name"
  fi
}

link_path() {
  source_path="$1"
  target_path="$2"
  backup_dir="$3"

  if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
    say "$target_path already points to $source_path"
    return 0
  fi

  backup_path "$target_path" "$backup_dir"
  ln -s "$source_path" "$target_path"
  say "Linked $target_path -> $source_path"
}

task_title() {
  case "$1" in
    vim_config) printf '%s\n' "Vim config symlinks" ;;
    karabiner_config) printf '%s\n' "Karabiner config symlink" ;;
    vim_plugins) printf '%s\n' "Vim plugins" ;;
    nerd_font) printf '%s\n' "Nerd Font icons" ;;
    language_tools) printf '%s\n' "Optional language tooling" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

run_task() {
  task_name="$1"
  say ""
  say "==> $(task_title "$task_name")"

  case "$task_name" in
    vim_config) install_vim_config ;;
    karabiner_config) install_karabiner_config ;;
    vim_plugins) install_vim_plugins ;;
    nerd_font) install_nerd_font ;;
    language_tools) install_language_tools ;;
    *)
      say "Unknown task: $task_name"
      return 1
      ;;
  esac
}

run_tasks() {
  for task_name in $install_tasks; do
    if ! run_task "$task_name"; then
      say "Task failed: $(task_title "$task_name")"
      if ! confirm "Continue with the remaining tasks?"; then
        return 1
      fi
    fi
  done
}

install_vim_config() {
  vim_dir="$repo_dir/vim"
  vimrc_path="$vim_dir/vimrc"

  if [ ! -f "$vimrc_path" ]; then
    say "Missing Vim config at $vimrc_path"
    return 1
  fi

  say "This will install Vim config from:"
  say "  $vim_dir"
  say "It may move existing ~/.vimrc and ~/.vim into a timestamped backup directory."

  if ! confirm "Install Vim symlinks?"; then
    say "Skipped Vim symlinks."
    return 0
  fi

  backup_dir="$(make_backup_dir)"
  link_path "$vimrc_path" "$HOME/.vimrc" "$backup_dir"
  link_path "$vim_dir" "$HOME/.vim" "$backup_dir"
}

install_karabiner_config() {
  karabiner_dir="$repo_dir/karabiner"
  karabiner_config="$karabiner_dir/karabiner.json"

  if [ ! -f "$karabiner_config" ]; then
    say "Missing Karabiner config at $karabiner_config"
    return 1
  fi

  say "This will install Karabiner config from:"
  say "  $karabiner_dir"
  say "It may move existing ~/.config/karabiner into a timestamped backup directory."

  if ! confirm "Install Karabiner config symlink?"; then
    say "Skipped Karabiner config."
    return 0
  fi

  mkdir -p "$HOME/.config"
  backup_dir="$(make_backup_dir)"
  link_path "$karabiner_dir" "$HOME/.config/karabiner" "$backup_dir"
}

install_vim_plugins() {
  if ! has_command vim; then
    say "Vim is not installed or not on PATH. Skipping plugin installation."
    return 0
  fi

  if confirm "Run Vim-Plug plugin installation now?"; then
    vim +PlugInstall +qall
  else
    say "Skipped Vim plugin installation."
  fi
}

has_jetbrains_nerd_font() {
  find "$HOME/Library/Fonts" /Library/Fonts -maxdepth 1 -type f \
    \( -iname '*JetBrains*Mono*Nerd*Font*Mono-Regular*' -o -iname '*JetBrains*Mono*Nerd*Font-Regular*' \) \
    2>/dev/null | grep . >/dev/null 2>&1
}

install_nerd_font_with_brew() {
  if ! has_command brew; then
    return 1
  fi

  brew install --cask font-jetbrains-mono-nerd-font
}

install_nerd_font_from_release() {
  if ! has_command curl; then
    say "curl is required to download the Nerd Font fallback."
    return 1
  fi

  if ! has_command unzip; then
    say "unzip is required to unpack the Nerd Font fallback."
    return 1
  fi

  font_dir="$HOME/Library/Fonts"
  tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/dotfile-nerd-font.XXXXXX")" || return 1
  zip_path="$tmp_dir/JetBrainsMono.zip"

  mkdir -p "$font_dir"
  say "Downloading JetBrainsMono Nerd Font from:"
  say "  $nerd_font_url"

  if ! curl -fL "$nerd_font_url" -o "$zip_path"; then
    rm -rf "$tmp_dir"
    say "JetBrainsMono Nerd Font download failed. Trying Symbols Nerd Font fallback."
    tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/dotfile-symbols-nerd-font.XXXXXX")" || return 1
    zip_path="$tmp_dir/NerdFontsSymbolsOnly.zip"
    if ! curl -fL "$symbols_nerd_font_url" -o "$zip_path"; then
      rm -rf "$tmp_dir"
      return 1
    fi
  fi

  if ! unzip -q "$zip_path" -d "$tmp_dir/font"; then
    rm -rf "$tmp_dir"
    return 1
  fi

  if ! find "$tmp_dir/font" -type f \
    \( -name '*Nerd*Font*.ttf' -o -name '*Nerd*Font*.otf' \) \
    -exec cp {} "$font_dir/" \;; then
    rm -rf "$tmp_dir"
    return 1
  fi

  rm -rf "$tmp_dir"
}

install_nerd_font() {
  say "vim-devicons requires a Nerd Font-capable terminal font for file icons."

  if has_jetbrains_nerd_font; then
    say "JetBrainsMono Nerd Font is already installed."
    return 0
  fi

  if ! confirm "Install JetBrainsMono Nerd Font for Vim icons?"; then
    say "Skipped Nerd Font installation."
    return 0
  fi

  if install_nerd_font_with_brew; then
    say "Installed JetBrainsMono Nerd Font with Homebrew."
    return 0
  fi

  if install_nerd_font_from_release; then
    say "Installed Nerd Font files into $HOME/Library/Fonts."
    say "Select JetBrainsMono Nerd Font Mono in your terminal profile if icons still show as boxes."
    return 0
  fi

  say "Failed to install Nerd Font."
  return 1
}

install_language_tools() {
  say "Optional language tooling can be installed for LSP, linting, and formatting."

  if ! confirm "Install optional language tooling?"; then
    say "Skipped optional language tooling."
    return 0
  fi

  for tool_task in $language_tool_tasks; do
    if ! run_language_tool_task "$tool_task"; then
      say "Language tooling task failed: $tool_task"
      if ! confirm "Continue with the remaining language tooling tasks?"; then
        return 1
      fi
    fi
  done
}

run_language_tool_task() {
  tool_task="$1"

  case "$tool_task" in
    javascript_typescript_tools) install_javascript_typescript_tools ;;
    python_tools) install_python_tools ;;
    elixir_tools) install_elixir_tools ;;
    *)
      say "Unknown language tooling task: $tool_task"
      return 1
      ;;
  esac
}

install_javascript_typescript_tools() {
  if has_command npm; then
    if confirm "Install global JavaScript/TypeScript tools with npm?"; then
      npm install -g typescript typescript-language-server eslint prettier
    fi
  else
    say "npm not found. Skipping JavaScript/TypeScript tooling."
  fi
}

install_python_tools() {
  if has_command python3; then
    if confirm "Install Python LSP with pip?"; then
      python3 -m pip install --user python-lsp-server
    fi
  else
    say "python3 not found. Skipping Python tooling."
  fi
}

install_elixir_tools() {
  if has_command mix; then
    if confirm "Install Elixir Hex and Credo tools?"; then
      mix local.hex --force
      mix archive.install hex credo --force
    fi
  else
    say "mix not found. Skipping Elixir tooling."
  fi
}

main() {
  say "dot-file installer"
  say "Install directory: $install_dir"
  say ""

  repo_dir="$(ensure_repo)" || exit 1

  run_tasks || exit 1

  say ""
  say "Done."
  say "Repo: $repo_dir"
}

main "$@"
