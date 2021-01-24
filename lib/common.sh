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

function debug() {
  if [[ "${DEBUG}" == 0 ]]; then
    return
  fi
  echo -e "${INFO_COLOR}$*${NO_COLOR}\n"
}

function err() {
  echo -e "${ERROR_COLOR}$*${NO_COLOR}\n" >&2
}

function info() {
  echo -e "${INFO_COLOR} $*${NO_COLOR}\n"
}

function die() {
  local exit_status=$?
  if [[ "${DEBUG}" == 0 ]]; then
    err "$@"
  else
    err "$@" "($(caller))"
  fi
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
if [[ "${DEBUG}" == 1 ]]; then
  trap '__errorCallBack__' ERR
fi

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

#Testing awk for parsing properties file(how to do variable substitution?)
function __get_property() {
  awk -v key="${1}" -f <(
    cat - <<-'_EOF_'
BEGIN {
    FS="=";
    n="";
    v="";
    c=0; # Not a line continuation.
}
/^($|[:space:]*#)/ { # The line containing whitespaces or is a comment.  Breaks line continuation.
    c=0;
    next;
}
/\\$/ && (c==0) && (NF>=2) { # Name value pair with a line continuation...
    e=index($0,"=");
    n=substr($0,1,e-1);
    v=substr($0,e+1,length($0) - e - 1);    # Trim off the backslash.
    c=1;                                    # Line continuation mode.
    next;
}
/^[^\\]+\\$/ && (c==1) { # Line continuation.  Accumulate the value.
    v= "" v substr($0,1,length($0)-1);
    next;
}
((c==1) || (NF>=2)) && !/^[^\\]+\\$/ { # End of line continuation, or a single line name/value pair
    if (c==0) {  # Single line name/value pair
        e=index($0,"=");
        n=substr($0,1,e-1);
        v=substr($0,e+1,length($0) - e);
    } else { # Line continuation mode - last line of the value.
        c=0; # Turn off line continuation mode.
        v= "" v $0;
    }
    # Make sure the name is a legal shell variable name
    gsub(/[^A-Za-z0-9_]/,"_",n);
    # Remove newlines from the value.
    gsub(/[\n\r]/,"",v);
#    print n "=\"" v "\"";
    print v;
    n = "";
    v = "";
}
END {
}
_EOF_
  )
}
