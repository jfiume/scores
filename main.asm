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
Mode:	.space 2
Histogram:
		.space 21

		.text
	clr.b R13
	clr.b R14
	clr.b R15
	clr.b R4
	clr.b R5
	clr.b R6
	clr.b R7
	clr.b R8
	clr.b R9
	clr.b R10
	clr.b R11
	mov.w #Scores, R13
	mov.w #Scores, R14
	add.w numScores, R14
	call #max
	mov.b R15, Max
	mov.w #Scores, R13
	clr.b R15
	mov.b numScores, R8
	mov.b #-1, R9
	call #Sort
	clr.b R5
	clr.b R6
	clr.b R7
	clr.b R8
loop:
	mov.b @R13, R12
	push R13
	call #histo
	mov.b R15, @R7(Histogram)
	inc.b R7
	pop R13
	add.w R15, R13
	clr.b R15
	cmp.w R14, R13
	jl loop

	mov.w #Histogram, R13
	mov.w #Histogram, R14
	add.w numScores, R14
	call #max
	mov.b R15, Mode
	jmp $

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
	cmp.w R13, R14
	jz returnHisto
	mov.b @R13, R5
	inc.w R13
	cmp R12, R5
	jne histo
	inc.b R15
	jmp histo
returnHisto:
	ret


Sort:
	tst.b R9		;test if R4 is 0
	jz    returnSort		;if R4 is 0 then jump to the end, the list is sorted
	mov.b #0, R7	;move 0x00 to R7, this will serve as index 1
	mov.b #1, R8	;move 0x01 to R8, this will serve as index 2
	mov.b #0, R9	;move 0x00 to R4, this will count the number of swaps though the list

next:
	mov.b @R7(Scores), R5		;move the element in the list corresponding to the index in R7 to R5
	mov.b @R8(Scores), R6		;move the element in the list corresponding to the index in R8 to R6
	cmp.b R5, R6			;compare list element i to i+1
	jge   incNums			;if R6 is larger or equal to R5 then we jump to incrementing the indexes, no swaps are made

swapNums:
	mov.b R6, @R7(Scores)		;swap the elements of the list, i -> i+1
	mov.b R5, @R8(Scores)		;swap the elements of the list, i+1 -> i
	inc.b R9				;add one to the count of swaps

incNums:
	inc.b R7				;increment index 1
	inc.b R8				;increment index 2
	cmp.b R8, numScores		;compare index 2 to the total number of elements in the list
	jz    Sort				;if it is 0 then we have reached the end of the list and jump back to the beginning
	jmp   next				;if we have not reached the end of the list, then we continue to compare the next two elements
returnSort:
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
            
