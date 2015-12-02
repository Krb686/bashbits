#!/bin/bash

# Cool trick of running a command that prints to stdout and redirecting
# that stdout to a reader in a loop.

# This uses process substitution. The process sub runs the command in a subshell, and redirects its 
# output to an anonymous fd (created in /dev/fd). Then, the process substitution resolves to the name
# of that fd, which is then redirected as input to the loop (read command)

while read -r LINE; do

done < <("someCommand")
