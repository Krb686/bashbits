#!/bin/bash

. "/home/kevin/gitrepos/bashbits/bash_funcs.sh"

declare -a testfuncs
testfuncs+=("array.contains_key.test")
testfuncs+=("array.contains_value.test")
testfuncs+=("array.push.test")

declare -A testpasses
declare -A testfailures
declare -i total_passes=0
declare -i total_failures=0

INFO_FLAG=1
DEBUG_FLAG=0
ERROR_FLAG=1

# ================ Function: pass ================ #
function pass {
    testpasses["$testfunc"]=$((${testpasses["$testfunc"]} + 1))
    total_passes=$(($total_passes + 1))
}

# ================ Function: fail ================ #
function fail {
    testfailures["$testfunc"]=$((${testfailures["$testfunc"]} + 1))
    total_failures=$(($total_failures + 1))
    print.error "    **** Fail at ${BASH_LINENO[1]}"
}

function test_report {
    echo "Total Passes --> $total_passes"
    echo "Total Failures --> $total_failures"
}

function check_pass {
    [[ $? -eq 0 ]] && pass || fail
}

function check_fail {
    [[ $? -eq ${1:?"No check code!"} ]] && pass || fail
}

function execute_tests {
    print.info "Executing tests"

    for testfunc in "${testfuncs[@]}"; do
        print.info "--> $testfunc"

        # Initialize passes and failures for test function
        testpasses["$testfunc"]=0
        testfailures["$testfunc"]=0

        # Run the test function
        "$testfunc"

        # Report passes and failures
        print.info "    --> passes: ${testpasses["$testfunc"]}"
        print.info "    --> failures: ${testfailures["$testfunc"]}"
    done

    # Generate summary report
    test_report
}

# ============================================================================ #
# ================ Test Functions ============================================ #

function array.contains_key.test {

    local -a array1=("v1")
    local -A array2=(["k2"]="v2")
    local i=0

    array.contains_key "array3" "k2"; check_fail 3
    array.contains_key "i" "k1";      check_fail 2
    array.contains_key "array1" "k3"; check_fail 1
    array.contains_key "array2" "k3"; check_fail 1
    array.contains_key "array1" "0";  check_pass
    array.contains_key "array2" "k2"; check_pass
}

function array.contains_value.test {

    local -a array1=("val1")
    local i=1

    array.contains_value "arrayBogus" "val1"; check_fail 3
    array.contains_value "i" "val1";          check_fail 2
    array.contains_value "array1" "val2";     check_fail 1
    array.contains_value "array1" "val1";     check_pass
}

function array.push.test {

    # Should be able to push individual elements, or a list of elements

    local -a array_std=()
    local -A array_assoc=()
    local i=1

    local el_list=""
    for i in {0..2}; do
        el_list+="$i"$'\n'
    done

    array.push "arrayBogus" "single element";        check_fail 2
    array.push "i" "single element";                 check_fail 2
    array.push "array_assoc" "element";              check_fail 1
    array.push "array_std" "element";                check_pass
    array.contains_value "array_std" "element";      check_pass
    array.push "array_std" "$el_list";               check_pass
    array.contains_value "array_std" "0";            check_pass
    array.contains_value "array_std" "1";            check_pass
    array.contains_value "array_std" "2";            check_pass
}

execute_tests
