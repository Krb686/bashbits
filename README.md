# bashbits

Note that this repo has spawned purely out of an arguably unhealthy love of bash.  If you choose to look around, know that weird stuff occurs here.

The functions herein are my attempt at doing things I find cool with bash just 'cause.  They are not efficient, not necessarily secure, and probably should not be
used in any sane production environment.  They are mainly to explore the limits of what can be done with bash.

The best example of the above statement is the 'bash.alloc' and 'bash.free' functions which implement a pseudo dynamic memory allocation feature via environment variables.

Another good example is the fact that most of the functions here return values by reference via evals and assignments to variable name parameters in order to get around some inconsistencies
and limitations of returning data via capturing stdout of a particular function call.

If that's not enough, then a third good example of this is simply the existence here of a bash static code analyzer written in bash.  It's still a major work in progress as I try to wrap my brain around it and static code analysis in general.

At this point if you're groaning in horror, you're free to go.  But if 


This repo contains 3 things:

1) A library of 60+ bash functions
    1_lib

2) Unit tests for each function.
    2_testsuite

3) A bash static code analyzer written in bash (in progress)
    3_analyzer


Current unit test status (bash 4.2.46)

  Total Passes --> 164  
  Total Failures --> 0  
