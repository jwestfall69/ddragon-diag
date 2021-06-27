	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global manual_sound_tests
	global STR_SOUND_TESTS

	section text


manual_sound_tests:

		; static text
		FG_XY	2,5
		ldy	#STR_SND_NUM
		SSU	fg_print_string

		ldb	#2		; sound number, 0/1 arent a sound.

	.loop_input:
		jsr	input_update
		lda	g_p1_input_edge

	 	bita	#UP
		beq	.up_not_pressed
		incb
	.up_not_pressed:

		bita	#DOWN
		beq	.down_not_pressed
		decb
	.down_not_pressed:

		bita	#LEFT
		beq	.left_not_pressed
		subb	#$10
	.left_not_pressed:

		bita	#RIGHT
		beq	.right_not_pressed
		addb	#$10
	.right_not_pressed:

		bita	#A_BUTTON
		beq	.a_not_pressed
		stb	REG_SOUND
	.a_not_pressed:

		bita	#B_BUTTON
		beq	.b_not_pressed
		lde	REG_SOUND		; reading will cause sound to stop
	.b_not_pressed:

		lda	g_extra_input_edge
		bita	#$2
		beq	.c_not_pressed
		lde	REG_SOUND
		rts

	.c_not_pressed:

		FG_XY	10,5
		tfr	b,a

		pshs	b
		SSU	fg_print_hex_byte
		puls	b

		jmp	.loop_input


STR_SOUND_TESTS:		string "SOUND TESTS"

STR_SND_NUM:			string "SND NUM: "
