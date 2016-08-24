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
function print_spaced {
    printf "%s\n" "$1"
}
