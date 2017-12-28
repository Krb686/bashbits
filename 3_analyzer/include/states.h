#ifndef STATES_H
#define STATES_H
int f_normal(void);
int f_command_backtick(void);
int f_command_expansion_check(void);
int f_command_opts(void);
int f_command_arg_string(void);
int f_command_group(void);
int f_command_var(void);
int f_command_subshell_list(void);
int f_comment(void);
int f_control_case(void);
int f_control_for(void);
int f_control_if(void);
int f_control_until(void);
int f_declaration(void);
int f_declaration_command(void);
int f_declaration_function(void);
int f_declaration_variable(void);
int f_function_body(void);
int f_parameter_expansion_simple(void);
int f_plus_check(void);
int f_string_ansi(void);
int f_string_single(void);
int f_string_double(void);
int f_test_check(void);
int f_test_single(void);
int f_test_double(void);


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
