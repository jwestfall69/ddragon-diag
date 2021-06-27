	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global auto_obj_ram_tests
	global manual_obj_ram_tests
	global STR_TESTING_OBJ_RAM

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

		ldx	#OBJ_RAM_START
		ldw	#OBJ_RAM_SIZE
		clra
		SSU	ram_fill

		puls	a
		rts

manual_obj_ram_tests:
	rts


STR_TESTING_OBJ_RAM:		string "TESTING OBJ/SPRITE RAM"

