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
		.space 16

		.text
	clr.b R13				;set R13 to 0x00
	clr.b R14				;set R14 to 0x00
	clr.b R15				;set R15 to 0x00
	clr.b R4				;set R4 to 0x00
	clr.b R5				;set R5 to 0x00
	clr.b R6				;set R6 to 0x00
	clr.b R7				;set R7 to 0x00
	clr.b R8				;set R8 to 0x00
	clr.b R9				;set R9 to 0x00
	clr.b R10				;set R10 to 0x00
	clr.b R11				;set R11 to 0x00
	mov.w #Scores, R13		;move the memory address of Scores to R13
	push  R13				;save R13 for later, save memory address of Scores to the stack
	mov.w #Scores, R14		;move the memory address of Scores to R14
	add.w numScores, R14	;add the number of scores numScores to the memory address of Scores, set it to the end of the Scores array
	call  #max				;call the max function
	mov.b R15, Max			;move the results of the max function held in R15 to Max
	pop   R13				;restore the contents of R13, the memory address of Scores
	clr.b R15				;set R15 to 0x00, will hold the histogram values
	mov.b #-1, R9			;set R9 to -1, this will be used a counter for the bubble sort, -1 is a dummy value
	call  #Sort				;call the Sort function, the Scores have to be sorted to produce a histogram
	clr.b R5				;set R5 to 0x00, clear registers used for the sorting operation
	clr.b R6				;set R6 to 0x00, clear registers used for the sorting operation
	clr.b R7				;set R7 to 0x00, clear registers used for the sorting operation
	clr.b R8				;set R8 to 0x00, clear registers used for the sorting operation
loop:
	mov.w #Scores, R13			;move the memory address of Scores to R13
	mov.b @R7(Scores), R12		;move an element of a now sorted Scores to R12
	call  #histo				;call the histo function
	mov.b R15, @R7(Histogram)	;push the results of the histo function to memory location Histogram indexed by R7
	inc.b R7					;increment the index of memory location Histogram
	clr.b R15					;reset the histo return for the next Score
	cmp.b numScores, R7			;compare the number of scores to the counter
	jl    loop					;jump to loop if we haven't counted all the scores yet

	mov.w #Histogram, R13		;move the memory address of Histogram to R13
	push  R13					;save R13 for later
	mov.w #Histogram, R14		;move the memory address of Histogram to R14
	add.w numScores, R14		;add the number of scores numScores to the memory address of Histogram, set it to the end of the Histogram array
	call  #max					;call function max
	pop   R13					;restore R13, the memory address of Histogram

modeLoop:
	mov.b @R13, R8				;loop through Histogram
	inc.w R13					;increment the memory address of Histogram
	inc.b R6					;increment the index counter
	cmp.b R8, R15				;compare the element in Histogram with the max element in Histogram
	jnz   modeLoop				;jump if not equal

	mov.b @R6(Scores), Mode		;save the mode of Scores to Mode
	jmp   $						;infinite loop to end the program

max:
	cmp.w R13, R14		;compare the start input memory address to the end input memory address
	jz    returnMax		;when the start of the memory address equals the end of the memory address, we went through the list, jump to return
	mov.b @R13, R4		;move the 1st element in the memory address to R4
	inc.w R13			;increment the start input memory address by 1 word
	cmp.b R15, R4		;compare the current element to the current max
	jl    max			;loop back to max if the current element is smaller than max
	jl    max			;loop back to max if the current element is smaller than max
	mov.b R4, R15		;move the current element to be the new max
	jmp   max			;loop back to max
returnMax:
	ret					;return


histo:
	cmp.w R13, R14			;compare the start input memory address to the end input memory address
	jz    returnHisto		;when the start of the memory address equals the end of the memory address, we went through the list, jump to return
	mov.b @R13, R5			;move the 1st element in the memory address to R5
	inc.w R13				;increment the start input memory address by 1 word
	cmp   R12, R5			;compare the current element to the element we are looking for
	jne   histo				;jump to histo if the elements are not equal
	inc.b R15				;increment the counter of histo R15 by 1
	jmp   histo				;jump to histo
returnHisto:
	ret						;return


Sort:
	tst.b R9			;test if R9 is 0
	jz    returnSort	;if R9 is 0 then jump to the end, the list is sorted
	mov.b #0, R7		;move 0x00 to R7, this will serve as index 1
	mov.b #1, R8		;move 0x01 to R8, this will serve as index 2
	mov.b #0, R9		;move 0x00 to R9, this will count the number of swaps through the list

next:
	mov.b @R7(Scores), R5	;move the element in the list corresponding to the index in R7 to R5
	mov.b @R8(Scores), R6	;move the element in the list corresponding to the index in R8 to R6
	cmp.b R5, R6			;compare list element i to i+1
	jge   incNums			;if R6 is larger or equal to R5 then we jump to incrementing the indexes, no swaps are made

swapNums:
	mov.b R6, @R7(Scores)	;swap the elements of the list, i -> i+1
	mov.b R5, @R8(Scores)	;swap the elements of the list, i+1 -> i
	inc.b R9				;add one to the count of swaps

incNums:
	inc.b R7				;increment index 1
	inc.b R8				;increment index 2
	cmp.b R8, numScores		;compare index 2 to the total number of elements in the list
	jz    Sort				;if it is 0 then we have reached the end of the list and jump back to the beginning
	jmp   next				;if we have not reached the end of the list, then we continue to compare the next two elements
returnSort:
	ret						;return


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
            
