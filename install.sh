#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")" || {
  echo "Failed to change to script's directory!(${BASH_SOURCE[0]})"
  exit 1
}
source bin/common.sh || {
  echo "Failed to load bin/common.sh"
  exit 1
}

ensure_root() {
  if ! [[ "0" == "$(id -u)" ]]; then
    err "Please run as 'root', type '$0 -h' for details."
    exit 1
  fi
}

resolve_link() {
  $(command -v greadlink readlink) "$1"
}

abs_dirname() {
  local cwd
  cwd="$(pwd)"
  local path="$1"

  while [[ -n "$path" ]]; do
    cd "${path%/*}" || die "Failed to change directory!"
    local name="${path##*/}"
    path="$(resolve_link "$name" || true)"
  done

  pwd
  cd "$cwd" || die "Failed to change directory!"
}

uninstall() {
  ensure_root
  rm -f /usr/local/bin/gng
  rm -rf /opt/gng
  info "gng is uninstalled."
}

usage() {
  usage="
sudo $0 [-fhsu]

Install gng from git source tree. See http://github.com/gdubw/gng for details.

-u uninstall
-f re-install
-h usage
-s check for update
"
  info "${usage}\n"
  err "NOTE: $0 requires root privileges, please run with sudo."
  echo
}

function git_get_upstream() {
  local dir="${1}"
  (
    cd "${dir}" || die "Failed to change directory to ${dir}"
    git rev-parse --abbrev-ref '@{upstream}'
  )
}

function git_validate() {
  local dir="${1}"
  (
    cd "${dir}" || die "Failed to change directory to ${dir}"
    git rev-parse --git-dir &>/dev/null || {
      die "${dir} is not a GIT repository！"
    }
    git_is_dirty "${dir}" && {
      die "${dir} is dirty!"
    }

    git fetch &>/dev/null || {
      die "git fetch failed!"
    }
    local upstream
    upstream=$(git_get_upstream "${dir}")
    if (($(git rev-list "${upstream}"..HEAD --count) > 0)); then
      die "${dir} is locally changed. Please try again after 'git push'"
    fi
    if (($(git rev-list "HEAD..${upstream}" --count) > 0)); then
      die "${dir} is not synced with remote. Please try again after 'git pull'"
    fi
  )
}

function git_is_dirty() {
  local dir="${1}"
  (
    cd "${dir}" || die "Can't change to directory ${dir}"
    if [ -z "$(git status --porcelain)" ]; then
      return 1
    else
      return 0
    fi
  )
}

check_update() {
  git_is_dirty || {
    die 'You have modified/untracked files, aborting...'
  }
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD)
  if [[ "$branch" != "master" ]]; then
    err "Not on master, aborting..."
    exit 1
  fi

  info "Checking Git remote repo for updates..."
  git fetch
  local head_hash
  head_hash=$(git rev-parse HEAD)
  local upstream_hash
  upstream_hash=$(git rev-parse master@{upstream})

  if [[ "$head_hash" != "$upstream_hash" ]]; then
    err "Not up to date with origin. Aborting."
    return 1
  else
    info "Current branch is up to date with origin/master."
    return 0
  fi
}

install() {
  ensure_root

  local PREFIX="${1:-/opt/gng}"
  local GNG_ROOT
  GNG_ROOT="$(abs_dirname "$0")"

  mkdir -p "${PREFIX}/bin"
  cp -R "${GNG_ROOT}/bin/" "${PREFIX}/bin"
  cp -R "${GNG_ROOT}/gradle" "${PREFIX}/"

  info "Installed gng to $PREFIX"

  ln -s "${PREFIX}"/bin/gng /usr/local/bin/gng
}

case "${1:-}" in
-h)
  usage
  exit 1
  ;;
-f)
  info "Re-install gng ..."
  uninstall
  install "${PREFIX:-}"
  ;;
-s)
  info "Check for updates ..."
  check_update
  ;;
-u)
  uninstall
  ;;
*)
  install "${PREFIX:-}"
  ;;
esac
