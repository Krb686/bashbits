#!/bin/bash

. "bash_functions.sh"


function hello {
    for i in {0..4}; do
        echo "$i"
        sleep 1
    done

    echo "DONE"
}

declare -a ARR=("a" "two" "c")

set -x
remove_array_duplicates "ARR"
