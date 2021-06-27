	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global manual_input_tests
	global STR_INPUT_TESTS

	section text

manual_input_tests:

		; static text
		FG_XY	6,4
		ldy	#STR_7_0_BITS
		SSU	fg_print_string

		FG_XY	0,5
		ldy	#STR_P1
		SSU	fg_print_string

		FG_XY	0,6
		ldy	#STR_P2
		SSU	fg_print_string

		FG_XY	0,7
		ldy	#STR_EXTRA
		SSU	fg_print_string

		FG_XY	0,8
		ldy	#STR_DSW0
		SSU	fg_print_string

		FG_XY	0,9
		ldy	#STR_DSW1
		SSU	fg_print_string


		FG_XY	16,5
		ldy	#STR_NMI
		SSU	fg_print_string

		FG_XY	16,6
		ldy	#STR_IRQ
		SSU	fg_print_string

		FG_XY	16,7
		ldy	#STR_FIRQ
		SSU	fg_print_string

		FG_XY	16,8
		ldy	#STR_SWI
		SSU	fg_print_string

		clrd
		std	g_nmi_count
		std	g_irq_count
		std	g_firq_count
		std	g_swi_count



	.loop_input:

		FG_XY	6,5
		lda	INPUT_P1
		coma
		SSU	fg_print_bits_byte

		FG_XY	6,6
		lda	INPUT_P2
		coma
		SSU	fg_print_bits_byte

		FG_XY	6,7
		lda	INPUT_EXTRA
		coma
		SSU	fg_print_bits_byte

		FG_XY	6,8
		lda	INPUT_DSW0
		coma
		SSU	fg_print_bits_byte

		FG_XY	6,9
		lda	INPUT_DSW1
		coma
		SSU	fg_print_bits_byte

		FG_XY	21,5
		ldd	g_nmi_count
		SSU	fg_print_hex_word

		FG_XY	21,6
		ldd	g_irq_count
		SSU	fg_print_hex_word

		FG_XY	21,7
		ldd	g_firq_count
		SSU	fg_print_hex_word

		FG_XY	21,8
		ldd	g_swi_count
		SSU	fg_print_hex_word

		jmp	.loop_input

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
STR_SWI:			string " SWI"
