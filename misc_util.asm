	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global delay_jru
	global input_update
	global palette_init_jru
	global play_error_code_jru
	global ram_fill_jru
	global wait_a_release

	section text

; a = byte
; w = length
; x = start address
ram_fill_jru:
		sta	,x+
		decw
		bne	ram_fill_jru
		JRU_RETURN

; setup palette to text is white
palette_init_jru:
		lda	#$ff				; text color
		sta	(PAL_RAM_START + 2)
		sta	(PAL_EXT_RAM_START + 2)

		lda	#$0
		sta	(PAL_RAM_START + 256)		; back ground color
		sta	(PAL_EXT_RAM_START + 256)
		JRU_RETURN

; busy loop
; params:
;  w = number of loop (#$ffff is roughly 1 second)
delay_jru:
		cmpd	#0		; 4 cycles
		cmpd	#0		; 4 cycles
		cmpd	#0		; 4 cycles
		cmpd	#0		; 4 cycles
		cmpd	#0		; 4 cycles
		cmpd	#0		; 4 cycles
		cmpd	#0		; 4 cycles
		cmpd	#0		; 4 cycles
		cmpd	#0		; 4 cycles
		cmpd	#0		; 4 cycles
		decw			; 3 cycles
		bne	 delay_jru 	; 2 cycles
		JRU_RETURN

; plays an error codes 8 bits
; params:
;  a = byte to play
play_error_code_jru:
		tfr	u,x		; backup u so we can do nested jru call
		ldy	#$08

	.loop_next_bit:
		lsla
		bcc	.is_zero
		ldb	#SND_GO
		jmp	.play_sound
	.is_zero:
		ldb	#SND_COIN

	.play_sound:
		stb	REG_SOUND

		ldw	#$6fff
		JRU	delay

		leay	-1,y
		bne	.loop_next_bit

		tfr	x,u
		JRU_RETURN

; refresh all inputs raw/edge values
input_update:
		pshs	a,b,x,y
		pshsw

		; force a small delay to debounce
		ldw	#$ff
		JRU	delay

		lda     INPUT_P1
		ldx	#g_p1_input_raw
		ldy	#g_p1_input_edge
		jsr	input_refresh

		lda	INPUT_P2
		ldx	#g_p2_input_raw
		ldy	#g_p2_input_edge
		jsr	input_refresh

		lda	INPUT_EXTRA
		ldx	#g_extra_input_raw
		ldy	#g_extra_input_edge
		jsr	input_refresh

		pulsw
		puls	a,b,x,y
		rts

; update the raw/edge for the provided input
; params:
;  a = new data
;  x = g_xx_input_raw address
;  y = g_xx_input_edge address
input_refresh:
		coma

		tfr	a,b
		eora	0,x
		andr	b,a

		sta	0,y
		stb	0,x
		rts

wait_a_release:
		lda	INPUT_P1
		anda	#A_BUTTON
		beq	wait_a_release
		rts
