	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global	fg_clear_with_header
	global	fg_fill_line_jru
	global	fg_print_bits_byte_jru
	global	fg_print_hex_byte_jru
	global	fg_print_hex_word_jru
	global	fg_print_string_jru

	section text

; clear the fg and redraw the header
fg_clear_with_header:
		lda	#0
		ldx	#FG_RAM_START
		ldw	#FG_RAM_SIZE
		JRU	ram_fill

		FG_XY	0,1
		ldy	#STR_HEADER
		JRU	fg_print_string

		FG_XY	0,2
		ldb	#'-'
		JRU	fg_fill_line
		rts



; ldx = start location in fg ram (use FG_XY x,y macro)
; ldy = start address of string
fg_print_string_jru:
		lda	#0
		ldb	,y+
	.loop_next_char:
		subb	#$20

	ifdef _BUILD_DD2
		; ddragon2 seems to have a gap between numbers and letters
		cmpb	#$21
		blt	.not_letter
		subb	#$6
	.not_letter:
	endif
		std	,x++
		ldb	,y+
		bne	.loop_next_char
		JRU_RETURN

; ldx = start location in fg ram (use FG_XY x,0 macro)
;   b = char
fg_fill_line_jru:
		lda	#0
		subb	#$20

	ifdef _BUILD_DD2
		; ddragon2 seems to have a gap between numbers and letters
		cmpb	#$21
		blt	.not_letter
		subb	#$6
	.not_letter:
	endif
		ldy	#$20
	.loop_next_column:
		std	,x++
		leay	-1,y
		bne	.loop_next_column
		JRU_RETURN

; prints the bits for the provided byte
; params:
;   x = start location in fg ram (use FG_XY x,y macro)
;   a = byte
fg_print_bits_byte_jru:

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

		JRU_RETURN

; print hex for the provided byte
; params:
;  x = start location in fg ram (use FG_XY x,y macro)
;  a = byte
fg_print_hex_byte_jru:

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

	ifdef _BUILD_DD1
		addf	#$7		; extra tile offset for a-f letters
	else
		addf	#$1		; extra tile offset for a-f letters
	endif

	.is_digit:
		stw	,x
		leax	-2,x

		rora			; prep a for the next nibble
		rora
		rora
		rora

		cmpr	y,x
		bhs	.loop_next_nibble

		JRU_RETURN

; print hex for the provided word
; params:
;  x = start location in fg ram (use FG_XY x,y macro)
;  d = word
fg_print_hex_word_jru:

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

	ifdef _BUILD_DD1
		addf	#$7		; extra tile offset for a-f letters
	else
		addf	#$1		; extra tile offset for a-f letters
	endif

	.is_digit:
		stw	,x
		leax	-2,x

		rord			; prep b for the next nibble
		rord
		rord
		rord

		cmpr	y,x
		bhs	.loop_next_nibble

		JRU_RETURN

