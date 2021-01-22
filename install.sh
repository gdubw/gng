#!/usr/bin/env bash
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  TARGET="$(readlink "$SOURCE")"
  if [[ $TARGET == /* ]]; then
    SOURCE="$TARGET"
  else
    SELF_DIR="$(dirname "$SOURCE")"
    SOURCE="$SELF_DIR/$TARGET" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  fi
done
SELF_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
# shellcheck disable=SC1090
source "${SELF_DIR}/bin/common.sh" || {
  echo "Failed to load common.sh in ${SELF_DIR}"
  exit 1
}

ensure_root() {
  if ! [[ "0" == "$(id -u)" ]]; then
    die "Please run as 'root', type '$0 -h' for details."
  fi
}

uninstall() {
  ensure_root
  rm -f /usr/local/bin/gng
  rm -f /usr/local/bin/gw
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

readonly FILE_LIST=(
  bin/common.sh
  bin/gng
  bin/gng.cfg
  gradle/GenerateWrapperProperties.java
  gradle/gradlew
  gradle/gradlew.bat
  gradle/wrapper/gradle-wrapper.jar
  gradle/wrapper/gradle-wrapper.properties
)

install() {
  ensure_root
  command -v javac >/dev.null || {
    die "'javac' is not found! Please Install JDK first!"
  }

  local PREFIX="${1:-/opt/gng}"

  info "Installed gng to $PREFIX"
  for file in ${FILE_LIST[*]}; do
    local dst_dir
    dst_dir="${PREFIX}"/$(dirname "${file}")
    [ -d "${dst_dir}" ] || mkdir -p "${dst_dir}"
    local src="${SELF_DIR}/${file}"
    cp -vf "${src}" "${dst_dir}"
  done
  chmod 755 "${PREFIX}/bin/gng"

  ln -sv "${PREFIX}"/bin/gng /usr/local/bin/gng
  ln -sv "${PREFIX}"/bin/gng /usr/local/bin/gw
  javac "${PREFIX}"/gradle/GenerateWrapperProperties.java
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
