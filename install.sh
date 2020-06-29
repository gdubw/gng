#!/usr/bin/env bash

set -e
set -o pipefail
DEBUG=${DEBUG:-0}
if [[ "${DEBUG}" = 1 ]]; then
    set -x
fi

ACTION='\033[1;90m'
FINISHED='\033[1;96m'
READY='\033[1;92m'
NOCOLOR='\033[0m' # No Color
ERROR='\033[0;31m'

ensure_root() {
    if ! [[ "0" == "$(id -u)" ]]; then
        err "Please run as 'root', type '$0 -h' for details."
        exit 1
    fi
}

err() {
    echo -e ${ERROR}"$*"${NOCOLOR}
}

info() {
    echo -e ${FINISHED}"$*"${NOCOLOR}
}

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
    ensure_root
    rm -f /usr/local/bin/gng
    rm -rf /opt/gng
    info "gng is uninstalled."
}

usage() {
    usage="
sudo $0 [-fhsu]

Install gng from git source tree. See http://github.com/dantesun/gng for details.

-u uninstall
-f re-install
-h usage
-s check for update
"
    info "${usage}\n"
    err "NOTE: $0 requires root privileges, please run with sudo."
    echo
}

check_update() {
    [[ -z $(git status -s) ]] || {
        err 'You have modified/untracked files, aborting...'
#        exit 1
    }
    local branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ "$branch" != "master" ]]; then
        err "Not on master, aborting..."
        exit 1
    fi

    info "Checking Git remote repo for updates..."
    git fetch
    local head_hash=$(git rev-parse HEAD)
    local upstream_hash=$(git rev-parse master@{upstream})

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
    local GNG_ROOT="$(abs_dirname "$0")"

    mkdir -p "${PREFIX}/bin"
    cp -R "${GNG_ROOT}/bin/gng" "${PREFIX}/bin"
    cp -R "${GNG_ROOT}/gradle" "${PREFIX}/"

    info "Installed gng to $PREFIX"

    ln -s /opt/gng/bin/gng /usr/local/bin/gng
}


case "$1" in
    -h)
        usage
        exit 1
    ;;
    -f)
        info "Re-install gng ..."
        uninstall
        install
    ;;
    -s)
        info "Check for updates ..."
        check_update
    ;;
    -u)
        uninstall
    ;;
    *)
        install
esac

