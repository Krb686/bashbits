#!/bin/bash

HYBRID_STRING="This is a hybrid string because"$'\n'"it combines two syntaxes for creating strings"

printf "%s\n\n\n" "$HYBRID_STRING"


printf "How exactly is this useful?\n"
printf "Well, in a situation where you are passing a variable to printf in the safe manner:"
printf "%s\n" "    printf \"%s\" \"\$VAR\""
printf "You can't get printf to expand escape sequences.  However, it can be done on the spot\n"
printf "with the $'' syntax\n"
