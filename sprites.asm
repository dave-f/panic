NEW_SPRITE_ROUTINE = TRUE

	; Sprite routine for 16x16 2 pixel aligned sprite where colour 15 is transparent (ie player)

	; t0 -> lo sprite ptr
	; t1 -> hi sprite ptr
	; t2 -> x
	; t3 -> y

	; C set if flip in X is needed

IF NEW_SPRITE_ROUTINE = FALSE
	
ENABLE_FLIP_SPRITE = FALSE
	
.plotSprite16x16Trans
	{
.start
IF ENABLE_FLIP_SPRITE
	LDA #0
	ADC #0
	STA ta
ENDIF
	
	; Calculate base character block to t4,t5
.calcBase
	LDA t3
	LSR A
	LSR A
	AND #&FE
	TAX

	LDA t2
	AND #&FE
	ASL A
	ASL A

	STA t4:tay
	TXA
	ADC #&40
	STA t5

	LDA t3
	AND #7

	CLC
	ADC t4
	STA t4

	; Y = y offset within block
	; TAY
	
	; t2,t3 now available, so use these for org base block
	LDA t5
	STA t3
	
	;LDX t4
	STY t2

;.offsetLoop
;	INX
;	DEY
;p;	BNE offsetLoop

;	STX t4

	; 16 rows
	LDA #16
	STA t8

	; 16 pixels per row (/2 = 8 (2 pixels per byte))
	LDA #8
	STA tb 

	LDY #0
	STY t6
	STY t7
	
.doRow
	;;  Get 2 sprite pixels and flip in X if required
IF ENABLE_FLIP_SPRITE
	LDA ta
	BEQ notFlipped
	
.flippedInX
	
	; invert the index into the row
	LDA t6
	EOR #7
	TAY
	; Get this pixel to Y
	LDA (t0),Y
	TAY
	; mask out interleave pixels
	AND #&55 
	; rotate left this pixel	
	ASL A 
	STA t9
	; get pixel again
	TYA
	; mask out interleave pixels
	AND #&AA
	; rotate right this pixel	
	LSR A 
	ORA t9
	JMP pixelOut1
ENDIF


.notFlipped
	; Get data offset to Y, and increment offset
	LDY t6
	INC t6
	
	; Load 2 sprite pixels
	LDA (t0),Y

	; If both pixels transparent, do nothing
	CMP #&FF
	BNE pixelOut1

	; new
	LDY t7
	JMP moveAlong

.pixelOut1
	; Save the 2 pixels
	STA tc

	; X is offset into masktable, so starts at 0 (eg plot neither)
	LDX #0

	; Save in Y for now
	TAY

.doRight
	AND #(&55)
	CMP #&55
	BEQ doLeft ; right is transparent (ie %1111)
	
	; plot this pixel
	INX

.doLeft
	; Restore from Y
	TYA
	AND #(&AA)
	CMP #&AA
	BEQ leftDone ; left is transparent (ie %1111)
	
	; plot this pixel
	INX
	INX

.leftDone
	
.pixelOut
	; dataOffset++
	; INC t6

	; Store them on screen
	; Get scanline offset to Y
	LDY t7
	
	; ldx tb ; 3 
	; ldy scanTableOffset-1,X ; 4 = 7 cycles

	; Get stored 2 pixels
	LDA tc

	; Mask appropriately
	AND maskTable,X ; 4 cycles
	STA tc ; 3 cycles
	LDA (t4),Y ; 5 cycles
	AND maskTableInverted,X ; 4 cycles
	ORA tc ; 3 cycles
	STA (t4),Y ; 6 cycles

	; Add 8 to get to the next 2 pixels
.moveAlong
	tya ; 2
	;lda t7 ; 3
	clc ; 2
	adc #8 ; 2
	sta t7 ; 3 = 10 cycles

	; Done a row?
	DEC tb
	BNE doRow

	; Add 1 to address : c is clear from above
	lda t4
	adc #1
	sta t4
	and #7
	;INC t4
	;LDA t4
	;AND #7
	BNE noRowBreak

	; Load base block and add 512 to get to next row
.rowBreak
	LDA t2
	STA t4
	CLC
	LDA t3
	ADC #2
	STA t5
	STA t3 ; also write back to baseblock

.noRowBreak
	; Re-initialise scanline offset
	LDA #0
	STA t7
	
	; Re-initialise scanline loopcount
	LDA #8
	STA tb

	; Done all rows?
	DEC t8
	BNE doRow
	
	RTS

	}
ENDIF

IF NEW_SPRITE_ROUTINE = TRUE
	; New player sprite routine

	; t0 -> lo sprite pointer
	; t1 -> hi sprite pointer
	; t2 -> x
	; t3 -> y

	; Uses t4-tc

.plotSprite16x16TransNew
	{
	; First, calculate X*8 (*4 in reality as 2 pixels per byte) and store in t4 / t5
	LDA t2
	STA t4
	LDA #0
	STA t5
	
	; Initialise sprite data offset to 0 and store in t7
	STA t7
	
	ASL t4
	ROL t5
	ASL t4
	ROL t5

	; Initialise current Y position to t6
	LDA t3
	STA t6

	; Row counter
	LDA #16
	STA ta

.nextRow:
	; Get starting scanline address of this Y
	LDY t6
	LDA &500,Y ; lo table
	STA t8
	LDA &600,Y ; hi table
	STA t9

	; Add the X*8, and t8/t9 now points to video ram address for 0,0
	CLC
	LDA t8
	ADC t4
	STA t8
	LDA t9
	ADC t5
	STA t9

	; Initialise X pixel offset from this 0,0 address
	LDA #0
	STA tc

	; Clear carry here as nothing will set it in the innerloop
	CLC

.doRow:
	; Get 2 sprite pixels and increment pointer
	LDY t7
	LDA (t0),Y
	INY
	STY t7

	; If both transparent, do nothing.  Y will never be zero so this is safe.
	BEQ donePixelPlot

	; X is index into masktable
	LDX #0

.doRight:
	BIT spriteBitMasks ; 0x55
	BEQ doLeft
	INX

.doLeft:
	BIT spriteBitMasks+1 ; 0xAA
	BEQ maskPixels
	INX
	INX
	CPX #3
	BNE maskPixels
	; New opt - if x is now 3, then don't bother doing the masking
	CLC
	LDY tc
	STA (t8),Y
	TYA
	ADC #8
	STA tc
	CMP #64
	BNE doRow
	
.maskPixels:
	; Load pixel offset (This is incremented by 8 below)
	LDY tc
	
	; A = pixel AND mask
	AND maskTable,X ; 4 cycles
	STA tb ; 3 cycles

	; A = framebuffer pixel AND mask OR (original)
	LDA (t8),Y ; 5 cycles

	AND maskTableInverted,X ; 4 cycles
	ORA tb ; 3 cycles

	; Store back to framebuffer
	STA (t8),Y ; 6 cycles

.donePixelPlot:
	
	; Add 8 to get to next pixel, and see if we've done a row
	LDA tc
	CLC
	ADC #8
	STA tc
	CMP #64
	BNE doRow

	; Increment Y scanline position
	INC t6

	; Have we done all rows?
	DEC ta
	BNE nextRow
	
.end:
	RTS
	}

	; New player sprite routine flipped

	; t0 -> lo sprite pointer
	; t1 -> hi sprite pointer
	; t2 -> x
	; t3 -> y

	; Uses t4-tc
	

.plotSprite16x16TransFlippedNew
	{
.start
	; First, calculate X*8 (*4 in reality as 2 pixels per byte) and store in t4 / t5
	LDA t2
	STA t4
	LDA #0
	STA t5
	
	ASL t4
	ROL t5
	ASL t4
	ROL t5

	; Initialise current Y position to t6
	LDA t3
	STA t6

	; Initialise sprite data offset to 0 and store in t7
	LDA #0
	STA t7

	; Row counter
	LDA #16
	STA ta

	; Clear carry here as nothing will set it in main loop
	CLC

.nextRow
	; Get starting scanline address of this Y
	LDY t6
	LDA &500,Y ; lo table
	STA t8
	LDA &600,Y ; hi table
	STA t9

	; Add the X*8, and t8/t9 now points to video ram address for 0,0
	CLC
	LDA t8
	ADC t4
	STA t8
	LDA t9
	ADC t5
	STA t9

	; Initialise X pixel offset from this 0,0 address
	LDA #0
	STA tc

.doRow
	; Get 2 sprite pixels and increment pointer
	LDA t7
	EOR #7
	TAY
	LDA (t0),Y
	INC t7

	; If both transparent, do nothing.  Y will never be zero so this is safe.
	; CMP #&FF
	BEQ donePixelPlot

	; Save A ready for the AND
	TAY

	AND #&55
	ASL A
	STA td
	TYA
	AND #&AA
	LSR A
	ORA td

	TAY

	; X is index into masktable
	LDX #0

.doRight
	BIT spriteBitMasks
	;AND #&55
	;CMP #&55
	BEQ doLeft
	INX

.doLeft:
	BIT spriteBitMasks+1
	BEQ maskPixels
	INX
	INX
	
	; New opt - if x is now 3, then don't bother doing the masking
	CPX #3
	BNE maskPixels
	CLC
	LDY tc
	STA (t8),Y
	TYA
	ADC #8
	STA tc
	CMP #64
	BNE doRow
	
	
.maskPixels:

	; Load pixel offset (This is incremented by 8 below)
	LDY tc

	; Do the plotting
	AND maskTable,X ; 4 cycles
	STA tb ; 3 cycles
	LDA (t8),Y ; 5 cycles
	AND maskTableInverted,X ; 4 cycles
	ORA tb ; 3 cycles
	STA (t8),Y ; 6 cycles

.donePixelPlot:

	; Add 8 to get to next pixel, and see if we've done a row
	LDA tc
	CLC
	ADC #8
	STA tc

	CMP #64
	BNE doRow

	; Increment Y index
	INC t6

	; Have we done all rows?
	DEC ta
	BNE nextRow
	
.end
	
	RTS
	}

ENDIF

	; Sprite routine for 16x16 none-masked 2 pixel aligned sprite
	
	; t0 -> lo sprite ptr
	; t1 -> hi sprite ptr
	; t2 -> x
	; t3 -> y

	; C set if flip in X is needed

	; t0,t1 Preserved
	; {t2-ta} trashed
	

.plotSprite16x16
	{
.start:
	LDA #0
	ADC #0
	STA ta
	
.calcBase:
	; Calculate base character block to t4,t5
	LDA t3
	LSR A
	LSR A
	AND #&FE
	TAX

	LDA t2
	AND #&FE
	ASL A
	ASL A

	STA t4
	TXA
	ADC #&40
	STA t5

	; Y = y offset within block
	LDA t3
	AND #7
	TAY

	; t2,t3 now available, so use these for org base block
	LDA t4
	STA t2
	LDA t5
	STA t3

.offsetLoop:
	INC t4
	DEY
	BNE offsetLoop

	; 16 rows
	LDA #16
	STA t8

	LDX #8

	LDY #0
	STY t6
	STY t7
	
.doRow:
	;;  Get 2 sprite pixels and flip in X if required
	LDA ta
	AND #1
	BEQ notFlipped
	
.flippedInX:
	; invert the index into the row
	LDA t6
	EOR #7
	TAY
	; Get this pixel to Y
	LDA (t0),Y
	TAY
	; mask out interleave pixels
	AND #&55 
	; rotate left this pixel	
	ASL A 
	STA t9
	; get pixel again
	TYA
	; mask out interleave pixels
	AND #&AA
	; rotate right this pixel	
	LSR A 
	ORA t9
	JMP pixelOut

.notFlipped:
	LDY t6
	LDA (t0),Y
	
.pixelOut:
	INC t6

	; Store them on screen
	LDY t7
	
	;EOR (t4),Y
	STA (t4),Y

	; Add 8 to get to the next 2 pixels
	LDA t7
	CLC
	ADC #8
	STA t7

	; Change to DEX, removes CPX
	DEX
	BNE doRow

	; Add 1 to address
	INC t4
	LDA t4
	AND #7
	BNE noRowBreak

	; Load base block and add 512
	LDA t2
	STA t4
	CLC
	LDA t3
	ADC #2
	STA t5
	STA t3

.noRowBreak:
	LDY #0
	STY t7
	
	LDX #8
	
	DEC t8
	BNE doRow
	
	RTS
	}

	; Sprite routine for 8x8 none-masked 2 pixel aligned sprite (eg harpoon, items..)
	
	;; t0 -> sprite lo
	;; t1 -> sprite hi
	;; t2 -> x
	;; t3 -> y
	;; t4 -> xor flag (1 to xor)

	;; C set if flipping X

	; t0,t1 Preserved
	; {t2-ta} trashed

.plotSprite8x8:
	{
.start:
	; Save C flag to ta
	LDA #0
	ADC #0
	STA ta

    ; Check for colour
    LDA t1
    BNE normalSprite

.colourSprite:
    LDA #2
    STA ta
    LDA t0 ; this colour should be stored somewhere (or not - might only need black?)
    JMP noRasterOp
        
.normalSprite:
	; Put correct raster op code in based on t4 value
	LDA t4
	BEQ noRasterOp
	LDA #&51
	STA rasterOp
	LDA #t4
	STA rasterOp+1
	JMP doneRasterOp
        
.noRasterOp:
	LDA #&EA
	STA rasterOp
	STA rasterOp+1
        
.doneRasterOp:
.calcBase:
	; Calculate base character block to t4,t5
	LDA t3
	LSR A
	LSR A
	AND #&FE
	TAX

	LDA t2
	AND #&FE
	ASL A
	ASL A

	STA t4
	TXA
	ADC #&40
	STA t5

	; Y = y offset within block
	LDA t3
	AND #7
	TAY

	; t2,t3 now available, so use these for org base block
	LDA t4
	STA t2
	LDA t5
	STA t3

.offsetLoop:
	INC t4
	DEY
	BNE offsetLoop

	; 8 rows
	LDA #8
	STA t8

	LDX #4

	LDY #0
	STY t6
	STY t7

.doRow:
	; Get 2 sprite pixels and flip in X if required
    LDA #2
    BIT ta
    BNE spriteIsColour
    LDA #1
	BIT ta
	BEQ notFlipped
        
.flippedInX:
	; invert the index into the row
	LDA t6
	EOR #3
	TAY
	; Get this pixel to Y
	LDA (t0),Y
	TAY
	; mask out interleave pixels
	AND #&55 
	; rotate left this pixel	
	ASL A 
	STA t9
	; get pixel again
	TYA
	; mask out interleave pixels
	AND #&AA
	; rotate right this pixel	
	LSR A 
	ORA t9
	JMP pixelOut

.spriteIsColour:
    LDA #0
    JMP pixelOut
        
.notFlipped:
	LDY t6
	LDA (t0),Y
        
.pixelOut:
	INC t6

	; Store them on screen
	LDY t7
        
.rasterOp:
	EOR (t4),Y
	STA (t4),Y

	; Add 8 to get to the next 2 pixels
	LDA t7
	CLC
	ADC #8
	STA t7

	DEX
	BNE doRow
	
	; Add 1 to address
	INC t4
	LDA t4
	AND #7
	BNE noRowBreak

	; Load base block and add 512
	LDA t2
	STA t4
	CLC
	LDA t3
	ADC #2
	STA t5
	STA t3

.noRowBreak
	LDY #0 ; flip in x, was 0
	STY t7
	LDX #4
	
	DEC t8
	BNE doRow
	
	RTS
	}

.fastPlotSpriteDirect16x16
	{
.start
	LDX #2
.setup
	LDY #63
.loop
	LDA (t0),Y
	STA (t2),Y
	DEY
	BPL loop
.nextRow
	CLC
	LDA t3
	ADC #2
	STA t3
	;CLC // will be clear
	LDA t0
	ADC #64
	STA t0
	BCC ok
	INC t1
.ok
	DEX
	BNE setup
	RTS
	}

.plotTileFlippedX:
	{
	; Mask off flags
	LDA t1
	AND #$40 - 1
	STA t1
	
	LDX #2
	
.flippedSprite:
	LDY #63
	
.flippedSpriteLoop:
	LDA (t0),Y
	
.flip:
	; Change to zp
	STA spriteWorkZP
	TYA
	PHA
	; EOR 63 + EOR 7
	EOR #56
	TAY
	LDA spriteWorkZP
	; mask out interleave pixels 
	AND #&55 
	; rotate left this pixel	
	ASL A 
	STA spriteWorkZP+1
	; get pixel again
	LDA spriteWorkZP
	; mask out interleave pixels
	AND #&AA
	; rotate right this pixel	
	LSR A
	ORA spriteWorkZP+1
	STA (t2),Y
	PLA
	TAY
	DEY
	BPL flippedSpriteLoop
	
.nextRow:
	CLC
	LDA t3
	ADC #2
	STA t3
	LDA t0
	ADC #64
	STA t0
	BCC noCarry
	INC t1
	
.noCarry:
	DEX
	BNE flippedSprite
	RTS
	}

.fastColourPlotDirect16x16
	{
.start
	LDX #2
.setup
	LDY #63
	LDA t0
.loop
	STA (t2),Y
	DEY
	BPL loop
.nextRow
	CLC
	LDA t3
	ADC #2
	STA t3
	DEX
	BNE setup
	RTS
	}
	
	;; t0,t1 => sprite ptr (if t1 == 0 then use t0's as colour)
	;; t2,t3 => screen address.
	;;
	;; High bit of address set -> flip in X
	;; Second to high bit of address set -> flip in Y
	;; Both of these are OK, since 0x8000 and 0x4000 are never used ingame.
.plotTileDirect:
	{
	; First, check for colour
    LDA screenDarkFlag
    BEQ litScreen
    LDA #0
    STA t0
    JMP fastColourPlotDirect16x16
        
.litScreen:   
	LDA t1
	AND #%111111
	BEQ fastColourPlotDirect16x16

	; Check X flag
	LDA #$80
	BIT t1
	BNE plotTileFlippedX

	; Check Y flag
	LDA #$40
	BIT t1
	BNE plotTileFlippedY
	
	; Both flags 0, normal tile
	JMP fastPlotSpriteDirect16x16
	}

.plotTileFlippedY:
	{
	; Mask off flags
	LDA t1
	AND #$40 - 1
	STA t1

	LDA t3
	CLC
	ADC #2
	STA t3

	LDA #2
	STA tileWorkZP
	
.setup:
	LDY #63
	;LDX #63

.plotBlock:
	LDA (t0),Y
	;PHA
	TAX
	TYA
	EOR #7
	TAY
	;PLA
	TXA
	STA (t2),Y
	TYA
	EOR #7
	TAY
	DEY
	;CPY #64
	BPL plotBlock
	;BNE plotBlock
	;DEX
	;BPL plotBlock

	CLC
	LDA t0
	ADC #64
	STA t0
	BCC noCarry1
	INC t1
	;CLC
	
.noCarry1:
	LDA t3
	SEC
	SBC #2
	STA t3

	DEC tileWorkZP
	BNE setup
	
	RTS
	}

