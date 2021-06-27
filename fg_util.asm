	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global	fg_clear_with_header
	global	fg_fill_line_ssu
	global	fg_print_bits_byte_ssu
	global	fg_print_hex_byte_ssu
	global	fg_print_hex_word_ssu
	global	fg_print_string_ssu

	section text

; clear the fg and redraw the header
fg_clear_with_header:
		lda	#0
		ldx	#FG_RAM_START
		ldw	#FG_RAM_SIZE
		SSU	ram_fill

		FG_XY	0,1
		ldy	#STR_HEADER
		SSU	fg_print_string

		FG_XY	0,2
		ldb	#'-'
		SSU	fg_fill_line
		rts



; ldx = start location in fg ram (use FG_XY x,y macro)
; ldy = start address of string
fg_print_string_ssu:
		lda	#0
		ldb	,y+
	.loop_next_char:
		subb	#$20
		std	,x++
		ldb	,y+
		bne	.loop_next_char
		SSU_RETURN

; ldx = start location in fg ram (use FG_XY x,0 macro)
;   b = char
fg_fill_line_ssu:
		lda	#0
		subb	#$20
		ldy	#$20
	.loop_next_column:
		std	,x++
		leay	-1,y
		bne	.loop_next_column
		SSU_RETURN

; prints the bits for the provided byte
; params:
;   x = start location in fg ram (use FG_XY x,y macro)
;   a = byte
fg_print_bits_byte_ssu:

		; will be printing backwards, so offset x
		ldb	#(2 * 7)
		abx

		ldb	#8
	.loop_next_bit:
		bita	#1
		beq	.print_zero

		ldw	#$0011		; '1' tile
		jmp	.do_print

	.print_zero:
		ldw	#$0010		; '0' tile

	.do_print:
		stw	,x
		leax	-2,x
		rora
		decb
		bne	.loop_next_bit

		SSU_RETURN

; print hex for the provided byte
; params:
;  x = start location in fg ram (use FG_XY x,y macro)
;  a = byte
fg_print_hex_byte_ssu:

		tfr	x,y

		; will be printing backwards, so offset x
		leax	2, x
		ldw	#0		; we will use w for writing to fg ram

	.loop_next_nibble:

		ldf	#$f
		andr	a,f

		addf	#$10		; base tile offset to get us to '0'
		cmpf	#$19
		ble	.is_digit
		addf	#$7		; extra tile offset for a-f letters

	.is_digit:
		stw	,x
		leax	-2,x

		rora			; prep a for the next nibble
		rora
		rora
		rora

		cmpr	y,x
		bhs	.loop_next_nibble

		SSU_RETURN

; print hex for the provided word
; params:
;  x = start location in fg ram (use FG_XY x,y macro)
;  d = word
fg_print_hex_word_ssu:

		tfr	x,y

		; will be printing backwards, so offset x
		leax	6, x
		ldw	#0		; we will use w for writing to fg ram

	.loop_next_nibble:

		ldf	#$f
		andr	b,f

		addf	#$10		; base tile offset to get us to '0'
		cmpf	#$19
		ble	.is_digit
		addf	#$7		; extra tile offset for a-f letters

	.is_digit:
		stw	,x
		leax	-2,x

		rord			; prep b for the next nibble
		rord
		rord
		rord

		cmpr	y,x
		bhs	.loop_next_nibble

		SSU_RETURN

