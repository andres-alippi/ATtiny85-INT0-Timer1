;
; Timer1 starts by an external interrupt
;
; Created: 23/03/2022 06:45:45
; Author : Andrés Alippi
;
; .INCLUDE "tn85def.inc"

.ORG		0x00			;location for reset
			RJMP MAIN
.ORG		0x02			;vector location for external interrupt 0
			RJMP EX0_ISR

MAIN:		
			LDI		R20, HIGH(RAMEND)
			OUT		SPH, R20
			LDI		R20, LOW(RAMEND)
			OUT		SPL, R20			;initialize stack

			SBI		DDRB, 1				;PB1 = output			
			SBI		PORTB, 2			;PB2 pull-up activated

			LDI		R20, 1<<INT0			;enable INT0
			OUT		GIMSK, R20
			SEI						;enable interrupts

HERE:		
			IN		R21, TIFR			;load TIFR
			SBRC		R21, TOV1			;if Timer1 is not overflow skip next instruction
			RCALL		LED_OFF			
			RJMP		HERE				

LED_OFF:	
			LDI		R21, 0x00
			OUT		TCCR1, R21			;stop Timer1
			LDI		R21, 1<<TOV1
			OUT		TIFR, R21			;clear TOV1 by setting it
			CBI		PORTB, 1			;PB1 = 0 (LED off)
			RET		

EX0_ISR:			
			SBI		PORTB, 1			;PB1 = 1 (LED on)

			LDI		R20, 0x00
			OUT		TCNT1, R20			;loading Timer1 counter with 0 (for maximum count)

			LDI		R20, 0x0F			
			OUT		TCCR1, R20			;Timer1, Normal mode, int clk, 1:16384 prescaler
										;(PB1 stays on for approx. 524 ms)
			RETI
