#!/bin/bash

# ================ is_alpha ================ #
# ========================================== #
function is_alpha {
    grep -Eoq "^[a-zA-Z]+$" <<< "${1:?'No argument to is_alpha!'}"
}

# ================ is_num ================ #
# ======================================== #
function is_num {
    grep -Eoq "^[0-9]+$" <<< "${1:?'No argument to is_num!'}"
}

# ================ is_alphanum ================ #
# ============================================= #
function is_alphanum {
    grep -Eoq "^[0-9a-zA-Z]+$" <<< "${1:?'No argument to is_alphanum!'}"
}

# ================ is_fd_valid ================ #
# ============================================= #
function is_fd_valid {
    { >&"${1:?'No argument to is_fd_valid!'}"; } 2>/dev/null
}
