; drawStringWithOSFont:
;
;		X  : centring flag
;		Y  : string index
;		t2 : screen address lo pointer
;		t3 : screen address hi pointer
;		t4 : length
;	
;		Uses t0,t1,t4,t5,t6,t7,t8

.drawStringWithOSFont:
{
.init:
	LDA #LO(stringTable)
	STA t0
	LDA #HI(stringTable)
	STA t1

	; Offsets are now 16 bit, so this index needs *2, fine up to 127 strings
    TYA
    ASL A
    TAY
        
    LDA (t0),Y ; offset lo
    STA t4
    INY
    LDA (t0),Y ; offset hi
    STA t5

    ; Do the 16 bit add
    CLC
        
    LDA t0
    ADC t4
    STA t0
        
    LDA t1
    ADC t5
    STA t1
        
	CPX #0
	BEQ centreDone
	
	LDY #0
.calcStringLengthLooop:
	LDA (t0),Y
	BEQ calcNumSpaces
	INY
	JMP calcStringLengthLooop
	
	; numSpaces = (14-stringlength) / 2
.calcNumSpaces:
	CPY #14
	BEQ centreDone
	STY t4
	LDA #14
	SEC
	SBC t4
	LSR A
	TAX
	
.addSpace:
	CLC
	LDA t2
	ADC #32
	STA t2
	LDA t3
	ADC #0
	STA t3
	DEX
	BNE addSpace
	
.centreDone:
	LDA #0
	STA t6
	LDA t4

.stringLoop:
	; Get character from (t0)
	LDY t6
	LDA (t0),Y
	BEQ stringOut
	CMP #' '
	BNE notSpace
	LDA #0
	
.notSpace:
	CLC
	STA t7
	LDA #0
	STA t8
	
	; Multiply by 8
	ASL t7:ROL t8
	ASL t7:ROL t8
	ASL t7:ROL t8

	; Add OS table base address (0xC000)
	CLC
	LDA t8
	ADC #&C0
	STA t8
	
	; Store at 'characterLoad'
	LDA t7
	STA characterLoad+1
	LDA t8
	STA characterLoad+2
	
.drawCharacter:

	; 8 scanlines to do
	LDY #7
	
.scanLineLoop:

	; Initialise screen pointer
	LDA t2
	STA storeToScreen+1
	LDA t3
	STA storeToScreen+2

	; t4 = 4 iterations per scanline
	LDA #3
	STA t4

	; '!'
.characterLoad:
	LDA &C108,Y
	STA t5

.pixelLoop:
	; X is index into pixel table
	LDX #0

	LDA #&80
	BIT t5
	BEQ rightPixel
	
.leftPixel:
	INX

.rightPixel:
	LSR A;LDA #&40 05/03/2012 - This was LDA #&40; but i've changed it to simple LSR as this saves 1 byte, and now fits in memory
	BIT t5
	BEQ drawPixel
	INX
	INX

.drawPixel:
	ASL t5
	ASL t5
	LDA textPixelTable,X
	
.storeToScreen:
	STA &4000,Y

	LDA storeToScreen+1
	CLC
	ADC #8
	STA storeToScreen+1
	BCC noCarry
	INC storeToScreen+2
	
.noCarry:
	DEC t4
	BPL pixelLoop

	DEY
	BPL scanLineLoop

	CLC
	LDA t2
	ADC #32
	STA t2
	BCC noCarry2
	INC t3
	
.noCarry2:
	INC t6
	JMP stringLoop

.stringOut:
	RTS
}

PRINT "* Text size:", P%-drawStringWithOSFont
	
IF FALSE
	; TODO: Needs fixing as drawString() now takes an index rather than a string pointer.
.drawDebugNumber:
	{
	LDA t0
	LSR A:LSR A:LSR A:LSR A
	CMP #$A
	BCC lower
	CLC
	ADC #33-16-10
.lower:
	ADC #16
	STA debugNumberBuffer

.secondDigit:
	LDA t0
	AND #$f
	CMP #$A
	BCC lower2
	CLC
	ADC #33-16-10
.lower2:
	ADC #16
	STA debugNumberBuffer+1
	
	LDA #LO(debugNumberBuffer)
	STA t0
	LDA #HI(debugNumberBuffer)
	STA t1
	LDA #2
	STA t4
	JSR drawStringWithOSFont
	RTS
	}
.debugNumberBuffer:
	SKIP 2
ENDIF
