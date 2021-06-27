	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global auto_fg_ram_tests
	global manual_fg_ram_tests
	global STR_TESTING_FG_RAM

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
		rts

STR_TESTING_FG_RAM:		string "TESTING FG RAM"

