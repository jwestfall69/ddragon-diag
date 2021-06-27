	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global _start
	global STR_ACTUAL
	global STR_ADDRESS
	global STR_EXPECTED
	global STR_HEADER
	global STR_VALUE
	global STR_PASSES

	section text

_start:
		; make sure f/irqs are disabled
		orcc	#$50

		; adding a small delay here to allow time
		; for the nmi (vblank) to go low.  Since we
		; haven't initialized the stack register yet
		; it will have the effect of stopping the nmi
		; vector from being called until we specifically
		; ack the nmi.  This will allow us to use the
		; stack register as temp storage.
		ldw	#$1fff
		SSU	delay

		; zero out pal/pal ext and fg ram, which are adjacent
		lda	#0
		ldx	#PAL_RAM_START
		ldw	#(PAL_RAM_SIZE + PAL_EXT_RAM_SIZE + FG_RAM_SIZE)
		SSU	ram_fill

		; zero out bg and sprite ram, which are adjacent
		lda	#0
		ldx	#OBJ_RAM_START
		ldw	#(OBJ_RAM_SIZE + BG_RAM_SIZE)
		SSU	ram_fill

		SSU	palette_init

		FG_XY	0,1
		ldy	#STR_HEADER
		SSU	fg_print_string

		FG_XY	0,2
		ldb	#'-'
		SSU	fg_fill_line

		; check work ram before we start using it
		SSU	work_ram_output
		tsta
		beq	.work_ram_output_passed
		jmp	.test_failed_work_ram_output
	.work_ram_output_passed:

		SSU	work_ram_writable
		tsta
		beq	.work_ram_writable_passed
		jmp	.test_failed_work_ram_writable
	.work_ram_writable_passed:

		lde	#0
		SSU	work_ram_data
		tsta
		beq	.work_ram_data_00_passed
		jmp	.test_failed_work_ram_data
	.work_ram_data_00_passed:

		lde	#$55
		SSU	work_ram_data
		tsta
		beq	.work_ram_data_55_passed
		jmp	.test_failed_work_ram_data
	.work_ram_data_55_passed:

		lde	#$aa
		SSU	work_ram_data
		tsta
		beq	.work_ram_data_aa_passed
		jmp	.test_failed_work_ram_data
	.work_ram_data_aa_passed:

		lde	#$ff
		SSU	work_ram_data
		tsta
		beq	.work_ram_data_ff_passed
		jmp	.test_failed_work_ram_data
	.work_ram_data_ff_passed:


		SSU	work_ram_address
		tsta
		beq	.work_ram_address_passed
		jmp	.test_failed_work_ram_address
	.work_ram_address_passed:

		; at this point we consider work ram good
		; init stack, enable ints
		lds	#$0fff
		andcc	#$af

		; ack nmi so we start getting them again
		sta	ACK_NMI

		jsr	automatic_tests
		jsr	fg_clear_with_header

		FG_XY	0,5
		ldy	#STR_ALL_TESTS_PASSED
		SSU	fg_print_string

		FG_XY	0,20
		ldy	#STR_A_MAIN_MENU
		SSU	fg_print_string

		; init ram vars
		clr	g_p1_input_raw
		clr	g_p1_input_edge
		clr	g_p2_input_raw
		clr	g_p2_input_edge
		clr	g_extra_input_raw
		clr	g_extra_input_edge
		clr	g_main_menu_cursor

	.loop_wait_a_button:
		jsr	input_update
		lda	g_p1_input_edge
		bita	#A_BUTTON
		beq	.loop_wait_a_button

		jsr	main_menu
		STALL

	.test_failed_work_ram_output:
		FG_XY	0,5
		ldy	#STR_WORK_RAM_DEAD_OUTPUT
		SSU	fg_print_string

		lda	#EC_WORK_RAM_DEAD_OUTPUT
		SSU	play_error_code
		STALL

	.test_failed_work_ram_writable:
		FG_XY	0,5
		ldy	#STR_WORK_RAM_UNWRITABLE
		SSU	fg_print_string

		lda	#EC_WORK_RAM_UNWRITABLE
		SSU	play_error_code

		STALL
	; I believe there might be a little risk below
	; in that we are using the stack register to
	; temp store data.  I'm unsure, but it seems like
	; if the nmi pin is floating it may cause the cpu
	; to trigger the nmi vector since we touched the
	; stack register.
	.test_failed_work_ram_data:

		; e = expected value
		; b = actual value
		; x = address
		tfr	e,a
		tfr	d,s			; save expected + actual to stack register
		tfr	x,d			; failed address to d
		FG_XY	10,7
		SSU	fg_print_hex_word

		tfr	s,d			; restore expected + bad data
		FG_XY	12,8
		SSU	fg_print_hex_byte

		tfr	s,d			; restore expected + bad again
		exg	a,b			; bad data
		FG_XY	12,9
		SSU	fg_print_hex_byte

		FG_XY	0,5
		ldy	#STR_WORK_RAM_DATA
		SSU	fg_print_string

		FG_XY	0,7
		ldy	#STR_ADDRESS
		SSU	fg_print_string

		FG_XY	0,8
		ldy	#STR_EXPECTED
		SSU	fg_print_string

		FG_XY	0,9
		ldy	#STR_ACTUAL
		SSU	fg_print_string

		lda	#EC_WORK_RAM_DATA
		SSU	play_error_code

		STALL

	.test_failed_work_ram_address:

		; b = actual value
		; f = expected
		tfr	f,s			; save expected to stack register
		tfr	b,a			; actual
		FG_XY	12,8
		SSU	fg_print_hex_byte

		tfr	s,a			; restore expected
		FG_XY	12,7
		SSU	fg_print_hex_byte

		FG_XY	0,5
		ldy	#STR_WORK_RAM_ADDRESS
		SSU	fg_print_string

		FG_XY	0,7
		ldy	#STR_EXPECTED
		SSU	fg_print_string

		FG_XY	0,8
		ldy	#STR_ACTUAL
		SSU	fg_print_string

		lda	#EC_WORK_RAM_ADDRESS
		SSU	play_error_code

		STALL

; struct auto_test_item {
;	word description_string_address;
;	word test_function;
;}
AUTO_TEST_ITEMS_START:
	AUTO_TEST_ITEM STR_TESTING_PAL_RAM, auto_pal_ram_tests
	AUTO_TEST_ITEM STR_TESTING_PAL_EXT_RAM, auto_pal_ext_ram_tests
	AUTO_TEST_ITEM STR_TESTING_FG_RAM, auto_fg_ram_tests
	AUTO_TEST_ITEM STR_TESTING_BG_RAM, auto_bg_ram_tests
	AUTO_TEST_ITEM STR_TESTING_OBJ_RAM, auto_obj_ram_tests
	AUTO_TEST_ITEM STR_TESTING_COMM_RAM, auto_comm_ram_tests
AUTO_TEST_ITEMS_END:

automatic_tests:
		ldy	#AUTO_TEST_ITEMS_START
		lde	#((AUTO_TEST_ITEMS_END - AUTO_TEST_ITEMS_START) / 4)
	.loop_next_auto_test_item:

		; clear the screen
		pshs	x,y,d
		pshsw
		jsr	fg_clear_with_header
		pulsw
		puls	x,y,d


		; print the test description
		pshs	y,a,b
		FG_XY	3,4
		ldy	0,y
		SSU	fg_print_string
		puls	y,a,b

		pshs	y,a,b
		pshsw
		jsr	[2,y]			; call test function

		tsta
		bne	.test_failed

		pulsw
		puls	y,a,b

		leay	4,y			; next item

		dece
		bne	.loop_next_auto_test_item
		rts

	.test_failed:
		pshs	a
		jsr	print_error
		puls	a

		SSU	play_error_code
		STALL
		rts


; struct main_menu_item {
;	word string_address;
;	word function;
;}

MAIN_MENU_ITEMS_START:
	MAIN_MENU_ITEM STR_INPUT_TESTS, manual_input_tests
	MAIN_MENU_ITEM STR_SOUND_TESTS, manual_sound_tests
	MAIN_MENU_ITEM STR_VIDEO_DAC_TESTS, manual_video_dac_tests
MAIN_MENU_ITEMS_END:

main_menu:
		jsr	main_menu_draw

		; draw initial cursor
		ldb	g_main_menu_cursor
		lda	#FG_TILES_PER_ROW
		mul
		FG_XY	2,4
		leax	d,x
		ldd	#$a		; #
		std	0,x

		lde	#(((MAIN_MENU_ITEMS_END - MAIN_MENU_ITEMS_START) / 4) - 1)

	.loop_input:
		jsr	input_update
		lda	g_p1_input_edge
		ldb	g_main_menu_cursor

		bita	#UP
		beq	.up_not_pressed

		decb
		bpl	.redraw_cursor
		tfr	e,b
		jmp	.redraw_cursor
	.up_not_pressed:

		bita	#DOWN
		beq	.down_not_pressed
		incb

		cmpr	b,e
		bpl	.redraw_cursor
		ldb	#0
		jmp	.redraw_cursor
	.down_not_pressed:

		bita	#A_BUTTON
		beq	.loop_input

		; prep screen and call function
		pshs	b
		jsr	fg_clear_with_header
		puls	b

		ldy	#MAIN_MENU_ITEMS_START
		aslb
		aslb
		leay	b,y		; get to the right menu item

		pshs	y
		FG_XY	0,3
		ldy	0,y		; menu item's string
		SSU	fg_print_string
		puls	y

		jsr	[2,y]		; call the menu item's function
		jmp	main_menu

	.redraw_cursor:
		pshs	b

		; remove old cursor
		ldb	g_main_menu_cursor
		lda	#FG_TILES_PER_ROW
		mul			; 0x40 * cursor = fg line offset

		FG_XY	2,4
		leax	d,x		; goto to the right line
		ldd	#0		; empty
		std	0,x

		; draw new cursor
		puls	b
		stb	g_main_menu_cursor
		lda	#FG_TILES_PER_ROW
		mul

		FG_XY	2,4
		leax	d,x
		ldd	#$a		; #
		std	0,x

		jmp	.loop_input
		STALL


main_menu_draw:

		jsr	fg_clear_with_header

		ldy	#MAIN_MENU_ITEMS_START
		lde	#((MAIN_MENU_ITEMS_END - MAIN_MENU_ITEMS_START) / 4)
		FG_XY	3,4

	.loop_next_item:
		pshs	y,d,x
		ldy	0,y
		SSU	fg_print_string
		puls	y,d,x

		leax	FG_TILES_PER_ROW,x
		leay	$4, y			; next menu item
		dece

		bne	.loop_next_item
		rts


STR_HEADER:			string " DOUBLE DRAGON DIAG - 00 - ACK"

STR_ALL_TESTS_PASSED:		string "ALL TESTS PASSED"
STR_A_MAIN_MENU:		string "PRESS A FOR MAIN MENU"

; misc strings
STR_ACTUAL:			string "ACTUAL"
STR_ADDRESS:			string "ADDRESS"
STR_EXPECTED:			string "EXPECTED"
STR_VALUE:			string "VALUE"
STR_PASSES:			string "PASSES"

; work ram error strings
STR_WORK_RAM_DEAD_OUTPUT:	string "WORK RAM DEAD OUTPUT"
STR_WORK_RAM_UNWRITABLE:	string "WORK RAM UNWRITABLE"
STR_WORK_RAM_DATA:		string "WORK RAM DATA"
STR_WORK_RAM_ADDRESS:		string "WORK RAM ADDRESS"
