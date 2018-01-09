#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

#include "analyzer.h"
#include "states.h"

#define EXIT_BAD_ARGS 1
#define EXIT_BAD_FILENAME 2

// c state machine ideas
//     https://stackoverflow.com/questions/1371460/state-machines-tutorials
//     https://stackoverflow.com/questions/1647631/c-state-machine-design?noredirect=1&lq=1
//
// The state machine is implemented with an array of structs
//TODO - enums
//TODO - pass struct ptr to functions to avoid globals
//
//
//

/* ================ Function: main ========================================== */
/* ========================================================================== */
int main(int argc, char *argv[]){
    if(argc != 2){
        exit_error(EXIT_BAD_ARGS);
    }

    char *filename = argv[1];
    printf("loading file: %s\n", filename);

    parse_file(filename);

    return 0;
}

/* ================ Function: parse_file ==================================== */
/* ========================================================================== */
void parse_file(char *filename){
    FILE *fp = fopen(filename, "r");
    if(!fp){
        exit_error(EXIT_BAD_FILENAME);
    }

    struct state state = { f_normal, '\0' };
    while(state.nextfunc){
        if((state.c = fgetc(fp)) != EOF){;
            state.nextfunc(&state);
            printf("char = %c\n", state.c);
        } else {
            break;
        }
    }
}

/* ================ Function: exit_error ==================================== */
/* ========================================================================== */
void exit_error(int code){
    switch(code){
    case EXIT_BAD_ARGS:
        printf("Incorrect arguments!\n");
        usage();
        break;
    case EXIT_BAD_FILENAME:
        printf("Filename is bad or file doesn't exist!\n");
        break;
    }

    exit(code);
}

/* ================ Function: usage ========================================= */
/* ========================================================================== */
void usage(){
    printf("analyzer <file>\n");
}
