#!/bin/bash

# Variables
LOG_FLAG=1
ERROR_FLAG=1
DEBUG_FLAG=1

DUMP_COMMENTS=0
DUMP_STRINGS=1
# ------------
BUILD_STR=1
LINENUM=1
STATE="init"
STR=
STRING=
COMMENT=
STR_ESCAPE="off"

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

    local file="${1:?'Need to specify file!'}"

    parse_loop "$1"
}

# ================ Function: parse_loop ================ #
# Parsing loop                                           #
# ====================================================== #
function parse_loop {
    # Main loop

#:<<'#b'
    IFS=
    STR=
    while read -rN1 char; do
        #printf "%s" "${char}"

        # Always turn off after a single char
        if [[ "$STR_ESCAPE" == "trigger" ]]; then
            STR_ESCAPE="on"
        elif [[ "$STR_ESCAPE" == "on" ]]; then
            STR_ESCAPE="off"
        fi

        case $char in
            "#")
                [[ "$STATE" == "norm" ]] && { STATE="comment"; } #printf "Now inside comment at line: $LINENUM!\n"; };;
                ;;
            "\\")
                if [[ "$STATE" == "str_double" ]] && [[ "$STR_ESCAPE" == "off" ]]; then
                    #printf "%s\n" "Turning STR_ESCAPE to trigger at lineno $LINENUM"
                    STR_ESCAPE="trigger"
                fi
                ;;
            "\"")
                if [[ "$STATE" == "norm" ]]; then
                    #printf "%s\n" "Entering state - str_double - at lineno $LINENUM"
                    STATE="str_double"
                elif [[ "$STATE" == "str_double" ]] && [[ "$STR_ESCAPE" == "off" ]]; then
                    STATE="norm"
                    [[ "$DUMP_STRINGS" -eq 1 ]] && printf "%s\n" "STRING = $STRING, at lineno $LINENUM"
                     STRING=
                fi
                ;;
            $'\n')
                if [[ "$STATE" == "comment" ]]; then
                    STATE="norm"
                    [[ "$DUMP_COMMENTS" -eq 1 ]] && printf "%s\n" "COMMENT = $COMMENT, at lineno $LINENUM"
                    COMMENT=
                fi
                LINENUM=$(($LINENUM+1))

                ;;
 #printf "Now inside norm!\n"; }
            "")
                                #LINENUM=$(($LINENUM+1))
                #printf "Ater inc, linenum = $LINENUM\n";;
        esac

        
        [[ $BUILD_STR -eq 1 ]] && STR+="$char" || STR=
        [[ "$STATE" == "comment" ]] && COMMENT+="$char"
        [[ "$STATE" == "str_double" ]] && STRING+="$char"

        case "$STR" in
            "#!/bin/bash")
                printf "%s\n" "got shebang!"
                STATE="norm"
                STR=
                ;;
        esac

    done <<< "$(<${1:?'No file!'})"
#b
}

main $*










