#!/bin/bash


. bash_functions.sh


function somefunc {
    print_log "i" "This is just a very long string that is ideally going to test the capability of the print_space function which is defined in the bash_functions file and should provide for some pretty printing" 1
    
    print_log "d" "This is just a very long string that is ideally going to test the capability of the print_space function which is defined in the bash_functions file and should provide for some pretty printing" 1
    
    print_log "e" "This is just a very long string that is ideally going to test the capability of the print_space function which is defined in the bash_functions file and should provide for some pretty printing" 1

    echo "hi"
}

VAL="$(somefunc)"

echo "VAL = $VAL"

function remove_arr_element {
    ARR_NAME="$1"
    IND="$2"

    "$ARR_NAME"=("${ARR_NAME[@]:0:$((${#ARR_NAME[@]}-1))}")

}

ARR=("a" "b" "c" "d" "e")

for i in {0..3}; do

    printf "%s\n" "Before, len = ${#ARR[@]}"
    remove_arr_element "ARR" "-1"
    printf "%s\n" "After, len = ${#ARR[@]}"

done

