# bashbits

This repo contains 3 things:

1) A library of 60+ bash functions
    /lib

2) Unit tests for each function.
    /testsuite

3) A bash static code analyzer written in bash (in progress)
    /analyzer


Current unit test status (bash 4.2.46)


[ ------ info ----- ]: Executing tests  
[ ------ info ----- ]: --> array.array_from_list.test  
[ ------ info ----- ]:     --> pass: 6  
[ ------ info ----- ]:     --> fail: 0  
[ ------ info ----- ]: --> array.clear.test  
[ ------ info ----- ]:     --> pass: 4
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.contains_element.test
[ ------ info ----- ]:     --> pass: 8
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.contains_key.test
[ ------ info ----- ]:     --> pass: 7
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.contains_value.test
[ ------ info ----- ]:     --> pass: 4
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.delete_by_key.test
[ ------ info ----- ]:     --> pass: 12
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.delete_by_value.test
[ ------ info ----- ]:     --> pass: 5
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.dump_keys.test
[ ------ info ----- ]:     --> pass: 5
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.dump_values.test
[ ------ info ----- ]:     --> pass: 5
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.get_by_key.test
[ ------ info ----- ]:     --> pass: 9
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.get_by_value.test
[ ------ info ----- ]:     --> pass: 11
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.get_keys.test
[ ------ info ----- ]:     --> pass: 6
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.get_values.test
[ ------ info ----- ]:     --> pass: 6
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.is_array.test
[ ------ info ----- ]:     --> pass: 4
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.is_associative.test
[ ------ info ----- ]:     --> pass: 4
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.is_standard.test
[ ------ info ----- ]:     --> pass: 4
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.join.test
[ ------ info ----- ]:     --> pass: 13
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.len.test
[ ------ info ----- ]:     --> pass: 6
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.pop.test
[ ------ info ----- ]:     --> pass: 10
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.push.test
[ ------ info ----- ]:     --> pass: 9
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.remove_duplicates.test
[ ------ info ----- ]:     --> pass: 5
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.set_element.test
[ ------ info ----- ]:     --> pass: 6
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> array.sort.test
[ ------ info ----- ]:     --> pass: 9
[ ------ info ----- ]:     --> fail: 0
[ ------ info ----- ]: --> bash.is_var_ro.test
[ ------ info ----- ]:     --> pass: 3
[ ------ info ----- ]:     --> fail: 0
Total Passes --> 161
Total Failures --> 0
