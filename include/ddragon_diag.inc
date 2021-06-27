; global vars
g_nmi_count			equ $0000
g_swi_count			equ $0002
g_irq_count			equ $0004
g_firq_count			equ $0006

g_main_menu_cursor		equ $0008

g_error_code_description	equ $0009

g_p1_input_raw			equ $0010
g_p1_input_edge			equ $0011
g_p2_input_raw			equ $0012
g_p2_input_edge			equ $0013
g_extra_input_raw		equ $0014
g_extra_input_edge		equ $0015

g_snd_num			equ $0016

; mem tester inputs
g_mt_mem_start_address		equ $0040
g_mt_mem_size			equ $0042
g_mt_mem_address_lines		equ $0044
g_mt_data_mask			equ $0045

; mem tester outputs (on error)
g_mt_error_address		equ $0046
g_mt_error_expected		equ $0048
g_mt_error_actual		equ $0049

; mem tester errors
MT_ERROR_DEAD_OUTPUT		equ $01
MT_ERROR_UNWRITABLE		equ $02
MT_ERROR_DATA			equ $03
MT_ERROR_ADDRESS		equ $04
