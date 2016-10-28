#!/bin/bash

. "bash_funcs.sh"

DEBUG_FLAG=1

declare -a array1

array1+=("")
array1+=("")

function func1 {
    local -a array
    array+=("hi")
    declare -p "array"

    func2

    declare -p "array"
}

function func2 {
    declare -p "array"
    local array="what"
    declare -p "array"
}

#func1

#for el in "${array1[@]}"; do
#    echo "el = $el"
#done


tree_node="Company>Hello>There"

printf "%s" "$tree_node" | awk -F '>' '{ if(NF>1) {print $(NF-1)} else {print $1}}'

#tree.create "newTree"
#tree.create "newTree"

#echo "$newTree"

#str="Joe:Johnson:25;what"
#array=($(echo "$str" | sed 's/:\|;/ /g'))
#for el in "${array[@]}"; do
#    echo "el = $el"
#done

tree="ROOT:Company>HR>HR Head<Legal>Legal Head:Engineering<Engineering>Engineering Head>Sub1>Assistant<Sub2>Assistant<<<Corporate>Director"
tree.add_node "$tree" "Company>Engineering>Developer"

