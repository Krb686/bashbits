#!/bin/bash

# TODO - list_package_contents
# TODO - colorize

[[ ${BASH_VERSINFO[0]}${BASH_VERSINFO[1]} < "43" ]] && { printf "%s\n" "Bash 4.3 or higher is required"; return 1; }

# ================ Function: array_contains_key ================ #
# ============================================================== #
function array_contains_key {
    local arr="${1:?"No arr to 'array_contains_key'!"}"
    local key="${2:?"No key to 'array_contains_key'!"}"

    local tmp="\"\${!$arr[@]}\""
    local keys="$(eval "echo $tmp")"

    for el in $keys; do
        [[ "$el" == "$key" ]] && return 0
    done
    return 1
}

# ================ Function: array_contains_value ================ #
# ================================================================ #
function array_contains_value {
    local arr="${1:?""}"
    local val="${2:?""}"

    local tmp="$arr[@]"
    local vals="${!tmp}"

    for el in $vals; do
        [[ "$el" == "$val" ]] && return 0
    done
    return 1
}

# ================ Function: delete_element_by_key ================ #
# ================================================================= #
function delete_element_by_key {
    local arr="${1:?""}"
    local key="${2:?""}"

    is_array "$arr" || return 1

    unset "$arr[$key]"
    eval "$arr=(\"\${$arr[@]}\")"
}

# ================ Function: delete_elements_by_value ================ #
# ==================================================================== #
function delete_elements_by_value {
:
}

# ================ is_alpha ================ #
# ========================================== #
function is_alpha {
    [[ "${1:?'Usage: is_alpha <string>'}" =~ ^[a-zA-Z]+$ ]]
}

# ================ Function: is_array ================ #
# Usage: is_array <var>                                #
# Return Codes:                                        #
#     0 if <var> is an array                           #
#     1 if <var> is not an array                       #
# ==================================================== #
function is_array {
    local var="${1:?"No var to 'is_array'!"}"

    var_contains_attr "$var" "a" && return 0
    var_contains_attr "$var" "A" && return 0
    return 1
}

# ================ Function: is_array_associative ================ #
# Usage: is_array_associative <var>                                #
# Return Codes:                                                    #
#     0 if <var> is an associative array                           #
#     1 if <var> is not an associative array                       #
#     2 if <var> is invalid                                        #
# ================================================================ #
function is_array_associative {
    local arr="${1:?""}"
    var_contains_attr "$var" "A"  && return 0 || return 1
}

# ================ Function: is_array_standard ================ #
# Usage: is_array_standard <var>                                #
# Return Codes:                                                 #
#     0 if <var> is a standard array                            #
#     1 if <var> is not a standard array                        #
#     2 if <var> is invalid                                     #
# ============================================================= #
function is_array_standard {
    local arr="${1:?""}"    
    var_contains_attr "$var" "a" && return 0 || return 1
}

# ================ is_call_internal ================ #
# ================================================== #
function is_call_internal {
    [[ "${BASH_SOURCE[2]}" == "${BASH_SOURCE[1]}" ]]
}

# ================ is_num ================ #
# ======================================== #
function is_num {
    [[ "${1:?'Usage: is_num <string>'}" =~ ^[0-9]*.?[0-9]+$ ]]
}

# ================ is_alphanum ================ #
# ============================================= #
function is_alphanum {
    [[ "${1:?'Usage: is_alphanum <string>'}" =~ ^[0-9a-zA-Z]+$ ]]
}

# ================ is_fd_valid ================ #
# ============================================= #
function is_fd_valid {
    is_num "${1:?'Usage: is_fd_valid <string>'}" || { printf "%s\n" "Arg to is_fd_valid is not a number!"; return 1; }
    { >&$1; } 2>/dev/null
}

# ================ Function: is_var_set ================ #
# Usage: is_var_set <var>                                #
# Return Codes:                                          #
#     0 if <var> is set                                  #
#     1 if <var> is unset                                #
# ====================================================== #
function is_var_set {
    local var="${1:?"No var to 'is_var_set'!"}"
    [[ -v "$var" ]] && return 0 || return 1
}

# ================ print_debug ================ #
# ============================================= #
function print_debug {
    [[ "${DEBUG_FLAG:-0}" -eq 1 ]] && print_log "d" "$1"
}

# ================ print_error ================ #
# ============================================= #
function print_error {
    [[ "${ERROR_FLAG:-0}" -eq 1 ]] && print_log "e" "$1"
}

# ================ print_info ================ #
# ============================================ #
function print_info {
    [[ "${INFO_FLAG:-0}" -eq 1 ]] && print_log "i" "$1"
}

# ================ Function: print_log ================ #
# Print equispaced content                              #
# ===================================================== #
function print_log {
    local TYPE="${1:?'No logtype specified! Must be i(info), d(debug), or e(error)!'}"
    [[ ! "$TYPE" =~ (i|d|e) ]] && printf "%s\n" "No logtype specified! Must be i(info), d(debug), or e(error)!" && return 1

    local STR="${2:?'No argument to print_log!'}"
    local R_OFF="${3:-0}"

    declare -A HEADERS=(["i"]="[ ------ info ----- ]: " ["d"]="[ ===== debug ===== ]: " ["e"]="[ ***** error ***** ]: ")
    local HEADER="${HEADERS[$TYPE]}"
     STR="$HEADER""$STR"

    which tput >&/dev/null || { printf "%s\n" "$STR" >&$LOG_FD; return 0; }

    local WIDTH=$(($(tput cols)-$R_OFF))

    while [[ "${#STR}" -gt $WIDTH ]]; do
        printf "%s\n" "${STR:0:$WIDTH}">&$LOG_FD
        STR="$(printf ' %0.s' $(seq 1 ${#HEADER}))""${STR:$WIDTH}"
    done

    printf "%s\n" "$STR">&$LOG_FD
}

# ================ Function: replace_spaces ================ #
# ========================================================== #
function replace_spaces {
    local dir="${1:?'Usage: replace_spaces <dir>'}"
    local fC=0
    for file in "$1"/*; do
        local new="$(echo $file | tr ' ' '_')"
        [[ "$new" == "$file" ]] && { :; } ||  { mv "$file" "$new"; fC=$(($fC+1)); }
    done
    printf "%s\n" "Renamed $fC files!"
}

# ================ Function: exec_locked ================ #
# ======================================================= #
function exec_locked {
    local FUNC="${1:?"No func to 'exec_locked'!"}"
    local LOCKFILE="$(realpath $0).lock"

    [[ ! -f "$LOCKFILE" ]] && touch "$LOCKFILE"

    exec {LOCK_FD}>"$LOCKFILE"

    flock -x "$LOCK_FD"
    "$FUNC"
    flock -u "$LOCK_FD"
}

# ================ Function: var_contains_attr ================ #
# Usage: var_contains_attr <var> <attr>                         #
# Return Codes                                                  #
#     0 if <var> contains <attr>                                #
#     1 if <var> does not contain <attr>                        #
# ============================================================= #
function var_contains_attr {
    local var="${1:?"No var to 'var_contains_attr'!"}"
    local attr="${2:?"No attr to 'var_contains_attr'!"}"

    local str="$(declare -p "$var")"
    str="${str#* }"
    str="${str% *}"

    [[ "$str" =~ .*"$attr".* ]] && return 0 || return 1
}


# Common setup
# Make sure 'LOG_FD' is not in use
[[ -n ${LOG_FD+x} ]] && printf "%s\n" "DO NOT use variable 'LOG_FD', as your values will be overwritten! This variable is reserved!"
exec {LOG_FD}>&1

