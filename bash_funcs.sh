#!/bin/bash

# array
# bash
# exec
# file
# io
# print
# string
# yum


# TODO - add bash.requires to all functions
# TODO - automatic test case generation
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



# ================ Function: array.contains_key ============================== #
# Description:                                                                 #
#     Check if an array contains a key.                                        #
# Usage:                                                                       #
#     array_contains_key <array> <key>                                         #
# Return Codes:                                                                #
#     0 if array <array> contains key <key>                                    #
#     1 if array <array> does not contain key <key>                            #
#     2 if <array> is set, but not an array.                                   #
#     3 if <array> is unset.                                                   #
# Order:
# ============================================================================ #
function array.contains_key {
    local array_name="${1:?"No array_name to 'array.contains_key'!"}"
    local key="${2:?"No key to 'array.contains_key'!"}"

    bash.is_var_set "$array_name" || return 3
    array.is_array "$array_name" || return 2

    local keys="$(array.get_keys "$array_name")"   

    local el
    for el in $keys; do
        [[ "$el" == "$key" ]] && return 0
    done
    return 1
}

# ================ Function: array.contains_value ============================ #
# Description:                                                                 #
#     Check if an array contains a value.                                      #
# Usage:                                                                       #
#     array_contains_value <array> <value>                                     #
# Return Codes:                                                                #
#     0 if array <array> contains value <value>                                #
#     1 if array does not contain value.                                       #
#     2 if <array> is set, but not an array.                                   #
#     3 if <array> is unset.                                                   #
# Order:
# ============================================================================ #
function array.contains_value {
    local array_name="${1:?"No array_name to 'array.contains_value'!"}"
    local val="${2:?"No value to 'array.contains_value'!"}"

    bash.is_var_set "$array_name" || return 3
    array.is_array "$array_name" || return 2

    local tmp="$array_name[@]"
    local vals="$(array.get_values "$array_name")"

    local el
    for el in $vals; do
        [[ "$el" == "$val" ]] && return 0
    done
    return 1
}

# ================ Function: array.delete_by_key ============================= #
# Description:                                                                 #
#     Delete element from array indexed by <key.                               #
# Usage:                                                                       #
#     array.delete_by_key <array> <key>                                        #
# Return Codes:                                                                #
#     0 if element indexed by <key> is successfully deleted.                   #
#     1 if element indexed by <key> did not exist in <aname>.                  #
#     2 if element indexed by <key> cannot be deleted because <array> is       #
#       readonly.                                                              #
#     3 if <array> is set, but not an array.                                   #
#     4 if <array> is unset.                                                   #
# Order:                                                                       #
# ============================================================================ #
function array.delete_by_key {
    local array_name="${1:?"No array_name to 'array.delete_by_key'!"}"
    local key="${2:?"No key to 'array.delete_by_key'!"}"

    bash.is_var_set "$array_name" || return 4
    array.is_array "$array_name" || return 3
    bash.is_var_ro "$array_name" && return 2
    array.contains_key "$array_name" "$key" || return 1

    unset "$array_name[$key]"
    eval "$array_name=(\"\${$array_name[@]}\")"
}

# ================ Function: array.delete_by_value =========================== #
# Description:                                                                 #
#     Delete all elements from array that have value <value>.                  #
# Usage:                                                                       #
#     array.delete_by_value <value>                                            #
# Return Codes:                                                                #
#     0 if at least 1 element is deleted.                                      #
#     1 if no elements with value <value> exist in the array.                  #
#     2 if <array> is readonly and no elements can be deleted.                 #
#     3 if <array> is set, but not an array.                                   #
#     4 if <array> is unset.                                                   #
# Order:                                                                       #
# ============================================================================ #
function array.delete_by_value {
    local array_name="${1:?"No array_name to 'array.delete_by_value'!"}"
    local val="${2:?"No value to 'array.delete_by_value'!"}"

    bash.is_var_set "$array_name" || return 4 
    array.is_array "$array_name" || return 3
    bash.is_var_ro "$array_name" && return 2

    array.is_standard "$array_name" && local -a tmparray
    array.is_associative "$array_name" && local -A tmparray 

    local keys="$(array.get_keys "$array_name")"

    local val_found=0
    while read -r key; do
        local value="$(array.get_by_key "$array_name" "$key")"
        if [[ "$value" == "$val" ]]; then
            val_found=1
        else
            array.set_element "$array_name" "$key" "$value"
        fi
    done <<< "$keys"
    [[ $val_found -eq 1 ]]
}

# ================ Function: array.dump_keys ================================= #
# Description: 
# Usage: 
# Return Codes:
# Order:
# ============================================================================ #
function array.dump_keys {
:
}

# ================ Function: array.dump_values =============================== #
# Description: 
# Usage: 
# Return Codes:
# Order:
# ============================================================================ #
function array.dump_values {
    local aname="${1:?""}"

    array.is_array "$aname" || exit 1

    while read -r el; do
        printf "%s\n" "$el"
    done <<< "$(array.get_values "$aname")"
}

# ================ Function: array.get_keys ================================== #
# Description:
# Usage: get_array_keys <array>                                                #
# Return Codes:                                                                #
#     0 if                                                                     #
#     1 if                                                                     #
# Order:
# ============================================================================ #
function array.get_keys {
    local aname="${1:?"No array to 'get_array_keys'!"}"

    array.is_array "$aname" || exit 1
    local tmp="\"\${!$aname[@]}\""
    printf "%s" "$(eval "echo $tmp")"
}

# ================ Function: array.get_by_key ================================ #
# Description:                                                                 #
# Usage:                                                                       #
# Return Codes:                                                                #
# Order:                                                                       #
# ============================================================================ #
function array.get_by_key {
    local array_name="${1:?""}"
    local key="${2:?""}"
    local tmp="$array_name[\"$key\"]"
    printf "%s" "${!tmp}"
}


# ================ Function: array.get_values ================================ #
# Description: 
# Usage: 
# Return Codes:
# Order:
# ============================================================================ #
function array.get_values {
    local aname="${1:?""}"

    array.is_array "$aname" || exit 1

    local tmp="$aname[@]"

    local el
    for el in "${!tmp}"; do
        printf "%s\n" "$el"
    done
}

# ================ Function: array.is_array ================================== #
# Description:
# Usage: is_array <var>                                                        #
# Return Codes:                                                                #
#     0 if <var> is an array                                                   #
#     1 if <var> is not an array                                               #
# Order:
# ============================================================================ #
function array.is_array {
    local var="${1:?"No var to 'is_array'!"}"

    bash.var_contains_attr "$var" "a" && return 0
    bash.var_contains_attr "$var" "A" && return 0
    return 1
}


# ================ Function: array.is_associative ============================ #
# Description:
# Usage: is_array_associative <var>                                            #
# Return Codes:                                                                #
#     0 if <var> is an associative array                                       #
#     1 if <var> is not an associative array                                   #
#     2 if <var> is invalid                                                    #
# Order:
# ============================================================================ #
function array.is_associative {
    local aname="${1:?""}"
    bash.var_contains_attr "$aname" "A"  && return 0 || return 1
}

# ================ Function: array.is_standard =============================== #
# Description:
# Usage: is_array_standard <var>                                               #
# Return Codes:                                                                #
#     0 if <var> is a standard array                                           #
#     1 if <var> is not a standard array                                       #
#     2 if <var> is invalid                                                    #
# Order:
# ============================================================================ #
function array.is_standard {
    local aname="${1:?""}"    
    bash.var_contains_attr "$aname" "a" && return 0 || return 1
}

# ================ Function: array.join ====================================== #
# Description:                                                                 #
#     Join elements from <array2> into <array1>                                #
# Usage:                                                                       #
#     array.join <array1> <array2>                                             #
# Return Codes:                                                                #
#     3 if <aname1> is not an array.                                           #
#     2 if <
# Order:                                                                       #
# ============================================================================ #
function array.join {
    local aname1="${1:?"No array1 to 'join_arrays'!"}"
    local aname2="${2:?"No array2 to 'join_arrays'!"}"

    array.is_array "$aname1" || return 3
    array.is_array "$aname2" || return 2

    while read -r el; do
        array.push "$aname1" "$el"
    done <<< "$(array.get_values "$aname2")"
}

# ================ Function: array.len ======================================= #
# Description:                                                                 #
# Usage:                                                                       #
# Return Codes:                                                                #
# Order:                                                                       #
# ============================================================================ #
function array.len {
    local aname="${1:?""}"
    declare -p "$aname"
    array.is_array "$aname" || return 1

    local str="\"\${#$aname[@]}\""
    eval "echo $str"
}


# ================ Function: array.pop ======================================= #
# Description:                                                                 #
# Usage:                                                                       #       
# Return Codes:                                                                #
# Order:
# ============================================================================ #
function array.pop {
    local aname="${1:?""}"
    array.is_standard "$aname" || exit 2
}


# ================ Function: array.push ====================================== #
# Description:                                                                 #
#     Push <el> to end of array named <aname>.                                 #
#     <el> can be a single element, or a newline separated list of elements.   #
# Usage:                                                                       #
#     array.push <aname> <el>                                                  #
# Return Codes:                                                                #
#     2 if <aname> is not an array.                                            #
#     1 if <aname> is an associative array.                                    #
#     0 if <el> was successfully pushed to array <aname>.                      #
# Order:                                                                       #
# ============================================================================ #
function array.push {
    local aname="${1:?"No array to 'add_array_element'!"}"
    local el="${2:?"No element to 'add_array_element'!"}"

    array.is_array "$aname" || return 2
    array.is_standard "$aname" || return 1

    string.contains "$el" $'\n'
    if [[ $? -eq 0 ]]; then
        local -a tmparray
        readarray -t tmparray <<< "$el"
        array.join "$aname" "tmparray"
    else
        eval "$aname+=(\""$el"\")"
    fi
}

# ================ Function: array.remove_duplicates ========================= #
# Description:                                                                 #
#     Remove duplicate values from an array                                    #
# Usage:                                                                       #
#     remove_array_duplicates <array>                                          #
# Return Codes:
# Order:
# ============================================================================ #
function array.remove_duplicates {
    local aname="${1:?"No array to 'remove_array_duplicates'!"}"

    local -a tmparray
    local el

    while read -r el; do
        array.contains_value "tmparray" "$el" || array.push "tmparray" "$el"
    done <<< "$(get_array_values "$aname")"

    eval "$aname=(\"\${tmparray[@]}\")"
}


# ================ Function: array.set_element =============================== #
# Description:                                                                 #
#     Set element in an array, specifying key and value.                       #
# Usage:                                                                       #
#     array.add_element <array> <key> <value>                                  #
# Return Codes:                                                                #
#     0 if                                                                     #
#     1 if                                                                     #
# Order:                                                                       #
# ============================================================================ #
function array.add_element {
    local array_name="${1:?""}"
    local key="${2:?""}"
    local value="${3:?""}"
    eval "$array_name[\"$key\"]=\"$value\""
}

# ================ Function: array.split ===================================== #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function array.split {
:
}


# ================ Function: bash.requires =================================== #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function bash.requires {
    local vers="${1:?""}"

}

# ================ Function: bash.is_var_ro ================================== #
# Description:                                                                 #
#     Determine if a variable is declared as read-only                         #
# Usage:                                                                       #
#     bash.is_var_ro <var>                                                     #
# Return Codes:                                                                #
#     0 if <var> is read-only                                                  #
#     1 if <var> is not read-only.                                             #
#     2 if <var> is unset.                                                     #
# ============================================================================ #
function bash.is_var_ro {
    local var="${1:?"No var to 'bash.is_var_ro'!"}"

    bash.is_var_set "$var" || return 2
    bash.var_contains_attr "$var" "r"
}

# ================ Function: bash.is_var_set ================================= #
# Description:
# Usage: is_var_set <var>                                                      #
# Return Codes:                                                                #
#     0 if <var> is set                                                        #
#     1 if <var> is unset                                                      #
# Order:
# ============================================================================ #
function bash.is_var_set {
    local var="${1:?"No var to 'is_var_set'!"}"
    [[ -v "$var" ]] && return 0 || return 1
}

# ================ Function: bash.var_contains_attr ========================== #
# Description:                                                                 #
# Usage: var_contains_attr <var> <attr>                                        #
# Return Codes:                                                                #
#     0 if <var> contains <attr>                                               #
#     1 if <var> does not contain <attr>                                       #
#     2 if <var> is not set                                                    #
# Order:
# ============================================================================ #
function bash.var_contains_attr {
    local var="${1:?"No var to 'var_contains_attr'!"}"
    local attr="${2:?"No attr to 'var_contains_attr'!"}"

    bash.is_var_set "$var" || return 2
    local str="$(declare -p "$var")"
    str="${str#* }"
    str="${str%% *}"

    [[ "$str" =~ .*"$attr".* ]]
}

# ================ Function: c.get_include_paths ============================= #
# ============================================================================ #
function c.get_include_paths {
    cpp -v </dev/null 2>&1 | sed -ne '/starts here/,/End of/p' | grep -v "search starts here" | grep -v "End of search list"
}

# ================ Function: c.get_includes ================================== #
# Description:                                                                 #
# Usage:                                                                       #
# ============================================================================ #
function c.get_includes {
    local file="${1:?""}"
    local -a array
    readarray -t array <<<"$(cat "$file" | grep -Po '(?<=^#include (<|")).*(?=(>|")$)')"

    for el in "${array[@]}"; do
        printf "%s\n" "$el"
    done
}

# ================ Function: c.get_all_includes ============================== #
# Description:                                                                 #
#     Find location of all necessary includes for a given c src.               #
# Usage:                                                                       #
#     c.get_all_includes <file>                                                #
# ============================================================================ #
function c.get_all_includes {
    local file="${1:?"No file to 'c.get_all_includes'!"}"
    local -a array
    readarray -t array <<< "$(c.get_includes "$file")"


    # 
    local icur=0
    local iend=${#array[@]}
    until [[ $icur -eq $iend ]]; do
    :    
    done

    local istart=0
    local icur=0
    local iend=0
    #while [[ 
    #for el in "${direct_includes[@]}"; do
    
    #    echo "el = $el"
    #done
}




# ================ Function: exec.exec_locked ================================ #
# Description:                                                                 #
#     Execute a function in locked state, forcing multiple calls to execute in #
#     serial
# Usage: exec_locked <func>                                                    #
# Return Codes:                                                                #
# Order:
# ============================================================================ #
function exec.exec_locked {
    local func="${1:?"No func to 'exec_locked'!"}"
    local lockfile="$(realpath $0).lock"

    [[ ! -f "$lockfile" ]] && touch "$lockfile"

    exec {lock_fd}>"$lockfile"

    flock -x "$lock_fd"
    "$func"
    flock -u "$lock_fd"
}

# ================ Function: exec.get_caller ================================= #
# Description:                                                                 #
# Usage:                                                                       #
# Return Codes:                                                                #
# Order:
# ============================================================================ #
function exec.get_caller {
    if [[ $? -eq 1 ]]; then
        echo "Failure at ${BASH_SOURCE[2]}, line ${BASH_LINENO[1]}"
    fi
}

# ================ exec.is_call_internal ===================================== #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function exec.is_call_internal {
    [[ "${BASH_SOURCE[2]}" == "${BASH_SOURCE[1]}" ]]
}


# ================ exec.is_locked ============================================ #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function exec.is_locked {
:
}

# ================ Function: file.despace_name =============================== #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function file.despace_name {
    local dir="${1:?'Usage: replace_spaces <dir>'}"
    local fC=0
    for file in "$1"/*; do
        local new="$(echo $file | tr ' ' '_')"
        [[ "$new" == "$file" ]] && { :; } ||  { mv "$file" "$new"; fC=$(($fC+1)); }
    done
    printf "%s\n" "Renamed $fC files!"
}


# ================ Function: file.wait_for_file ============================== #
# Description:                                                                 #
# Usage:                                                                       #
# Return Codes:                                                                #
# Order:
# ============================================================================ #
function file.wait_for_file {
    local file="${1:?""}"
    local timeout="${2:--1}"

    until [[ -f "$file" ]]; do
        sleep 1
        [[ $timeout -gt 0 ]] && timeout=$(($timeout-1))
        [[ $timeout -eq 0 ]] && break
    done
}

# ================ Function: io.is_fd_term =================================== #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function io.is_fd_term {
:
}


# ================ Function: io.is_fd_valid ================================== #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function io.is_fd_valid {
    string.is_num "${1:?'Usage: is_fd_valid <string>'}" || { printf "%s\n" "Arg to is_fd_valid is not a number!"; return 1; }
    { >&$1; } 2>/dev/null
}


# ================ Function: print.debug ===================================== #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function print.debug {
    [[ "${DEBUG_FLAG:-0}" -eq 1 ]] && print.log "d" "$1"
}

# ================ Function: print.error ===================================== #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function print.error {
    [[ "${ERROR_FLAG:-0}" -eq 1 ]] && print.log "e" "$1"
}

# ================ Function: print.info ====================================== #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function print.info {
    [[ "${INFO_FLAG:-0}" -eq 1 ]] && print.log "i" "$1"
}

# ================ Function: print.log ======================================= #
# Description:
# Usage:
# Return Codes:
# Order:
# Print equispaced content                                                     #
# ============================================================================ #
function print.log {
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

# ================ Function: print.status ==================================== #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function print.status {
:
}


# ================ Function: string.colorize ================================= #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function string.colorize {
:
}

# ================ Function string.contains ================================== #
# Description:                                                                 #
# Usage:                                                                       #
# Return Codes:                                                                #
# Order:
# ============================================================================ #
function string.contains {
    local str1="${1:?""}"
    local str2="${2:?""}"
    [[ "$str1" =~ .*"$str2".* ]]
}


# ================ Function: string.is_alpha ================================= #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function string.is_alpha {
    [[ "${1:?'Usage: is_alpha <string>'}" =~ ^[a-zA-Z]+$ ]]
}

# ================ Function string.is_alphanum =============================== #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function string.is_alphanum {
    [[ "${1:?'Usage: is_alphanum <string>'}" =~ ^[0-9a-zA-Z]+$ ]]
}


# ================ Function: string.is_num =================================== #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function string.is_num {
    [[ "${1:?'Usage: is_num <string>'}" =~ ^[0-9]*.?[0-9]+$ ]]
}

# Tree variable
# Cannot use ", :, <, >
#
# --> Company
#     --> HR
#         --> HR Head
#     --> Legal
#         --> Legal Head
#         --> Engineering
#     --> Engineering
#         --> Engineering Head
#             --> Sub1
#                 --> Assistant
#             --> Sub2
#                 --> Assistant
#     --> Corporate
#         --> Director
#
# "ROOT:Company>HR>HR Head<Legal>Legal Head:Engineering<Engineering>Engineering Head>Sub1>Assistant<Sub2>Assistant<<<Corporate>Director"

# adding node

# Company>Engineering>Developer

# --> split by '<'

# HR>HR Head
# Legal>Legal Head:Engineering
# Engineering>Engineering Head>Sub1>Assistant
# Sub2>Assistant
# Corporate>Director

# ================ Function: tree.add_node =================================== #
# ============================================================================ #
function tree.add_node {
    local INFO_FLAG=1
    local tree="${1:?"No tree to 'tree.add_node'!"}"
    local node="${2:?"No node to 'tree.add_node'!"}"

    local node_parent="$(printf "%s" "$node" | awk -F '>' '{print NR}')"

    local pre=""
    local post=""
    local branch_found=false

    local index=0
    local node_array=($(printf "%s" "$node" | sed 's/>/ /g'))
    if [[ ${#node_array[@]} -gt 1 ]]; then
        local node_parent="${node_array[$((${#node_array[@]} - 2))]}"
        print.debug "node_parent = $node_parent"
    fi


    local depth=0
    local left=""
    local str=""
    while read -rN1 char; do
        case "$char" in
            "<")
                echo "str = $str, depth = $depth"
                depth=$(($depth-1))
                left+="$str"
                str="";;
            ">")
                if [[ "$str" == ${node_array[$index]} && $index -eq $depth ]]; then
                    print.info "-----------------------> match found"
                    index=$(($index+1))
                fi
                print.debug "str = $str"
                print.debug "n[index] = ${node_array[$index]}"
                print.debug "index = $index"
                print.debug "depth = $depth"
                print.debug "--------"
                depth=$(($depth+1))
                left+="$str"
                str="";;
            ":")
                echo "str = $str, depth = $depth"
                left+="$str"
                str="";;
            *)
                str+="$char";;
        esac
    done <<< "$tree"


    # make sure node doesnt already exist
    # make sure parent node exists

    pre+="$(printf "%s" "$tree" | awk -F ':' '{print $1}')"
    post+="${tree#*:}"

    #until $branch_found; do
    #:    
    #done

    # Record leading portion
    # Record trailing portion
    # Insert between
}

# ================ Function: tree.create ===================================== #
#                                                                              #
# ============================================================================ #
function tree.create {
    local var="${1:?""}"

    bash.is_var_set "$var" && return 1
    eval "$var=\"ROOT:\""
}


# ================ Function: tree.delete_node ================================ #
# ============================================================================ #
function tree.delete_node {
:
}

# ================ Function: tree.node_exists ================================ #
# ============================================================================ #
function tree.node_exists {
    local tree="${1:?""}"
    local node="${2:?""}"
}

# ================ Function: yum.get_package_deps ============================ #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function yum.get_package_deps {
    local package="${1:?"No package to 'get_package_dependencies'!"}"
    printf "%s" "$(repoquery --requires --resolve "$package")"
}


# ================ Function: yum.get_all_package_deps  ======================= #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function yum.get_all_package_deps {
    local package="${1:?"No package to 'get_package_dependencies'!"}"

    local -a final_deps
    local -a tmp_array
    readarray -t final_deps <<< "$(yum.get_package_deps "$package")"
    local index=0
    while true; do

        lstop="$((${#final_deps[@]}-1))"
        [[ $lstop -le $index ]] && break

        for ((i=$index; i<=$lstop; i++)); do
            package="${final_deps[$i]}"

            readarray -t tmp_array <<< "$(yum.get_package_deps "$package")"
            [[ ${tmp_array[@]} != "" ]] && array.join "final_deps" "tmp_array"
            index=$(($index+1))
        done

        array.remove_duplicates "final_deps"

    done

    array.dump_values "final_deps"
}

# ================ Function: yum.is_package_installed ======================== #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function yum.is_package_installed {
:
}

# ================ Function: yum.list_package_contents ======================= #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function yum.list_package_contents {
:
}

# ================ Function: yum.update_repo ================================= #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function yum.update_repo {
:
}


# Common setup
# Make sure 'LOG_FD' is not in use
[[ -n ${LOG_FD+x} ]] && printf "%s\n" "DO NOT use variable 'LOG_FD', as your values will be overwritten! This variable is reserved!"
exec {LOG_FD}>&1

trap exec.get_caller EXIT
