#include <string.h>
#include <stdio.h>
#include <stdbool.h>
#include "../include/drunk.h"

void drunk_msg(char* str) {
    char string[256];
    strcpy(string ,str);

    printf("\033[0;32m");
    printf("%s", string);
    printf("\033[0;37m");

    putchar('\n');
}

void drunk_msg_2(char* str, char* str2) {
    char string[256];
    char string2[256];

    strcpy(string ,str);
    strcpy(string2 ,str2);

    printf("\033[0;32m");
    printf("%s", string);
    printf("%s", string2);
    printf("\033[0;37m");

    putchar('\n');
}

void drunk_debug(char* str) {
    char string[256];
    strcpy(string ,str);

    extern bool is_debug;
    extern bool enable_build;

    if (is_debug == true) {
    printf("\033[0;32m");
    printf("%s", string);
    printf("\033[0;37m");

    putchar('\n');
    }
}

void drunk_debug_2(char* str, char* str2) {
    char string[256];
    char string2[256];

    extern bool is_debug;
    extern bool enable_build;

    if (is_debug == true) {
    strcpy(string ,str);
    strcpy(string2 ,str2);

    printf("\033[0;32m");
    printf("%s", string);
    printf("%s", string2);
    printf("\033[0;37m");

    putchar('\n');
    }
}
