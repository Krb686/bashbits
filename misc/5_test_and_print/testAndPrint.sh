#!/bin/bash

#[ $(some command -somearg) ] && printf "The command returned non-empty\n" || printf "The command returned empty\n"

COMMAND="bash"
[ $(pgrep "$COMMAND") ] && printf "$COMMAND is running!\n" || (printf "$COMMAND is not running!\n"; exit 1;)

COMMAND="someRandomCommand"
[ $(pgrep "$COMMAND") ] && printf "$COMMAND is running!\n" || (printf "$COMMAND is not running!\n"; exit 1;)

