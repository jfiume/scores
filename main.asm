;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
		.data
Scores: .byte 18, 20, 6, 10, 16, 16, 18, 19, 13, 0, 14, 16, 14, 17, 16
numScores:
		.word 15
Max:	.space 2
mode:	.space 2
histogram:
		.space 21

		.text
	clr.b R13
	clr.b R14
	clr.b R15
	clr.b R4
	clr.b R5
	clr.b R6
	clr.b R7
	mov.w #Scores, R13
	mov.w #Scores, R14
	add.w numScores, R14
	call #max
	mov.b R15, Max
	mov.w #Scores, R13
	clr.b R15
	;call #Sort
loop:
	mov.b @R13, R12
	push R13
	call #histo
	mov.b R15, @R7(histogram)
	clr.b R15
	inc.b R7
	pop R13
	inc.w R13
	cmp.w R13, R14
	jnz loop

max:
	cmp.w R13, R14
	jz returnMax
	mov.b @R13, R4
	inc.w R13
	cmp.b R15, R4
	jl max
	mov.b R4, R15
	jmp max
returnMax:
	ret


histo:
	cmp.b R6, numScores
	jz returnHisto
	mov.b @R13, R5
	inc.w R13
	inc.b R6
	cmp R12, R5
	jne histo
	inc.b R15
	jmp histo
returnHisto:
	clr.b R6
	ret




Sort:
	clr.b R15
	call #max
	;mov.b R15, sortedScores
	inc.w R6
	add.w #Scores, R6
	mov.w R6, R13
	inc.b R5
	cmp numScores, R5
	jl Sort
	ret


;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
