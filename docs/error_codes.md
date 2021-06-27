# Error Codes
---
This document contains a list of possible errors that may occur.

#### Beep Codes:
The diag rom support having the sound cpu play sounds to help
identify an error code that may not be visable from corrupt/bad
video output.

A beep code consists of a series of 8 sounds that correspond to
the Beep Codes in the table below.  The coin up sound represents
a 0, and the 'go go' sound is a 1.

#### Error Codes
|  Hex  | Number | Beep Code | Error Text |
| ----: | -----: | --------: | :--------- |
|  0x01 |      1 | 0000 0001 | WORK RAM DEAD OUTPUT
|  0x02 |      2 | 0000 0010 | WORK RAM UNWRITABLE
|  0x03 |      3 | 0000 0011 | WORK RAM DATA
|  0x04 |      4 | 0000 0100 | WORK RAM ADDRESS
|  0x05 |      5 | 0000 0101 | FG RAM DEAD OUTPUT
|  0x06 |      6 | 0000 0110 | FG RAM UNWRITABLE
|  0x07 |      7 | 0000 0111 | FG RAM DATA
|  0x08 |      8 | 0000 1000 | FG RAM ADDRESS
|  0x09 |      9 | 0000 1001 | PAL RAM DEAD OUTPUT
|  0x0a |     10 | 0000 1010 | PAL RAM UNWRITABLE
|  0x0b |     11 | 0000 1011 | PAL RAM DATA
|  0x0c |     12 | 0000 1100 | PAL RAM ADDRESS
|  0x0d |     13 | 0000 1101 | PAL EXT RAM DEAD OUTPUT
|  0x0e |     14 | 0000 1110 | PAL EXT RAM UNWRITABLE
|  0x0f |     15 | 0000 1111 | PAL EXT RAM DATA
|  0x10 |     16 | 0001 0000 | PAL EXT RAM ADDRESS
|  0x11 |     17 | 0001 0001 | BG RAM DEAD OUTPUT
|  0x12 |     18 | 0001 0010 | BG RAM UNWRITABLE
|  0x13 |     19 | 0001 0011 | BG RAM DATA
|  0x14 |     20 | 0001 0100 | BG RAM ADDRESS
|  0x15 |     21 | 0001 0101 | OBJ/SPRITE RAM DEAD OUTPUT
|  0x16 |     22 | 0001 0110 | OBJ/SPRITE RAM UNWRITABLE
|  0x17 |     23 | 0001 0111 | OBJ/SPRITE RAM DATA
|  0x18 |     24 | 0001 1000 | OBJ/SPRITE RAM ADDRESS
|  0x19 |     25 | 0001 1001 | COMM RAM DEAD OUTPUT
|  0x1a |     26 | 0001 1010 | COMM RAM UNWRITABLE
|  0x1b |     27 | 0001 1011 | COMM RAM DATA
|  0x1c |     28 | 0001 1100 | COMM RAM ADDRESS
