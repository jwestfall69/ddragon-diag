	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global auto_obj_ram_tests
	global manual_obj_ram_tests
	global STR_TESTING_OBJ_RAM
	global STR_OBJ_RAM_TESTS

	section text

auto_obj_ram_tests:
		ldd	#OBJ_RAM_START
		std	g_mt_mem_start_address
		ldd	#OBJ_RAM_SIZE
		std	g_mt_mem_size
		lda	#OBJ_RAM_ADDRESS_LINES
		sta	g_mt_mem_address_lines
		lda	#$ff
		sta	g_mt_data_mask

		jsr	mem_tester
		tsta
		beq	.mem_tester_passed
		adda	#(EC_OBJ_RAM_DEAD_OUTPUT - 1)

	.mem_tester_passed:
		; clear our obj ram to fix the screen
		pshs	a

		jsr	obj_clear

		puls	a
		rts

manual_obj_ram_tests:

		FG_XY	3,5
		ldy	#STR_OBJ_RAM_TESTS
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

		ldd	#OBJ_RAM_START
		std	g_mt_mem_start_address
		ldd	#OBJ_RAM_SIZE
		std	g_mt_mem_size
		lda	#OBJ_RAM_ADDRESS_LINES
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
		jsr	obj_clear
		jsr	wait_a_release
	.a_not_pressed:

		lda	g_extra_input_edge
		bita	#P1_C_BUTTON
		beq	.loop_next_test

		jsr	obj_clear
		; fix up stack
		pulsw
		rts

	.test_failed:
		adda	#(EC_OBJ_RAM_DEAD_OUTPUT - 1)
		jsr	print_error

		FG_XY	3,5
		ldy	#STR_OBJ_RAM_TESTS
		JRU	fg_print_string

		FG_XY	2,12
		ldy	#STR_PASSES
		JRU	fg_print_string

		pulsw
		tfr	w,d

		FG_XY	12,12
		JRU	fg_print_hex_word

		jsr	obj_clear

		STALL
		rts

obj_clear:
		ldx	#OBJ_RAM_START
		ldw	#OBJ_RAM_SIZE
		clra
		JRU	ram_fill
		rts


STR_TESTING_OBJ_RAM:		string "TESTING OBJ/SPRITE RAM"
STR_OBJ_RAM_TESTS:		string "OBJ/SPRITE RAM TESTS"
