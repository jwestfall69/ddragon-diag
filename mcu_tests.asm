	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global manual_mcu_tests
        global STR_MCU_TESTS

        section text


manual_mcu_tests:

		jsr	fg_clear_with_header

		FG_XY	12,4
		ldy	#STR_MCU_TESTS
		JRU	fg_print_string

		FG_XY	5,25
		ldy	#STR_A_RE_RUN
		JRU	fg_print_string

		FG_XY	5,26
		ldy	#STR_C_MAIN_MENU
		JRU	fg_print_string

		FG_XY	4,8
		ldy	#STR_IRQ_TEST
		JRU	fg_print_string

	ifdef _BUILD_DD1
		FG_XY	4,9
		ldy	#STR_CHECKSUM
		JRU	fg_print_string
	endif

		JRU	mcu_reset
		JRU	mcu_run

		ldy	#STR_PASS
		jsr	mcu_irq_test
		tsta
		beq	.print_irq_test
		ldy	#STR_FAIL

	.print_irq_test:
		FG_XY	15,8
		JRU	fg_print_string

	ifdef _BUILD_DD1
		ldy	#STR_PASS
		jsr	mcu_checksum_test
		tsta
		beq	.print_checksum_test

		cmpa	#1
		beq	.checksum_bad

		FG_XY	20,9
		ldy	#STR_CHECKSUM_NO_BA
		JRU	fg_print_string
		jmp	.checksum_test_failed

	.checksum_bad:
		FG_XY	20,9
		tfr	b,a
		JRU	fg_print_hex_byte

	.checksum_test_failed:
		ldy	#STR_FAIL

	.print_checksum_test:
		FG_XY	15,9
		JRU	fg_print_string
	endif

	.loop_input:
		jsr	input_update
		lda	g_p1_input_edge
		bita	#A_BUTTON
		beq	.a_not_pressed
		jmp	manual_mcu_tests

	.a_not_pressed:

		lda	g_extra_input_edge

		bita	#P1_C_BUTTON
		beq	.loop_input
		rts

; by sending the mcu an nmi it should send us
; and irq
; return
;  a = (0 = pass, 1 = fail)
mcu_irq_test:
		ldd	#0
		std	g_irq_count

		lda	#$0
		sta	REG_MCU

		ldb	#$ff			; don't wait forever
	.wait_irq:
		lda	g_irq_count+1		; we only care about the lower byte changing
		bne	.test_passed

		ldw	#$ff
		JRU	delay

		decb
		bne	.wait_irq

		lda	#1
		rts

	.test_passed:
		clra
		rts

; When the mcu boots it will create a checksum
; by summing up all the bytes in its internal eprom
; and store the results at $2000 of the shared ram.
; The value should be #$84
; returns
;  a = (0 = pass, 1 = bad checksum, 2 = bus available fail)
;  b = read checksum
mcu_checksum_test:
		JRU	mcu_halt

		; we need to wait for the bus to be available
		; before reading from shared ram, but don't
		; wait too long
		ldb	#$ff
	.wait_bus_available:
		lda	REG_EXTRA_INPUT
		anda	#$10
		beq	.bus_available

		ldw	#$ff
		JRU	delay

		decb
		bne	.wait_bus_available

		; bus never became available
		lda	#2
		jmp	.cleanup

	.bus_available:
		ldb	MCU_CHECKSUM_LOCATION
		clr	MCU_CHECKSUM_LOCATION
		cmpb	#MCU_CHECKSUM
		beq	.test_passed
		lda	#1
		jmp	.cleanup

	.test_passed:
		clra

	.cleanup:
		pshs	a,b
		JRU	mcu_run
		puls	b,a
		rts

STR_MCU_TESTS:		string "MCU TESTS"

STR_A_RE_RUN:		string "A - RE-RUN TESTS"
STR_IRQ_TEST:		string "NMI/IRQ"
STR_CHECKSUM:		string "CHECKSUM"
STR_CHECKSUM_NO_BA:	string "NO BA"

