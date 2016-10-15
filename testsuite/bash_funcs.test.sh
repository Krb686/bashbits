#!/bin/bash

. "/home/kevin/gitrepos/bashbits/bash_funcs.sh"

PASS=0
FAIL=0

SUCCESS==0

function pass {
    PASS=$(($PASS+1))
}

function fail {
    FAIL=$(($FAIL+1))
    echo "Fail at ${BASH_LINENO[1]}"
}

function test_report {
    echo "Passes --> $PASS"
    echo "Failures --> $FAIL"
}

function check_pass {
    [[ $? -eq 0 ]] && pass || fail
}

function check_fail {
    [[ $? -eq ${1:?"No check code!"} ]] && pass || fail
}


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



array.contains_key.test
array.contains_value.test
test_report
