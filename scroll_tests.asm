	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global manual_scroll_tests
	global STR_SCROLL_TESTS

	section text

g_scrollx_offset		equ g_local_vars_start
g_scrolly_offset		equ g_local_vars_start+2

manual_scroll_tests:

		ldd	#$0
		std	g_scrollx_offset
		std	g_scrolly_offset

		jsr	print_static_text
		jsr	print_dynamic_text
		jsr	setup_palette
		jsr	setup_bg

	.loop_input:

		; scrolling will be handled by raw input
		lda	INPUT_P1
		coma

		bita	#RIGHT
		beq	.right_not_pressed
		ldw	g_scrollx_offset
		decw
		stw	g_scrollx_offset
	.right_not_pressed:

		bita	#LEFT
		beq	.left_not_pressed
		ldw	g_scrollx_offset
		incw
		stw	g_scrollx_offset
	.left_not_pressed:

		bita	#DOWN
		beq	.down_not_pressed
		ldw	g_scrolly_offset
		decw
		stw	g_scrolly_offset
	.down_not_pressed:

		bita	#UP
		beq	.up_not_pressed
		ldw	g_scrolly_offset
		incw
		stw	g_scrolly_offset
	.up_not_pressed:

		jsr	input_update
		lda	g_extra_input_edge

		bita	#P1_C_BUTTON
		beq	.c_not_pressed

		; cleanup and return to main menu
		lda	#0
		ldx	#BG_RAM_START
		ldw	#BG_RAM_SIZE
		JRU	ram_fill
		rts

	.c_not_pressed:
		jsr	scroll_update
		jsr	print_dynamic_text

		ldw	#$2ff
		JRU	delay
		jmp	.loop_input


; make the scrol values active, the upper bit
; need to goto REG_BANKSWITCh, and lower 8 bits
; goto REG_SCROLL(X|Y)
scroll_update:
		; start by figuring out scroll high bits
		; needed on REG_BANKSWITCH
		ldd	g_scrollx_offset
		jsr	scroll_num_wrap
		std	g_scrollx_offset

		andd	#$100
		tfr	a,b
		exg	d,w

		ldd	g_scrolly_offset
		jsr	scroll_num_wrap
		std	g_scrolly_offset

		andd	#$100
		tfr	a,b
		aslb
		orr	b,f

		; f should now contain the scroll x/y bits
		; needed for REG_BANKSWITCH
		ldb	#$8		; start with mcu not halted/reset
		lda	INPUT_DSW0
		coma
		bita	#$80
		bne	.skip_screen_flip_bit
		orb	#$4
	.skip_screen_flip_bit:

		orr	b,f
		stf	REG_BANKSWITCH

		ldd	g_scrollx_offset
		stb	REG_SCROLLX

		ldd	g_scrolly_offset
		stb	REG_SCROLLY
		rts

; scroll values are only valid between 0 - 0x1ff
; this function deals with wrapping the values
; around
; d = scroll value
scroll_num_wrap:
		bita	#$80
		beq	.test_greater
		ldd	#$1ff
		rts

	.test_greater:
		bita	#$02
		beq	.no_change
		ldd	#$0

	.no_change:
		rts

; sets up a checker board pattern of bg tiles
setup_bg:
		ldx	#(BG_RAM_START - 2)
		lde	#$40

		; 2nd bg palette, tile 1.  tile doesn't
		; matter here since we setting all colors
		; in the palette the same
		ldd	#$0801

	.loop_next_row:

		; this deal with the row offset
		; so we get the checker board
		; instead of bars
		leax	2,x
		exg	x,d
		bitd	#$4
		beq	.skip_adjust
		subd	#4
	.skip_adjust:
		exg	x,d

		ldf	#$8

	.loop_next_address:
		std	0,x
		leax	4,x

		decf
		bne	.loop_next_address

		dece
		bne	.loop_next_row
		rts

; bg palettes start at palette 16. We will
; use the 17th since 16th seems to be the
; default background color.  Will use magenta
; for the color.
setup_palette:
		lde	#16	; 16 colors in the palette

		ldx	#(PAL_RAM_START + (17 * PAL_SIZE))
		ldy	#(PAL_EXT_RAM_START + (17 * PAL_SIZE))
		lda	#$0F

	.loop_next_color:
		sta	,x+
		sta	,y+

		dece
		bne	.loop_next_color
		rts

print_static_text:
		FG_XY	10,4
		ldy	#STR_SCROLL_TESTS
		JRU 	fg_print_string

		FG_XY	2,12
		ldy	#STR_SCROLLX
		JRU	fg_print_string

		FG_XY	2,13
		ldy	#STR_SCROLLY
		JRU	fg_print_string

		FG_XY	5,25
		ldy	#STR_JOY_SCROLL
		JRU	fg_print_string

		FG_XY	5,26
		ldy	#STR_C_MAIN_MENU
		JRU	fg_print_string
		rts

print_dynamic_text:
		FG_XY	12,12
		ldd	g_scrollx_offset
		JRU	fg_print_hex_word

		FG_XY	12,13
		ldd	g_scrolly_offset
		JRU	fg_print_hex_word
		rts

STR_SCROLL_TESTS:		string "SCROLL TESTS"

STR_SCROLLX:			string "SCROLL X"
STR_SCROLLY:			string "SCROLL Y"
STR_JOY_SCROLL:			string "JOY - SCROLL"
