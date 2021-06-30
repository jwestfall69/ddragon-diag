# MCU Tests
---
The MCU is the HD63701Y0 chip on the CPU board.  The following 2 tests are done.

#### NMI/IRQ Test
The CPU can trigger an NMI on the MCU, when this happens the MCU should trigger
an IRQ on the CPU.  This test verifies this is working.


#### Checksum
When the MCU starts up it will initialize itself/io ports then the main
execution will go into an infinite loop (jmp instruction that jumps to itself)
From that point forward all execution is done when an NMI is received from the
CPU.

When the first NMI is received from the CPU, the MCU will calculate a single
byte checksum.  The checksum consists of summing up each of the bytes of the
internal prom space, then storing the resulting byte at memory location 0x8000.
This address maps to the first by of the shared ram between the CPU and MCU. On
The CPU side its at 0x2000.  The expected checksum value is 0x84.

In order for the CPU to read the shared address 0x2000 the MCU needs to have its
bus available set.  This is done by halting the MCU, waiting for the bus
available flag, reading the memory location, and then unhalting the MCU.

Because of this there are 2 failure modes for this test.

* Bus available never happens, which will result in "FAILED NO BA"
* Bad checksum value, which will result in "FAILED XY" where XY is the read checksum value (hex)
