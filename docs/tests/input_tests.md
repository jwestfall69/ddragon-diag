# Input Tests
---
The inputs tests screen allows for testing / seeing various inputs.

![input tests screen](images/input_tests.png)

### P1
| Bit | Function           |
|:---:| :------------------|
|  0  | P1 Joystick Right  |
|  1  | P1 Joystick Left   |
|  2  | P1 Joystick Up     |
|  3  | P1 Joystick Down   |
|  4  | P1 Button A (kick) |
|  5  | P1 Button B (jump) |
|  6  | P1 Start           |
|  7  | P2 Start           |

### P2
| Bit | Function           |
|:---:| :------------------|
|  0  | P2 Joystick Right  |
|  1  | P2 Joystick Left   |
|  2  | P2 Joystick Up     |
|  3  | P2 Joystick Down   |
|  4  | P2 Button A (kick) |
|  5  | P2 Button B (jump) |
|  6  | P1 Coin            |
|  7  | P2 Coin            |

### Extra
| Bit | Function           |
|:---:| :------------------|
|  0  | Service Button     |
|  1  | P1 Button C (punch)|
|  2  | P2 Button C (punch)|
|  3  | VBlank Pulse       |
|  4  | MCU Bus Available  |
|  5  | Unused             |
|  6  | Unused             |
|  7  | Unused             |

### DSW0/DSW1
DSW0 and DSW1 are the dip switch banks near the jamma edge.  Refer to the
Double Dragon manual for what they toggle.

### NMI
An NMI should triggered with every VBlank.  You should expect VBP == NMI.

### IRQ
An IRQ is triggered by the MCU.  The MCU will only trigger an IRQ if we first
send it an NMI.  This can be down by pressing B+P1 Start

### FIRQ
The FIRQ (fast irq) should be triggering once every 1ms, which should be roughly
16x as often as the NMI/VBP.

### VBP (VBlank Poll)
VBlank is also communicated via bit 3 of the Extra Input.  This requires polling
the Extra Input to see.  You should expect VBP == NMI.
