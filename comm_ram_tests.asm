	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global auto_comm_ram_tests
	global manual_comm_ram_tests
	global STR_TESTING_COMM_RAM

	section text

; comm ram, shared between cpu the mcu
auto_comm_ram_tests:

		; NOTE: on hardware writing 1 to bit 4 on
		; REG_BANKSWITCH causes the screen to be upside
		; down, 0 right side up.  MAME has the opposite
		; logic.  Likewise in game if DSW0 switch 8 is
		; in the 'off' position, on hardware the game
		; is unside down, in MAME its right side up.

		; halt the MCU so we can fully access the shared
		; ram
		lda	#$18
		sta	REG_BANKSWITCH

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
		SSU	ram_fill


	; this works around hardware vs mame
	; screen flip/flop difference
		ldb	#$8
		lda	INPUT_DSW0
		coma
		bita	#$80
		bne	.skip_flip_bit
		orb	#$4
	.skip_flip_bit:

		; unhalt MCU
		stb	REG_BANKSWITCH
		puls	a
		rts

manual_comm_ram_tests:
		rts

STR_TESTING_COMM_RAM:		string "TESTING COMM RAM"

