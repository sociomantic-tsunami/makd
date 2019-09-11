### Position-independent code can now be specified with `USE_PIC`

Newer distro releases (e.g. Ubuntu 18.04) require builds to use position
independent code (i.e. the `-fPIC` build flag), otherwise linking fails.
The new `USE_PIC` build variable can be used to enable this option:

    USE_PIC=1 make [...]
