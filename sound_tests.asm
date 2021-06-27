	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global manual_sound_tests
	global STR_SOUND_TESTS

	section text


manual_sound_tests:

		; static text
		FG_XY	10,4
		ldy	#STR_SOUND_TESTS
		JRU	fg_print_string

		FG_XY	2,7
		ldy	#STR_SND_NUM
		JRU	fg_print_string

		FG_XY	2,19
		ldy	#STR_02_12_FM
		JRU	fg_print_string

		FG_XY	2,20
		ldy	#STR_80_BA_PCM
		JRU	fg_print_string

		FG_XY	2,23
		ldy	#STR_JOY_CHANGE
		JRU	fg_print_string

		FG_XY	2,24
		ldy	#STR_A_PLAY
		JRU	fg_print_string

		FG_XY	2,25
		ldy	#STR_B_STOP
		JRU	fg_print_string

		FG_XY	2,26
		ldy	#STR_C_MAIN_MENU
		JRU	fg_print_string

		ldb	#2		; sound number; start at 2 as 0/1 aren't valid

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

		FG_XY	13,7
		tfr	b,a

		pshs	b
		JRU	fg_print_hex_byte
		puls	b

		jmp	.loop_input


STR_SOUND_TESTS:		string "SOUND TESTS"

STR_SND_NUM:			string "SND NUMBER "
STR_02_12_FM:			string "02 TO 12 ARE FM"
STR_80_BA_PCM:			string "80 TO BA ARE PCM"

STR_JOY_CHANGE:			string "JOY - CHANGE SOUND NUMBER"
STR_A_PLAY:			string "A - PLAY SOUND"
STR_B_STOP:			string "B - STOP SOUND"
