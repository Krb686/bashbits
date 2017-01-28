#!/bin/bash

# ======== Function Descriptions ======== #
# array
#     - array.contains_element          Check if an array contains a key - value pair
#     - array.contains_key		Check if an array contains a key
#     - array.contains_value		Check if an array contains a value
#     - array.delete_by_key		Delete element from array specified by key
#     - array.delete_by_value		Delete all elements from array specified by value
#     - array.dump_keys			Print out all array keys
#     - array.dump_values		Print out all array values
#     - array.get_by_key		Get single array element specified by key
#     - array.get_by_value		Get all array elements specified by value
#     - array.get_keys			Get all array keys
#     - array.get_values		Get all array values
#     - array.is_array			Check if variable is an array
#     - array.is_associative		Check if array is associative type
#     - array.is_standard		Check if array is standard typr
#     - array.join			Join 2 arrays.  Elements of 2nd array merged into 1st array.
#     - array.len			Return length of an array
#     - array.pop			Remove last element of a standard array
#     - array.push			Add element to the end of a standard array
#     - array.remove_duplicates		Remove duplicate entries
#     - array.set_element		Set an element of an array, by specifying key and value
#     - array.split			
# bash
#     - bash.requires
#     - bash.is_var_ro
#     - bash.is_var_set
#     - bash.var_contains_attr
# exec
#     - exec.exec_locked
#     - exec.get_caller
#     - exec.is_call_internal
#     - exec.is_locked
# file
#     - file.despace_name
#     - file.wait_for_file
# io
#     - io.is_fd_term
#     - io.is_fd_valid
# print
#     - print.debug
#     - print.error
#     - print.info
#     - print.log
#     - print.status
# string
#     - string.colorize
#     - string.contains
#     - string.is_alpha
#     - string.is_alphanum
#     - string.is_num
# tree
#     - tree.add_node
#     - tree.create
#     - tree.delete_node
#     - tree.node_exists
# yum
#     - yum.get_package_deps
#     - yum.get_all_package_deps
#     - yum.is_package_installed
#     - yum.list_package_contents
#     - yum.update_repo


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


# ================ Function: array.contains_element ========================== #
# Description:                                                                 #
#     Check if an array contains an element (key-value pair)                   #
# Usage:                                                                       #
#     array.contains_element <array> <key> <value>                             #
# Return Codes:                                                                #
#     0 if array contains the <key> - <value> pair element                     #
#     1 if array does not contain the <key><value> element.                    #
#     2 if <array_name> is not an array                                        #
# Order:                                                                       #
# ============================================================================ #
function array.contains_element {
    local array_name="${1:?"Usage: array.contains_element <array> <key> <value>"}"
    local key="${2:?"No key "}"
    local val="${3:?""}"

    array.is_array "$array_name" || return 2

    array.contains_key "$array_name" "$key" || return 1
    array.get_by_key "$array_name" "$key" "retval"
    [[ "$retval" == "$val" ]] && return 0 || return 1
}

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

    while read -r el; do
        [[ "$el" == "$key" ]] && return 0
    done <<< "$keys"
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
#     Delete element from array indexed by <key>                               #
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

    local keys="$(array.get_keys "$array_name")"

    local val_found=0
    local arraystring=""
    while read -r key; do
        array.get_by_key "$array_name" "$key" "retval"
        if [[ "$retval" == "$val" ]]; then
            val_found=1
        else
            arraystring+="[\"$key\"]=\"$retval\" "
        fi
    done <<< "$keys"

    if [[ $val_found -eq 1 ]]; then
        eval "$array_name=($arraystring)"
    else
        return 1
    fi
}

# ================ Function: array.dump_keys ================================= #
# Description:                                                                 #
#     Dump array keys to stdout.                                               #
# Usage:                                                                       #
#     array.dump_keys <array_name>                                             #
# Return Codes:                                                                #
#     0 if successful                                                          #
#     1 if <array_name> is not an array                                        #
# Order:                                                                       #
# ============================================================================ #
function array.dump_keys {
    local array_name="${1:?"No array to 'array.dump_keys'!"}"

    array.is_array "$array_name" || return 1
    while read -r el; do
        printf "%s\n" "$el"
    done <<< "$(array.get_keys "$array_name")"
}

# ================ Function: array.dump_values =============================== #
# Description:                                                                 #
#     Dump array values to stdout.                                             #
# Usage:                                                                       #
#     array.dump_values <array_name>                                           #
# Return Codes:                                                                #
#     0 if successful                                                          #
#     1 if <array_name> is not an array                                        #
# Order:                                                                       #
# ============================================================================ #
function array.dump_values {
    local array_name="${1:?"No array_name provided to 'array.dump_values'!"}"

    array.is_array "$array_name" || return 1
    while read -r el; do
        printf "%s\n" "$el"
    done <<< "$(array.get_values "$array_name")"
}

# ================ Function: array.get_by_key ================================ #
# Description:                                                                 #
#     Return value indexed by <key> indirectly from array <array_name>         #
# Usage:                                                                       #
#     array.get_by_key <array_name> <key> <retval>                             #
# Return Codes:                                                                #
#     0 if successful                                                          #
#     1 if <array_name> did not contain <key>                                  #
#     2 if <array_name> is not an array                                        #
# Order:                                                                       #
# ============================================================================ #
function array.get_by_key {
    local array_name="${1:?"No array_name provided to 'array.get_by_key'!"}"
    local key="${2:?"No key provided to 'array.get_by_key'!"}"
    local __retval="${3:?"No retval variable provided!"}"

    array.is_array "$array_name" || return 2
    array.contains_key "$array_name" "$key" || return 1
    local tmp="$array_name[\"$key\"]"
    #echo "retval = $__retval"
    #echo "tmp1 = $tmp"
    eval "$__retval=\"${!tmp}\""
    #echo "tmp2 = $tmp"
}

# ================ Function: array.get_by_value ============================== #
# Description:                                                                 #
#     Return all keys with indexing <value> indirectly from array <array_name> #
# Usage:                                                                       #
#     array.get_by_value <array_name> <value>                                  #
# Return Codes:                                                                #
#     0 if at least 1 key was returned                                         #
#     1 if no keys index the specified <value>                                 #
#     2 if <array_name> is not an array                                        #
# Order:                                                                       #
# ============================================================================ #
function array.get_by_value {
    local array_name="${1:?"No array_name provided to 'array.get_by_value'!"}"
    local value="${2:?"No value provided to 'array.get_by_value'!"}"
    local rval_name="${3:?"No rval provided!"}"
    

    #declare -g "$rval_name"
    #eval "$rval_name=0"
    #return 0
    
    #bash.is_var_set "$rval_name" || declare "$rval_name"
    
    #local dvi="$(bash.gen_dvi "__rval")"            # get dynamic variable index
    #local __rval$dvi="${3:?"No retval provided!"}"  # define dynamic variable, which is 1st layer of indirection
    #local rvi="__rval$dvi"                          # define rvi (retval indirect), 2nd layer of indirection

    # rvi -> __rval1 --> rval --> 5
    #set -x
    #eval "declare ${!rvi}=\"\""                     # double indirection - clear the actual value
    #set +x

    

    array.is_array "$array_name" || return 2
    array.contains_value "$array_name" "$value" || return 1

    local keys="$(array.get_keys "$array_name")"

    local val_found=0
    while read -r key; do
        array.get_by_key "$array_name" "$key" "rval2"
        if [[ "$rval2" == "$value" ]]; then
            if [[ $val_found -eq 0 ]]; then
                unset "$rval_name"
                val_found=1
                eval "$rval_name+=\"${key}\""
            else
                eval "${rval_name}+=$'\n'\"${key}\""
            fi
        fi
    done <<< "$keys"
    [[ "$val_found" -eq 1 ]]

}

# ================ Function: array.get_keys ================================== #
# Description:                                                                 #
#     Return all keys from <array>                                             #
#     Keys are returned as a newline separated list                            #
# Usage:                                                                       #
#     array.get_keys <array>                                                   #
# Return Codes:                                                                #
#     0 if successful                                                          #
#     1 if <array_name> is not an array                                        #
# Order:                                                                       #
# ============================================================================ #
function array.get_keys {
    local array_name="${1:?"No array to 'array.get_keys'!"}"

    array.is_array "$array_name" || return 1

    # TODO - see if there is a better way to do this
    local loopStr="for key in \"\${!$array_name[@]}\"; do
                     printf \"%s\n\" \"\$key\"
                   done"

    eval "$loopStr"
}



# ================ Function: array.get_values ================================ #
# Description:                                                                 #
#     Return all values from <array>                                           #
#     Values are returned as a newline separated list                          #
# Usage:                                                                       #
#     array.get_values <array>                                                 #
# Return Codes:                                                                #
#     0 if successful                                                          #
#     1 if <array_name> is not an array                                        #
# Order:                                                                       #
# ============================================================================ #
function array.get_values {
    local array_name="${1:?"Usage: array.get_values <array>"}"

    array.is_array "$array_name" || return 1

    # TODO - see if there is a better way to do this
    local loopStr="for val in \"\${$array_name[@]}\"; do
                       printf \"%s\n\" \"\$val\"
                   done"

    eval "$loopStr"
}

# ================ Function: array.is_array ================================== #
# Description:                                                                 #
#     Check if a variable is an array                                          #
# Usage:                                                                       #
#     array.is_array <var>                                                     #
# Return Codes:                                                                #
#     0 if <var> is an array                                                   #
#     1 if <var> is not an array                                               #
# Order:                                                                       #
# ============================================================================ #
function array.is_array {
    local var="${1:?"No var to 'is_array'!"}"

    bash.var_contains_attr "$var" "a" && return 0
    bash.var_contains_attr "$var" "A" && return 0
    return 1
}


# ================ Function: array.is_associative ============================ #
# Description:                                                                 #
#     Check if an array is associative                                         #
# Usage:                                                                       #
#     array.is_associative <array>                                             #
# Return Codes:                                                                #
#     0 if <var> is an associative array                                       #
#     1 if <var> is not an associative array                                   #
# Order:                                                                       #
# ============================================================================ #
function array.is_associative {
    local array_name="${1:?"Usage: array.is_associative <array>"}"
    bash.var_contains_attr "$array_name" "A"  && return 0 || return 1
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
#     Join elements from <array1> into <array2> (left to right)                #
# Usage:                                                                       #
#     array.join <array1> <array2>                                             #
# Return Codes:                                                                #
#     3 if <array_name1> is not an array.                                      #
#     2 if <array_name2> is not an array.                                      #
#     1 if array types do not match.                                           #
# Order:                                                                       #
# ============================================================================ #
function array.join {
    local array_name1="${1:?"No array1 to 'join_arrays'!"}"
    local array_name2="${2:?"No array2 to 'join_arrays'!"}"

    array.is_array "$array_name1" || return 3
    array.is_array "$array_name2" || return 2

    array.is_standard "$array_name1" && array.is_standard "$array_name2" && local mode="standard"
    array.is_associative "$array_name1" && array.is_associative "$array_name2" && local mode="associative"

    [[ "$mode" != "standard" && "$mode" != "associative" ]] && return 1

    if [[ "$mode" == "standard" ]]; then
        while read -r el; do
            array.push "$array_name2" "$el"
        done <<< "$(array.get_values "$array_name1")"
    elif [[ "$mode" == "associative" ]]; then
        while read -r key; do
            array.get_by_key "$array_name1" "$key" "retval"
            array.set_element "$array_name2" "$key" "$retval"
        done <<< "$(array.get_keys "$array_name1")"
    fi
}

# ================ Function: array.len ======================================= #
# Description:                                                                 #
#     Return length of an array                                                #
# Usage:                                                                       #
#     array.len <array>                                                        #
# Return Codes:                                                                #
#     0 if the array length is returned successfully                           #
#     1 if <array_name> is not an array                                        #
# Order:                                                                       #
# ============================================================================ #
function array.len {
    local array_name="${1:?""}"

    array.is_array "$array_name" || return 1

    eval "echo \${#$array_name[@]}"
}


# ================ Function: array.pop ======================================= #
# Description:                                                                 #
# Usage:                                                                       #       
# Return Codes:                                                                #
# Order:
# ============================================================================ #
function array.pop {
    local array_name="${1:?""}"
    local popval="${2:?"No popval provided!"}"

    array.is_array "$array_name" || return 2
    array.is_standard "$array_name" || return 1

    local last_key=$(( $(array.len "$array_name" ) - 1 ))
    array.get_by_key "$array_name" $last_key "retval"
    eval "$popval=$retval"

    array.delete_by_key "$array_name" $last_key
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
    local aname="${1:?"Usage: array.push <array> <el>"}"
    local el="${2:?"No element to 'add_array_element'!"}"

    array.is_array "$aname" || return 2
    array.is_standard "$aname" || return 1

    string.contains "$el" $'\n'
    if [[ $? -eq 0 ]]; then
        while read -r s_el; do
            array.push "$aname" "$s_el"
        done <<< "$el"
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
function array.set_element {
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

# ================ Function: bash.generate_dynamic_var ======================= #
# Description:
# Usage:
# Return Codes:
# Order:
# ============================================================================ #
function bash.gen_dvi {
    local prefix="${1:?"No prefix provided!"}"

    

    local highest="$(declare -p | grep "$prefix" | awk -F'[ =]+' '{print $3}' | grep -Po "(?<=$prefix)[0-9]+" | sort -n | tail -n 1)"
    printf $(( $highest + 1 ))
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
