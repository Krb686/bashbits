#include <stdio.h>
#include <stdlib.h>
#include "states.h"

/* Array of function pointers to state transition functions */
void (* statefuncs[])(struct state *) = { f_normal,
                                          f_command_backtick,
                                          f_command_expansion_check,
                                          f_command_opts,
                                          f_command_arg_string,
                                          f_command_group,
                                          f_command_var,
                                          f_command_subshell_list,
                                          f_comment,
                                          f_control_case,
                                          f_control_for,
                                          f_control_if,
                                          f_control_until,
                                          f_declaration,
                                          f_declaration_command,
                                          f_declaration_function,
                                          f_declaration_variable,
                                          f_function_body,
                                          f_parameter_expansion_simple,
                                          f_plus_check,
                                          f_string_ansi,
                                          f_string_single,
                                          f_string_double,
                                          f_test_check,
                                          f_test_single,
                                          f_test_double
                                        };

enum state_codes state_stack[10];
int stack_index;

void f_normal(struct state *state){
    printf("state normal\n");

    switch(state->c){
    case '#':
        state->nextfunc = f_comment;
        break;
    case '`':
        state->nextfunc = f_command_backtick;
        break;
    case '$':
        state->nextfunc = f_command_expansion_check;
        break;
    case '\'':
        state->nextfunc = f_string_single;
        break;
    case '"':
        state->nextfunc = f_string_double;
        break;
    case '\\':
        state->nextfunc = f_command_esc_check;
        break;
    case '!':
        state->nextfunc = f_history_expansion;
        break;
    case '(':
        state->nextfunc = f_command_subshell_list;
        break;
    case '{':
        state->nextfunc = f_command_group;
        break;
    case '}':
        state->nextfunc = pop_state(2);
        break;
    case '[':
        state->nextfunc = f_test_check;
        break;
    }
}

void f_command_backtick(struct state *state){
    switch(state->c){
    case '`':
        state->nextfunc = pop_state(1);
        break;
    }
}

void f_command_expansion_check(struct state *state){
    switch(state->c){
    case '\'':
        state->nextfunc = f_string_ansi;
        break;
    }
}

void f_command_opts(struct state *state){
}

void f_command_arg_string(struct state *state){
}

void f_command_esc_check(struct state *state){
}

void f_command_group(struct state *state){
}

void f_command_var(struct state *state){
}

void f_command_subshell_list(struct state *state){
}

void f_comment(struct state *state){
    printf("state: comment\n");
}

void f_control_case(struct state *state){
}

void f_control_for(struct state *state){
}

void f_control_if(struct state *state){
}

void f_control_until(struct state *state){
}

void f_declaration(struct state *state){
}

void f_declaration_command(struct state *state){
}

void f_declaration_function(struct state *state){
}

void f_declaration_variable(struct state *state){
}

void f_function_body(struct state *state){
}

void f_history_expansion(struct state *state){
}

void f_parameter_expansion_simple(struct state *state){
}

void f_plus_check(struct state *state){
}

void f_string_ansi(struct state *state){
}

void f_string_single(struct state *state){
}

void f_string_double(struct state *state){
}

void f_test_check(struct state *state){
}

void f_test_single(struct state *state){
}

void f_test_double(struct state *state){
}

void (*pop_state(int num))(struct state *){
    (num <= stack_index) ? stack_index -= num : exit(-1);
    return statefuncs[stack_index];
};
