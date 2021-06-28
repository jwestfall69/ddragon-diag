	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global handle_firq
	global handle_irq
	global handle_nmi
	global handle_swi

	section text

handle_nmi:
		pshs	d
		ldd	g_nmi_count
		incd
		std	g_nmi_count
		lda	#0
		sta	ACK_NMI
		puls	d
		rti

handle_irq:
		pshs	d
		ldd	g_irq_count
		incd
		std	g_irq_count
		lda	#1
		sta	ACK_IRQ
		puls	d
		rti

handle_firq:
		pshs	d
		ldd	g_firq_count
		incd
		std	g_firq_count
		lda	#0
		sta	ACK_FIRQ
		puls	d
		rti

handle_swi:
		pshs	d
		ldd	g_firq_count
		incd
		std	g_firq_count
		puls	d
		rti



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
