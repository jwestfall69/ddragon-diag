	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global manual_video_dac_tests
	global STR_VIDEO_DAC_TESTS

	section text

	ifdef _BUILD_DD1
; 4 tiles that are filled with a unique
; palette color index
RED_TILE			equ $062
GREEN_TILE			equ $3ff
BLUE_TILE			equ $2e6
COMBINED_TILE			equ $105

; color index in each palette for the
; fgiven tile
RED_TILE_COLOR_INDEX		equ $1
GREEN_TILE_COLOR_INDEX		equ $3
BLUE_TILE_COLOR_INDEX		equ $c
COMBINED_TILE_COLOR_INDEX	equ $e

	else
; 4 tiles that are filled with a unique
; palette color index
RED_TILE			equ $201
GREEN_TILE			equ $223
BLUE_TILE			equ $207
COMBINED_TILE			equ $229

; color index in each palette for the
; fgiven tile
RED_TILE_COLOR_INDEX		equ $7
GREEN_TILE_COLOR_INDEX		equ $3
BLUE_TILE_COLOR_INDEX		equ $5
COMBINED_TILE_COLOR_INDEX	equ $9

	endif

manual_video_dac_tests:
		jsr	fg_clear_with_header
		jsr	setup_palettes
		jsr	draw_screen

	.loop_input:
		jsr	input_update
		lda	g_p1_input_edge

		bita	#A_BUTTON
		beq	.a_not_pressed
		jsr	full_screen
		jmp	manual_video_dac_tests
	.a_not_pressed:

		lda	g_extra_input_edge
		bita	#P1_C_BUTTON
		beq	.loop_input

		rts


; will use palettes 0 to 4
; palette 0 = 0 color bit enabled
; palette 1 = 1 color bit enabled
; palette 2 = 2 color bit enabled
; palette 3 = 3 color bit enabled
; palette 4 = ALL color bits enabled
setup_palettes:

		lde	#4		; number of color bits
		ldx	#PAL_RAM_START
		ldy	#PAL_EXT_RAM_START

		lda	#$01		; red/blue
		ldb	#$10		; green
		ldf	#$11		; combined

	.loop_next_color_bit:
		sta	RED_TILE_COLOR_INDEX,x
		sta	BLUE_TILE_COLOR_INDEX,y
		stb	GREEN_TILE_COLOR_INDEX,x

		; this makes sure the color value on the
		; other pal memory is empty
		pshs	a
		lda	#0
		sta	RED_TILE_COLOR_INDEX,y
		sta	BLUE_TILE_COLOR_INDEX,x
		sta	GREEN_TILE_COLOR_INDEX,y
		puls	a

		stf	COMBINED_TILE_COLOR_INDEX,x
		stf	COMBINED_TILE_COLOR_INDEX,y

		leax	PAL_SIZE,x
		leay	PAL_SIZE,y

		; shift over to next color bit
		lsla
		lslb
		exg	a,f
		lsla			; no lslf instruction
		exg	f,a

		dece
		bne	.loop_next_color_bit

		; all bits for each
		lda	#$0f		; red/blue
		ldb	#$f0		; green
		ldf	#$ff		; combined

		sta	RED_TILE_COLOR_INDEX,x
		sta	BLUE_TILE_COLOR_INDEX,y
		stb	GREEN_TILE_COLOR_INDEX,x

		lda	#0
		sta	RED_TILE_COLOR_INDEX,y
		sta	BLUE_TILE_COLOR_INDEX,x
		stb	GREEN_TILE_COLOR_INDEX,y

		stf	COMBINED_TILE_COLOR_INDEX,x
		stf	COMBINED_TILE_COLOR_INDEX,y

		rts

draw_screen:

		FG_XY	8,4
		ldy	#STR_VIDEO_DAC_TESTS
		JRU	fg_print_string

		FG_XY	7,6
		ldy	#STR_BIT_HEADER
		JRU	fg_print_string

		FG_XY	6,7
		ldw	#RED_TILE
		jsr	draw_color_block_row

		FG_XY	6,11
		ldw	#GREEN_TILE
		jsr	draw_color_block_row

		FG_XY	6,15
		ldw	#BLUE_TILE
		jsr	draw_color_block_row

		FG_XY	6,19
		ldw	#COMBINED_TILE
		jsr	draw_color_block_row

		FG_XY	5,25
		ldy	#STR_A_FULLSCREEN
		JRU	fg_print_string

		FG_XY	5,26
		ldy	#STR_C_MAIN_MENU
		JRU	fg_print_string

		rts

; x = location in fg ram to start at
; w = tile
draw_color_block_row:

		tfr	x,y
		tfr	w,u
		ldb	#$4		; block height

	.loop_next_row:
		tfr	u,w
		lda	#$5		; number of blocks

	.loop_next_color_bit:
		stw	,y++
		stw	,y++
		stw	,y++
		stw	,y++

		adde	#$20		; next pal

		deca
		bne	.loop_next_color_bit

		leax	$40,x		; next row
		tfr	x,y

		decb
		bne	.loop_next_row

		rts


FS_TILE_LIST:	word RED_TILE,GREEN_TILE,BLUE_TILE,COMBINED_TILE

full_screen:

		ldw	#RED_TILE
		jsr	fg_fill
		ldw	#0			; e is palette, f is index in TILES

	.loop_input:
		jsr	input_update
		lda	g_p1_input_edge

		bita	#UP
		beq	.up_not_pressed
		decf
		bpl	.redraw_fullscreen
		ldf	#3
		jmp	.redraw_fullscreen
	.up_not_pressed:

		bita	#DOWN
		beq	.down_not_pressed
		incf
		cmpf	#3
		ble	.redraw_fullscreen
		ldf	#0
		jmp	.redraw_fullscreen
	.down_not_pressed:

		bita	#RIGHT
		beq	.right_not_pressed
		ince
		cmpe	#4
		ble	.redraw_fullscreen
		lde	#0
		jmp	.redraw_fullscreen
	.right_not_pressed:

		bita	#LEFT
		beq	.left_not_pressed
		dece
		bpl	.redraw_fullscreen
		lde	#4
		jmp	.redraw_fullscreen

	.left_not_pressed:
		lda	g_extra_input_edge

		bita	#P1_C_BUTTON
		beq	.loop_input
		rts

	.redraw_fullscreen:
		pshsw
		tfr	w,d

		; adjust the raw value to be the pallete number
		lsla
		lsla
		lsla
		lsla
		lsla

		; 2x dealing with words, lookup tile
		lslb
		ldx	#FS_TILE_LIST
		ldw	b,x

		; merge the pallete/tile data and fill screen
		ldb	#0
		adcr	d,w
		jsr	fg_fill

		pulsw
		jmp	.loop_input

; w = tile
fg_fill:
		pshs	d

		ldx	#FG_RAM_START
		ldd	#(FG_RAM_SIZE / 2)

	.loop_next_word:
		stw	,x++
		decd
		bne	.loop_next_word

		puls	d
		rts

STR_VIDEO_DAC_TESTS:		string "VIDEO DAC TESTS"
STR_BIT_HEADER:			string "B0  B1  B2  B3  ALL"
STR_A_FULLSCREEN:		string "A - FULLSCREEN"





