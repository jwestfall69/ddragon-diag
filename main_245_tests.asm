	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global auto_main_245_dead_output_test

	section text



; On both ddragon|2 boards there is a single 74ls245
; thats the bus transceiver between the cpu's data
; lines and everything besides the ROMs.
;
; ddragon  its at IC12
; ddragon2 its at IC62
;
; this test checks if that 245 has dead output

MAIN_245_TEST_ADDRESSES_START:
	word	BG_RAM_START, COMM_RAM_START, FG_RAM_START, OBJ_RAM_START
	word	PAL_RAM_START, PAL_EXT_RAM_START, WORK_RAM_START
MAIN_245_TEST_ADDRESSES_END:

auto_main_245_dead_output_test:

		; the 6809 does dummy memory reads of 0xffff
		; when its doesnt need to access the address bus.
		; because of this, reads of memory locations with
		; no/dead output will cause the register to be filled
		; with the lower byte of the reset function's address
		; from the vector table.
		lda	$ffff

		ldy	#MAIN_245_TEST_ADDRESSES_START
		lde	#((MAIN_245_TEST_ADDRESSES_END - MAIN_245_TEST_ADDRESSES_START)/2)

	.loop_next_address:
		ldb	[,y]
		leay	2,y
		cmpr	a,b
		bne	.test_passed
		dece
		bne	.loop_next_address

		; if the 245 is dead its unlikely we will be able
		; to draw on screen or send a byte to the sound
		; cpu, but do it anyways.
		FG_XY	0,5
		ldy	#STR_MAIN_245_DEAD_OUTPUT
		JRU	fg_print_string

		lda	#EC_MAIN_245_DEAD_OUTPUT
		JRU	play_error_code

		lda	#EC_MAIN_245_DEAD_OUTPUT
		JRU	loop_error_address

	.test_passed:
		jmp	auto_main_245_dead_output_passed

	ifdef _BUILD_DD1
STR_MAIN_245_DEAD_OUTPUT:	string "IC12 DEAD OUTPUT"
	else
STR_MAIN_245_DEAD_OUTPUT:	string "IC62 DEAD OUTPUT"
	endif
