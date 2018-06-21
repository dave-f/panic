_bitNull		= &00
_bitClimbable 		= &80
_bitCollidable 		= &40
_bitFlipped 		= &20
_bitHookable		= &10

;_bitRope		= &01
_bitColour		= &80
	
_tileFlagsMask		= &F0
_invTileFlagsMask	= &0F

	; *getTileX -> Hit x
	; *getTileY -> Hit y
	;
	; On exit - A corrupted
	;           X is preserved
	;	    Y is index into map table

.getTile
	{
	; Take 32 off the Y value to account for the top panel
	LDA getTileX
	LSR A	; /2
	LSR A	; /4
	LSR A	; /8
	LSR A	; /16
	STA getTileWork	; work = (Hx/16)

	LDA getTileY
	SEC
	SBC #32

	LSR A	; y = ((y/16) * 8) compressed to 1 LSR and AND
	AND #&F8
	
	CLC
	ADC getTileWork
	TAY
	RTS
	}

	; A - Tile index to draw
.redrawTile:
	{
	; Save
	TAX
	; Set screen address for this tile (into t2,t3)
	ASL A
	TAY
	LDA tileAddressTable,Y
	STA t2
	LDA tileAddressTable+1,Y
	STA t3
	; This bit set if just a colour
	LDA tileData,X
	TAY
	AND #_bitColour
	BEQ normalTile
	;LDY #3 ; debug-plot redrawn tile as red, with above line commented out

.tileIsColour:
	TYA
	AND #&0f
	STA t0
	LDA #0
	STA t1
	JMP fastColourPlotDirect16x16

.normalTile:
	; Get flipped flag
	LDA collData,X
	AND #_bitFlipped
	BEQ notFlipped

	; The only tile currently flipped in y is 0.
	; Also see player.asm and screen.asm
	TYA
	AND #_invTileFlagsMask
	BEQ flippedInY
	CMP #8
	BEQ flippedInY

.flippedInX:	
	LDA #$80
	PHA
	BNE flipDone ; was jmp

.flippedInY:
	LDA #$40
	PHA
	BNE flipDone ; was jmp
	
.notFlipped:
    ; 01/07/2013 - A is already 0
	; LDA #$00 
	PHA
	
.flipDone:
	TYA
	CMP #8
	BCC notAnXTile
	; take off the 8 so it's a proper index into extra tileset
	;SEC
	;SBC #8
	AND #$7
	TAY
	LDA #LO(unpackedTileXSprites)
	STA tileBaseLoadLO+1
	LDA #HI(unpackedTileXSprites)
	STA tileBaseLoadHI+1
    jmp pass
	
.notAnXTile:
	LDA #LO(unpackedTileSprites)
	STA tileBaseLoadLO+1
	LDA #HI(unpackedTileSprites)
	STA tileBaseLoadHI+1
	
.pass:
	; Get tile index back
	TYA
	; *2 
	ASL A
	TAX
	LDA lookup128,X
	STA t0
	LDA lookup128+1,X
	STA t1
	
	; Now add this 128* to the base sprite pointer
	CLC
.tileBaseLoadLO:
	LDA #LO(unpackedTileSprites)
	ADC t0
	STA t0
.tileBaseLoadHI:
	LDA #HI(unpackedTileSprites)
	ADC t1
	STA t1
	
	;; t0,t1 => sprite ptr (if t1 == 0 then use t0's as colour)
	;; t2,t3 => screen address
	;; Pull the flipped flags off the stack and or them in.
	PLA
	ORA t1
	STA t1
	JMP plotTileDirect ; was JSR
	;RTS
	}
	
