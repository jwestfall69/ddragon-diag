	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global auto_pal_ram_tests
	global manual_pal_ram_tests
	global STR_TESTING_PAL_RAM

	section text

; palette ram (red/green)
auto_pal_ram_tests:
		ldd	#PAL_RAM_START
		std	g_mt_mem_start_address
		ldd	#PAL_RAM_SIZE
		std	g_mt_mem_size
		lda	#PAL_RAM_ADDRESS_LINES
		sta	g_mt_mem_address_lines
		lda	#$ff
		sta	g_mt_data_mask

		jsr	mem_tester
		tsta
		beq	.mem_tester_passed
		adda	#(EC_PAL_RAM_DEAD_OUTPUT - 1)

	.mem_tester_passed:
		pshs	a
		JRU	palette_init
		puls	a
		rts

manual_pal_ram_tests:
		rts

STR_TESTING_PAL_RAM:		string "TESTING PAL RAM"

