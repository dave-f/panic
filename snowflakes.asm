_numSnowFlakes		= 10 ; can drop to 8 to save cycles / mem - REMEMBER THIS IS ALSO IN MEMORY.ASM TOO
	
_effectNone		= &00
_effectSnow		= &10
_effectPaletteChange	= &20 ; change to red for hell
_effectPaletteChange2	= &40 ; change to magenta for catacombs area
_effectGems	        = &80 ; read inv bits, plot red/green boxes for eyes on statues
_effectDark		= &08 ; dark unless have torch

.snowFlakes
	{
	; Get number of snowflakes plotted last frame
	LDX flakeActiveList
	BEQ doneRemovingOldFlakes

	LDY #0
	
	LDA #LO(flakeActiveList+1)
	STA t0
	LDA #HI(flakeActiveList+1)
	STA t1
	
.removeOldFlakesLoop

	; Get mask - commented out on 26/05/2010 as it didn't do much?
	; LDA (t0),Y
	; STA t5
	INY
	; Get address lo
	LDA (t0),Y
	INY
	STA t2
	; Get address hi
	LDA (t0),Y
	INY
	STA t3

	; Store mask, eg remove flake : Y reg needs saving here, zeroing, and restoring
	TYA
	PHA
	LDA #0
    TAY
	STA (t2),Y
	PLA
	TAY
	
	DEX
	BNE removeOldFlakesLoop

.doneRemovingOldFlakes
	
	LDA #0
	STA t8		  	; t8 = active flake table
	STA t9			; t9 = x,y table offset (+2 bytes each pass)
	
	STA flakeActiveList	; Re-initialise active list

	TAY			; Zero index register

	LDA #7
	STA t2			; t2 = colour

.flakeLoop
	LDA (flakesLO),Y
	STA ta			; Get x pos to ta
	INY
	LDA (flakesLO),Y		
	STA tb			; Get y pos to tb
	
	STY tc			; tc = index
	
	INC tb			; Increment Y
	LDA #16
	AND tc
	BEQ noInc		; Used for a parallex
	INC tb
.noInc
	LDA tb
	CMP #&d0		; If at bottom, wrap
	BCC ok
	LDA #&20
.ok
	STA (flakesLO),Y	; Store Y back
	TAY
	LDA (sinTableLO),Y	; Load sin for this Y position
	CLC
	ADC ta			; Add X pos to sin value
	
	STA t0			; t0 => X
	STY t1			; t1 = >Y

	; New - windowed snowflake effect for caves
.checkFlakeX1
	CMP snowWindow+0
	BCC endOfFlake
.checkFlakeY1
	CPY snowWindow+1
	BCC endOfFlake
.checkFlakeX2
	CMP snowWindow+2
	BCS endOfFlake
.checkFlakeY2
	CPY snowWindow+3
	BCS endOfFlake
	
	; Go through player tiles
	LDX playerTileList
	BEQ doneTileCheck
	STY tf
.checkPlayerTile
	LDA playerTileList,X
	CMP tf
	BEQ endOfFlake
	DEX
	BNE checkPlayerTile
	
.doneTileCheck
	JSR plotPixelSet
	BCC notPlotted
	
	; Add y offset
	CLC
	TYA
	ADC t3
	STA t3
	LDA #0
	ADC t4
	STA t4

	; We have another snowflake!
	INC flakeActiveList

	; Store details
	LDY t8
	LDA #LO(flakeActiveList+1)
	STA t0
	LDA #HI(flakeActiveList+1)
	STA t1
	
	; Save mask : Either left or right pixel
	TXA
	STA (t0),Y
	INY
	
	; Save transformed pixel address
	LDA t3
	STA (t0),Y
	INY
	LDA t4
	STA (t0),Y
	INY
	
	; Update offset
	STY t8

.notPlotted

.endOfFlake	
	LDY t9
	INY
	INY
	STY t9
.flakeCheckEnd
	CPY #_numSnowFlakes * 2
	BNE flakeLoop

	; We need to a) set a flag to indicate just doing one snowflake OR store 1*2 at 'flakeCheckEnd'
	;            b) increment the offset of the flake number each time it reaches bottom
	;            c) init the flake to Y=12*6
	RTS
	}
	
