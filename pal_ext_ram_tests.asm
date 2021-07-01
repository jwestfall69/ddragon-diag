	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global auto_pal_ext_ram_tests
	global manual_pal_ext_ram_tests
	global STR_PAL_EXT_RAM_TESTS

	section text

; extra/extended palette ram (blue), which is 4 bit data
auto_pal_ext_ram_tests:
		ldd	#PAL_EXT_RAM_START
		std	g_mt_mem_start_address
		ldd	#PAL_EXT_RAM_SIZE
		std	g_mt_mem_size
		lda	#PAL_EXT_RAM_ADDRESS_LINES
		sta	g_mt_mem_address_lines
		lda	#$0f				; lower 4 bits only
		sta	g_mt_data_mask

		jsr	mem_tester
		tsta
		beq	.mem_tester_passed
		adda	#(EC_PAL_EXT_RAM_DEAD_OUTPUT - 1)

	.mem_tester_passed:
		pshs	a
		JRU	palette_init
		puls	a
		rts

manual_pal_ext_ram_tests:

		jsr	print_static_text
		ldw	#0		; # of passes
		pshsw

	.loop_next_test:

		pulsw
		tfr	w,d
		pshsw

		FG_XY	12,12
		JRU	fg_print_hex_word

		ldd	#PAL_EXT_RAM_START
		std	g_mt_mem_start_address
		ldd	#PAL_EXT_RAM_SIZE
		std	g_mt_mem_size
		lda	#PAL_EXT_RAM_ADDRESS_LINES
		sta	g_mt_mem_address_lines
		lda	#$0f				; lower 4 bits only
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
		JRU	palette_init
		jsr	wait_a_release
	.a_not_pressed:

		lda	g_extra_input_edge
		bita	#P1_C_BUTTON
		beq	.loop_next_test

		; fix up stack
		pulsw

		JRU	palette_init
		rts


	.test_failed:
		adda	#(EC_PAL_EXT_RAM_DEAD_OUTPUT - 1)

		pshs	a
		JRU	palette_init
		puls	a

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
		ldy	#STR_PAL_EXT_RAM_TESTS
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
STR_PAL_EXT_RAM_TESTS:		string "PAL EXT RAM TESTS"
