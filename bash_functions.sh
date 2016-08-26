#!/bin/bash

# ================ is_alpha ================ #
# ========================================== #
function is_alpha {
    grep -Eqo "^[a-zA-Z]+$" <<< "${1:?'No argument to is_alpha!'}"
}

# ================ is_num ================ #
# ======================================== #
function is_num {
    grep -Eqo "^[0-9]*.?[0-9]+$" <<< "${1:?'No argument to is_num!'}"
}

# ================ is_alphanum ================ #
# ============================================= #
function is_alphanum {
    grep -Eqo "^[0-9a-zA-Z]+$" <<< "${1:?'No argument to is_alphanum!'}"
}

# ================ is_fd_valid ================ #
# ============================================= #
function is_fd_valid {
    { >&"${1:?'No argument to is_fd_valid!'}"; } 2>/dev/null
}

# ================ Function: print_error ================ #
# Print error information                                 #
# ======================================================= #
function print_error {
    [[ "${ERROR_FLAG:-0}" -ne 0 ]] && print_spaced "[ ***** ERROR ***** ]: $1" 23
}

# ================ Function: print_spaced ================ #
# Print equispaced content                                 #
# ======================================================== #
function print_log {
    local TYPE="${1:?'No logtype specified! Must be i(info), d(debug), or e(error)!'}"
    [[ ! "$TYPE" =~ (i|d|e) ]] && printf "%s\n" "No logtype specified! Must be i(info), d(debug), or e(error)!" && return 1

    local STR="${2:?'No argument to print_log!'}"
    local R_OFF="${3:-0}"

    declare -A HEADERS=(["i"]="[ ------ info ----- ]: " ["d"]="[ ===== debug ===== ]: " ["e"]="[ ***** error ***** ]: ")

    is_fd_valid 3 || { printf "%s" "fd 3 is invalid!"; return 1; }

    which tput >&/dev/null || printf "%s" "$STR" >&3

    local WIDTH=$(($(tput cols)-$R_OFF))
    local HEADER="${HEADERS[$TYPE]}"
    STR="$HEADER""$STR"

    while [[ "${#STR}" -gt $WIDTH ]]; do
        printf "%s\n" "${STR:0:$WIDTH}">&3
        STR="$(printf ' %0.s' $(seq 1 ${#HEADER}))""${STR:$WIDTH+1:-1}"
    done

    printf "%s\n" "$STR"
}
