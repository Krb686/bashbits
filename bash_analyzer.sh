#!/bin/bash

# Variables
LOG_FLAG=1
ERROR_FLAG=1
DEBUG_FLAG=1
# ------------
BUILD_STRING=1
LINENUM=1
STATE="init"
STR=

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
            print_log "e" "Bash functions file not found!";;
    esac

    builtin exit "$CODE"
}

# ================ Function: main ================ #
# Main entrypoint                                  #
# ================================================ #
function main {
    trap exit EXIT

    parse_loop "$1"
}

# ================ Function: parse_loop ================ #
# Parsing loop                                           #
# ====================================================== #
function parse_loop {
    # Main loop
    while read -r -n1 char; do

        if [[ $char == $'\n' ]]; then
            printf "yes, char is newline\n"
        fi

        case $char in
            "#")
                [[ "$STATE" == "norm" ]] && { STATE="comment"; };; #printf "Now inside comment at line: $LINENUM!\n"; };;
            "")
                [[ "$STATE" == "comment" ]] && { STATE="norm"; } #printf "Now inside norm!\n"; }
                LINENUM=$(($LINENUM+1))
                printf "Ater inc, linenum = $LINENUM\n";;
        esac

        [ $BUILD_STRING -eq 1 ] && STR+=$char

  #      printf "%s\n" "$STR"
        case $STR in
            "#!/bin/bash")
                STR=
                printf "Got shebang!\n"
                STATE="norm";;
            "function")
                printf "Found 'function'\n"
                ;;
            "")
                STR=
                printf "Got newline!\n"
        esac
    done <<< "$(<${1:?'No file!'})"
}

main "$1"



