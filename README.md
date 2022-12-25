# Tools for developemnt

* This is basic toolset of tools for drunk development environment. Sets up everything from pkg management to source clones ( basic env for all new devs )

# Packages needed to work with these scriptlets

```
## modules deps ( docker, mkiso and builder )
$ bottle -Syu --needed make cmake docker ninja meson llvm clang bash libisofs libisoburn
```

## Getting started

1. Make empty directory somewhere ( And dont use root user )
2. Clone this repository into empty directory.
3. Open terminal in that empty directory where you have repo called tools

```
$ ln -sf tools/drunk.sh drunk

$ ./drunk -h
```

4. Now youre ready to start adding/changing packages
