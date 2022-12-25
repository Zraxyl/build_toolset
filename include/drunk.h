#ifndef DRUNK_H_
#define DRUNK_H_

#include <string.h>
#include <stdio.h>
#include <stdbool.h>

extern void build_package(char* str);
extern char* const packages;
extern void konsole_run(char* str);
extern void enable_debug();

extern bool is_debug;
extern bool enable_build;

bool is_debug = false;
bool enable_build = false;

#endif // DRUNK_H_
