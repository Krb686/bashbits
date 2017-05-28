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
__state="normal"
__next_state=""
declare -a __state_array=( $__state )
STR=
STRING=
COMMENT=
STR_ESCAPE="off"
QUOTE_CHECK="off"
CAPTURE=""
LINE=1

STATE_LVL=-1
STATE_EXIT_CHECK="off"
QUOTE_TRACKER=()


# Exit codes
EXIT_NO_BASH_FUNCS=1
EXIT_BAD_ARGS=2


declaration_text=""

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

    main
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


function get_previous_state {
    local num=${1:?"No num provided!"}
    local previous_state=""

    while [[ $num -gt 0 ]]; do
        array.pop "__state_array" "previous_state"
        num=$(( $num - 1 ))
    done
    echo "$previous_state"
}


# ================ Function: parse_loop ================ #
# Parsing loop                                           #
# ====================================================== #
function parse_loop {
    # Main loop

    IFS=
    STR=
    while read -rN1 char; do
    # State Machine
    # The next state is a function of the current state and current character
        case "$__state" in
            "normal")
                [[ $char == '#' ]] && __next_state="comment"
                [[ $char == '`' ]] && __next_state="command-backtick"
                [[ $char == "\$" ]] && __next_state="command-expansion-check"
                [[ $char == "'" ]] && __next_state="string-single"
                [[ $char == '"' ]] && __next_state="string-double"
                [[ $char == '\' ]] && __next_state="command-esc-check"
                [[ $char == '!' ]] && __next_state="history-expansion"
                [[ $char == '(' ]] && __next_state="command-subshell-list"
                [[ $char == '{' ]] && __next_state="command-group"
                [[ $char == '[' ]] && __next_state="test"
                echo $char | grep -Pq '[a-zA-Z0-9_]' && __next_state="declaration"
                ;;
            "command-backtick")
                echo $char | grep -q $'`' && { __next_state="previous"; previous=1; }
                ;;
            "command-expansion-check")
                echo $char | grep -q $'\'' && __next_state="string-ansi"
                echo $char | grep -Pq '[a-zA-Z_]' && { __next_state="parameter-expansion-simple"; }
                ;;
            "command-subshell-list")
                echo $char | grep -q $'\n' && { __next_state="previous"; previous=1; };;
            "comment")
                CAPTURE+="$char"
                [[ $char == $'\n' ]] && { __next_state="previous"; previous=1; }
                ;;
            "declaration")
                [[ $char == "=" ]] && { __next_state="declaration-variable"; declaration_text=""; }
                if [[ $char == " " ]]; then
                    [[ $declaration_text == "function" ]] && { __next_state="declaration-function"; declaration_text=""; continue; }
                    [[ $declaration_text != "function" ]] && { __next_state="declaration-command"; declaration_text=""; continue; }
                fi
                ;;
            "declaration-command")
                [[ $char == $'\n' ]] && { __next_state="previous"; previous=2; }
                ;;
            "declaration-function")
                [[ $char == $'\n' ]] && __next_state="function-body"
                ;;
            "declaration-variable")
                [[ $char == " " || $char == $'\n' ]]   && { __next_state="previous"; previous=2; }
                ;;
            "parameter-expansion-simple")
                echo $char | grep -q ' ' && { __next_state="previous"; previous=2; }
                ;;
            "string-ansi")
                echo $char | grep -q $'\'' && { __next_state="previous"; previous=2; }
                ;;
            "string-single")
                echo $char | grep -q $'\'' && { __next_state="previous"; previous=1; }
                ;;
           "string-double")
               echo $char | grep -q $'"' && { __next_state="previous"; previous=1; }
                ;;
        esac


    


    # assign the new state
    if [[ "$__next_state" != "" ]]; then
	if [[ "$__next_state" == "previous" ]]; then
            print.debug "----------------"
            print.debug "l: $LINE - $__state ----> $__next_state"
            

            while [[ $previous -gt 0 ]]; do
                array.drop "__state_array"
                previous=$(( $previous - 1 ))
            done
            array.len "__state_array" "len"
            __state="${__state_array[$(($len-1))]}"
            __next_state=""
            array.dump_values "__state_array"
	else
            # Output from previous capture
            if [[ "$__state" == "comment" ]]; then
                CAPTURE="${CAPTURE:0:$(( ${#CAPTURE} - 1 ))}"
                #echo "L: $LINE - CAPTURE = $CAPTURE"
            fi

            # Reset capture
            CAPTURE=""

            # Setup before next capture
            if [[ "$__next_state" == "comment" ]]; then
                CAPTURE+="#"
            fi

            print.debug "----------------"
            print.debug "l: $LINE - $__state ----> $__next_state"
            
	    array.push "__state_array" "$__next_state"

	    #array.dump_values "__state_array"
            __state=$__next_state
            __next_state=""
            array.dump_values "__state_array"

	fi
    fi


    case "$__state" in
        "declaration")
            declaration_text+=$char
            ;;

    esac

    if [[ "$char" == $'\n' ]]; then
        LINE=$(( $LINE + 1 ))
    fi

    # special exit
    [[ $LINE -eq 42 ]] && exit 0

    done <<< "$(<$TARGET)"
}

init "$@"
