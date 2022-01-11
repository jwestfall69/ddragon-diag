# Error Codes
---
This document contains a list of possible errors that may occur.

#### Beep Codes:
The diag rom support having the sound cpu play sounds to help
identify an error code that may not be visible from corrupt/bad
video output.

A beep code consists of a series of 8 sounds that correspond to
the Beep Codes in the table below.  The coin up sound represents
a 0, and the 'go go' sound is a 1.

#### Error Addresses:
If the screen and beep codes are not working, you can also make use of error
addresses.  After the beep code is played the diag rom will jump to a specific
address in the rom and then continually loop at that address.  This causes the
CPUs address lines to become static with the exception of a0.

A logic probe is needed to probe each of the address lines to determine what
address the diag rom stopped on.  When doing this its best to start with A15
and work your ways backward.

Address lines that are stuck high should be considered a 1, while pulsing
address lines should be considered a 0.

The error addresses will follow the following format

0xc[error code]0

For example, error code 0x1a would have error address of 0xc1a0.

#### Error Codes
|  Hex  | Number | Beep Code | Error Address A15 ... A0 |Error Text |
| ----: | -----: | --------: | :-----------------------:|:--------- |
|  0x01 |      1 | 0000 0001 | 1100 0000 0001 0000      | WORK RAM DEAD OUTPUT |
|  0x02 |      2 | 0000 0010 | 1100 0000 0010 0000      | WORK RAM UNWRITABLE |
|  0x03 |      3 | 0000 0011 | 1100 0000 0011 0000      | WORK RAM DATA |
|  0x04 |      4 | 0000 0100 | 1100 0000 0100 0000      | WORK RAM ADDRESS |
|  0x05 |      5 | 0000 0101 | 1100 0000 0101 0000      | FG RAM DEAD OUTPUT |
|  0x06 |      6 | 0000 0110 | 1100 0000 0110 0000      | FG RAM UNWRITABLE |
|  0x07 |      7 | 0000 0111 | 1100 0000 0111 0000      | FG RAM DATA |
|  0x08 |      8 | 0000 1000 | 1100 0000 1000 0000      | FG RAM ADDRESS |
|  0x09 |      9 | 0000 1001 | 1100 0000 1001 0000      | PAL RAM DEAD OUTPUT |
|  0x0a |     10 | 0000 1010 | 1100 0000 1010 0000      | PAL RAM UNWRITABLE |
|  0x0b |     11 | 0000 1011 | 1100 0000 1011 0000      | PAL RAM DATA |
|  0x0c |     12 | 0000 1100 | 1100 0000 1100 0000      | PAL RAM ADDRESS |
|  0x0d |     13 | 0000 1101 | 1100 0000 1101 0000      | PAL EXT RAM DEAD OUTPUT |
|  0x0e |     14 | 0000 1110 | 1100 0000 1110 0000      | PAL EXT RAM UNWRITABLE |
|  0x0f |     15 | 0000 1111 | 1100 0000 1111 0000      | PAL EXT RAM DATA |
|  0x10 |     16 | 0001 0000 | 1100 0001 0000 0000      | PAL EXT RAM ADDRESS |
|  0x11 |     17 | 0001 0001 | 1100 0001 0001 0000      | BG RAM DEAD OUTPUT |
|  0x12 |     18 | 0001 0010 | 1100 0001 0010 0000      | BG RAM UNWRITABLE |
|  0x13 |     19 | 0001 0011 | 1100 0001 0011 0000      | BG RAM DATA |
|  0x14 |     20 | 0001 0100 | 1100 0001 0100 0000      | BG RAM ADDRESS |
|  0x15 |     21 | 0001 0101 | 1100 0001 0101 0000      | OBJ/SPRITE RAM DEAD OUTPUT |
|  0x16 |     22 | 0001 0110 | 1100 0001 0110 0000      | OBJ/SPRITE RAM UNWRITABLE |
|  0x17 |     23 | 0001 0111 | 1100 0001 0111 0000      | OBJ/SPRITE RAM DATA |
|  0x18 |     24 | 0001 1000 | 1100 0000 1000 0000      | OBJ/SPRITE RAM ADDRESS |
|  0x19 |     25 | 0001 1001 | 1100 0001 1001 0000      | COMM RAM DEAD OUTPUT |
|  0x1a |     26 | 0001 1010 | 1100 0001 1010 0000      | COMM RAM UNWRITABLE |
|  0x1b |     27 | 0001 1011 | 1100 0001 1011 0000      | COMM RAM DATA |
|  0x1c |     28 | 0001 1100 | 1100 0001 1100 0000      | COMM RAM ADDRESS |
|  0x1d |     29 | 0001 1101 | 1100 0001 1101 0000      | IC12 (245) DEAD OUTPUT |
