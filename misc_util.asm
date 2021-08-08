	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global delay_jru
	global input_update
	global input_refresh
	global mcu_halt_jru
	global mcu_reset_jru
	global mcu_run_jru
	global palette_init_jru
	global play_error_code_jru
	global ram_fill_jru
	global wait_a_release
	global wait_c_press

	section text

; a = byte
; w = length
; x = start address
ram_fill_jru:
		sta	,x+
		decw
		bne	ram_fill_jru
		JRU_RETURN

; setup palette so text is white on black background
palette_init_jru:

		; make all colors be green by default as a poison
		tfr	u,y
		lda	#$f0
		ldx	#PAL_RAM_START
		ldw	#PAL_RAM_SIZE
		JRU	ram_fill

		lda	#$00
		ldx	#PAL_EXT_RAM_START
		ldw	#PAL_EXT_RAM_SIZE
		JRU	ram_fill
		tfr	y,u

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

		lda     REG_P1_INPUT
		ldx	#g_p1_input_raw
		ldy	#g_p1_input_edge
		jsr	input_refresh

		lda	REG_P2_INPUT
		ldx	#g_p2_input_raw
		ldy	#g_p2_input_edge
		jsr	input_refresh

		lda	REG_EXTRA_INPUT
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
		lda	REG_P1_INPUT
		anda	#A_BUTTON
		beq	wait_a_release
		rts

wait_c_press:
		jsr	input_update
		lda	g_extra_input_edge
		bita	#P1_C_BUTTON
		beq	wait_c_press
		rts

mcu_halt_jru:
		lda	#$18
		jmp	mcu_add_screen_flip_bit

mcu_run_jru:
		lda	#$8
		jmp	mcu_add_screen_flip_bit

; NOTE: on hardware writing 1 to bit 4 on
; REG_BANKSWITCH causes the screen to be upside
; down, 0 right side up.  MAME has the opposite
; logic.  Likewise in game if DSW0 switch 8 is
; in the 'off' position, on hardware the game
; is unside down, in MAME its right side up.
; To work around this we have the following
; code so everyone is right side up, instead of
; just being able to hardcode the bit to 0.
mcu_add_screen_flip_bit:
		ldb	REG_DSW0
		comb
		bitb	#$80
		bne	.skip_screen_flip_bit
		ora	#$4
	.skip_screen_flip_bit:

		sta	REG_BANKSWITCH
		JRU_RETURN


mcu_reset_jru:
		lda	#$0
		ldb	REG_DSW0
		comb
		bitb	#$80
		bne	.skip_screen_flip_bit
		ora	#$4
	.skip_screen_flip_bit:

		sta	REG_BANKSWITCH

		tfr	u,x
		ldw	#$1ff
		JRU	delay

		tfr	x,u

		jmp	mcu_run_jru
