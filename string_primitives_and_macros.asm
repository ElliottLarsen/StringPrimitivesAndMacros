TITLE String Primitives and Macros     (string_primitives_and_macros.asm)

; Author: Elliott Larsen
; Date: 12/23/2021
; Description: This program receives signed integers as strings (ASCII representation of numbers) using mGetString (macro),
;	       converts them to integers (numeric value), and saves them to an array.  It then calculates the sum and truncated
;	       average (integer part only) of the input numbers.  Finally, it converts integers (numeric) back to strings (ASCII)
;	       and shows the list of numbers entered, their sum, and their truncated average.  The program ends with a farewell
;	       message.

INCLUDE Irvine32.inc

;---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Displays the string.
;
; Preconditions: String to be displayed is passed to it.
;
; Postconditions: The string is displayed and EDX holds the OFFSET to the string.
;
; Receives: OFFSET of the string to be displayed and EDX.
;
; Returns: EDX value is restored.
;---------------------------------------------------------------------------------

mDisplayString	MACRO	display_string

	PUSH	EDX					; Preserve the register value.
	
	MOV	EDX, display_string
	CALL	WriteString
	
	POP	EDX					; Restore the register value.

ENDM

;---------------------------------------------------------------------------------
; Name: mGetString
;
; Receives a string from the user.  In this case, it is an ASCII representation
;	of signed integers.
;
; Preconditions: prompt, inputStr, numChar, and strLen are on the stack.
;
; Postconditions: Prompt message is displayed and it receives a string.  EDX takes
;	the offset of the prompt string, ECX takes the buffer size, and EAX has the
;	number of characters it received.
;
; Receives: prompt, inputStr, numChar, strLen, EDX, EAX, and ECX.
;
; Returns: strLen passed to this macro from the stack now has the number of
;	characters it received.
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

	MAXSIZE = 12					; Including a unary operator and null.			
	SDWORDLO = -2147483648
	SDWORDHI = +2147483647

.data

	programTitle	BYTE	"String Primitives and Macros", 0
	programmerName	BYTE	"By Elliott Larsen", 0
	introMsg1	BYTE	"Please provide 10 signed decimal integers.", 0
	introMsg2	BYTE	"Each number must be small enough to fit inside a 32-bit register. After all 10 integers are received,", 0 
	introMsg3	BYTE	"this program will display the list of entered integers, their sum, and truncated average.", 0

	numPrompt	BYTE	"Please enter a signed number: ", 0
	errorMsg1	BYTE	"ERROR: Your input is not recognized.", 0
	errorMsg2	BYTE	"Did you enter a signed integer?  Does your input fit inside a 32-bit register? Let's try again.", 0

	inputNumMsg	BYTE	"You entered the following integers:", 0
	sumNumMsg	BYTE	"The sum of these numbers is: ", 0
	aveNumMsg	BYTE	"The truncated average is: ",0
	commaSpace	BYTE	", ", 0
	negativeSign	BYTE	"-", 0
	positiveSign	BYTE	"+", 0
	goodbyeMsg	BYTE	"Thank you for using this program.  Goodbye!", 0
	
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

	; parameters and procedure call for introduction
	PUSH	OFFSET programTitle			
	PUSH	OFFSET programmerName			
	PUSH	OFFSET introMsg1			
	PUSH	OFFSET introMsg2			
	PUSH	OFFSET introMsg3			
	CALL	introduction
	
	; readVal
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
	
	; writeVal
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
	
	; writeVal for the last number
	INC	isLastNum
	PUSH	OFFSET tempStr
	PUSH	OFFSET outStr
	PUSH	OFFSET resetStr
	PUSH	OFFSET negativeSign
	PUSH	OFFSET commaSpace
	PUSH	counter
	PUSH	isLastNum
	CALL	writeVal
	CALL	CrLf
	CALL	CrLf
	
	; numSumDisplay
	PUSH	OFFSET inNumArray
	PUSH	OFFSET sumNumMsg
	PUSH	OFFSET tempStr
	PUSH	OFFSET outStr
	PUSH	OFFSET resetStr
	PUSH	OFFSET negativeSign
	PUSH	numCount
	PUSH	numSum
	CALL	numSumDisplay
	CALL	CrLf
	
	; numAveDisplay
	PUSH	OFFSET inNumArray
	PUSH	OFFSET aveNumMsg
	PUSH	OFFSET tempStr
	PUSH	OFFSET outStr
	PUSH	OFFSET resetStr
	PUSH	OFFSET negativeSign
	PUSH	numcount
	PUSH	numAve
	CALL	numAveDisplay
	CALL	CrLf
	CALL	CrLf
	
	; farewell
	PUSH	OFFSET goodbyeMsg
	CALL	farewell
	CALL	CrLf

	Invoke ExitProcess,0				; Exit to operating system.
	
main ENDP

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
; Name: readVal
;
; Invokes mGetString to receive user input, converts the input string to integer,
;	and stores it in an array.
;
; Preconditions: OFFSETs to null-terminated strings and empty array and other values
;	are present on the stack.
;
; Postconditions: The array is filled with signed integers.  Depending on the input
;	received, error message may be displayed.  Register values change depending
;	on the user input.
;
; Receives: OFFSETs to an empty array, messages, and various values.  EAX, EDI, ECX, 
;	EBP, EBX, EDX, ESI, and EDI.
;
; Returns: EBP value is restored.
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
; Name: writeVal
;
; Converts integers (numeric) to strings (ASCII) and invokes mDisplayString to
;	display.
;
; Preconditions: OFFSETs to various null-terminated strings and other values are 
;	present on the stack.
;
; Postconditions: The array element is displayed in ASCII representation.  Register
;	values change depending on the data passed to them.
;
; Receives: OFFSETs to an array, message, and various values.  EBP, ESP, ESI, EDI,
;	ECX, EAX, EBX, and EDX.
;
; Returns: ESI, EDI, and EBP values are restored.
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
	JNE	_convertToStr
	
	MOV	EDX, 0			; If the entered value is 0, then convert it to ASCII representation.
	MOV	EBX, 10			; The program will terminate otherwise because 0 is read as a null character.
	CDQ
	IDIV	EBX
	MOV	EBX, EDX
	ADD	EBX, 48
	MOV	EAX, EBX
	STOSB
	ADD	ECX, 1
	JMP	_finishConvert
	
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

;---------------------------------------------------------------------------------
; Name: numSumDisplay
;
; Calculates the total sum of the numbers entered, converts it to ASCII, and
;	displays the result.
;
; Preconditions: The array consisting of integers and null-terminated strings are
;	present on the stack.
;
; Postconditions: All numbers in the array are added up and displayed.  Registers
;	change their values depending on the data passed to them.
;
; Receives: OFFSETs to strings and various values.  EAX, EBP, ESP, ESI, EDI, EDX,
;	ECX, and EBX.
; 
; Returns: EBP, ESI, and EDI values are restored.
;---------------------------------------------------------------------------------

numSumDisplay	PROC

	PUSH	EBP			; Build stack frame.
	MOV	EBP, ESP
	
	MOV	EAX, [EBP + 8]		; numSum to EAX.
	MOV	ESI, [EBP + 36]		; inNumArray element to ESI.
	MOV	ECX, [EBP + 12]		; numCount to ECX.
	
	_sumLoop:
		ADD	EAX, [ESI]
		ADD	ESI, 4
		LOOP	_sumLoop
	
	MOV	[EBP + 8], EAX		; Total sum of numbers (integer) to numSum.
	MOV	EDI, [EBP + 28]		; tempStr to EDI.	
	MOV	ECX, 0
	
	PUSH	EDI
	PUSH	ESI
	
	CMP	EAX, 0			
	JS	_negate
	JNE	_convertToStr
	
	MOV	EDX, 0			; If the total sum is 0, convert to ASCII representation of the number.
	MOV	EBX, 10			; Otherwise, the program exits because 0 is read as a null character.
	CDQ
	IDIV	EBX
	MOV	EBX, EDX
	ADD	EBX, 48
	MOV	EAX, EBX
	STOSB
	ADD	ECX, 1
	JMP	_finishConvert
	
_convertToStr:
	CMP	EAX, 0
	JE	_finishConvert
	INC	ECX
	MOV	EDX, 0
	MOV	EBX, 10
	CDQ
	IDIV	EBX
	
	MOV	EBX, EDX
	ADD	EBX, 48
	PUSH	EAX
	MOV	EAX, EBX
	STOSB
	POP	EAX
	JMP	_convertToStr
	
_finishConvert:
	MOV	ESI, [EBP + 28]		; tempStr to ESI.
	ADD	ESI, ECX
	DEC	ESI
	MOV	EDI, [EBP + 24]		; outStr to EDI.
	
	_revLoop:
		STD
		LODSB
		CLD
		STOSB
		LOOP	_revLoop
		
	mDisplayString [EBP + 32]	; sumNumMsg.
	mDisplayString [EBP + 24]	
	
	PUSH	ESI			; Preserve register.
	MOV	ESI, [EBP + 20]		; resetStr to ESI.
	MOV	EDI, [EBP + 24]		; outStr to EDI.
	MOV	ECX, 12
	REP	MOVSB			; Clears outStr.
	POP	ESI			; Restore register.
	
	POP	ESI
	POP	EDI
	JMP	_done

_negate:
	NEG	EAX
	
_convertToStrNegative:
	CMP	EAX, 0
	JE	_finishConvertNegative
	INC	ECX
	MOV	EDX, 0
	MOV	EBX, 10
	CDQ
	IDIV	EBX
	
	MOV	EBX, EDX
	ADD	EBX, 48
	PUSH	EAX
	MOV	EAX, EBX
	STOSB
	POP	EAX
	JMP	_convertToStrNegative
	
_finishConvertNegative:
	MOV	ESI, [EBP + 28]		; tempStr to ESI.
	ADD	ESI, ECX
	DEC	ESI
	MOV	EDI, [EBP + 24]		; outStr to EDI.
	
	_revLoopNegative:
		STD
		LODSB
		CLD
		STOSB
		LOOP	_revLoopNegative
		
	mDisplayString [EBP + 32]	; sumNumMsg.
	mDisplayString [EBP + 16] 	; negativeSign.
	mDisplayString [EBP + 24]	
	
	PUSH	ESI			; Preserve register.
	MOV	ESI, [EBP + 20]		; resetStr to ESI.
	MOV	EDI, [EBP + 24]		; outStr to EDI.
	MOV	ECX, 12
	REP	MOVSB			; Clears outStr.
	POP	ESI			; Restore register.
	
	POP	ESI
	POP	EDI
	
_done:
	POP	EBP			; Restore register.
	RET	32

numSumDisplay	ENDP

;---------------------------------------------------------------------------------
; Name: numAveDisplay
;
; Calculates the average of the numbers in the array, converts the result (integer
;	part) to ASCII, and displays the result.
;
; Preconditions: The array consisting of integers and null-terminated strings are
;	present on the stack.
;
; Postconditions: The truncated average of all numbers is calculated and displayed.  
;	Registers change their values depending on the data passed to them.
;
; Receives: OFFSETs to strings and various values.  EAX, EBP, ESP, ESI, EDI, EDX,
;	ECX, and EBX.
;
; Returns: EBP, ESI, and EDI values are restored.
;---------------------------------------------------------------------------------

numAveDisplay	PROC
	
	PUSH	EBP			; Build stack frame.
	MOV	EBP, ESP
	
	MOV	EAX, [EBP + 8]		; numAve to EAX.
	MOV	ESI, [EBP + 36]		; inNumArray to ESI.
	MOV	ECX, [EBP + 12]		; numCount to ECX.
	
	_sumLoop:
		ADD	EAX, [ESI]	; Add each element of inNumArray to EAX.
		ADD	ESI, 4
		LOOP	_sumLoop
	
	MOV	EDX, 0			; Clear EDX.
	MOV	EBX, [EBP + 12]		; numCount to EBX.
	CDQ
	IDIV	EBX
	
	MOV	[EBP + 8], EAX		; numAve now has the truncated average (integer part) of all numbers.
	MOV	EDI, [EBP + 28]		; tempStr to EDI
	
	MOV	ECX, 0
	
	PUSH	EDI
	PUSH	ESI
	
	CMP	EAX, 0			
	JS	_negate
	JNE	_convertToStr
	
	MOV	EDX, 0			; If the truncated average is 0, convert to ASCII representation of the number.
	MOV	EBX, 10			; Otherwise, the program exits because 0 is read as a null character.
	CDQ
	IDIV	EBX
	MOV	EBX, EDX
	ADD	EBX, 48
	MOV	EAX, EBX
	STOSB
	ADD	ECX, 1
	JMP	_finishConvert
	
_convertToStr:
	CMP	EAX, 0
	JE	_finishConvert
	INC	ECX
	MOV	EDX, 0
	MOV	EBX, 10
	CDQ
	IDIV	EBX
	
	MOV	EBX, EDX
	ADD	EBX, 48
	PUSH	EAX
	MOV	EAX, EBX
	STOSB
	POP	EAX
	JMP	_convertToStr
	
_finishConvert:
	MOV	ESI, [EBP + 28]		; tempStr to ESI.
	ADD	ESI, ECX
	DEC	ESI
	MOV	EDI, [EBP + 24]		; outStr to EDI.
	
	_revLoop:
		STD
		LODSB
		CLD
		STOSB
		LOOP	_revLoop
		
	mDisplayString [EBP + 32]	; aveNumMsg.
	mDisplayString [EBP + 24]	
	
	PUSH	ESI			; Preserve register.
	MOV	ESI, [EBP + 20]		; resetStr to ESI.
	MOV	EDI, [EBP + 24]		; outStr to EDI.
	MOV	ECX, 12
	REP	MOVSB			; Clears outStr.
	POP	ESI			; Restore register.
	
	POP	ESI
	POP	EDI
	JMP	_done

_negate:
	NEG	EAX
	
_convertToStrNegative:
	CMP	EAX, 0
	JE	_finishConvertNegative
	INC	ECX
	MOV	EDX, 0
	MOV	EBX, 10
	CDQ
	IDIV	EBX
	
	MOV	EBX, EDX
	ADD	EBX, 48
	PUSH	EAX
	MOV	EAX, EBX
	STOSB
	POP	EAX
	JMP	_convertToStrNegative
	
_finishConvertNegative:
	MOV	ESI, [EBP + 28]		; tempStr to ESI.
	ADD	ESI, ECX
	DEC	ESI
	MOV	EDI, [EBP + 24]		; outStr to EDI.
	
	_revLoopNegative:
		STD
		LODSB
		CLD
		STOSB
		LOOP	_revLoopNegative
		
	mDisplayString [EBP + 32]	; aveNumMsg.
	mDisplayString [EBP + 16] 	; negativeSign.
	mDisplayString [EBP + 24]	
	
	PUSH	ESI			; Preserve register.
	MOV	ESI, [EBP + 20]		; resetStr to ESI.
	MOV	EDI, [EBP + 24]		; outStr to EDI.
	MOV	ECX, 12
	REP	MOVSB			; Clears outStr.
	POP	ESI			; Restore register.
	
	POP	ESI
	POP	EDI
	
_done:
	POP	EBP			; Restore register.
	RET	32	

numAveDisplay	ENDP

;---------------------------------------------------------------------------------
; Name: farewell
;
; Displays the farewell message using mDisplayString.
;
; Preconditions: A null-terminated goodbye message is present on the stack.
;
; Postconditions: The string is displayed.  EDX holds the OFFSET to the string.
;
; Receives: OFFSET to the string, EBP, ESP, and EDX.
;
; Returns: EBP value is restored.
;---------------------------------------------------------------------------------

farewell	PROC

	PUSH	EBP			; Build stack frame.
	MOV	EBP, ESP
	
	mDisplayString [EBP + 8]
	
	POP	EBP
	RET	4

farewell	ENDP

END main
