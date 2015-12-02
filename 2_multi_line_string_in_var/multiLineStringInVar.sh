#!/bin/bash

printf "Suppose you want a string that spans multiple lines of code and you \n"
printf "want that string to exist inside your script in exactly the same    \n" 
printf "format that it will be printed in and appear in on the terminal,    \n"
printf "probably because it's just as likely that someone might find it     \n"
printf "useful by reading the script itself rather than seeing it printed.  \n"
printf "Well, then this is the obvious manner...                            \n" 


printf "\n\n\n"

STRING_FAIL_1="But if you also want it stored inside a variable so it can be\n\
               referenced later, then this basic line continuation will not \n\
               work with the standard %s format to printf since no escape   \n\
               characters are expanded inside the argument.                    "
printf "%s" "$STRING_FAIL_1"
printf "\n\n\n"


STRING_FAIL_2="Of course, printf does have a convenient option to allow  \n\
               for expansion of escape sequences inside an argument,     \n\
               by using the %b format rather than %s. however this is    \n\
               generally considered to be unsafe and is discouraged.     \n\
               Not only that, this method literally retains horizontal   \n\
               spacing because of the line continuation mechanism, so    \n\
               the first line must be spaced incorrectly either in the   \n\
               script or in the terminal window when printed.               "

 
printf "%b\n" "$STRING_FAIL_2"
printf "\n\n\n"



STRING_SUCCESS_1="$(printf "Ultimately, one of the easiest way to achieve  \n"
                    printf "the desired effect is like this, with multiple \n"
                    printf "calls to printf inside of a command            \n"
                    printf "substitution block.  This way, the newlines are\n"
                    printf "handled here on the spot, being injected into  \n"
                    printf "the string.  Also, this method allows the      \n"
                    printf "string inside the script to look exactly the   \n"
                    printf "way it should when it will actually be printed.\n"
                    printf "Furthermore, line continuations are not needed!\n"
                   )"

printf "%s\n" "$STRING_SUCCESS_1"



