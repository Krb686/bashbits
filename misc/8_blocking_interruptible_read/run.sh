#!/bin/bash

# This demonstrates using a "soft" blocking read. ie it is interruptible, from another process's stdout
while true; do
  read -r LINE < <(./single_output_command.sh)
  printf "DATA: $LINE\n"
done

# This is the typically thought of way to do this, however this will NOT work
# if single_output_command.sh blocks uninterruptibly AND you want the process to be able to handle
# signals
while true; do
  DATA="$(./single_output_command.sh)"
  printf "DATA: $LINE\n"
done
