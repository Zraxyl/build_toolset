#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <getopt.h>
#include "../include/msg_type.h"
#include "../include/drunk.h"

int main (int argc, char *argv[])
{
    while (1)
    {
        static struct option long_options[] =
        {
            {"debug", no_argument, 0, '1'},
            {"help", no_argument, 0, '2'},
            {"build", 0, 0, '3'},
            {0, 0, 0, 0}
        };
        /* getopt_long stores the option index here. */
        int option_index = 0;

        int c = getopt_long (argc, argv, "",
                             long_options, &option_index);

        /* Detect the end of the options. */
        if (c == -1)
            break;

        switch (c) {
            case '1':
                enable_debug;

                drunk_msg("debugger flag is set");
                printf("%d", is_debug);
                putchar('\n');
                break;
            case '2':
                show_help();
                break;
            case '3':
                enable_build = true;
                break;
            case '?':
                drunk_msg ("Unknown option\n");
                break;

            default:
                abort ();
        }
    }

    /* Print any remaining command line arguments (not options). */
    if (optind < argc)
    {
        while (optind < argc)
            if (enable_build == true) {
            build_package(argv[optind++]);
            }
    }
    return 0;
}
