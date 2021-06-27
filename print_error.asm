	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global print_error

	section text


; struct ec_lookup_item {
;	byte error_code;
;	word error_string_address;
;	word print_error_function;
;}
; the EC_LOOKUP_ITEM macro takes care of converting
; its first arg into EC_<ARG1> and STR_<ARG1>
EC_LOOKUP_ITEMS_START:
	EC_LOOKUP_ITEM FG_RAM_DEAD_OUTPUT, print_error_string
	EC_LOOKUP_ITEM FG_RAM_UNWRITABLE, print_error_string
	EC_LOOKUP_ITEM FG_RAM_DATA, print_error_ram_data_fail
	EC_LOOKUP_ITEM FG_RAM_ADDRESS, print_error_ram_address_fail

	EC_LOOKUP_ITEM PAL_RAM_DEAD_OUTPUT, print_error_string
	EC_LOOKUP_ITEM PAL_RAM_UNWRITABLE, print_error_string
	EC_LOOKUP_ITEM PAL_RAM_DATA, print_error_ram_data_fail
	EC_LOOKUP_ITEM PAL_RAM_ADDRESS, print_error_ram_address_fail

	EC_LOOKUP_ITEM PAL_EXT_RAM_DEAD_OUTPUT, print_error_string
	EC_LOOKUP_ITEM PAL_EXT_RAM_UNWRITABLE, print_error_string
	EC_LOOKUP_ITEM PAL_EXT_RAM_DATA, print_error_ram_data_fail
	EC_LOOKUP_ITEM PAL_EXT_RAM_ADDRESS, print_error_ram_address_fail

	EC_LOOKUP_ITEM BG_RAM_DEAD_OUTPUT, print_error_string
	EC_LOOKUP_ITEM BG_RAM_UNWRITABLE, print_error_string
	EC_LOOKUP_ITEM BG_RAM_DATA, print_error_ram_data_fail
	EC_LOOKUP_ITEM BG_RAM_ADDRESS, print_error_ram_address_fail

	EC_LOOKUP_ITEM OBJ_RAM_DEAD_OUTPUT, print_error_string
	EC_LOOKUP_ITEM OBJ_RAM_UNWRITABLE, print_error_string
	EC_LOOKUP_ITEM OBJ_RAM_DATA, print_error_ram_data_fail
	EC_LOOKUP_ITEM OBJ_RAM_ADDRESS, print_error_ram_address_fail

	EC_LOOKUP_ITEM COMM_RAM_DEAD_OUTPUT, print_error_string
	EC_LOOKUP_ITEM COMM_RAM_UNWRITABLE, print_error_string
	EC_LOOKUP_ITEM COMM_RAM_DATA, print_error_ram_data_fail
	EC_LOOKUP_ITEM COMM_RAM_ADDRESS, print_error_ram_address_fail
EC_LOOKUP_ITEMS_END:

; lookup the error code and call the proper function
; to print details about it
print_error:
		pshs	a
		jsr	fg_clear_with_header
		puls	a

		ldy	#EC_LOOKUP_ITEMS_START
		lde	#((EC_LOOKUP_ITEMS_END - EC_LOOKUP_ITEMS_START) / 5)

	.loop_next_ec_lookup_item:
		cmpa	0,y
		beq	.error_code_found

		leay	5,y			; next item
		dece
		bne	.loop_next_ec_lookup_item

		jmp	print_error_invalid	; will rts for us

	.error_code_found:
		ldx	1,y
		stx	g_error_code_description
		jmp	[3,y]			; will rts for us


; just print the error code description
print_error_string:
		FG_XY	0,5
		ldy	g_error_code_description
		JRU	fg_print_string
		rts

; prints
;  <description>
;  ADDRESS 1234
;  EXPECTED  00
;  ACTUAL    FF
print_error_ram_data_fail:
		FG_XY	0,5
		ldy	g_error_code_description
		JRU	fg_print_string

		FG_XY	0,7
		ldy	#STR_ADDRESS
		JRU	fg_print_string

		FG_XY	0,8
		ldy	#STR_EXPECTED
		JRU	fg_print_string

		FG_XY	0,9
		ldy	#STR_ACTUAL
		JRU	fg_print_string

		FG_XY	12,7
		ldd	g_mt_error_address
		JRU	fg_print_hex_word

		FG_XY	14,8
		lda	g_mt_error_expected
		JRU	fg_print_hex_byte

		FG_XY	14,9
		lda	g_mt_error_actual
		JRU	fg_print_hex_byte
		rts


; prints
;  <description>
;  EXPECTED  00
;  ACTUAL    FF
print_error_ram_address_fail:

		FG_XY	0,5
		ldy	g_error_code_description
		JRU	fg_print_string

		FG_XY	0,7
		ldy	#STR_EXPECTED
		JRU	fg_print_string

		FG_XY	0,8
		ldy	#STR_ACTUAL
		JRU	fg_print_string

		FG_XY	12,7
		lda	g_mt_error_expected
		JRU	fg_print_hex_byte

		FG_XY	12,8
		lda	g_mt_error_actual
		JRU	fg_print_hex_byte
		rts

; prints the invalid error code number
; params
;  a = bad error code
; prints
;  INVALID ERROR CODE
;  VALUE 12
print_error_invalid:
		FG_XY	7,7
		JRU	fg_print_hex_byte

		FG_XY	0,5
		ldy	#STR_INVALID_ERROR_CODE
		JRU	fg_print_string

		FG_XY	0,7
		ldy	#STR_VALUE
		JRU	fg_print_string
		rts

STR_FG_RAM_DEAD_OUTPUT:		string "FG RAM DEAD OUTPUT"
STR_FG_RAM_UNWRITABLE:		string "FG RAM UNWRITABLE"
STR_FG_RAM_DATA:		string "FG RAM DATA"
STR_FG_RAM_ADDRESS:		string "FG RAM ADDRESS"

STR_PAL_RAM_DEAD_OUTPUT:	string "PAL RAM DEAD OUTPUT"
STR_PAL_RAM_UNWRITABLE:		string "PAL RAM UNWRITABLE"
STR_PAL_RAM_DATA:		string "PAL RAM DATA"
STR_PAL_RAM_ADDRESS:		string "PAL RAM ADDRESS"

STR_PAL_EXT_RAM_DEAD_OUTPUT:	string "PAL EXT RAM DEAD OUTPUT"
STR_PAL_EXT_RAM_UNWRITABLE:	string "PAL EXT RAM UNWRITABLE"
STR_PAL_EXT_RAM_DATA:		string "PAL EXT RAM DATA"
STR_PAL_EXT_RAM_ADDRESS:	string "PAL EXT RAM ADDRESS"

STR_BG_RAM_DEAD_OUTPUT:		string "BG RAM DEAD OUTPUT"
STR_BG_RAM_UNWRITABLE:		string "BG RAM UNWRITABLE"
STR_BG_RAM_DATA:		string "BG RAM DATA"
STR_BG_RAM_ADDRESS:		string "BG RAM ADDRESS"

STR_OBJ_RAM_DEAD_OUTPUT:	string "OBJ/SPRITE RAM DEAD OUTPUT"
STR_OBJ_RAM_UNWRITABLE:		string "OBJ/SPRITE RAM UNWRITABLE"
STR_OBJ_RAM_DATA:		string "OBJ/SPRITE RAM DATA"
STR_OBJ_RAM_ADDRESS:		string "OBJ/SPRITE RAM ADDRESS"

STR_COMM_RAM_DEAD_OUTPUT:	string "COMM RAM DEAD OUTPUT"
STR_COMM_RAM_UNWRITABLE:	string "COMM RAM UNWRITABLE"
STR_COMM_RAM_DATA:		string "COMM RAM DATA"
STR_COMM_RAM_ADDRESS:		string "COMM RAM ADDRESS"

STR_INVALID_ERROR_CODE:		string "INVALID ERROR CODE"
