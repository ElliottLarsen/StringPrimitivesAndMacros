TITLE String Primitives and Macros     (string_primitives_and_macros.asm)

; Author: Elliott Larsen
; Date:
; Description: 

INCLUDE Irvine32.inc

; (insert macro definitions here)

;---------------------------------------------------------------------------------
;
;
;
;
;
;
;---------------------------------------------------------------------------------

mDisplayString	MACRO	display_string

	PUSH	EDX					; Preserve the register value.
	
	MOV	EDX, display_string
	CALL	WriteString
	
	POP	EDX					; Restore the register value.

ENDM

;---------------------------------------------------------------------------------
;
;
;
;
;
;
;---------------------------------------------------------------------------------

mGetString  MACRO   prompt, inputStr, numChar, strLen
	
	MOV	EDX, 0					; Reset EDX.
	MOV	EAX, 0					; Reset EDX.
	
	MOV	EDX, prompt
	CALL	WriteString
	MOV	EDX, inputStr
	MOV	ECX, numChar
	CALL	ReadString
	MOV	strLen, EAX
	
ENDM

; (insert constant definitions here)

	MAXSIZE = 12					; Including a unary operator and null.			
	SDWORDLO = -2147483648
	SDWORDHI = +2147483647

.data

; (insert variable definitions here)

	programTitle	BYTE	"String Primitives and Macros", 0
	programmerName	BYTE	"By Elliott Larsen", 0
	introMsg1	BYTE	"Please provide 10 signed decimal integers.", 0
	introMsg2	BYTE	"Each number must be small enough to fit inside a 32-bit register. After all 10 integers are received,", 0 
	introMsg3	BYTE	"this program will display the a list of entered integers, their sum, and truncated average.", 0

	numPrompt	BYTE	"Please enter a signed number: ", 0
	errorMsg1	BYTE	"ERROR: Your input is not recognized.", 0
	errorMsg2	BYTE	"Did you enter a signed integer?  Does your input fit inside a 32-bit register? Let's try again.", 0

	inputNumMsg	BYTE	"You entered the following integers:", 0
	sumNumMsg	BYTE	"The sum of these numbers is: ", 0
	aveNumMsg	BYTE	"The truncated average is: ",0
	commaSpace	BYTE	", ", 0
	negativeSign	BYTE	"-", 0
	positiveSign	BYTE	"+", 0
	goodByeMsg	BYTE	"Thank you for using this program.  Goodbye!", 0
	
	inString	BYTE	MAXSIZE DUP(?)		; ReadString stores input integer as ASCII.
	inNumArray	SDWORD	10 DUP(?)		; Array for integers (not ASCII).
	tempStr		BYTE	MAXSIZE	DUP(?)		;
	outStr		BYTE	MAXSIZE DUP(?)		;
	resetStr	BYTE	MAXSIZE DUP(?)		;
	
	sLen		SDWORD	?
	tempNum		SDWORD	?
	numInt		SDWORD	?
	numSum		SDWORD	?
	numAve		SDWORD	?
	numCount	SDWORD	10
	counter		SDWORD	0
	isLastNum	SDWORD	0

	
.code
;---------------------------------------------------------------------------------
; Name: main 
; 
; Sets up and calls other procedures.
;---------------------------------------------------------------------------------
main PROC

; (insert executable instructions here)

	; parameters and procedure call for introduction
	PUSH	OFFSET programTitle			
	PUSH	OFFSET programmerName			
	PUSH	OFFSET introMsg1			
	PUSH	OFFSET introMsg2			
	PUSH	OFFSET introMsg3			
	CALL	introduction
	
	
	MOV	ECX, numCount
	MOV	EDI, OFFSET inNumArray
_numinput:
	PUSH	ECX
	
	PUSH	tempNum
	PUSH	numInt
	PUSH	OFFSET numCount
	PUSH	OFFSET inNumArray
	PUSH	OFFSET errorMsg1
	PUSH	OFFSET errorMsg2
	PUSH	OFFSET numPrompt
	PUSH	MAXSIZE
	PUSH	OFFSET inString
	PUSH	OFFSET sLen
	CALL	readVal
	
	MOV	[EDI], EAX
	ADD	EDI, 4
	
	POP	ECX					; Restore ECX value for numInput loop.
	LOOP	_numInput
	CALL	CrLf
	
	;This test loop shows that the ASCII versions of the user inputs are converted as integers/are stored in inNumArray correctly.
	;MOV	ECX, numCount
	;MOV	EDI, OFFSET inNumArray
	;_testLoop:
	;MOV	EAX, [EDI]
	;CALL	WriteInt
	;ADD	EDI, 4
	;LOOP	_testLoop
	
	MOV	ECX, numCount
	DEC	ECX
	MOV	ESI, OFFSET inNumArray
	mDisplayString	OFFSET inputNumMsg
	CALL	CrLf
	
_writeValLoop:
	PUSH	ECX
	
	PUSH	OFFSET tempStr
	PUSH	OFFSET outStr
	PUSH	OFFSET resetStr
	PUSH	OFFSET negativeSign
	PUSH	OFFSET commaSpace
	PUSH	counter
	PUSH	isLastNum
	CALL	writeVal
	
	ADD	ESI, 4
	POP	ECX
	LOOP	_writeValLoop
	
	INC	isLastNum
	PUSH	OFFSET tempStr
	PUSH	OFFSET outStr
	PUSH	OFFSET resetStr
	PUSH	OFFSET negativeSign
	PUSH	OFFSET commaSpace
	PUSH	counter
	PUSH	isLastNum
	CALL	WriteVal

	Invoke ExitProcess,0				; Exit to operating system.
main ENDP

; (insert additional procedures here)

;---------------------------------------------------------------------------------
; Name: introduction
;
; Displays the program title, programmer name, and instruction.
;
; Preconditions: Five null-terminated strings in memory and their OFFSETs are
;	pushed to the stack prior to the procedure call.  mDisplayString (macro) 
;	is used to display the strings.
;
; Postconditions: Strings are displayed.
; 
; Receives: OFFSEts of five strings, EBP, and ESP.  EDX is used by the macro.
;
; Returns: EBP value is restored.  EDX value is restored inside the macro.
;---------------------------------------------------------------------------------
introduction	PROC
	
	PUSH	EBP			; Build stack frame.
	MOV	EBP, ESP
	
	CALL	CrLf
	mDisplayString [EBP + 24]	; OFFSET programTitle.
	CALL	CrLf
	
	mDisplayString [EBP + 20]	; OFFSET programmerName.
	CALL	CrLf
	CALL	CrLf
	
	mDisplayString [EBP + 16]	; OFFSET introMsg1.
	CALL	CrLf
	CALL	CrLf
	
	mDisplayString [EBP + 12]	; OFFSET introMsg2.
	CALL	CrLf
	
	mDisplayString [EBP + 8]	; OFFSET introMsg3.
	CALL	CrLf
	
	POP	EBP			; Restore the register.
	RET	20
	
introduction	ENDP

;---------------------------------------------------------------------------------
;
;
;
;
;
;
;---------------------------------------------------------------------------------

readVal		PROC

	PUSH	EBP			; Build stack frame.
	MOV	EBP, ESP

_getNum:
	MOV	EAX, 0
	MOV	EBX, 0
	MOV	ECX, 0
	
	MOV	EAX, [EBP + 40]
	IMUL	EBX
	MOV	[EBP + 40], EAX

	mGetString	[EBP + 20], [EBP + 12], [EBP + 16], [EBP + 8]

	MOV	ESI, [EBP + 12]		; inString to ESI.
										
	MOV	ECX, [EBP + 8]		; Length of the string entered.
	JMP	_validateIfUnary

_invalidEntry:
	CALL	CrLf
	mDisplayString [EBP + 28]
	CALL	CrLf
	mDisplayString [EBP + 24]
	CALL	CrLf
	CALL	CrLf
	JMP	_getNum

_validateIfUnary:			; Checking - or + sign.
	CLD
	LODSB
	CMP	AL, 45
	JE	_negativeInt
	CMP	AL, 43
	JE	_positiveInt
	JMP	_positiveIntNoUnary

_positiveInt:	
	DEC	ECX			; Because the first character was a unary symbol.

	_positiveIntLoop:
		MOV	EAX, 0
		LODSB

		_positiveIntNoUnary:
			CMP	AL, 48						; 0 is 48 in ASCII.
			JB	_invalidEntry
			CMP	AL, 57						; 9 is 57 in ASCII.
			JA	_invalidEntry
			
			SUB	EAX, 48						; Algorithm to convert from ASCII representation to numeric value.
			MOV	[EBP + 44], EAX					
			MOV	EAX, [EBP + 40]					
			MOV	EBX, 10
			IMUL	EBX
			ADD	EAX, [EBP + 44]					
			JO	_invalidEntry					
			MOV	[EBP + 40], EAX					
			LOOP	_positiveIntLoop
	JMP	_done


_negativeInt:	
	DEC	ECX								; Because the first character was a unary symbol.

	_negativeIntLoop:
		MOV	EAX, 0
		LODSB

		_negativeIntNoUnary:
			CMP	AL, 48						; 0 is 48 in ASCII.
			JB	_invalidEntry
			CMP	AL, 57						; 9 is 57 in ASCII.
			JA	_invalidEntry

			SUB	EAX, 48						; Algorithm to convert from ASCII representation to numeric value.
			MOV	[EBP + 44], EAX					
			MOV	EAX, [EBP + 40]					
			MOV	EBX, 10
			IMUL	EBX
			ADD	EAX, [EBP + 44]					
			JO	_invalidEntry					
			MOV	[EBP + 40], EAX				
			JO	_invalidEntry					
			LOOP	_negativeIntLoop

			NEG	EAX						; Negate the number.
			MOV	[EBP + 40], EAX
	JMP	_done

_done:
	POP	EBP			; Restore the register.
	RET 	40

readVal		ENDP

;---------------------------------------------------------------------------------
;
;
;
;
;
;
;---------------------------------------------------------------------------------

writeVal	PROC

	PUSH	EBP			; Build stack frame.
	MOV	EBP, ESP
	
	MOV	EDI, [EBP + 32]		; tempStr to EDI.
	MOV	ECX, [EBP + 12]		; counter to ECX.
	MOV	EAX, [ESI]		; Array elements to EAX.
	PUSH	EDI			; Reserve registers.
	PUSH	ESI

	CMP	EAX, 0			
	JS	_negate			; If the number is negative.
	
_convertToStr:
	CMP	EAX, 0
	JE	_finishConvert
	INC	ECX
	MOV	EDX, 0			; Algorithm/calculation to convert a number (int) to ASCII representation.
	MOV	EBX, 10
	CDQ
	IDIV	EBX

	MOV	EBX, EDX		
	ADD	EBX, 48
	PUSH	EAX

	MOV	EAX, EBX
	STOSB
	POP	EAX
	JMP _convertToStr

_finishConvert:
	MOV	ESI, [EBP + 32]		; tempStr to ESI.
	ADD	ESI, ECX
	DEC	ESI
	MOV	EDI, [EBP + 28]		; outStr to ESI.

		_revLoop:
			STD
			LODSB
			CLD
			STOSB
			LOOP	_revLoop
			
	mDisplayString [EBP + 28]

	PUSH	ESI			; Preserve register.
	MOV	ESI, [EBP + 24]		; resetStr to ESI.
	MOV	EDI, [EBP + 28]		; outStr to EDI.
	MOV	ECX, 12
	REP	MOVSB			; Clears outStr.
	POP	ESI			; Restore register.
	
	MOV	EAX, [EBP + 8]		; isLastNum to EAX for comparison.
	CMP	EAX, 0	
	JE	_insertCommaSpace
	JNE	_done

_negate:
	NEG	EAX			; Negative number.

_convertToStrNegative:
	CMP	EAX, 0
	JE	_finishConvertNegative
	INC	ECX
	MOV	EDX, 0			; Algorithm/calculation to convert a number (int) to ASCII representation.
	MOV	EBX, 10
	CDQ
	IDIV	EBX

	MOV	EBX, EDX
	ADD	EBX, 48
	PUSH	EAX

	MOV	EAX, EBX
	STOSB
	POP	EAX
	JMP _convertToStrNegative

_finishConvertNegative:
	MOV	ESI, [EBP + 32]		; tempStr to ESI.
	ADD	ESI, ECX
	DEC	ESI
	MOV	EDI, [EBP + 28]		; outStr to ESI.

		_revLoopNegative:
			STD
			LODSB
			CLD
			STOSB
			LOOP	_revLoopNegative
			
	mDisplayString [EBP + 20]	; negativeSign.
	mDisplayString [EBP + 28]	

	PUSH	ESI			; Preserve register.
	MOV	ESI, [EBP + 24]		; resetStr to ESI.
	MOV	EDI, [EBP + 28]		; outStr to EDI.
	MOV	ECX, 12
	REP	MOVSB			; Clears outStr.
	POP	ESI			; Restore register.
	
	MOV	EAX, [EBP + 8]		; isLastNum to EAX for comparison.
	CMP	EAX, 0
	JE	_insertCommaSpace
	JNE	_done

_insertCommaSpace:
	mDisplayString [EBP + 16]	; commaSpace.

_done:
	POP	ESI			; Restore registers.
	POP	EDI
	POP	EBP
	RET	28

writeVal	ENDP

END main
