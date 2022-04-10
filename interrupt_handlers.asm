	include "ddragon.inc"
	include "ddragon_diag.inc"
	include "error_codes.inc"
	include "macros.inc"

	global handle_reset
	global handle_firq
	global handle_irq
	global handle_nmi
	global handle_swi

	section reset,"rodata"

handle_reset:
		jmp	main


	section text

handle_nmi:
		pshs	d
		ldd	g_nmi_count
		incd
		std	g_nmi_count
		puls	d

		; add a small delay, it seems on
		; hardware if we ack to fast it
		; will re-trigger the same nmi?
		pshsw
		pshs	u
		ldw	#$1f
		JRU	delay
		puls	u
		pulsw

		sta	REG_NMI_ACK
		rti

handle_irq:
		pshs	d
		ldd	g_irq_count
		incd
		std	g_irq_count
		lda	#1
		sta	REG_IRQ_ACK
		puls	d
		rti

handle_firq:
		pshs	d
		ldd	g_firq_count
		incd
		std	g_firq_count
		lda	#0
		sta	REG_FIRQ_ACK
		puls	d
		rti

handle_swi:
		pshs	d
		ldd	g_firq_count
		incd
		std	g_firq_count
		puls	d
		rti

