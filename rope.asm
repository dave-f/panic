
_ropeStateOff 		= 0
_ropeStateFiring 	= 1
_ropeStateAttaching	= 2
_ropeStateAttached 	= 4

_ropeLengthBasic	= 20

.fastPlotRope
	{
	LDX ropeData
	BEQ plotRopeOut
	DEX
	TXA
	ASL A
	TAX
	LDY #0
.plotRopeLoop
	LDA ropeData+1,X
	STA t0
	LDA ropeData+2,X
	STA t1
	LDA #&0f
	STA (t0),Y
	DEX
	DEX
	BPL plotRopeLoop

	; New - fast plot of base
	INX
	INX
	
	LDA ropeData+1,X
	STA t0
	LDA ropeData+2,X
	STA t1
	LDA #&0f

	STA (t0),Y; yellow
	INY
	LDA #&03
	STA (t0),Y ; red

	LDA #&0f

	LDA t0
	AND #&07
	STA t2
	SEC
	LDA t0
	SBC t2
	STA t0
	CLC
	LDA t1
	ADC #2
	STA t1
	LDA #&0f
	LDY #0
.loop
	STA (t0),Y
	INY
	CPY #8
	BNE loop

.plotRopeOut
	RTS
	}

.fastEraseRope
	{
	LDX ropeTileList
	BEQ eraseRopeOut
	; Go through the rope's tiles, redrawing each
	DEX
        
.eraseRopeLoop:
	LDA ropeTileList+1,X
	TAY
	STX tf
	; First, OR out of coll map
	LDA collData,Y
	AND #_bitRope EOR &FF
	STA collData,Y
	; Now redraw the tile and item if necessary
    TYA
    LDX #$ff
    CPX itemTile
    BEQ noTile ; x=0 on noTile entry due to the inx

    CMP itemTile
    BNE noTile
    INX ; x=0

.noTile:
    INX
    STX itemRedrawFlag
	JSR redrawTile
    LDA itemRedrawFlag
    BEQ noItem
    JSR drawItemOnScreen
        
.noItem:        
	LDX tf
	DEX
	BPL eraseRopeLoop
        
.eraseRopeOut:
	LDA #0
	STA ropeData
	STA ropeTileList
	RTS
	}

.updateRope
	{
	LDA playerState
	CMP #_playerStateFiringRope
	BEQ okToContinue
	CMP #_playerStateNormal
    BNE noRope
        
.okToContinue
	LDA ropeState
	CMP #_ropeStateFiring
	BEQ firingSkip
	CMP #_ropeStateAttaching
	BEQ attachEffectSkip
	LDA playerInventory
	AND #_bitRope
	BEQ noRope
	LDA playerUsingItem
	CMP #_itemRope
	BNE noRope
	JMP checkForFireKey
        
.noRope:
	RTS
	; Attach rope effect - just waits for 5 frames ATM
.attachEffectSkip
	LDA ropeAttachFrames
	CMP #5
	BEQ attachEffectSkip3
	; remove old pixel
	LDA ropePosX
	STA t0
	LDA ropePosY
	STA t1
	DEC t1
	LDA #7
	STA t2
	JSR plotPixel
	
	INC t0:INC t0
	INC t1:INC t1
	JSR plotPixel
	
.attachEffectSkip3
	DEC ropeAttachFrames
	BEQ attachEffectSkip2
	LDA ropePosX
	STA t0
	LDA ropePosY
	STA t1
	LDA #7
	STA t2
	JSR plotPixel
	
	INC t0:INC t0
	INC t1:INC t1
	JSR plotPixel
	
	INC ropePosY
	RTS
.attachEffectSkip2
	LDA #_ropeStateAttached
	STA ropeState
	LDA #_playerStateNormal
	STA playerState
	; Store the tile in which the rope base is drawn
	LDA ropeOrgPosX
	;SEC
	;SBC #4
	STA getTileX
	LDA ropeOrgPosY
	STA getTileY
	JSR getTile
	STY ropeTile
	RTS
	
.firingSkip
	; Firing - so update it
	LDA ropeCounter
	CMP currentRopeLength
	BEQ norem

	; Remove old harpoon
	LDA #LO(itemSprites)
	STA t0
	LDA #HI(itemSprites)
	STA t1
	LDA ropePosX
	STA t2
	LDA ropePosY
	STA t3
	SEC
	SBC #7
	STA t3
	;DEC t3:DEC t3:DEC t3:DEC t3:DEC t3:DEC t3:DEC t3
	
	; Set carry flag based on rope org dir (if rope org left (0) then we need to flip)
	LDA ropeOrgDir
	EOR #1
	LSR A
	BCC notFlipped2
	
	LDA t2
	SEC
	SBC #6
	STA t2
	;DEC t2:DEC t2:DEC t2:DEC t2:DEC t2:DEC t2
.notFlipped2
	LDA #1
	STA t4
	JSR plotSprite8x8
	;
.norem
	LDA ropeOrgDir
	AND #1
	BNE norem2
	; going left ( ie = 0, so decrement x of rope )
	DEC ropePosX
	DEC ropePosX
	JMP norem3
.norem2
	; going right ( ie = 1, so increment x of rope )
	INC ropePosX
	INC ropePosX
.norem3
	DEC ropePosY
	DEC ropePosY
	
	LDA ropePosX
	STA getTileX
	LDA ropePosY
	STA getTileY
	
	; check screen extents ; this depends on ropeOrgPos ** TODO
	LDA ropeOrgDir
	BNE ropeCheckExtentsRight
.ropeCheckExtentsLeft
	LDA ropePosX
	CMP #8
	BCS daveSkip
	JMP cancelThisRopeFire
.daveSkip
	JMP doneExtentChecking
.ropeCheckExtentsRight
	LDA ropePosX
	CMP #128-4
	BCC doneExtentChecking
	JMP cancelThisRopeFire

.doneExtentChecking
	; Check height
	LDA ropePosY
	CMP #32
	BCS reallyDoneExtentCheck
	JMP cancelThisRopeFire
.reallyDoneExtentCheck

	; Check collision map to see if we have an attachable tile : MIGHT HAVE TO ALSO SET ROPE BIT IN THIS TILE
	JSR getTile
	LDA collData,Y
	;TAX
	AND #_bitHookable
	BEQ noSetRope
	;TXA
	LDA playerScreen ; only do icicle drop in hell, bit of a bodge :/ screens 41-45
	CMP #41
	BCC contRope
	CMP #46
	BCS contRope
	CMP #42
	BEQ contRope

	LDA &FE44
	AND #1
    BEQ contRope
	
    STA icicleDropFlag ; drop an icicle
    LDA #40
    STA icicleDropFrames
    LDA ropePosX
    ;SEC
    ;SBC #2
    STA icicleDropX
    LDA ropePosY
    SBC #8
    STA icicleDropY
     
.contRope:
	JMP setRope
        
.noSetRope:
	LDA #_bitRope
	ORA collData,Y
	STA collData,Y

	; Store this tile index into our list if a) the list is empty or b) the list's last entry is different to this tile
	TYA
	LDX ropeTileList
	BEQ addToList
	CMP ropeTileList,X
	BEQ doneAdd
        
.addToList:
	STA ropeTileList+1,X
	INX
	STX ropeTileList
        
.doneAdd:
	LDA ropePosX
	STA t0
	LDA ropePosY
	STA t1
	LDA #3
	STA t2
	JSR plotPixel

	; Add Y register in to get correct transformed pixel address
	CLC
	TYA
	ADC t3
	STA t3
	LDA #0
	ADC t4
	STA t4

	; Save this address??
	LDA ropeData
	ASL A
	TAY
	LDA t3
	STA ropeData+1,Y
	LDA t4
	STA ropeData+2,Y

	; We have a new item in the list: Increment counter
	INC ropeData ; TODO: Play the game and watch the memory on this - currently 96 bytes which seems a shitload, hmm 48 dots, maybe..

	; Increment length
	INC ropeLength

	; Keep going?
	DEC ropeCounter
	BEQ cancelThisRopeFire

	; Only plot harpoon if needed
	LDA ropeOrgDir
	EOR #1
	LSR A ; carry flag = ropedirection
	
	LDA #LO(itemSprites)
	STA t0
	LDA #HI(itemSprites)
	STA t1
	LDA ropePosX
	STA t2
	LDA ropePosY
	STA t3
	;BCS flipped - > can now clear/set carry flag to LDA, SBC/ADC and set as appropriate.
	PHP
	LDA t3
	SEC
	SBC #7
	STA t3
	PLP
	;DEC t3:DEC t3:DEC t3:DEC t3:DEC t3:DEC t3:DEC t3 ; HORRENDOUS =7*DEC(zp)=7*5=35.  Alternative is 4+2*7=18 cycles.
	BCC notFlipped1
	LDA t2
	SEC
	SBC #6
	STA t2
	;DEC t2:DEC t2:DEC t2:DEC t2:DEC t2:DEC t2 ; HORRENDOUS = 6*DEC(zp)=6*5=30 cycles.  TAX(2)+6*DEX(2)+TXA(2)=16 cycles
.notFlipped1
	LDA #1
	STA t4
	JSR plotSprite8x8
    RTS
	;JMP ropeOut
	
.cancelThisRopeFire
	JSR fastEraseRope
	
	LDA #_ropeStateOff
	STA ropeState

	LDA #_playerStateNormal
	STA playerState

	RTS

.setRope
	;; Set rope state to fixed
	LDA #_ropeStateAttaching
	STA ropeState
	LDA #5
	STA ropeAttachFrames

	; Play a sound
	LDA #LO(ropeAttachSound):STA notereq+0
	LDA #HI(ropeAttachSound):STA notereq+1  ; always store MSB last
	RTS
	
.checkForFireKey:
	LDA #_keyFire
	BIT keyFlags
	BEQ ropeOut
	
	; If player pos=0, can only fire rope if facing right.
	LDA playerPosX
	BNE nextStep
	LDA playerFlags
	AND #_playerFlagsDirection
	BEQ ropeOut
	BNE okToFire ; was a jmp
	
.nextStep:
	; If player pos=108, can only fire rope if facing left
	CMP #&6C
	BCC okToFire
	LDA playerFlags
	AND #_playerFlagsDirection
	BNE ropeOut
	
.okToFire:
	; Check state = 2 and erase old rope if needed.  Remember to erase from collision map.
	LDA ropeState
	CMP #_ropeStateAttached
	BNE beginRope

	; Erase rope base - Just redraw the rope tiles
	LDA ropeTile
	PHA
	JSR redrawTile
	PLA
	; Redraw this tile+1
	CLC
	ADC #1
	JSR redrawTile

	; Then erase actual rope
	; JSR eraseRope
	JSR fastEraseRope

	; Start a new rope off
.beginRope
	LDA #_playerStateFiringRope
	STA playerState

	; Initialise rope length and store into table
	LDA #0
	STA ropeLength
	STA ropeData
	STA ropeTileList
	
	LDA currentRopeLength
	STA ropeCounter

	; Start rope at PlayerX+8, PlayerY+8
	LDA playerPosX
	CLC
	ADC #8
	STA ropePosX
	STA ropeOrgPosX
	LDA playerPosY
	CLC
	ADC #8
	STA ropePosY
	STA ropeOrgPosY

	; Set state to firing
	LDA #_ropeStateFiring
	STA ropeState
	
	; Save direction of rope; can use previous '1' as it is same as the define
	AND playerFlags
	STA ropeOrgDir

    ; Play a sound
    ; LDA #LO(ropeFireSound):STA notereq+2
    ; LDA #HI(ropeFireSound):STA notereq+3
	
.ropeOut
	RTS

.ropeFireSound:
    ;EQUB 20,0,7
	}
