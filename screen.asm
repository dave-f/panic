_screenChangeLeft	= 1
_screenChangeRight	= 2
_screenChangeDown	= 3
_screenChangeUp		= 4

.soundEerie:
EQUB 160    ; pitch
EQUB 1     ; pitch envelope
EQUB 6     ; volume envelope
	
.drawScreen:
	{
	; Drawn 0 snowflakes this frame
	LDA #0
	STA flakeActiveList
    TAX
    LDA #1
    STA shogDrawElderSigns
        
    LDA playerScreen
    CMP #45 ; on shoggoth don't touch
    BEQ nextCheck
    STX numElderSigns ; eldersigns=0

.nextCheck:
    CMP #41
    BNE noSigns
    
    LDA #4
    STA numElderSigns
    LDY #16*6+8+8+3
    LDA #(16*3)-3

.elderSol:        
    STA elderSignsPos,X
    STY elderSignsPos+1,X
    CLC
    ADC #10
    INX
    INX
    CPX #8
    BNE elderSol

.noSigns:        
    LDX #$ff
.checkWindowLoop:
	INX
	LDA snowWindowValueTable,X
	BEQ checkWindowLoopOut
	CMP playerScreen
	BNE checkWindowLoop
	;BEQ foundMatch
	;INX
	;JMP checkWindowLoop
        
.foundMatch:
	; JSR setupSnowFlakesForScreen
	; X is offset into table
;.setupSnowFlakesForScreen
	;{
	TXA
	; Times index by 4 to get the value
	ASL A
	ASL A
	TAX
	LDY #0
.setupSnowLoop
	LDA snowWindowValues,X
	STA snowWindow,Y
	INX
	INY
	CPY #4
	BNE setupSnowLoop
	;RTS
	;}
	JMP doneSnowWindow
        
.checkWindowLoopOut:
	; Setup default window
	LDA #0
	STA snowWindow
	STA snowWindow+1
	LDA #16*8
	STA snowWindow+2
	LDA #16*13
	STA snowWindow+3

.doneSnowWindow:
	; No tiles to do
	LDA #0
	STA playerTileList

	; No rope
	STA ropeState
	
	; Unpack counter offset
	STA ta

	; tb,tc => 8 bytes of screen data
	LDX playerScreen
	; DEX
	STX tb
	TAX; LDX #0
	STX tc

	; tb,tc = (screenIndex-1)*8 gives us the offset
	ASL tb
	ROL tc
	ASL tb
	ROL tc
	ASL tb
	ROL tc

	; Add onto tb,tc the map address to give address of current screen
	CLC
	LDA #LO(mapData)
	ADC tb
	STA tb
	STA curScreenLO
	LDA #HI(mapData)
	ADC tc
	STA tc
	STA curScreenHI

	; Use Y as an index register into the 8 bytes of screen data
	LDY #0

	; Load tilepage index and string index
	LDA (tb),Y
	PHA

	; Top nibble is index into tileset table (1,2,4..)
	AND #$e0
	LSR A
	LSR A
	LSR A
	LSR A
    STA currentTileBank
	TAX

	CLC
	LDA packedTileTable,X
	ADC #LO(tileSpritesPacked+2)
	STA loadPackedTileSetLO+1
	
	LDA packedTileTable+1,X
	ADC #HI(tileSpritesPacked+2)
	STA loadPackedTileSetHI+1

.unpackTileSet:
	CLC
.loadPackedTileSetHI:
	LDX #0
.loadPackedTileSetLO:
	LDY #0

	JSR unpack
IF 0
	BCC handlePalette
	BRK ; tile unpack failed
ENDIF        

    ; Handle palette.
.handlePalette:
	LDY #2
	LDA (tb),Y
    TAX
	AND #(_effectPaletteChange OR _effectPaletteChange2)
	BEQ palGreen
	
	CMP #_effectPaletteChange
	BNE palMagenta
	
.palRed:
	LDA #&80 + (1 EOR 7)
	STA &FE21
	JMP okPal
	
.palMagenta:
	LDA #&80 + (5 EOR 7)
	STA &FE21
	JMP okPal
	
.palGreen:
	LDA #&80 + (2 EOR 7)
	STA &FE21
	
.okPal:
    ; Check dark flag - if so, turn all colours off.  Need to do this before we re-program
    TXA
    LDX #0
    AND #_effectDark
    BEQ litScreen
    LDA playerInventory
    AND #_bitTorch
    BNE litScreen
    INX
        
.litScreen:
    STX screenDarkFlag
        
	; Restore A,Y and mask off top nibble, leaving screen string index.
	PLA
	AND #$1f
	TAX

	; Plot text
	LDA #LO(&4000 + 512 + (32*8) )
	STA t2
	LDA #HI(&4000 + 512 + (32*8) )
	STA t3

	LDA #0
	TAY;LDY #0
	
.clearTextLoop1:
	STA (t2),Y
	INY
	CPY #256-32
	BNE clearTextLoop1

	LDA #LO(&4000 + 512 + 32)
	STA t2
	LDA #HI(&4000 + 512 + 32)
	STA t3
	LDA #0
	TAY;LDY #0

.clearTextLoop2:
	STA (t2),Y
	INY
	CPY #256-32
	BNE clearTextLoop2

	TXA
	TAY

	LDX #1 ; centre flag
	JSR drawStringWithOSFont
	LDY #0

	; Get the screen index
	INY
	LDA (tb),Y
	
	; Mask off flip bit
	AND #&7F

	; *2 for table index
	ASL A
	TAX

	; (t4,t5) -> Screen data
	LDA screenTable,X
	STA t4
	INX
	LDA screenTable,X
	STA t5

	; Do 12 rows
	LDA #12
	STA tf

	; Index into lookup table
	LDY #0
	STY td
	; Byte offset
	STY tc
	STY tb
	
.outerRowLoop
	; t6 = Tile present byte
	LDY tc
	LDA (t4),Y
	STA t6

	; 8 tiles to do in this row
	LDA #8
	STA te

    ; Initialise run-length
    LDA #0
    STA t7
    STA runLenCnt

.innerRowLoop

	; Set up screen RAM pointers for this tile
	LDY td
	LDA tileAddressTable,Y
	STA t2
	INY
	LDA tileAddressTable,Y
	STA t3
	INY
	STY td

	LDA t6
	
	; Bit set - there is a tile here
	AND #&80
	BNE tilePresent

	; Plot black
	LDA #&00
	STA t0
	STA t1

	; Update collision map
	LDY tb
	STA collData,Y
        
	; Set high bit to say this is a colour
	ORA #_bitColour
	STA tileData,Y
	INY
	STY tb

	; CLC=&18
	; LDA #&18
	; STA drawTile
	JMP drawTile
	
.tilePresent:
    ; 17/02/2012:
    ; Are we run-lengthing?
    LDA runLenCnt;t7
    BEQ noRunLength
        
    ; If so, make t7 is our tile - and jump
    DEC runLenCnt
    BEQ noRunLength
    LDA t7
    TAX
    JMP properTile
    
	; Else load pointer with sprite tile data
.noRunLength:        
	LDY tc
	INY
	LDA (t4),Y
	STY tc
	
	; X register is original data byte
	TAX

    ; 17/02/2012:
	; See if this tile has all high bits set.  If so, it means ALL tiles which follow on this row
    ; are a copy of the following byte, so we store that byte to t7.
	AND #$f0
	CMP #$f0
	BNE properTile

.tileIsRunLength:
    ; Special case
    TXA
    AND #$f ; a = count of run length.  If 0, rest of row.
    BNE noInc
    CMP #$e
    BNE nextBit
    JMP skipTile

.nextBit:
    LDA #255 ; 0=do rest of row

.noInc:
    STA runLenCnt ; zp

    ; Load another byte. This is then used for the rest of the row.
    INY
    LDA (t4),Y
    STY tc
    STA t7 ; store to runlength temp
    TAX ; and transfer to X ready for render

.properTile:
	TXA
	; Update collision map
	AND #_tileFlagsMask
	LDY tb
	STA collData,Y
	
	TXA
	
	; See if this tile is flipped
	AND #_bitFlipped
	BEQ notFlipped
	
	; The only tile flipped in Y currently is the pillar bottom (at index 0).  May in the future include spikes and generics.
	TXA
	AND #_invTileFlagsMask
	BEQ flippedInY
	CMP #8
	BEQ flippedInY

.flippedInX:
	LDA #$80
	PHA
	;JMP flipSet
	bne flipSet
	
.flippedInY:
	LDA #$40
	PHA
	;JMP flipSet
	bne flipSet
	
.notFlipped:
	;LDA #$00 ; already 0
	PHA
	
.flipSet:
	TXA
	
	; Mask off tilebits
	AND #_invTileFlagsMask

	; If tile# is >=8, subtract 8 and point to the generic tile pool.
	CMP #8
	BCC notAnXTile
	;SEC
	;SBC #8
	; Store before -8
	STA tileData,Y
	AND #$07

	; Modify base pointers below
	LDX #LO(unpackedTileXSprites)
	STX tileBaseLoadLO+1
	LDX #HI(unpackedTileXSprites)
	STX tileBaseLoadHI+1

	JMP skipSol2

.notAnXTile:
	; Modify base pointers below
	LDX #LO(unpackedTileSprites)
	STX tileBaseLoadLO+1
	LDX #HI(unpackedTileSprites)
	STX tileBaseLoadHI+1
	
.skipSol:
	; Y is still set OK from above
	STA tileData,Y
	
.skipSol2:
	STA t0

	INY
	STY tb

	LDA #0
	STA t1

	; * 128 - Get this from the table now - needs whacking up to 16*128 (0-15) entries...
	;
	ASL t0:ROL t1
	ASL t0:ROL t1
	ASL t0:ROL t1
	ASL t0:ROL t1
	ASL t0:ROL t1
	ASL t0:ROL t1
	ASL t0:ROL t1

	CLC
.tileBaseLoadLO:
	LDA #LO(unpackedTileSprites)
	ADC t0
	STA t0
.tileBaseLoadHI:
	LDA #HI(unpackedTileSprites)
	ADC t1
	STA t1

	; Pull flipped flags off stack and or them in
	PLA
	ORA t1
	STA t1

.drawTile:
 	JSR plotTileDirect
	
.skipTile:
	ROL t6
	DEC te

	BEQ doneRow
	JMP innerRowLoop

.doneRow:
	; Increment new byte pointer
	INC tc

	; Have we done all rows
	DEC tf
	BEQ sanLoss
	JMP outerRowLoop

.sanLoss:  ; just play the sound
	LDY #7
	LDA (curScreenLO),Y
	AND #%100
	BEQ doItems ; anything to do?

    ; yes - clear flag and play note
    LDA #%11111011
    AND (curScreenLO),Y
    STA (curScreenLO),Y
        
	LDA #LO(soundEerie):STA notereq+0 ; yes - play sound
	LDA #HI(soundEerie):STA notereq+1

.doItems:

	; r4,r5 -> te,tf as they are trashed by plotSprite8x8
	LDA t4
	STA te
	LDA t5
	STA tf

	; Check for items
	LDY #2
	LDA (curScreenLO),Y
	AND #SCREEN_FLAGS_ITEM_PRESENT
	BEQ exitNoItems

	; We have items
	LDY tc

	; x pos of item
	LDA (t4),Y
	STA getTileX
	STA itemX
	INY

	; y pos of item
	LDA (t4),Y
	STA getTileY
	STA itemY
	JSR getTile

	; set up item tile
	STY itemTile
	
	LDY tc
	INY
	INY

	; item ID ; lower nibble contains 'extra' bits for elder sign
	LDA (t4),Y
    TAX
    AND #$f0
	STA itemID
    TXA
    ASL A:ASL A:ASL A:ASL A
    STA itemExtra
        
	INY

	; load item text block
	LDA (t4),Y
	STA dynTextString
	INY
	LDA (t4),Y
	STA dynTextTileIndex
	INY

	; Store back - needed for aliens
	STY tc

    LDA screenDarkFlag
    BNE drawItemFinished ; don't draw item on dark screen

	; t0/t1 -> Sprite data
	CLC
	LDA #LO(itemSprites)
	ADC itemID
	STA t0
	LDA #HI(itemSprites)
	ADC #0
	STA t1

	; t2/t3 -> x,y
	LDA itemX
	STA t2
	LDA itemY
	STA t3

	; Plot item
	CLC
	JSR plotSprite8x8
        
.drawItemFinished:        
	JMP handleAliens

.exitNoItems:
	LDA #&FF
	STA itemTile

	; If there originally was an item, skip the item pointer
	LDY #7
	LDA (curScreenLO),Y
	AND #1
	BEQ handleAliens
	LDA tc:CLC:ADC #5:STA tc
        
IF FALSE
    LDY tc
	INY
	INY
	INY
	INY
	INY
	STY tc
ENDIF
        
.handleAliens:
	JSR initialiseEnemiesForScreen
	RTS
	}
