	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global auto_bg_ram_tests
	global manual_bg_ram_tests
	global STR_BG_RAM_TESTS

	section text

auto_bg_ram_tests:
		ldd	#BG_RAM_START
		std	g_mt_mem_start_address
		ldd	#BG_RAM_SIZE
		std	g_mt_mem_size
		lda	#BG_RAM_ADDRESS_LINES
		sta	g_mt_mem_address_lines
		lda	#$ff
		sta	g_mt_data_mask

		jsr	mem_tester
		tsta
		beq	.mem_tester_passed
		adda	#(EC_BG_RAM_DEAD_OUTPUT - 1)

	.mem_tester_passed:
		; clear our bg ram to fix the screen
		pshs	a
		ldx	#BG_RAM_START
		ldw	#BG_RAM_SIZE
		clra
		JRU	ram_fill
		puls	a
		rts

manual_bg_ram_tests:

		FG_XY	10,4
		ldy	#STR_BG_RAM_TESTS
		JRU	fg_print_string

		FG_XY	2,12
		ldy	#STR_PASSES
		JRU	fg_print_string

		FG_XY	5,25
		ldy	#STR_A_HOLD_PAUSE
		JRU	fg_print_string

		FG_XY	5,26
		ldy	#STR_C_MAIN_MENU
		JRU	fg_print_string

		ldw	#0		; # of passes
		pshsw

	.loop_next_test:

		pulsw
		tfr	w,d
		pshsw

		FG_XY	12,12
		JRU	fg_print_hex_word

		ldd	#BG_RAM_START
		std	g_mt_mem_start_address
		ldd	#BG_RAM_SIZE
		std	g_mt_mem_size
		lda	#BG_RAM_ADDRESS_LINES
		sta	g_mt_mem_address_lines
		lda	#$ff
		sta	g_mt_data_mask

		jsr	mem_tester
		tsta
		bne	.test_failed

		pulsw
		incw
		pshsw

		jsr	input_update
		lda	g_p1_input_edge

		bita	#A_BUTTON
		beq	.a_not_pressed
		jsr	bg_clear
		jsr	wait_a_release

	.a_not_pressed:

		lda	g_extra_input_edge
		bita	#P1_C_BUTTON
		beq	.loop_next_test

		; fix up stack
		pulsw

		jsr	bg_clear
		rts

	.test_failed:
		adda	#(EC_BG_RAM_DEAD_OUTPUT - 1)

		; clear our bg ram to fix the screen
		pshs	a
		jsr	bg_clear
		puls	a

		jsr	print_error

		FG_XY	10,4
		ldy	#STR_BG_RAM_TESTS
		JRU	fg_print_string

		FG_XY	0,12
		ldy	#STR_PASSES
		JRU	fg_print_string

		pulsw
		tfr	w,d
		FG_XY	12,12
		JRU	fg_print_hex_word

		STALL
		rts

bg_clear:
		ldx	#BG_RAM_START
		ldw	#BG_RAM_SIZE
		clra
		JRU	ram_fill
		rts

STR_BG_RAM_TESTS:		string "BG RAM TESTS"
