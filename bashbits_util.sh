#!/bin/bash
. "1_lib/bash_funcs.sh"


function list_funcs {
    # Print list of all defined functions
    cat "1_lib/bash_funcs.sh" | grep -Po '^function.*{$' | awk '{print $2}'
}

function list_test_funcs {
    cat "2_testsuite/bash_funcs.test.sh" | grep -Po '^function.*test {$' | awk '{print $2}'
}

function list_test_coverage {
    readarray -t funcs <<< "$(list_funcs)"
    readarray -t testfuncs <<< "$(list_test_funcs)"
    
    for func in "${funcs[@]}"; do
    
        array.contains_value "testfuncs" "${func}.test" && printf "%s" "yes" || printf "%s" "no"

        printf "%s\n" "  $func: "
    
        
    done
}

list_test_coverage
