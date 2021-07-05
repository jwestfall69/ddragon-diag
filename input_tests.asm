	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global manual_input_tests
	global STR_INPUT_TESTS

	section text

g_start_b_pressed		equ g_local_vars_start
g_vblank_pulses			equ g_local_vars_start+1

manual_input_tests:

		clrd
		sta	g_start_b_pressed
		std	g_vblank_pulses
		std	g_nmi_count
		std	g_irq_count
		std	g_firq_count
		std	g_swi_count
		jsr	print_static_text

	.loop_input:

		lda	REG_EXTRA_INPUT
		ldx	#g_extra_input_raw
		ldy	#g_extra_input_edge
		jsr	input_refresh

		lda	g_extra_input_edge
		bita	#VBLANK
		beq	.vblank_not_pulse
		ldd	g_vblank_pulses
		incd
		std	g_vblank_pulses
	.vblank_not_pulse:

		jsr	print_dynamic_text

		ldb	REG_P1_INPUT
		comb
		tfr	b,a

		; only send the nmi to mcu on newly
		; pressed p1 start + b button, and
		; not constantly sending it while
		; pressed
		anda	#(P1_START + B_BUTTON)
		cmpa	#(P1_START + B_BUTTON)
		bne	.p1_start_b_not_pressed

		tst	g_start_b_pressed
		bne	.skip_clr_start_b_pressed

		lda	#0
		sta	REG_MCU

		lda	#1
		sta	g_start_b_pressed
		jmp	.skip_clr_start_b_pressed

	.p1_start_b_not_pressed:
		clr	g_start_b_pressed

	.skip_clr_start_b_pressed:

		tfr	b,a
		anda	#(P1_START + A_BUTTON)
		cmpa	#(P1_START + A_BUTTON)
		bne	.loop_input
		rts

print_static_text:
		FG_XY	10,4
		ldy	#STR_INPUT_TESTS
		JRU	fg_print_string

		FG_XY	6,6
		ldy	#STR_7_0_BITS
		JRU	fg_print_string

		FG_XY	0,7
		ldy	#STR_P1
		JRU	fg_print_string

		FG_XY	0,8
		ldy	#STR_P2
		JRU	fg_print_string

		FG_XY	0,9
		ldy	#STR_EXTRA
		JRU	fg_print_string

		FG_XY	0,10
		ldy	#STR_DSW0
		JRU	fg_print_string

		FG_XY	0,11
		ldy	#STR_DSW1
		JRU	fg_print_string

		FG_XY	16,7
		ldy	#STR_NMI
		JRU	fg_print_string

		FG_XY	16,8
		ldy	#STR_IRQ
		JRU	fg_print_string

		FG_XY	16,9
		ldy	#STR_FIRQ
		JRU	fg_print_string

		FG_XY	16,10
		ldy	#STR_VBP
		JRU	fg_print_string

		FG_XY	5,25
		ldy	#STR_A_START_MAIN_MENU
		JRU	fg_print_string

		FG_XY	5,26
		ldy	#STR_B_START_NMI_TO_MCU
		JRU	fg_print_string
		rts

print_dynamic_text:
		FG_XY	6,7
		lda	REG_P1_INPUT
		coma
		JRU	fg_print_bits_byte

		FG_XY	6,8
		lda	REG_P2_INPUT
		coma
		JRU	fg_print_bits_byte

		FG_XY	6,9
		lda	REG_EXTRA_INPUT
		coma
		JRU	fg_print_bits_byte

		FG_XY	6,10
		lda	REG_DSW0
		coma
		JRU	fg_print_bits_byte

		FG_XY	6,11
		lda	REG_DSW1
		coma
		JRU	fg_print_bits_byte

		FG_XY	21,7
		ldd	g_nmi_count
		JRU	fg_print_hex_word

		FG_XY	21,8
		ldd	g_irq_count
		JRU	fg_print_hex_word

		FG_XY	21,9
		ldd	g_firq_count
		JRU	fg_print_hex_word

		FG_XY	21,10
		ldd	g_vblank_pulses
		JRU	fg_print_hex_word
		rts


STR_INPUT_TESTS:		string "INPUT TESTS"

STR_7_0_BITS:			string "76543210"
STR_P1:				string "   P1"
STR_P2:				string "   P2"
STR_EXTRA:			string "EXTRA"
STR_DSW0:			string " DSW0"
STR_DSW1:			string " DSW1"
STR_NMI:			string " NMI"
STR_IRQ:			string " IRQ"
STR_FIRQ:			string "FIRQ"
STR_VBP:			string " VBP"

STR_A_START_MAIN_MENU:		string "A+P1 START - MAIN MENU"
STR_B_START_NMI_TO_MCU:		string "B+P1 START - NMI TO MCU"
