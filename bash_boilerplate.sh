#!/bin/bash

# Variables
LOG_FLAG=1
ERROR_FLAG=1
DEBUG_FLAG=1

# Exit codes
EXIT_NO_BASH_FUNCS=1

#Bash opts
set -euo pipefail

# Source bash functions
. "bash_functions.sh" || exit $EXIT_NO_BASH_FUNCS

# ================ Function: exit ======================== #
# Handle exit cases                                        #
# ======================================================== #
function exit {
    local CODE="${1:--1}"
    case "$CODE" in
        "$EXIT_NO_BASH_FUNCS")
            print_error "Bash functions file not found!"
            builtin exit "$EXIT_NO_BASH_FUNCS";;
    esac
}

# ================ Function: main ================ #
# Main entrypoint                                  #
# ================================================ #
function main {
    trap exit EXIT
}

main
