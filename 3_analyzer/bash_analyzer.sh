#!/bin/bash
# Goals
# - code flow
# - check variable reference validity
#   - know variable scope
#   - know variable 1st reference
#   - know variable declaration
# - dependencies (list builtin and external command calls)
# - code optimization
# - dynamic command dependency checking with traps
# - POSIX compliance
#   - suggestions to make compliant
# - bash version requirements

# ---- Objects ---- #
# - variables
# - functions
# - commands
#   - command
#   - args
# - control flow
# - comments


# ================ Function: init ================ #
# ================================================ #
function init {
    #Bash opts
    set -u

    # Setup exit trap
    trap exit EXIT

    declare -a __variables=()
    declare -a __variables_meta=()
    declare -a __functions=()
    declare -a __commands=()
    declare -a __controls=()
    declare -a __comments=()
    declare -a __comments_meta=()
    
    # Variables
    INFO_FLAG=1
    ERROR_FLAG=1
    DEBUG_FLAG=0
    
    BASH_FUNCS="bash_funcs.sh"
    
    DUMP_COMMENTS=0
    DUMP_STRINGS=1
    # ------------
    BUILD_STR=1
    LINENUM=1
    __check_declare=0
    __declare_opt=0
    __state="normal"
    __next_state=""
    declare -A __vars
    declare -A __vars_scope
    declare -a __state_array=( $__state )
    START=""
    END=""
    STR=
    STRING=
    COMMENT=
    STR_ESCAPE="off"
    QUOTE_CHECK="off"
    CAPTURE=""
    SKIP=0
    LINE=1
    TARGET=""
    
    STATE_LVL=-1
    STATE_EXIT_CHECK="off"
    QUOTE_TRACKER=()
    
    
    # Exit codes
    EXIT_NO_BASH_FUNCS=1
    EXIT_BAD_ARGS=2
    EXIT_NO_TARGET=3
    
    
    declaration_text=""

    # Source bash functions
    . "$BASH_FUNCS" 2>/dev/null || exit $EXIT_NO_BASH_FUNCS

    arg_handler "$@"

    main
    #report_comments
    report_variables
    #report_functions
}


# ================ Function: arg_handler ================ #
# ======================================================= #
function arg_handler {
    if [[ $# -eq 0 ]]; then
        exit "$EXIT_BAD_ARGS"
    else
        while [[ $# -gt 0 ]]; do
            case "$1" in
                "--target")
                    TARGET="${2:?"No target specified!"}" && shift 2;;
                "--start")
                    START="${2:?"No START line specified!"}" && shift 2
                    string.is_num "$START" || exit "$EXIT_BAD_ARGS";;
                "--end")
                    END="${2:?"No END line specified!"}" && shift 2
                    string.is_num "$END" || exit "$EXIT_BAD_ARGS";;
                *)
                    exit "$EXIT_BAD_ARGS";;
            esac
        done
    fi

    [[ -z "$TARGET" ]] && exit "$EXIT_NO_TARGET"
    LINE_TOTAL=$(get_last_line)
    [[ -z "$START" ]] && START=1
    [[ -z $END     ]] && END=$LINE_TOTAL
    print.debug "START = $START"
    print.debug "END = $END"
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
        "$EXIT_NO_TARGET")
            print.error "No target specified!"
            print.usage
            ;;
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
        print.info "l: $LINE/$LINE_TOTAL"

        if [[ $LINE -lt $START || $LINE -gt $END ]]; then
            if [[ "$char" == $'\n' ]]; then
                LINE=$(( $LINE + 1 ))
                print.debug "line = $LINE"
            fi
            continue
        fi
        # State Machine
        # The next state is a function of the current state and current character
        case "$__state" in
            "ampersand-check")
               if [[ $char == "&" ]]; then
                   __next_state="previous-normal"
               else
                   __next_state="previous" && previous=1
               fi
               ;;
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
                [[ $char == '}' ]] && __next_state="previous"; previous=2
                [[ $char == '[' ]] && __next_state="test-check"
                echo $char | grep -Pq '[a-zA-Z0-9_]' && __next_state="declaration"
                ;;
            "command-backtick")
                echo $char | grep -q $'`' && { __next_state="previous"; previous=1; }
                ;;
            "command-expansion-check")
                echo $char | grep -q $'\'' && __next_state="string-ansi"
                echo $char | grep -Pq '[a-zA-Z_]' && { __next_state="parameter-expansion-simple"; }
                ;;
            "command-opts")
                if [[ $char == $'\n' ]]; then
                    print.debug "OPT: $CAPTURE"
                    __next_state="previous-normal"

                    if [[ $__check_declare -eq 1 && $__declare_opt -eq 0 ]]; then
                        __check_declare=0
                        add_variable "${CAPTURE%%=*}"
                    fi
                    [[ $__declare_opt -eq 1 ]] && __declare_opt=0
                    CAPTURE=""
                elif [[ $char == " " ]]; then
                    if [[ $__check_declare -eq 1 && $__declare_opt -eq 0 ]]; then
                        __check_declare=0
                        add_variable "${CAPTURE%%=*}"
                    fi
                    print.debug "OPT: $CAPTURE"
                    [[ $__declare_opt -eq 1 ]] && __declare_opt=0
                    CAPTURE=""
                elif [[ $char == "=" ]]; then
                    __next_state="command-var"
                    add_variable "${CAPTURE%%=*}"
                    [[ $__check_declare -eq 1 ]] && __check_declare=0
                elif [[ $char == '"' ]]; then
                    __next_state="command-arg-string"
                elif grep -Pq '\-|\+' <<< $char; then
                    __declare_opt=1
                elif [[ $char == "|" ]]; then
                    __next_state="previous-normal"
                elif [[ $char == "&" ]]; then
                    __next_state="ampersand-check"
                else
                    CAPTURE+="$char"
                fi 
                ;;
            "command-arg-string")
                if [[ $char == $'\n' ]]; then
                    __next_state="previous-normal"
                elif [[ $char == '"' ]]; then
                    __next_state="previous"
                    previous=1
                fi
                ;;
            "command-group")
                [[ $char == ' ' ]] && __next_state="normal"
                ;;
            "command-var")
                if [[ $char == $'\n' ]]; then
                    __next_state="previous-normal"
                fi
                ;;
            "command-subshell-list")
                echo $char | grep -q $'\n' && { __next_state="previous"; previous=1; };;
            "comment")
                if [[ $char == $'\n' ]]; then
                    __next_state="previous"
                    previous=1
                    add_comment "$CAPTURE"
                else
                    CAPTURE+="$char"
                fi
                ;;
            # A declaration can be:
            # - defining a variable
            # - defining or calling a function
            # - calling a command
            "control-case")
                if [[ $char == $'\n' ]]; then
                    __next_state="previous-normal"
                fi
                ;;
            "control-for")
                if [[ $char == $'\n' ]]; then
                    __next_state="previous-normal"
                fi
                ;;
            "control-if")
                if [[ $char == $'\n' ]]; then
                    __next_state="previous-normal"
                fi
                ;;
            "control-until")
                if [[ $char == $'\n' ]]; then
                    __next_state="previous-normal"
                fi
                ;;
            "declaration")
                if [[ $char == "+" ]]; then
                    __next_state="plus-check"
                elif [[ $char == "=" ]]; then
                     __next_state="declaration-variable"
                     add_variable "$declaration_text"
                     declaration_text=""
                elif [[ $char == " " ]]; then
                    print.debug "decl_text = $declaration_text"
                    if [[ $declaration_text == "function" ]]; then 
                        __next_state="declaration-function"
                        print.debug "function = $declaration_text"
                        array.push "__functions" "$declaration_text"
                    elif [[ $declaration_text == "case" ]]; then
                        __next_state="control-case"
                    elif [[ $declaration_text =~ "if"|"elif" ]]; then
                        __next_state="control-if"
                    elif [[ $declaration_text == "until" ]]; then
                        __next_state="control-until"
                    elif [[ $declaration_text == "for" ]]; then
                        __next_state="control-for"
                    else
                        __next_state="command-opts"

                        if [[ "$declaration_text" =~ "declare"|"typeset"|"local" ]]; then
                            __check_declare=1
                        fi
                    fi
                    declaration_text=""
                fi
                [[ $char == $'\n' ]] && { __next_state="previous"; previous=1; declaration_text=""; }
                ;;
            "declaration-command")
                [[ $char == $'\n' ]] && { __next_state="previous"; previous=2; }
                ;;
            "declaration-function")
                [[ $char == '{' ]] && __next_state="function-body"
                ;;
            "declaration-variable")
                [[ $char == " " || $char == ";" || $char == $'\n' ]] && { __next_state="previous"; previous=2; }
                ;;
            "function-body")
                [[ $char == $'\n' ]] && __next_state="normal"
                ;;
            "parameter-expansion-simple")
                echo $char | grep -q ' ' && { __next_state="previous"; previous=2; }
                ;;
            "plus-check")
                if [[ $char == "=" ]]; then
                    __next_state="declaration-variable"
                    add_variable "$declaration_text"
                    declaration_text=""
                elif [[ $char == " " ]]; then
                    __next_state="previous-normal"
                else
                    __next_state="previous" && previous=1
                fi
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
            "test-check")
                [[ $char == '[' ]] && __next_state="test-double"
                [[ $char == ' ' ]] && __next_state="test-single"
                [[ $char == ']' ]] && __next_state="previous"; previous=1
                ;;
            "test-single")
                ;;
            "test-double")
                [[ $char == ']' ]] && __next_state="previous"; previous=1
                [[ $char == "'" ]] && __next_state="string-single"
                [[ $char == '"' ]] && __next_state="string-double"
                ;;
        esac


        # assign the new state
        if [[ "$__next_state" != "" ]]; then
            if [[ "$__next_state" == "previous" ]]; then
                print.debug "l: $LINE - $__state ----> $__next_state"

                while [[ $previous -gt 0 ]]; do
                    array.drop "__state_array"
                    previous=$(( $previous - 1 ))
                done
                array.len "__state_array" "len"
                __state="${__state_array[$(($len-1))]}"
                __next_state=""
            elif [[ "$__next_state" == "previous-normal" ]]; then
                print.debug "looping back to last 'normal' on state stack"
                until [[ "$__state" == "normal" ]]; do
                    array.drop "__state_array"
                    array.len "__state_array" "len"
                    __state="${__state_array[$(($len-1))]}"
                done
                print.debug "left at state = $__state" 
            else
                # Output from previous capture
                if [[ "$__state" == "comment" ]]; then
                    CAPTURE="${CAPTURE:0:$(( ${#CAPTURE} - 1 ))}"
                    echo "hi from old code"
                    #echo "L: $LINE - CAPTURE = $CAPTURE"
                fi

                # Reset capture
                CAPTURE=""

                # Setup before next capture
                if [[ "$__next_state" == "comment" ]]; then
                    CAPTURE+="#"
                fi

                print.debug "l: $LINE - $__state ----> $__next_state"
                
                array.push "__state_array" "$__next_state"

                #array.dump_values "__state_array"
                __state=$__next_state
                __next_state=""

            fi
        fi


        case "$__state" in
            "declaration")
                declaration_text+=$char
                ;;

        esac

        if [[ "$char" == $'\n' ]]; then
            LINE=$(( $LINE + 1 ))
            print.debug "line = $LINE"
        fi

        # special exit
        #[[ $LINE -eq 150 ]] && exit 0

    done <<< "$(<$TARGET)"
}

function report_comments {
    echo "-------- Comments --------"
    for ((i=0;i<${#__comments[@]};i++)); do
        echo "${__comments_meta[$i]}: ${__comments[$i]}"
    done
}

function report_variables {
    echo "-------- Variables --------"
    for ((i=0;i<${#__variables[@]};i++)); do
        echo "${__variables_meta[$i]}: ${__variables[$i]}"
    done
}

function get_last_line {
    cat "$TARGET" | wc -l
}

function report_functions {
    :
}

function add_comment {
    local cmt="${1:?""}"
    print.debug "comment = $cmt"
    array.push "__comments" "$cmt"
    array.push "__comments_meta" "$LINE"
}

function add_variable {
    local var="${1:?""}"
    print.debug "variable = $var"
    array.push "__variables" "$var"
    array.push "__variables_meta" "$LINE"
}


init "$@"
