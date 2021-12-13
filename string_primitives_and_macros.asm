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

	numSum		SDWORD	?
	numAve		SDWORD	?
	numCount	SDWORD	10
	
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

	Invoke ExitProcess,0		; Exit to operating system.
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
	mDisplayString [EBP + 24]	; OFFSET programTitle
	CALL	CrLf
	
	mDisplayString [EBP + 20]	; OFFSET programmerName
	CALL	CrLf
	CALL	CrLf
	
	mDisplayString [EBP + 16]	; OFFSET introMsg1
	CALL	CrLf
	CALL	CrLf
	
	mDisplayString [EBP + 12]	; OFFSET introMsg2
	CALL	CrLf
	
	mDisplayString [EBP + 8]	; OFFSET introMsg3
	CALL	CrLf
	
	POP	EBP			; Restore the register.
	RET	20
	
introduction	ENDP

END main
