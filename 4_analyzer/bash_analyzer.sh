#!/bin/bash

# Variables
INFO_FLAG=1
ERROR_FLAG=1
DEBUG_FLAG=1

BASH_FUNCS="bash_funcs.sh"

DUMP_COMMENTS=0
DUMP_STRINGS=1
# ------------
BUILD_STR=1
LINENUM=1
__state="init"
__next_state=""
declare -a __state_array
STR=
STRING=
COMMENT=
STR_ESCAPE="off"
QUOTE_CHECK="off"

STATE_ARRAY=()
STATE_LVL=-1
STATE_EXIT_CHECK="off"
QUOTE_TRACKER=()


# Exit codes
EXIT_NO_BASH_FUNCS=1
EXIT_BAD_ARGS=2

# ================ Function: init ================ #
# ================================================ #
function init {
    #Bash opts
    set -u

    # Setup exit trap
    trap exit EXIT

    # Source bash functions
    . "$BASH_FUNCS" 2>/dev/null || exit $EXIT_NO_BASH_FUNCS

    arg_handler "$@"
}


# ================ Function: arg_handler ================ #
# ======================================================= #
function arg_handler {
    if [[ $# -eq 0 ]]; then
        exit "$EXIT_BAD_ARGS"
    else
        case "$1" in
            "--target")
                TARGET="${2:?"No target specified!"}"
        shift 2;;
            *)
                exit "$EXIT_BAD_ARGS";;
        esac
    fi

    main
}



# ================ Function: main ================ #
# Main entrypoint                                  #
# ================================================ #
function main {
    parse_loop
}

# ================ Function: exit ======================== #
# Handle exit cases                                        #
# ======================================================== #
function exit {
    local CODE="${1:--1}"
    case "$CODE" in
        "$EXIT_NO_BASH_FUNCS")
            printf "%s\n" "Bash functions file not found!";;
        "$EXIT_BAD_ARGS")
            print.error "Bad arguments!"
        print.usage;;
    esac

    builtin exit "$CODE"
}

# =============== Function: print.usage ================ #
# ====================================================== #
function print.usage {
    printf "%s\n" "Usage: bash_analyzer.sh <--target> <script>"
}


# ================ Function: parse_loop ================ #
# Parsing loop                                           #
# ====================================================== #
function parse_loop {
    # Main loop

    IFS=
    STR=
    while read -rN1 char; do
        #printf "%s" "${char}"

    # State Machine
    # The next state is a function of the current state and current character
        case "$__state" in
            "init")
                case "$char" in
                    $'\n')
                        __next_state="normal"
                        ;;
                    *)
                esac
                ;;
            "normal")
                case "$char" in
                    $'\'')
                        __next_state="string-single";;
                    $'"')
                        __next_state="string-double";;
                    $'`')
                        __next_state="command";; 
                    $'\\')
                        __next_state="command-esc-check";;
                    $'!')
                        __next_state="history-expansion";;
                    $'$')
                        __next_state="command-expansion-check";;
                    $'(')
		        __next_state="command-subshell-list";;
                    $'{')
			__next_state="command-group";;
                    $'[')
			__next_state="test-check";;
                esac    
                ;;
            "string-single")
                ;;
           "string-double")
                ;;
        esac

    # assign the new state
    if [[ "$__next_state" != "" ]]; then
	if [[ "$__next_state" == "previous" ]]; then
	    :
	else
	    array.push "__state_array" "$__next_state"
	    array.dump "__state_array"
            print.debug "change state --> $__next_state"
            __next_state=""
	fi
    fi
    done <<< "$(<$TARGET)"
}

init "$@"
