# Tools for developemnt

* This is basic toolset of tools for Zraxyl development environment.

# Packages needed to work with the scriptlets

```
## modules deps ( docker, mkiso and builder )
$ bottle -Syu --needed make cmake docker ninja meson llvm clang bash libisofs libisoburn
```

## Getting started

1. Make empty directory somewhere ( And dont use root user )
2. Clone this repository into empty directory.
3. Open terminal in that empty directory where you have repo called tools

```
$ ln -sf tools/envsetup.sh envsetup

$ ./envsetup --help
```

4. Now youre ready to start adding/changing packages
