#!/bin/bash

dir="$(readlink -f "$(dirname $0)")"
. "$dir/bash_funcs.sh"

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
    local tc=$?
    [[ $tc -eq 0 ]] && pass || fail $tc 0
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
    local -A array2=(["k2"]="v2")
    local -A array3=( ["k 1"]="x" ["k 2"]="y" )
    local i=0


    array.contains_key "arrayBogus" "k2";  check_fail 3
    array.contains_key "i" "k1";       check_fail 2
    array.contains_key "array1" "k3";  check_fail 1
    array.contains_key "array2" "k3";  check_fail 1
    array.contains_key "array1" "0";   check_pass
    array.contains_key "array2" "k2";  check_pass
    array.contains_key "array3" "k 1"; check_pass
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

function array.dump_values.test {

    local i=0
    local array1=("el1" "el2")
    local -A array2=(["el1"]="a" ["el2"]="b")

    array.dump_values "bogusVar";             check_fail 1
    array.dump_values "i";                    check_fail 1
    array.dump_values "array1" >/dev/null;    check_pass

    local str="$(array.dump_values "array1")" check_pass
    [[ "$str" == "el1"$'\n'"el2" ]];          check_pass

    local str="$(array.dump_values "array2")" check_pass
    [[ "$str" == "a"$'\n'"b" ]];              check_pass
}

function array.get_by_key.test {

    local i=0
    local -a array1=("el1" "el2")
    local -A array2=(["el1"]="a" ["el2"]="b")
    local -A array3=( ["k 1"]="x" ["k 2"]="y" ["k 3"]="z" )

    array.get_by_key "bogusVar" "key1";                   check_fail 2
    array.get_by_key "i" "key1";                          check_fail 2
    array.get_by_key "array1" "9";                        check_fail 1

    local str="$(array.get_by_key "array1" "0")";         check_pass
    [[ "$str" == "el1" ]];                                check_pass

    local str="$(array.get_by_key "array2" "el1")"        check_pass
    [[ "$str" == "a" ]];                                  check_pass

    local str="$(array.get_by_key "array3" "k 1")";       check_pass
    [[ "$str" == "x" ]];                                  check_pass

}

function array.get_by_value.test {

    local i=0
    local -a array1=("el1" "el2" "el2")
    local -A array2=(["el1"]="a" ["el2"]="b" ["el3"]="b")

    array.get_by_value "bogusVar" "val1";    check_fail 2
    array.get_by_value "i" "val1";           check_fail 2
    array.get_by_value "array1" "el3";       check_fail 1

    local str="$(array.get_by_value "array1" "el1")";       check_pass
    [[ "$str" == "0" ]];                                    check_pass

    local str="$(array.get_by_value "array1" "el2")";       check_pass
    [[ "$str" == "1"$'\n'"2" ]];                            check_pass

    local str="$(array.get_by_value "array2" "a")";         check_pass
    [[ "$str" == "el1" ]];                                  check_pass

    local str="$(array.get_by_value "array2" "b")";         check_pass
    [[ "$str" == "el3"$'\n'"el2" ]];                        check_pass

}

function array.get_keys.test {

    local i=0
    local -a array1=("el1" "el2" "el2")
    local -A array2=(["el 1"]="a" ["el 2"]="b" ["el 3"]="b")

    array.get_keys "bogusVar";  check_fail 1
    array.get_keys "i";         check_fail 1

    local str="$(array.get_keys "array1")";  check_pass
    [[ "$str" == "0"$'\n'"1"$'\n'"2" ]];     check_pass

    local str="$(array.get_keys "array2")";  check_pass
    [[ "$str" == "el 3"$'\n'"el 2"$'\n'"el 1" ]]; check_pass  # Order is NOT guaranteed!
}

function arrray.get_values.test {

    local i=0
    local -a array1=("el1" "el2" "el2")
    local -A array2=(["el 1"]="a" ["el 2"]="b" ["el 3"]="c")

    array.get_values "bogusVar";  check_fail 1
    array.get_values "i";         check_fail 1

    local str="$(array.get_values "array1")";    check_pass
    [[ "$str" == "el1"$'\n'"el2"$'\n'"el2" ]];   check_pass

    local str="$(array.get_values "array2")";    check_pass
    [[ "$str" == "c"$'\n'"b"$'\n'"a" ]];         check_pass
}

function array.is_array.test {

    local i=0
    local -a array1=("el1" "el2" "el2")
    local -A array2=(["el 1"]="a" ["el 2"]="b" ["el 3"]="c")

    array.is_array "bogus";    check_fail 1
    array.is_array "i";        check_fail 1
    array.is_array "array1";   check_pass
    array.is_array "array2";   check_pass

}

function array.is_associative.test {

    local i=0
    local -a array1=("el1" "el2" "el2")
    local -A array2=(["el 1"]="a" ["el 2"]="b" ["el 3"]="c")

    array.is_associative "bogus";   check_fail 1
    array.is_associative "i";       check_fail 1
    array.is_associative "array1";  check_fail 1
    array.is_associative "array2";  check_pass
}

function array.is_standard.test {

    local i=0
    local -a array1=("el1" "el2" "el2")
    local -A array2=(["el 1"]="a" ["el 2"]="b" ["el 3"]="c")

    array.is_standard "bogus";    check_fail 1
    array.is_standard "i";        check_fail 1
    array.is_standard "array1";   check_pass
    array.is_standard "array2";   check_fail 1
}

function array.join.test {

    local i=0
    local -a array_std1=("el1" "el2" "el3")
    local -a array_std2=("el4" "el5" "el6")
    local -A array_assoc1=(["el 1"]="a" ["el 2"]="b" ["el 3"]="c")
    local -A array_assoc2=(["el 4"]="d" ["el 5"]="e" ["el 6"]="f")

    array.join "bogus1"     "bogus2";     check_fail 3
    array.join "bogus1"     "array_std2"; check_fail 3
    array.join "array_std1" "bogus2";     check_fail 2

    # Array mismatch
    array.join "array_std1" "array_assoc2";  check_fail 1
    array.join "array_assoc2" "array_std1";  check_fail 1

    # Join standard arrays
    array.join "array_std1" "array_std2";    check_pass
    array.contains_value "array_std2" "el1"; check_pass
    array.contains_value "array_std2" "el2"; check_pass
    array.contains_value "array_std2" "el3"; check_pass

    # Join associative arrays
    array.join "array_assoc1" "array_assoc2"; check_pass

    

}

function array.push.test {

    # Should be able to push individual elements, or a list of elements

    local -a array_std=()
    local -A array_assoc=()
    local i=1

    local el_list=""
    for i in {0..2}; do
        if [[ $i -ne 2 ]]; then
            el_list+="$i"$'\n'
        else
            el_list+="$i"
        fi
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