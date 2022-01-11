# IC12 Dead Output Test
---
IC12 is a 74LS245 IC that sits between the CPU's data bus and everything except
the program roms.  This test checks to see if that IC has dead output towards
the CPU.

Detecting dead output on the 6309/6809 is somewhat interesting.  When the CPU
isn't actively doing anything on the address bus it does dummy reads of
address 0xffff.  When a read happens of an actual memory address and there is
dead output the register ends up being filled with the contents of 0xffff.  This
address is the lower byte of the reset vector.  The diag rom does a little
voodoo as part of the build process to control what that byte will be (0x5a).

The test involves doing a read of the first address of all the different memory
locations (BG, COMM, FG, OBJ, PAL, PAL EXT, and WORK).  If these all come back
with 0x5a it will trigger the error.

If this test fails the diag rom will still attempt to display the error and
trigger the beep code, however neither of those are likely to work given they
depend on IC12.  To detect this error you will have to rely on the error
address being 0xc1d0.
