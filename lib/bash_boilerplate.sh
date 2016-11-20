#!/bin/bash

# Variables
LOG_FLAG=1
ERROR_FLAG=1
DEBUG_FLAG=1

# Exit codes
EXIT_NO_BASH_FUNCS=1


# ================ Function: main ================ #
# Main entrypoint                                  #
# ================================================ #
function main {

    # Source bash functions
    . "bash_functions.sh" || exit $EXIT_NO_BASH_FUNCS

    #Bash opts
    set -euo pipefail

    # Setup fd 3
    exec 3>&1

    # Trap all exit signals
    trap exit EXIT

    arg_handler $*
}

# ================ Function: arg_handler ================ #
# Handle arguments                                        #
# ======================================================= #
function arg_handler {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            *)
                ;;
        esac
    done
}

# ================ Function: exit ======================== #
# Handle exit cases                                        #
# ======================================================== #
function exit {
    local CODE="${1:--1}"
    case "$CODE" in
        "$EXIT_NO_BASH_FUNCS")
            print_error "Bash functions file not found!";;
    esac

    builtin exit "$CODE"
}


main $*
