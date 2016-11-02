#!/bin/bash

. "/home/kevin/gitrepos/bashbits/bash_funcs.sh"

declare -a testfuncs
declare -A testpasses
declare -A testfailures
declare -i total_passes=0
declare -i total_failures=0

INFO_FLAG=1
DEBUG_FLAG=0
ERROR_FLAG=1

function parse_test_funcs {
    local func_string="$(cat $0 | grep -Po '(?<=^function ).*\.test(?= {)')"
    while read -r func; do
        testfuncs+=("$func")
    done <<< "$func_string"
}

# ================ Function: pass ================ #
function pass {
    testpasses["$testfunc"]=$((${testpasses["$testfunc"]} + 1))
    total_passes=$(($total_passes + 1))
}

# ================ Function: fail ================ #
function fail {
    local tc=$1 # test code
    local ec=$2 # expected code
    testfailures["$testfunc"]=$((${testfailures["$testfunc"]} + 1))
    total_failures=$(($total_failures + 1))
    print.error "    **** Fail at ${BASH_LINENO[1]}! Should have returned $ec, but returned $tc!!"
}

function test_report {
    echo "Total Passes --> $total_passes"
    echo "Total Failures --> $total_failures"
}

function check_pass {
    [[ $? -eq 0 ]] && pass || fail
}

function check_fail {
    local tc=$?
    [[ $tc -eq ${1:?"No check code!"} ]] && pass || fail $tc $1
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
        print.info "    --> pass: ${testpasses["$testfunc"]}"
        print.info "    --> fail: ${testfailures["$testfunc"]}"
    done

    # Generate summary report
    test_report
}

# ============================================================================ #
# ================ Test Functions ============================================ #

function array.contains_key.test {

    local -a array1=("v1")
    declare -A array2=(["k2"]="v2")
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

function array.delete_by_key.test {

    local -a array1=("el1")
    local -A array2=(["k1"]="el1")
    local -ar array3=("el1")
    local i=1

    array.delete_by_key "arrayBogus" "k1";    check_fail 4 # Should return 4 if array param is not set.
    array.delete_by_key "i" "k1";             check_fail 3 # Should return 3 if array param is not an array.
    array.delete_by_key "array3" "k1";        check_fail 2 # Should return 2 if array param is readonly.
    array.delete_by_key "array2" "k2";        check_fail 1 # Should return 1 if array did not contain specified key.
    array.delete_by_key "array2" "k1";        check_pass
    array.delete_by_key "array1" "0";         check_pass

}

function array.delete_by_value.test {

    local i=0
    local -ar array1=("el1" "el2")
    local -a array2=("el1" "el1" "el2" "el3")

    array.delete_by_value "arrayBogus" "el1"; check_fail 4
    array.delete_by_value "i" "el1";          check_fail 3
    array.delete_by_value "array1" "el1";     check_fail 2
    array.delete_by_value "array2" "el4";     check_fail 1
    array.delete_by_value "array2" "el3";     check_pass
}

function array.dump_keys.test {

    local i=0
    local array1=("el1" "el2")
    local -A array2=(["el1"]="a" ["el2"]="b")

    array.dump_keys "bogusVar";          check_fail 1
    array.dump_keys "i";                 check_fail 1
    array.dump_keys "array1" >/dev/null; check_pass

    local str="$(array.dump_keys "array1")"
    [[ "$str" == "0"$'\n'"1" ]];         check_pass

    local str="$(array.dump_keys "array2")"
    [[ "$str" == "el1"$'\n'"el2" ]];     check_pass
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

function bash.is_var_ro.test {

    local var2="hello"
    local -r var3="hello"

    bash.is_var_ro "var1";    check_fail 2
    bash.is_var_ro "var2";    check_fail 1
    bash.is_var_ro "var3";    check_pass
}

parse_test_funcs
execute_tests
