	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

; Work ram can't use the normal mem_tester code since it depends
; on work ram.  The below function handle testing work ram

	global auto_work_ram_tests

	section text

auto_work_ram_tests:

		JRU	work_ram_output_test
		tsta
		lbne	work_ram_output_failed

		JRU	work_ram_writable_test
		tsta
		lbne	work_ram_writable_failed

		lde	#0
		JRU	work_ram_data_test
		tsta
		lbne	work_ram_data_failed

		lde	#$55
		JRU	work_ram_data_test
		tsta
		lbne	work_ram_data_failed

		lde	#$aa
		JRU	work_ram_data_test
		tsta
		lbne	work_ram_data_failed

		lde	#$ff
		JRU	work_ram_data_test
		tsta
		lbne	work_ram_data_failed

		JRU	work_ram_address_test
		tsta
		lbne	work_ram_address_failed

		; jump back to _start
		jmp	auto_work_ram_tests_passed

; The data connection between the cpu and ram chips looks like
;
; cpu <=> 245 (IC12) <=> 245 for specific ram chip <=> specific ram chip
;
; When a 245 has floating input pins the output will be 0xff.
; This test will attempt to detect if the ram chip or its
; specific 245 are not outputing anything.
; returns
;  a = (0 = pass, 1 = fail)
work_ram_output_test_jru:
		ldx	#WORK_RAM_START
		tfr	u,y		; backup u so we can do a nested delay call
		lda	#1		; counter and value we will write

	.loop_next_address:
		sta	0,x		; write our incrementing value

		ldw	#$1ff		; wait a little bit
		JRU	delay

		lde	,x+		; read it back
		cmpe	#$ff
		bne	.test_passed

		inca
		cmpa	#$ff
		bne	.loop_next_address

		tfr	y,u
		lda	#1
		JRU_RETURN

	.test_passed:
		tfr	y,u
		clra
		JRU_RETURN

; Read a byte from ram, write !byte back, then re-read it. If
; the re-read byte is the original byte ram is unwritable.
; returns
;  a = (0 = pass, 1 = fail)
work_ram_writable_test_jru:
		ldx	#WORK_RAM_START
		lda	0,x
		tfr	a,b
		coma

		sta	0,x
		cmpb	0,x
		beq	.test_failed

		clra
		JRU_RETURN

	.test_failed:
		lda	#1
		JRU_RETURN

; This tests the supplied byte pattern byte pattern
; params
;   e = byte to write/read
; return
;   a = (0 = pass, 1 = fail)
;   b = fail data
;   x = fail address
work_ram_data_test_jru:
		ldx	#WORK_RAM_START
		ldy	#WORK_RAM_SIZE

	.loop_next_address:

		ste	0,x
		ldf	0,x
		cmpr	e,f
		bne	.test_failed

		leax	1,x
		leay	-1,y
		cmpy	#0
		bne	.loop_next_address
		clra

		JRU_RETURN

	.test_failed:
		lda	#1
		tfr	f,b
		JRU_RETURN


; return
;   a = (0 = pass, 1 = fail)
;   e = actual value
;   b = expected value
work_ram_address_test_jru:
		ldx	#WORK_RAM_START
		lda	#WORK_RAM_ADDRESS_LINES

		deca
		tfr	a,e	; can only lsl on d
		tfr	a,y	;
		ldf	#1	; byte we will write at offset
		ldd	#0	; offset from start address

		stf	0,x
		incf
		incd

	.loop_write_next_address:
		stf	d,x

		lsld
		incf

		dece
		bpl	.loop_write_next_address

		ldd	#0
		tfr	y,e
		ldf	#1
		cmpf	0,x
		bne	.test_failed

		incf
		incd

	.loop_read_next_address:
		cmpf	d,x
		bne	.test_failed

		lsld
		incf
		dece
		bpl	.loop_read_next_address

		lda	#0
		JRU_RETURN

	.test_failed:
		ldb	d,x
		tfr	f,e
		lda	#1
		JRU_RETURN


work_ram_output_failed:
		FG_XY	0,5
		ldy	#STR_WORK_RAM_DEAD_OUTPUT
		JRU	fg_print_string

		lda	#EC_WORK_RAM_DEAD_OUTPUT
		JRU	play_error_code
		STALL

work_ram_writable_failed:
		FG_XY	0,5
		ldy	#STR_WORK_RAM_UNWRITABLE
		JRU	fg_print_string

		lda	#EC_WORK_RAM_UNWRITABLE
		JRU	play_error_code
		STALL

; I believe there might be a little risk below
; in that we are using the stack register to
; temp store data.  I'm unsure, but it seems like
; if the nmi pin is floating it may cause the cpu
; to trigger the nmi vector since we touched the
; stack register.
work_ram_data_failed:

		; e = expected value
		; b = actual value
		; x = address
		tfr	e,a
		tfr	d,s			; save expected + actual to stack register
		tfr	x,d			; failed address to d
		FG_XY	10,7
		JRU	fg_print_hex_word

		tfr	s,d			; restore expected + bad data
		FG_XY	12,8
		JRU	fg_print_hex_byte

		tfr	s,d			; restore expected + bad again
		exg	a,b			; bad data
		FG_XY	12,9
		JRU	fg_print_hex_byte

		FG_XY	0,5
		ldy	#STR_WORK_RAM_DATA
		JRU	fg_print_string

		FG_XY	0,7
		ldy	#STR_ADDRESS
		JRU	fg_print_string

		FG_XY	0,8
		ldy	#STR_EXPECTED
		JRU	fg_print_string

		FG_XY	0,9
		ldy	#STR_ACTUAL
		JRU	fg_print_string

		lda	#EC_WORK_RAM_DATA
		JRU	play_error_code

		STALL

work_ram_address_failed:

		; b = actual value
		; f = expected
		tfr	f,s			; save expected to stack register
		tfr	b,a			; actual
		FG_XY	12,8
		JRU	fg_print_hex_byte

		tfr	s,a			; restore expected
		FG_XY	12,7
		JRU	fg_print_hex_byte

		FG_XY	0,5
		ldy	#STR_WORK_RAM_ADDRESS
		JRU	fg_print_string

		FG_XY	0,7
		ldy	#STR_EXPECTED
		JRU	fg_print_string

		FG_XY	0,8
		ldy	#STR_ACTUAL
		JRU	fg_print_string

		lda	#EC_WORK_RAM_ADDRESS
		JRU	play_error_code

		STALL


; work ram error strings
STR_WORK_RAM_DEAD_OUTPUT:	string "WORK RAM DEAD OUTPUT"
STR_WORK_RAM_UNWRITABLE:	string "WORK RAM UNWRITABLE"
STR_WORK_RAM_DATA:		string "WORK RAM DATA"
STR_WORK_RAM_ADDRESS:		string "WORK RAM ADDRESS"
