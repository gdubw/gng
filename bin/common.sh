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

function err() {
  echo -e "${ERROR_COLOR}$*${NO_COLOR}\n" >&2
}

function info() {
  echo -e "${INFO_COLOR}$*${NO_COLOR}\n"
}

function die() {
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
  err "StackTrace =>
${trace_info}
"
  exit $exit_status
}
trap '__errorCallBack__' ERR

trim() {
  # Remove the beginning spaces and tabs
  : "${1#"${1%%[![:blank:]]*}"}"
  # Remove the ending spaces and tabs
  : "${_%"${_##*[![:blank:]]}"}"
  # Remove the ending '\r'
  : "${_%$'\r'}"
  printf '%s' "$_"
}

# Finding the value of specific key in the __GNG_CONFIG array which is loaded from gng.cfg.
# The whole function is a subshell , so user can only
# reference variables from environment or from the variables previously declared gng.cfg.
function __load_cfg() (
  local line_no=0
  while IFS='' read -r line; do
    ((line_no++))
    line=$(trim "${line}")
    #ignore comments
    if [[ $line =~ ^# ]]; then
      continue
    fi
    #Ignore empty line
    if [[ -z $line ]]; then
      continue
    fi
    IFS='=' read -r key value <<<"${line}"
    key="$(trim "${key}")"
    value="$(trim "${value}")"
    [[ $key =~ ^[a-zA-Z_]*$ ]] || die \
      "Illegal key format! (key='${key}')!(${__GNG_CFG_FILE}:${line_no})." \
      "Only letters or underscore are allowed in configuration key!"

    if command -v envsubst &>/dev/null; then
      # Eagerly checking any variable that not able to be resolved by envsubst
      local -a all_var_names
      IFS='' read -r -a all_var_names <<<"$(envsubst -v -- "${value}")" || die "envsubst failed to list all variables of ${value}!"
      if ((${#all_var_names[@]} > 0)); then
        for var in "${all_var_names[@]}"; do
          declare -p "${var}" &>/dev/null || {
            die "
$(declare -xp)

The value of ${var} is not found!(${__GNG_CFG_FILE}:${line_no}) All available variables are above.
"
          }
        done
        value=$(envsubst <<<"${value}") || die "envsubst failed to substitute variables!"
      fi
      #export the variable so envsubst can use it in the loops afterward
      export "${key}"="${value}"
    fi
    printf "%s=%s\n" "${key}" "${value}"
  done
) || die

declare -a __GNG_CONFIG
__GNG_CFG_FILE="${HOME}/.gradle/gng.cfg"
[ -f "${__GNG_CFG_FILE}" ] && {
  IFS=$'\n' read -r -d $'\0' -a __GNG_CONFIG < <(__load_cfg <"${__GNG_CFG_FILE}" && printf '\0')
}
readonly __GNG_CONFIG

function cfg_get() {
  local key="${1}"
  for kv in "${__GNG_CONFIG[@]}"; do
    if [[ ${kv} =~ ^${key}= ]]; then
      printf "%s" "${kv#${key}=}"
      return 0
    fi
  done
}
