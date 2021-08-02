        include "ddragon.inc"
        include "ddragon_diag.inc"
        include "macros.inc"

	global manual_mem_viewer
	global STR_MEM_VIEWER

	section text

g_start_address		equ g_local_vars_start
g_fg_offset		equ g_local_vars_start+2

manual_mem_viewer:

		FG_XY	4,3
		ldy	#STR_ADDR
		JRU	fg_print_string

		FG_XY	16,3
		ldy	#STR_DATA
		JRU	fg_print_string

		FG_XY	5,26
		ldy	#STR_NAVIGATE
		JRU	fg_print_string

		FG_XY	5,27
		ldy	#STR_C_MAIN_MENU
		JRU	fg_print_string

		ldd	#BG_RAM_START
		std	g_start_address

	.loop_input:
		jsr	input_update
		lda	g_p1_input_edge
		ldw	g_start_address
		bita	#UP
		beq	.up_not_pressed
		subw	#$8
		jmp	.update_screen
	.up_not_pressed:

		bita	#DOWN
		beq	.down_not_pressed
		addw	#$8
		jmp	.update_screen
	.down_not_pressed:

		bita	#RIGHT
		beq	.right_not_pressed
		addw	#$100
		jmp	.update_screen
	.right_not_pressed:

		bita	#LEFT
		beq	.left_not_pressed
		subw	#$100
		jmp	.update_screen
	.left_not_pressed:

		lda	g_extra_input_edge
		bita	#P1_C_BUTTON
		beq	.update_screen
		rts

	.update_screen:
		stw	g_start_address
		jsr	draw_screen
		jmp	.loop_input
		rts


draw_screen:
		FG_XY	4,4
		stx	g_fg_offset
		ldy	g_start_address
		lde	#20

	.loop_next_line:
		ldx	g_fg_offset
		leax	$40,x
		stx	g_fg_offset
		pshsw

		tfr	y,d
		pshs	x,y
		JRU	fg_print_hex_word
		puls	x,y

		jsr	print_next_word
		jsr	print_next_word
		jsr	print_next_word
		jsr	print_next_word

		pulsw
		dece
		bne	.loop_next_line

		rts

print_next_word:
		leax	10,x
		ldd	,y++
		pshs	x,y
		JRU	fg_print_hex_word
		puls	x,y
		rts

STR_MEM_VIEWER:		string "MEM VIEWER"

STR_NAVIGATE:		string "U/D/L/R - NAVIGATE"
STR_ADDR:		string "ADDR"
STR_DATA:		string "DATA"
