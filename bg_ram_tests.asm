	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global auto_bg_ram_tests
	global manual_bg_ram_tests
	global STR_TESTING_BG_RAM

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
		rts

STR_TESTING_BG_RAM:		string "TESTING BG RAM"

