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
		rts

STR_TESTING_COMM_RAM:		string "TESTING COMM RAM"

