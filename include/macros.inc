

	macro	SSU
		ldu	#.\@
		jmp	\1_ssu
.\@
	endm

	macro	SSU_RETURN
		jmp 0,u
	endm

	macro	FG_XY
		ldx	#($1800 + (\1 * 2) + (\2 * FG_TILES_PER_ROW))
	endm

	macro	MAIN_MENU_ITEM
		word \1, \2
	endm

	macro	AUTO_TEST_ITEM
		word \1, \2
	endm

	macro	EC_LOOKUP_ITEM
		byte EC_\1
		word STR_\1, \2
	endm

	macro	STALL
.\@
		jmp	.\@
	endm


