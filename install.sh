#!/usr/bin/env sh

set -u

repo_url="https://github.com/ambas/dot-file.git"
install_dir="${DOTFILE_DIR:-$HOME/Developer/configs/dot-file}"

# Add future top-level installers here, then map them in task_title and run_task.
install_tasks="${INSTALL_TASKS:-vim_config vim_plugins language_tools}"
language_tool_tasks="${LANGUAGE_TOOL_TASKS:-javascript_typescript_tools python_tools elixir_tools}"

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
    vim_plugins) printf '%s\n' "Vim plugins" ;;
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
    vim_plugins) install_vim_plugins ;;
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
