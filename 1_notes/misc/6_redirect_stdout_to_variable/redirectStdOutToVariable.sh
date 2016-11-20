#!/bin/bash

# A couple ways to do this

# #1

function someCommand(){
    printf "hello"
}

function redirectionTarget(){
    while read -r LINE; do
        printf  "LINE = $LINE\n"
    done
}

OUTPUT="$(someCommand | redirectionTarget)"
