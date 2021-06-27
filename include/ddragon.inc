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

PAL_RAM_START			equ $1000
PAL_RAM_SIZE			equ $200
PAL_RAM_ADDRESS_LINES		equ 9

PAL_EXT_RAM_START		equ $1200
PAL_EXT_RAM_SIZE		equ $200
PAL_EXT_RAM_ADDRESS_LINES	equ 9

WORK_RAM_START			equ $0000
WORK_RAM_SIZE			equ $1000
WORK_RAM_ADDRESS_LINES		equ 12

; size of each individual palette
PAL_SIZE			equ $10

ACK_NMI				equ $380b
ACK_FIRQ			equ $380c
ACK_IRQ				equ $380d
ACK_MCU				equ $380f

; input addresses
INPUT_P1			equ $3800
INPUT_P2			equ $3801
INPUT_EXTRA			equ $3802
INPUT_DSW0			equ $3803
INPUT_DSW1			equ $3804

; buttons
UP				equ $04
DOWN				equ $08
LEFT				equ $02
RIGHT				equ $01
A_BUTTON			equ $10
B_BUTTON			equ $20

; these are on the extra input
C_P1_BUTTON			equ $02
C_P2_BUTTON			equ $01

; fg stuff
FG_TILES_PER_ROW		equ $40

REG_BANKSWITCH		equ $3808
REG_SOUND		equ $380e

SND_COIN		equ $02
SND_GO			equ $12

