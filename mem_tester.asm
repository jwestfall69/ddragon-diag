; generic memory tester which will test for follow:
;  - dead output
;  - writable
;  - data tests
;  - address line tests
; prior to calling this the following variable
; need to be setup:
;  - g_mt_mem_start_address
;  - g_mt_mem_size
;  - g_mt_mem_address_lines
;  - g_mt_data_mask

        include "ddragon.inc"
        include "ddragon_diag.inc"
        include "error_codes.inc"
        include "macros.inc"

	section text
	global mem_tester

mem_tester:
		jsr	mem_tester_output
		tsta
		beq	.mem_output_passed
		lda	#MT_ERROR_DEAD_OUTPUT
		rts
	.mem_output_passed:

		jsr	mem_tester_writable
		tsta
		beq	.mem_writable_passed
		lda	#MT_ERROR_UNWRITABLE
		rts
	.mem_writable_passed:
		jsr	mem_tester_data
		tsta
		beq	.mem_data_passed
		lda	#MT_ERROR_DATA
		rts
	.mem_data_passed:

		jsr	mem_tester_address
		tsta
		beq	.mem_address_passed
		lda	#MT_ERROR_ADDRESS
		rts
	.mem_address_passed:

		clra	; all tests passed
		rts

; The data connection between the cpu and ram chips looks like
;
; cpu <=> 245 (IC12) <=> 245 for specific ram chip <=> specific ram chip
;
; When a 245 has floating input pins the output will be 0xff.
; This test will attempt to detect if the ram chip or its
; specific 245 are not outputing anything.
; returns
;  a = (0 = pass, 1 = fail)
mem_tester_output:
		lda	#1	; counter and value we will write
		ldx	g_mt_mem_start_address

	.loop_next_address:
		sta	0,x	; write our incrementing value

		ldw	#$1ff	; wait a little bit
		SSU	delay

		lde	,x+	; read it back
		cmpe	#$ff
		bne	.test_passed

		inca
		cmpa	#$ff
		bne	.loop_next_address

		lda     #1
		rts

	.test_passed:
		clra
		rts

; Read a byte from ram, write !byte back, then re-read it. If
; the re-read byte is the original byte ram is unwritable.
; returns
;  a = (0 = pass, 1 = fail)
mem_tester_writable:
		ldx	g_mt_mem_start_address
		lda	0,x
		tfr	a,b
		coma

		sta	0,x
		cmpb	0,x
		beq	.test_failed

		clra
		rts

	.test_failed:
		lda	#1
		rts

MEM_TESTER_DATA_PATTERNS_START:
	byte	$00,$55,$aa,$ff
MEM_TESTER_DATA_PATTERNS_END:

; This tests all byte patterns in our list above
; returns
;  a = (0 = pass, 1 = fail)
mem_tester_data:

		ldy	#MEM_TESTER_DATA_PATTERNS_START
		ldb	#(MEM_TESTER_DATA_PATTERNS_END - MEM_TESTER_DATA_PATTERNS_START)

	.loop_next_pattern:
		ldx	g_mt_mem_start_address
		ldw	g_mt_mem_size

		lda	,y+
		anda	g_mt_data_mask

	.loop_next_address:
		sta	0,x

		pshs	b
		ldb	,x+
		andb	g_mt_data_mask
		cmpr	a,b
		puls	b
		bne	.test_failed

		decw
		bne	.loop_next_address

		decb
		bne	.loop_next_pattern

		clra
		rts

	.test_failed:
		leax	-1,x
		stx	g_mt_error_address
		sta	g_mt_error_expected
		stb	g_mt_error_actual
		lda	#1
		rts


; write an incrementing byte at each address line,
; then read the back to verify they match
; returns
;  a = (0 = pass, 1 = fail)
mem_tester_address:
		ldx	g_mt_mem_start_address
		lde	g_mt_mem_address_lines

		ldf	#1	; byte we will write at offset
		clrd		; offset from start address

                stf	0,x	; special write for address line 0
                incf
                incd

	; write remaining address lines
	.loop_write_next_address:
		stf     d,x

		lsld
		incf

		dece
                bne	.loop_write_next_address

		; reset, and see if values match on re-read
		clrd
		lde	g_mt_mem_address_lines

		ldf	#1
		pshs	a
		lda	0,x
		anda	g_mt_data_mask
		cmpr	a,f
		bne	.test_failed
		puls	a

		incf
		incd

	.loop_read_next_address:
		pshs	a
		lda	d,x
		anda	g_mt_data_mask
		cmpr	a,f
		bne	.test_failed
		puls	a

		lsld
		incf
		dece
		bne	.loop_read_next_address

		clra
		rts

	.test_failed:
		stf	g_mt_error_expected
		sta	g_mt_error_actual
		puls	a	; fix stack
                lda	#1
		rts
