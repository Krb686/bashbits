#!/bin/bash

awk '/^# .* #$/{x=$0} {print $x}' "/home/kevin/gitrepos/bashbits/bash_funcs.sh"
