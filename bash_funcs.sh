#!/bin/bash

# bash
# ldap
# snmp
# ucarp
# java
# git
# nfs
# - network
# - disk
# - memory
# - process

function add_array_element {
    local arr="${1:?"No array to 'add_array_element'!"}"
    local el="${2:?"No element to 'add_array_element'!"}"

    eval "$arr+=(\""$el"\")"
}

# ================ Function: array_contains_key ================ #
# Description:                                                   #
#     Check if an array contains a key.                          #
# Usage:                                                         #
#     array_contains_key <array> <key>                           #
# Return Codes:                                                  #
#     0 if array <array> contains key <key>                      #
#     1 if array <array> does not contain key <key>              #
#     2 if <array> is set, but not an array.                     #
#     3 if <array> is unset.                                     #
# +Tested                                                        #
# ============================================================== #
function array_contains_key {
    local arr="${1:?"No arr to 'array_contains_key'!"}"
    local key="${2:?"No key to 'array_contains_key'!"}"

    is_var_set "$arr" || return 3
    is_array "$arr" || return 2

    local keys="$(get_array_keys "$arr")"   

    local el
    for el in $keys; do
        [[ "$el" == "$key" ]] && return 0
    done
    return 1
}

# ================ Function: array_contains_value ================ #
# Description:                                                     #
#     Check if an array contains a value.                          #
# Usage:                                                           #
#     array_contains_value <array> <value>                         #
# Return Codes:                                                    #
#     0 if array <array> contains value <value>                    #
#     1 if array does not contain value.                           #
#     2 if <array> is set, but not an array.                       #
#     3 if <array> is unset.                                       #
# ================================================================ #
function array_contains_value {
    local arr="${1:?""}"
    local val="${2:?""}"

    is_var_set "$arr" || return 3
    is_array "$arr" || return 2

    local tmp="$arr[@]"
    local vals="${!tmp}"

    local el
    for el in $vals; do
        [[ "$el" == "$val" ]] && return 0
    done
    return 1
}

# ================ Function: bash_requires ================ #
# ========================================================= #
function bash_requires {
    local vers="${1:?""}"

}

function colorize {
:
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


# ================ Function: get_array_keys ================ #
# Usage: get_array_keys <array>                              #
# Return Codes:                                              #
#     0 if                                                   #
#     1 if                                                   #
# ========================================================== #
function get_array_keys {
    local arr="${1:?"No array to 'get_array_keys'!"}"

    is_array "$arr" || exit 1
    local tmp="\"\${!$arr[@]}\""
    printf "%s" "$(eval "echo $tmp")"
}


# ================ Function: get_array_values ================ #
# ============================================================ #
function get_array_values {
    local arr="${1:?""}"

    is_array "$arr" || exit 1

    local tmp="$arr[@]"

    local el
    for el in "${!tmp}"; do
        printf "%s\n" "$el"
    done
}


# ================ Function: get_package_deps ================ #
# ============================================================ #
function get_package_deps {
    local package="${1:?"No package to 'get_package_dependencies'!"}"
    printf "%s" "$(repoquery --requires --resolve "$package")"
}


# ================ Function: get_all_package_deps ================ #
# ================================================================ #
function get_all_package_deps {
    local package="${1:?"No package to 'get_package_dependencies'!"}"

    local -a final_deps
    local -a tmp_array
    readarray -t final_deps <<< "$(get_package_deps "$package")"
    local index=0
    while true; do

        lstop="$((${#final_deps[@]}-1))"
        [[ $lstop -eq $index ]] && break

        for ((i=$index; i<=$lstop; i++)); do
            package="${final_deps[$i]}"
            readarray -t tmp_array <<< "$(get_package_deps "$package")"
            join_arrays "final_deps" "tmp_array"
            index=$(($index+1))
        done

        remove_array_duplicates "final_deps"

        echo "len = "${#final_deps[@]}""
    done
}

# ================ is_alpha ================ #
# ========================================== #
function is_alpha {
    [[ "${1:?'Usage: is_alpha <string>'}" =~ ^[a-zA-Z]+$ ]]
}

# ================ is_alphanum ================ #
# ============================================= #
function is_alphanum {
    [[ "${1:?'Usage: is_alphanum <string>'}" =~ ^[0-9a-zA-Z]+$ ]]
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



function is_fd_term {
:
}

# ================ is_fd_valid ================ #
# ============================================= #
function is_fd_valid {
    is_num "${1:?'Usage: is_fd_valid <string>'}" || { printf "%s\n" "Arg to is_fd_valid is not a number!"; return 1; }
    { >&$1; } 2>/dev/null
}

function is_package_installed {
:
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

# ================ Function: join_arrays ================ #
# Usage: join_arrays <array1> <array2>                    #
# ======================================================= #
function join_arrays {
    local arr1="${1:?"No array1 to 'join_arrays'!"}"
    local arr2="${2:?"No array2 to 'join_arrays'!"}"

    is_array "$arr1" || return 3
    is_array "$arr2" || return 2

    set -x
    while read -r el; do
        add_array_element "$arr1" "$el"
    done <<< "$(get_array_values "$arr2")"
    set +x
}

function list_package_contents {
:
}

function print_array_elements {
    local arr="${1:?""}"

    is_array "$arr" || exit 1

    while read -r el; do
        printf "%s\n" "$el"
    done <<< "$(get_array_values "$arr")"
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

# ================ Function: remove_array_duplicates ================ #
# Remove duplicate values from an array                               #
# Usage: remove_array_duplicates <array>                              #
# =================================================================== #
function remove_array_duplicates {
    local arr="${1:?"No array to 'remove_array_duplicates'!"}"

    local -a tmparray
    local el

    while read -r el; do
        array_contains_value "tmparray" "$el" || add_array_element "tmparray" "$el"
    done <<< "$(get_array_values "$arr")"

    eval "$arr=(\"\${tmparray[@]}\")"
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
# Execute a function in locked state, forcing             #
# multiple calls to execute in serial                     #
# Usage: exec_locked <func>                               #
# Return Codes:                                           #
# ======================================================= #
function exec_locked {
    local func="${1:?"No func to 'exec_locked'!"}"
    local lockfile="$(realpath $0).lock"

    [[ ! -f "$lockfile" ]] && touch "$lockfile"

    exec {lock_fd}>"$lockfile"

    flock -x "$lock_fd"
    "$func"
    flock -u "$lock_fd"
}

function update_repo {
:
}

# ================ Function: var_contains_attr ================ #
# Usage: var_contains_attr <var> <attr>                         #
# Return Codes                                                  #
#     0 if <var> contains <attr>                                #
#     1 if <var> does not contain <attr>                        #
#     2 if <var> is not set                                     #
# ============================================================= #
function var_contains_attr {
    local var="${1:?"No var to 'var_contains_attr'!"}"
    local attr="${2:?"No attr to 'var_contains_attr'!"}"

    is_var_set "$var" || return 2
    local str="$(declare -p "$var")"
    str="${str#* }"
    str="${str%% *}"

    [[ "$str" =~ .*"$attr".* ]]
}

function wait_for_file {
:
}

function show_caller {
    if [[ $? -eq 1 ]]; then
        echo "Failure at ${BASH_SOURCE[2]}, line ${BASH_LINENO[1]}"
    fi
}


# Common setup
# Make sure 'LOG_FD' is not in use
[[ -n ${LOG_FD+x} ]] && printf "%s\n" "DO NOT use variable 'LOG_FD', as your values will be overwritten! This variable is reserved!"
exec {LOG_FD}>&1

trap show_caller EXIT
