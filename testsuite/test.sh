#!/bin/bash
#. "/home/kevin/gitrepos/bashbits/bash_funcs.sh"

#wait_for_file "/tmp/file" 1

function func1 {
    local myvar="hello"
    echo "func1: myvar = $myvar"
    func2
}

function func2 {
    echo "func2: myvar = $myvar"
}

func1
echo "myvar = $myvar"
