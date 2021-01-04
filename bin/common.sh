set -o errexit
set -o nounset
set -o pipefail
set -o errtrace
DEBUG="${DEBUG:-0}"
if [[ "${DEBUG}" == 1 ]]; then
  set -x
fi
export SHELLOPTS

readonly INFO_COLOR='\033[1;96m'
readonly NO_COLOR='\033[0m' # No Color
readonly ERROR_COLOR='\033[0;31m'

err() {
  echo -e "${ERROR_COLOR}$*${NO_COLOR}\n" >&2
}

info() {
  echo -e "${INFO_COLOR}$*${NO_COLOR}\n"
}

die() {
  local exit_status=$?
  err "$@" "($(caller))"
  if [ "$exit_status" = "0" ]; then
    exit 1
  else
    exit $exit_status
  fi
}

__errorCallBack__() {
  local exit_status=$?
  local trace_info
  trace_info=$(
    local frame=0
    while caller ${frame}; do
      ((frame++))
    done
  )
  err "ErrorStack =>
${trace_info}"
  exit $exit_status
}
trap '__errorCallBack__' ERR
