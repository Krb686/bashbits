#!/bin/bash

printf "%s\n\n" "If you run a command inside a command substitution block like this:"
printf "%s\n\n" "    VAR=\$(ps -elF)"
printf "%s\n\n" "Then the inner command runs inside a subshell, and its stdout file descriptor"
printf "%s\n\n" "captures text and stores it in the assigned variable. Thats the essence of the idea"
printf "%s\n\n" "but what if you really need to exit from the subshell and print to stdout anyways?"
printf "%s\n\n" "of course, with bash it is possible."


function subCommand(){
  printf "42"
}



OUTPUT="$(subCommand)"
printf "subCommand: $OUTPUT\n"
printf "See, you must wait to receive the output\n"


exec 3>&1

function subCommand2(){
  printf "84"

  printf "Error! Need to exit immediately!\n" >&3
}

printf "With this trick, you setup a new file descriptor that serves\n"
printf "as a reference to the original stdout (your terminal) of the\n"
printf "parent process.\n"

OUTPUT="$(subCommand2)"
printf "You can see the error message from subCommand2 appears before this string.\n"
