#include <stdio.h>
#include <stdlib.h>
#include "states.h"

int (* state[])(void) = { f_normal,
                          f_command_backtick};

int f_normal(void){
    return 0;
}

int f_command_backtick(void){
    return 0;
}

int f_command_expansion_check(void){
    return 0;
}

int f_command_opts(void){
    return 0;
}

int f_command_arg_string(void){
    return 0;
}

int f_command_group(void){
    return 0;
}

int f_command_var(void){
    return 0;
}

int f_command_subshell_list(void){
    return 0;
}

int f_comment(void){
    return 0;
}

int f_control_case(void){
    return 0;
}

int f_control_for(void){
    return 0;
}

int f_control_if(void){
    return 0;
}
int f_control_until(void){
    return 0;
}

int f_declaration(void){
    return 0;
}

int f_declaration_command(void){
    return 0;
}

int f_declaration_function(void){
    return 0;
}

int f_declaration_variable(void){
    return 0;
}

int f_function_body(void){
    return 0;
}

int f_parameter_expansion_simple(void){
    return 0;
}

int f_plus_check(void){
    return 0;
}

int f_string_ansi(void){
    return 0;
}

int f_string_single(void){
    return 0;
}

int f_string_double(void){
    return 0;
}

int f_test_check(void){
    return 0;
}

int f_test_single(void){
    return 0;
}

int f_test_double(void){
    return 0;
}

