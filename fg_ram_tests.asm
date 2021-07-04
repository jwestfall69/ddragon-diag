	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global auto_fg_ram_tests
	global manual_fg_ram_tests
	global STR_FG_RAM_TESTS

	section text

; foreground video ram test, which is on the
; same ram chip as work ram.  If the chip has
; ijrues will likely trigger the work ram tests
auto_fg_ram_tests:

		ldd	#FG_RAM_START
		std	g_mt_mem_start_address
		ldd	#FG_RAM_SIZE
		std	g_mt_mem_size
		lda	#FG_RAM_ADDRESS_LINES
		sta	g_mt_mem_address_lines
		lda	#$ff
		sta	g_mt_data_mask

		jsr	mem_tester
		tsta
		beq	.mem_tester_passed
		adda	#(EC_FG_RAM_DEAD_OUTPUT - 1)

	.mem_tester_passed:
		rts

manual_fg_ram_tests:
		; not doing print_static_text here
		; cause it will just get nuked when we
		; start testing fg ram

		ldw	#0		; # of passes
		pshsw

	.loop_next_test:
		ldd	#FG_RAM_START
		std	g_mt_mem_start_address
		ldd	#FG_RAM_SIZE
		std	g_mt_mem_size
		lda	#FG_RAM_ADDRESS_LINES
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
		jsr	fg_clear_with_header
		jsr	print_static_text

		pulsw
		tfr	w,d
		pshsw

		FG_XY	12,12
		JRU	fg_print_hex_word

		jsr	wait_a_release
	.a_not_pressed:

		lda	g_extra_input_edge
		bita	#P1_C_BUTTON
		beq	.loop_next_test

		; fix up stack
		pulsw

		; main menu code will handle cleanup
		rts

	.test_failed:
		adda	#(EC_FG_RAM_DEAD_OUTPUT - 1)

		jsr	print_error
		jsr	print_static_text

		pulsw
		tfr	w,d

		FG_XY	12,12
		JRU	fg_print_hex_word

		jsr	wait_c_press
		rts

print_static_text:
		FG_XY	10,4
		ldy	#STR_FG_RAM_TESTS
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

STR_FG_RAM_TESTS:		string "FG RAM TESTS"
