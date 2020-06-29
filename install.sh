#!/usr/bin/env bash
set -e
set -o pipefail

resolve_link() {
  $(type -p greadlink readlink | head -1) "$1"
}

abs_dirname() {
  local cwd="$(pwd)"
  local path="$1"

  while [[ -n "$path" ]]; do
    cd "${path%/*}"
    local name="${path##*/}"
    path="$(resolve_link "$name" || true)"
  done

  pwd
  cd "$cwd"
}

uninstall() {
  rm -f /usr/local/bin/gng
  rm -rf /opt/gng
  echo "gng is uninstalled."
}

usage() {
    cat >&2 <<USAGE
Install gng.
usage: sudo $0
Uninstall gng.
usage: sudo $0 -u

USAGE
    exit 1
}

install() {
  if [[ "$1" == "-h" ]]; then
    usage
  fi
  if [[ "$1" == "-u" ]]; then
    uninstall
    exit 0
  fi
  local PREFIX="${1:-/opt/gng}"
  local GNG_ROOT="$(abs_dirname "$0")"

  mkdir -p "${PREFIX}/bin"
  cp -R "${GNG_ROOT}/bin/gng" "${PREFIX}/bin"
  cp -R "${GNG_ROOT}/gradle" "${PREFIX}/"
  echo "Installed gng to $PREFIX"

  ln -s /opt/gng/bin/gng /usr/local/bin/gng
}

if ! [[ "0" == "$(id -u)" ]]; then
    echo "Please run as 'root'"
    usage
    exit 1
fi

install "$@"