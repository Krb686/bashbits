#!/bin/bash

`!!`
# potential special chars #
#
# ' " ` \ ! ? $ _ ( { [ # %
#
# ==== States ====
#* normal				normal state 
#* string single                         creating a simple string
#* string double				
#* string expansion check                temp state to look for sub-command,param simple,param advanced
#* string escape check			temp state to check for potential escape
#* string ANSI				string state that can insert special types of chars/substitutions
#* ANSI escape
#* dollar underscore check
# command (tick)                        executing a command
# command (dollar)			executing a command
# command expansion check               temp state to look for sub-command,param simple,param advanced
# command escape check                  check for escaping of normally special chars
# command subshell list                 special case of command
# command group                         special case of command
# argument                              arguments to a command
# parameter expansion simple            basic parameter expansion
# parameter expansion advanced          advanced parameter expansion
# test check                            temp state to check for basic/advanced test
# test basic				using the basic [ test
# test advanced				using the advanced [[ test
# comment
# job control
# arithmetic



# normal
# ====================================================================================
#	'		-->	string single		-->	+string
#	"		-->	string double		-->	+string
#	`		-->	command
#	\		--> 	command escape check	-->	none
#	!		-->	(opt) history exp	-->	none
#	?		-->	----
#	$		-->	command expansion check	-->	none
#	_		-->	----
#	(		-->	command subshell list	-->	none
#	{		-->	command group		-->	none
#	[		-->	test check		-->	none
#	#		-->	comment
#	%		-->	job control
#	whitespace	-->	----
#	other		-->	command


# string single
# ====================================================================================
#	'		-->	previous
#	"		-->	----
#	`		-->	----
#	\		-->	----
#	!		-->	----
#	?		-->	----
#	$		-->	----
#	_		-->	----
#	(		-->	----
#	{		-->	----
#	[		-->	----
#	#		-->	----
#	%		-->	----
#	whitespace	-->	----
#	other		-->	----


# string double
# ====================================================================================
#	'		-->	----
#       "               -->     previous                -->     none
#	`		-->	command			-->	none
#	\		-->	string escape check	-->	none
#	!		-->	----
#	?		-->	----
#       $               -->     string expansion check  -->     none
#	_		-->	----
#	(		-->	----
#	{		-->	----
#	[		-->	----
#	#		-->	----
#	%		-->	----
#	whitespace	-->	----
#	other		-->	----


# string expansion check
# ====================================================================================
#	'		-->	previous state		-->	none
#	"		-->     previous 2 states	-->	none
#	`		-->	command			-->	none
#	\		-->	string escape		-->	none
#	!		-->	previous		-->	special variable (last bg PID)
#	?		-->	previous state		-->	special variable (last exit code)
#	$		-->	previous state		-->	special variable (current PID)
#	_		-->	dollar underscore check	-->	none
#	{		-->     param advanced		-->	none
#	[		-->	deprecated		-->	none
#	#		-->	previous		-->	number of arguments
#	%		-->	previous		-->	----
#	whitespace	-->	previous state		-->	none
#	other		-->	param simple		-->	none



# string escape check
# ====================================================================================
#	'		-->	previous state		-->	----
#	"		-->	previous state		-->	escape "
#	`		-->	previous state		-->	escape `
#	\		-->	previous state		--> 	escape \
#	!		-->	previous state		-->	----
#	?		-->	previous state		-->	----
#	$		-->	previous state		-->	escape $
#	_		-->	previous state		-->	----
#	(		-->	previous state		-->	----
#	{		-->	previous state		-->	----
#	[		-->	previous state		-->	----
#	#		-->	previous state		-->	----
#	%		-->	previous state		-->	----
#	whitespace	-->	previous state		-->	----
#	other		-->	previous state		-->	----


# string ANSI
# ====================================================================================
#       '		-->	previous 2 states	-->	end string ANSI
#       "               --> 	----			-->	----
#       `               -->	----			-->	----
#       \		-->	ANSI escape		-->	----
#       !               -->	----			-->	----
#       ?               -->	----			-->	----
#       $               -->	----			-->	----
#       _		-->	----			-->	----
#       (		-->	----			-->	----
#       {		-->	----			-->	----
#       [		-->	----			-->	----
#       #		-->	----			-->	----
#       %		-->	----			-->	----
#       whitespace	-->	----			-->	----
#       other		--.	----			-->	----


# ANSI escape
# ====================================================================================
#
#	see ANSI C escapes

# dollar underscore check 
# ====================================================================================
#	'		-->	back 2(string)
#	"		--> 	back 3(normal)
#	`		-->	command
#	\		-->	string escape check
#	!		-->	back 2(string)
#	?		-->	back 2(string)
#	$		-->	back 1(string expansion check)
#	_		-->	simple expansion
#	(		-->	back 2(string)
#	{		-->	back 2(string)
#	[		-->	back 2(string)
#	#		-->	back 2(string)
#	%		-->	back 2(string)
#	whitespace	-->	back 2(string)
#	other		-->	simple expansion

#set -x

set -x

# 1st slash does nothing?
# 2nd prevents special
# 3rd??
# 4th - literal slash
# 5th?
# 6th literal + prevent special

hi=1
`$hi`

#echo `echo \\\` what

#$(\\\echo "hi")

# command (tick)
# ====================================================================================
#	'		-->	string single
#	"		-->	string double
#	`		-->	back 1
#	\		-->	????
#	!		-->	history expansion check
#	?		--> 	TODO
#	$		-->	command expansion check
#	_
#	(
#	{
#	[
#	#
#	%
#	whitespace
#	other

hi="hostname"

# command (dollar)
# ====================================================================================
#       '		-->	string single
#       "               -->     string double
#       `               -->	command
#       \		-->	command escape check
#       !               -->	history expansion/----
#       ?               -->	----
#       $               -->	command expansion check
#       _		-->	----
#       (		-->	arithmetic
#       {
#       [
#       #
#       %
#       whitespace	-->	argument
#       other



# command expansion check
#====================================================================================
#	'			-->	string ANSI
#
#       "                       -->     special locale string
#
#       [whitespace]            -->     syntax error
#
#       $                       -->     special PID variable
#
#       (                       -->     Command state
#
#       {                       -->     Parameter Expansion Advanced State
#
#       [                       -->     Syntax Error/Arithmetic Expansion in OLD bash versions
#
#       a-zA-Z0-9               -->     Parameter Expansion Simple State

# command escape check
# ====================================================================================


# command subshell list
# ====================================================================================

# command group
# ====================================================================================

# argument
# ====================================================================================
#	[whitespace]	-->	argument scan
#
#	"		-->	string(*1)		-->	??
#
#	$		-->	expansion check		-->	??
#

# history expansion check
# ====================================================================================

# parameter expansion simple
# ====================================================================================

# parameter expansion advanced
# ====================================================================================

# test check
# ====================================================================================

# test basic
# ====================================================================================

# test advanced
# ====================================================================================

