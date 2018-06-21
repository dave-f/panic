	;; t0 -> x
	;; t1 -> y
	;; t2 -> colour

	;; On exit t3,t4 are the transformed address and X is the colour lookup

.plotPixel
	{
	LDA t1
	LSR A
	LSR A
	AND #&FE
	TAX
	LDA t0
	AND #&FE
	ASL A
	ASL A
	STA t3
	TXA
	ADC #&40
	STA t4
	LDA t1
	AND #7
	TAY
	LDA t0
	LSR A
	LDA t2
	ROL A
	TAX
	LDA colours,X
	EOR (t3),Y		; This can be change to two NOPs to stop the XOR
	STA (t3),Y
	RTS
	}

.plotPixelSet
	{
	LDA t1
	LSR A
	LSR A
	AND #&FE
	TAX
	LDA t0
	AND #&FE
	ASL A
	ASL A
	STA t3
	TXA
	ADC #&40
	STA t4
	LDA t1
	AND #7
	TAY
	LDA t0
	LSR A
	LDA t2
	ROL A
	TAX
	LDA (t3),Y
	BNE noPlot
	LDA colours,X
	STA (t3),Y
	SEC
	RTS
.noPlot
	CLC
	RTS
	}	

PRINT "* Plot pixel size:", P%-plotPixel
	
IF FALSE
	; Draws a box at t0,t1 with width and height at t2,t3 in colour t4
.drawBox
	{
	LDA t0
	STA orgX
	LDA t1
	STA orgY
	LDA t2
	STA width
	LDA t3
	STA height
	LDA t4
	STA t2
	
	; t0,t1   -> t0+w,t1
	LDA orgX
	STA t0
	LDA orgY
	STA t1
	LDA width
	STA t5
	; change to inc &70
	LDA #t0
	STA iter+1
	JSR drawLineLoop
	
	; t0+w,t1 -> t0+w,t1+h
	LDA orgX
	CLC
	ADC width
	STA t0
	LDA orgY
	STA t1
	LDA height
	STA t5
	; change to inc &71
	LDA #t1 
	STA iter+1
	JSR drawLineLoop
	
	; t0,t1   -> t0,t1+h
	LDA orgX
	STA t0
	LDA orgY
	STA t1
	INC t1
	; change to inc &71
	LDA #t1
	STA iter+1
	LDA height
	STA t5
	JSR drawLineLoop
	
	; t0,t1+h -> t0+w,t1+h
	LDA orgX
	STA t0
	INC t0
	LDA orgY
	CLC
	ADC height
	STA t1
	; change to inc &71
	LDA #t0
	STA iter+1
	LDA width
	STA t5
	JSR drawLineLoop
	
	RTS
	
.orgX
	SKIP 1
.orgY
	SKIP 1
.width
	SKIP 1
.height
	SKIP 1
	
.drawLineLoop
	JSR plotPixel
.iter
	INC t0
	DEC t5
	BNE drawLineLoop
	RTS
	}
	
ENDIF
