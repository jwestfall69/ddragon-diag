	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global auto_comm_ram_tests
	global manual_comm_ram_tests
	global STR_COMM_RAM_TESTS

	section text

; comm ram, shared between cpu the mcu
auto_comm_ram_tests:

		JRU	mcu_halt

		ldd	#COMM_RAM_START
		std	g_mt_mem_start_address
		ldd	#COMM_RAM_SIZE
		std	g_mt_mem_size
		lda	#COMM_RAM_ADDRESS_LINES
		sta	g_mt_mem_address_lines
		lda	#$ff
		sta	g_mt_data_mask

		jsr	mem_tester
		tsta
		beq	.mem_tester_passed
		adda	#(EC_COMM_RAM_DEAD_OUTPUT - 1)

	.mem_tester_passed:
		; clear out comm ram
		pshs	a
		ldx	#COMM_RAM_START
		ldw	#COMM_RAM_SIZE
		clra
		JRU	ram_fill

		JRU	mcu_run
		puls	a
		rts

manual_comm_ram_tests:

		jsr	print_static_text
		JRU	mcu_halt

		ldw	#0		; # of passes
		pshsw

	.loop_next_test:

		pulsw
		tfr	w,d
		pshsw

		FG_XY	12,12
		JRU	fg_print_hex_word

		ldd	#COMM_RAM_START
		std	g_mt_mem_start_address
		ldd	#COMM_RAM_SIZE
		std	g_mt_mem_size
		lda	#COMM_RAM_ADDRESS_LINES
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
		jsr	wait_a_release

	.a_not_pressed:

		lda	g_extra_input_edge
		bita	#P1_C_BUTTON
		beq	.loop_next_test

		; fix up stack
		pulsw
		JRU	mcu_run
		rts

	.test_failed:
		adda	#(EC_COMM_RAM_DEAD_OUTPUT - 1)

		jsr	print_error
		jsr	print_static_text

		pulsw
		tfr	w,d
		FG_XY	12,12
		JRU	fg_print_hex_word

		JRU	mcu_run

		jsr	wait_c_press
		rts

print_static_text:
		FG_XY	9,4
		ldy	#STR_COMM_RAM_TESTS
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
		rts

STR_COMM_RAM_TESTS:		string "COMM RAM TESTS"
