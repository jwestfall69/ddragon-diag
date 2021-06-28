	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global _start
	global auto_work_ram_tests_passed
	global STR_ACTUAL
	global STR_ADDRESS
	global STR_EXPECTED
	global STR_HEADER
	global STR_VALUE
	global STR_PASSES
	global STR_A_HOLD_PAUSE
	global STR_C_MAIN_MENU

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
		JRU	delay

		; zero out pal/pal ext and fg ram, which are adjacent
		lda	#0
		ldx	#PAL_RAM_START
		ldw	#(PAL_RAM_SIZE + PAL_EXT_RAM_SIZE + FG_RAM_SIZE)
		JRU	ram_fill

		; zero out bg and sprite ram, which are adjacent
		lda	#0
		ldx	#OBJ_RAM_START
		ldw	#(OBJ_RAM_SIZE + BG_RAM_SIZE)
		JRU	ram_fill

		JRU	palette_init

		FG_XY	0,1
		ldy	#STR_HEADER
		JRU	fg_print_string

		FG_XY	0,2
		ldb	#'-'
		JRU	fg_fill_line

		lda	INPUT_EXTRA
		anda	#C_P1_BUTTON			; if c button pressed we will skip auto tests
		beq	auto_work_ram_tests_passed

		; jmp to the work ram tests, we can't
		; use jsr since the work ram/stack maybe
		; bad
		jmp	auto_work_ram_tests

auto_work_ram_tests_passed:

		; init ram vars
		clr	g_p1_input_raw
		clr	g_p1_input_edge
		clr	g_p2_input_raw
		clr	g_p2_input_edge
		clr	g_extra_input_raw
		clr	g_extra_input_edge
		clr	g_main_menu_cursor

		; at this point we consider work ram good
		; init stack, enable ints
		lds	#$0fff
		andcc	#$af

		; ack nmi so we start getting them again
		sta	ACK_NMI

		lda	INPUT_EXTRA
		anda	#C_P1_BUTTON
		beq	.skip_auto_tests

		jsr	automatic_tests

		lda	#$0c
		sta	REG_SOUND

		jsr	fg_clear_with_header

		FG_XY	0,5
		ldy	#STR_ALL_TESTS_PASSED
		JRU	fg_print_string

		FG_XY	0,20
		ldy	#STR_A_MAIN_MENU
		JRU	fg_print_string

	.loop_wait_a_button:
		jsr	input_update
		lda	g_p1_input_edge
		bita	#A_BUTTON
		beq	.loop_wait_a_button

	.skip_auto_tests:
		jsr	main_menu
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
		JRU	fg_print_string
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

		JRU	play_error_code
		STALL
		rts


; struct main_menu_item {
;	word string_address;
;	word function;
;}

MAIN_MENU_ITEMS_START:
	MAIN_MENU_ITEM STR_BG_RAM_TESTS, manual_bg_ram_tests
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
		JRU	fg_print_string
		puls	y,d,x

		leax	FG_TILES_PER_ROW,x
		leay	$4, y			; next menu item
		dece

		bne	.loop_next_item
		rts


STR_HEADER:			string " DOUBLE DRAGON DIAG - 00 - ACK"

STR_ALL_TESTS_PASSED:		string "ALL TESTS PASSED"
STR_A_MAIN_MENU:		string "PRESS A FOR MAIN MENU"
STR_A_HOLD_PAUSE:		string "A - HOLD TO PAUSE"
STR_C_MAIN_MENU:		string "C - MAIN MENU"

; misc strings
STR_ACTUAL:			string "ACTUAL"
STR_ADDRESS:			string "ADDRESS"
STR_EXPECTED:			string "EXPECTED"
STR_VALUE:			string "VALUE"
STR_PASSES:			string "PASSES"
