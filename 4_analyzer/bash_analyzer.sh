#!/bin/bash

# Variables
LOG_FLAG=1
ERROR_FLAG=1
DEBUG_FLAG=1

BASH_FUNCS="/home/kevin/gitrepos/bashbits/bash_funcs.sh"

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
    set -euo pipefail

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

#:<<'#b'
    IFS=
    STR=
    while read -rN1 char; do
        #printf "%s" "${char}"

        # If QUOTE_CHECK is on, need to check if truly entering a string, or an expansion
        if [[ "$QUOTE_CHECK" == "on" ]]; then
            case "$char" in
                "\$")
                    STATE_LVL=$(($STATE_LVL++))
                    STATE_EXIT_CHECK="on"
                    STATE_ARRAY[$STATE_LVL]="expansion"
                    QUOTE_TRACKER[$STATE_LVL]=""
                    ;;
                *)
                    if [[ "$STATE_EXIT_CHECK" == "on" ]]; then
                        # Remove element
                        STATE_ARRAY=("${STATE_ARRAY[@]:0:$((${#STATE_ARRAY}-1))}")
                        STATE_LVL=$(($STATE_LVL-1))
                    else
                        STATE_LVL=$(($STATE_LVL++))
                        STATE_EXIT_CHECK="on"
                        STATE_ARRAY[$STATE_LVL]="str_double"
                        QUOTE_TRACKER[$STATE_LVL]=""
                    fi
                    ;;
            esac

            QUOTE_CHECK="off"
        fi

        # Always turn off after a single char
        if [[ "$STR_ESCAPE" == "trigger" ]]; then
            STR_ESCAPE="on"
        elif [[ "$STR_ESCAPE" == "on" ]]; then
            STR_ESCAPE="off"
        fi

        # Expansions within strings
	#	Look for placement of 2 double quotes ""
	#	If before expansion, then concatenation
	#	If after expansion, then nesting

        # If quote level = -1					up level
        # If leading sig char = (				up level
        # If leading sig char is ", then find next double quote in same sub level. If another double quote follows w/o level decrement, then nesting.
        # If decrement before finding quote at entry level, then it is concatenation

        # So basically, 0 quote = concatenation 
        # 		1 quote = 
        # 		2 quote = substitution

#			echo "   hi"$(v1)$(v2)$(var)" $()   "		# Not true
        #v2="there"
        #v1="$(echo "$(echo "hey - "$(echo "$V2")"" | grep -Eo "e")")"

        #v3="$()"$HELLO

        case $char in
            "#")
                [[ "$STATE" == "norm" ]] && { STATE="comment"; } #printf "Now inside comment at line: $LINENUM!\n"; };;
                ;;
            "\$")
                ;;
            "\\")
                if [[ "$STATE" == "str_double" ]] && [[ "$STR_ESCAPE" == "off" ]]; then
                    #printf "%s\n" "Turning STR_ESCAPE to trigger at lineno $LINENUM"
                    STR_ESCAPE="trigger"
                fi
                ;;
            "\"")
                if [[ "$STR_ESCAPE" == "off" ]]; then
                    QUOTE_CHECK="on"
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
        [[ "$STATE" == "comment" ]] && STR_TRACKER[-1]+="$char"
        [[ "$STATE" == "str_double" ]] && STRING+="$char"

        if [[ "${#QUOTE_TRACKER[@]}" -gt 0 ]]; then
            for i in "${!QUOTE_TRACKER[@]}"; do
                QUOTE_TRACKER[$i]+="$char"
            done
        fi

        case "$STR" in
            "#!/bin/bash")
                printf "%s\n" "got shebang!"
                STATE="norm"
                STR=
                ;;
        esac

    done <<< "$(<$TARGET)"


#b
}

function push_state {
    local ADD="${1:?"No state to 'push_state'!"}"
    STATE_LEVEL=$(($STATE_LEVEL+1))
    STATE_ARRAY[$STATE_LEVEL]="$ADD"
}

function pop_state {
    delete_element_by_key "STATE_ARRAY" "$STATE_LEVEL"
    STATE_LEVEL=$(($STATE_LEVEL-1))
}

init "$@"
