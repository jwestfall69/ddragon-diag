BG_RAM_START			equ $3000
BG_RAM_SIZE			equ $800
BG_RAM_ADDRESS_LINES		equ 11

COMM_RAM_START			equ $2000
COMM_RAM_SIZE			equ $200
COMM_RAM_ADDRESS_LINES		equ 9

FG_RAM_START			equ $1800
FG_RAM_SIZE			equ $800
FG_RAM_ADDRESS_LINES		equ 11

; Note: pins 19 & 22 on the obj/sprite ram chip
; are tied to ground, which only leaves a0-a8 as
; viable.  So the size is really 512 bytes and
; not 2048 as mame has it.
OBJ_RAM_START			equ $2800
OBJ_RAM_SIZE			equ $200
OBJ_RAM_ADDRESS_LINES		equ 9

	ifdef _BUILD_DD1
PAL_RAM_START			equ $1000
PAL_EXT_RAM_START		equ $1200
	else
PAL_RAM_START			equ $3c00
PAL_EXT_RAM_START		equ $3e00
	endif

PAL_RAM_SIZE			equ $200
PAL_RAM_ADDRESS_LINES		equ 9

PAL_EXT_RAM_SIZE		equ $200
PAL_EXT_RAM_ADDRESS_LINES	equ 9

WORK_RAM_START			equ $0000

	ifdef _BUILD_DD1
WORK_RAM_SIZE			equ $1000
WORK_RAM_ADDRESS_LINES		equ 12
	else
WORK_RAM_SIZE			equ $1800
WORK_RAM_ADDRESS_LINES		equ 13
	endif

; size of each individual palette
PAL_SIZE			equ $10

; address registers
REG_P1_INPUT			equ $3800
REG_P2_INPUT			equ $3801
REG_EXTRA_INPUT			equ $3802
REG_DSW0			equ $3803
REG_DSW1			equ $3804
REG_BANKSWITCH			equ $3808
REG_SCROLL_X			equ $3809
REG_SCROLL_Y			equ $380a
REG_NMI_ACK			equ $380b
REG_FIRQ_ACK			equ $380c
REG_IRQ_ACK			equ $380d
REG_SOUND			equ $380e
REG_MCU				equ $380f

; buttons
UP				equ $04
DOWN				equ $08
LEFT				equ $02
RIGHT				equ $01
A_BUTTON			equ $10
B_BUTTON			equ $20
P1_START			equ $40
P2_START			equ $80

; these are on the extra input
P1_C_BUTTON			equ $02
P2_C_BUTTON			equ $04
VBLANK				equ $08
P1_COIN				equ $40
P2_COIN				equ $80

; fg stuff
FG_TILES_PER_ROW		equ $40

; When the mcu starts it will sum up all 
; the bytes of its internal rom as a checksum
; Below is the expected checksum value and
; location we can read it from on the main cpu
MCU_CHECKSUM			equ $84
MCU_CHECKSUM_LOCATION		equ $2000
