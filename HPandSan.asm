
_panelBaseAddress	= &7800
_sanBarX		= 18
_sanBarY		= 4+7+7
_hpBarX			= 8
_hpBarY			= 11+1+7
	
_sanBarAddress		= _panelBaseAddress + (512*(_sanBarY DIV 8)) + (_sanBarY AND 7) + (_sanBarX*8/2)
_hpBarAddress 		= _panelBaseAddress + (512*(_hpBarY DIV 8)) + (_hpBarY AND 7) + (_hpBarX*8/2)

_sanLossFrameDelayLatch = 8
_hpLossFrameDelayLatch 	= 4

.refillHealthBars:
	{
	;
	; Do 50 pixels of bar (25 iterations)
	LDX #0
	LDY #0

.barLoop:
	LDA #168 OR (168>>1) ; 14
	STA _hpBarAddress,X
	STA _hpBarAddress+1,X
        
	;LDA #%10000010 OR (%10000010>>1) ; colour 9
	;STA _sanBarAddress,X
	;STA _sanBarAddress+1,X
        
	TXA
	CLC
	ADC #8
	TAX
	INY
	CPY playerEnergy
	BNE barLoop
	RTS
	}
	
.updateHPAndSan:
	{
	LDA playerHPLoss
	BEQ out ; Nothing to do

	DEC hpLossFrameDelay
	BNE out

	LDA #_hpLossFrameDelayLatch
	STA hpLossFrameDelay

	DEC playerHPLoss
	BNE jump2

	LDA #$e0 + PAL_red
	STA $fe21
        
.jump2:
	;
	; Now do the bar
	LDY playerEnergy
	BEQ out;handleSanLoss
	DEY
	STY playerEnergy

	; Do 50 pixels of bar (25 iterations)
	LDX #0
	LDY #0
	
.barLoop:
	LDA #0
	CPY playerEnergy
	BCS pop
	LDA #168 OR (168>>1) ; 14
	
.pop:
	STA _hpBarAddress,X
	STA _hpBarAddress+1,X
	TXA
	CLC
	ADC #8
	TAX
	INY
	CPY #28
	BNE barLoop

IF 0        
.handleSanLoss:
	LDA playerSanLoss
	BEQ out
	
	DEC sanLossFrameDelay
	BNE out

	LDA #_sanLossFrameDelayLatch
	STA sanLossFrameDelay

	DEC playerSanLoss
	BNE jump
	
	LDA #$90 + PAL_red
	STA $fe21
.jump:
	;
	; Now do the bar
	LDY playerSanity
	BEQ out
	DEY
	STY playerSanity

	;
	; Do 50 pixels of bar (25 iterations)
	LDX #0
	LDY #0
	
.barLoop2
	LDA #0 ; black
	CPY playerSanity
	BCS pop2
	LDA #%10000010 OR (%10000010>>1)
.pop2
	STA _sanBarAddress,X
	STA _sanBarAddress+1,X
	TXA
	CLC
	ADC #8
	TAX
	INY
	CPY #28
	BNE barLoop2
ENDIF
	    
.out:
	RTS
IF 0
.sanLossFrameDelay
	EQUB _sanLossFrameDelayLatch
ENDIF

	
	}
	
PRINT "* HPAndSAn size: ",P%-refillHealthBars
