#ifndef STATES_H
#define STATES_H

struct state {
    void (*nextfunc)(struct state *);
    char c;
};

/* State transition functions */
void f_normal(struct state *state);
void f_command_backtick(struct state *state);
void f_command_expansion_check(struct state *state);
void f_command_opts(struct state *state);
void f_command_arg_string(struct state *state);
void f_command_esc_check(struct state *state);
void f_command_group(struct state *state);
void f_command_var(struct state *state);
void f_command_subshell_list(struct state *state);
void f_comment(struct state *state);
void f_control_case(struct state *state);
void f_control_for(struct state *state);
void f_control_if(struct state *state);
void f_control_until(struct state *state);
void f_declaration(struct state *state);
void f_declaration_command(struct state *state);
void f_declaration_function(struct state *state);
void f_declaration_variable(struct state *state);
void f_function_body(struct state *state);
void f_history_expansion(struct state *state);
void f_parameter_expansion_simple(struct state *state);
void f_plus_check(struct state *state);
void f_string_ansi(struct state *state);
void f_string_single(struct state *state);
void f_string_double(struct state *state);
void f_test_check(struct state *state);
void f_test_single(struct state *state);
void f_test_double(struct state *state);

void (*pop_state(int num))(struct state *);


/* Enumeration of possible states */

enum state_codes { normal,
                   command_backtick,
                   command_expansion_check, 
                   command_opts, 
                   command_arg_string, 
                   command_group, 
                   command_var, 
                   command_subshell_list, 
                   comment, 
                   control_case, 
                   control_for, 
                   control_if, 
                   control_until, 
                   declaration, 
                   declaration_command, 
                   declaration_function, 
                   declaration_variable, 
                   function_body, 
                   parameter_expansion_simple, 
                   plus_check, 
                   string_ansi, 
                   string_single, 
                   string_double, 
                   test_check, 
                   test_single, 
                   test_double
                 };
#endif
