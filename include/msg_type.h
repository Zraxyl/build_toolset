#ifndef MSG_TYPE_H_
#define MSG_TYPE_H_

#include <string.h>
#include <stdio.h>
#include "../include/drunk.h"

extern void drunk_msg(char* str);
extern void drunk_msg_2(char* str, char* str2);

extern void drunk_debug(char* str);
extern void drunk_debug_2(char* str, char* str2);

extern void show_help(void);

#endif // MSG_TYPE_H_
