#include <stdio.h>
#include <stdlib.h>
#include "../include/msg_type.h"
#include "../include/drunk.h"

////
// Build system
////
void build_package(char* str) {
    char* const packages = str;
    drunk_msg("debugger flag is set second time");
    printf("%d", is_debug);
    putchar('\n');

    drunk_msg_2("List of package's to build: ", packages);

    // Start of the build system
    konsole_run("''");

}

void konsole_run(char* str) {

    // Make sure to use it like this
    // konsole_run("'ls && pwd'");

    char cmd[256];
    strcpy(cmd ,str);

    char base[] = "dbus-launch /usr/bin/konsole --hold --separate -e /bin/bash -c ";
    strcat(base, cmd);

    drunk_msg(base);

    system(base);
}

////
//  Usual things here
////
void show_help(void) {
    drunk_msg( "------------ HELP MENU \n");
    drunk_msg("--debug      : Will enable debug messages");
    drunk_msg("--docker     : Will enable docker usage");
    drunk_msg("--build      : Will build the requested packages");

    return;
}

void enable_debug() {
    is_debug = true;
    return;
}
