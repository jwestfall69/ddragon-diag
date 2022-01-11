	; vector table that exists at
	; the end of the rom file
	section vectors,"rodata"

	word    handle_swi
	word    handle_swi
	word    handle_firq
	word    handle_irq
	word    handle_swi
	word    handle_nmi
	word    handle_reset

