	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

; Work ram can't use the normal mem_tester code since it depends
; on work ram.  The below function handle testing work ram

	global work_ram_output_ssu
	global work_ram_writable_ssu
	global work_ram_data_ssu
	global work_ram_address_ssu

	section text
; The data connection between the cpu and ram chips looks like
;
; cpu <=> 245 (IC12) <=> 245 for specific ram chip <=> specific ram chip
;
; When a 245 has floating input pins the output will be 0xff.
; This test will attempt to detect if the ram chip or its
; specific 245 are not outputing anything.
; returns
;  a = (0 = pass, 1 = fail)
work_ram_output_ssu:
		ldx	#WORK_RAM_START
		tfr	u,y		; backup u so we can do a nested delay call
		lda	#1		; counter and value we will write

	.loop_next_address:
		sta	0,x		; write our incrementing value

		ldw	#$1ff		; wait a little bit
		SSU	delay

		lde	,x+		; read it back
		cmpe	#$ff
		bne	.test_passed

		inca
		cmpa	#$ff
		bne	.loop_next_address

		tfr	y,u
		lda	#1
		SSU_RETURN

	.test_passed:
		tfr	y,u
		clra
		SSU_RETURN

; Read a byte from ram, write !byte back, then re-read it. If
; the re-read byte is the original byte ram is unwritable.
; returns
;  a = (0 = pass, 1 = fail)
work_ram_writable_ssu:
		ldx	#WORK_RAM_START
		lda	0,x
		tfr	a,b
		coma

		sta	0,x
		cmpb	0,x
		beq	.test_failed

		clra
		SSU_RETURN

	.test_failed:
		lda	#1
		SSU_RETURN

; This tests the supplied byte pattern byte pattern
; params
;   e = byte to write/read
; return
;   a = (0 = pass, 1 = fail)
;   b = fail data
;   x = fail address
work_ram_data_ssu:
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

		SSU_RETURN

	.test_failed:
		lda	#1
		tfr	f,b
		SSU_RETURN


; return
;   a = (0 = pass, 1 = fail)
;   e = actual value
;   b = expected value
work_ram_address_ssu:
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
		SSU_RETURN

	.test_failed:
		ldb	d,x
		tfr	f,e
		lda	#1
		SSU_RETURN
