# ddragon-diag
This is a diagnostics program that can be run on the original double dragon
jamma/arcade boards.  Its a similar concept as the [neogeo-diag-bios](https://github.com/jwestfall69/neogeo-diag-bios).

It is targeted to the HD6309 cpu and will not work on bootleg boards that
have a 6809 cpu.

It will need to be burnt to a 27c256 and installed in to IC26.  All remain
other roms should be left installed.

## Pre-Built
You can grab the lastest build from the main branch at

https://www.mvs-scans.com/ddragon-diag/ddragon-diag-main.zip


## Building
Building requires vasm (vasm6809_oldstyle) and vlink which are available here

http://sun.hasenbraten.de/vasm/<br>
http://sun.hasenbraten.de/vlink/

For the time being you must use the nightly build of vasm as there are a couple
bugs in 1.8k that cause problems when building for the 6309 cpu.
