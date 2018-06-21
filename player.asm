; These are increments of 2 as they are also used as base pointers for the animations
_playerStateNormal 	   = 0
_playerStateClimbing	   = 2
_playerStateClimbingRope   = 4
_playerStateClimbingScene  = 6
_playerStateFiringRope 	   = 8
_playerStateFalling 	   = 10

_playerFlagsDirection	= 1
_playerFlagsOnRope	= 2

_playerCollisionOffsetX = 8 ; was 8
_playerCollisionOffsetY = 15; was 15

_playerCollisionOffsetXRope = 8
_playerCollisionOffsetYRope = 0

.walkSound1:
    EQUB 90,0,3
	
.pickupSound:
	EQUB 150
	EQUB 0
	EQUB 1
	
    ; play a walk sound : Put the x/y pos in A first.
.playWalkSound:
{
    AND #%100
    BNE skipWalkSound ; should this be beq?

    ; Play walk sound effect
    LDA playerWalkSfxFlag
    EOR #5 ; pitch offset
    STA playerWalkSfxFlag
    CLC
    ADC #1 ; base pitch
    STA walkSound1        
    LDA #LO(walkSound1)
    STA notereq+2
    LDA #HI(walkSound1)
    STA notereq+3
        
.skipWalkSound:        
    RTS
}        

.updatePlayer
	{
	; Test player state and call appropriate routine.
	; These do their stuff then set X=1 if a redraw is required.
	;
	LDX playerState
	LDA playerStateJumpTables,X
	STA jumpToUpdate+1
	LDA playerStateJumpTables+1,X
	STA jumpToUpdate+2
	
	; Put key flags in X
	;
	LDX keyFlags
	
.jumpToUpdate
	JSR &0000

	; If X=1, player needs redrawing, ie something has changed
	;
	STX redrawPlayerFlag
	
	; If the state has changed, we also need to redraw
	;
	LDA playerOldState
	CMP playerState
	BEQ checkCollisions
	LDA #1
	STA redrawPlayerFlag

	; First, check to see if player is on a 'spike' tile [10/09/2012]
.checkCollisions:
    LDA currentTileBank
    BEQ checkEnemies ; Only tileset 1 is a collision (spikes)
    LDY playerTileList
    BEQ checkEnemies
    LDY playerTileList+1
	LDA tileData,Y
    CMP #4
    BNE checkEnemies
    ;JMP collided
    beq collided

.checkEnemies:        
	JSR checkPlayerColl ; Returns with C set if collision
	BCC noColl

.collided:        
	; Player has collided; lose 2 HP every other frame
	DEC playerCollFlag
	BNE noColl
	LDA #4:STA playerCollFlag
	
	LDX #2
	STX playerHPLoss

	; play a sound
	LDA #LO(colSound):STA notereq+0
	LDA #HI(colSound):STA notereq+1

	; And redraw
	DEX
	STX redrawPlayerFlag

.noColl:
	LDA redrawPlayerFlag
	BNE redrawPlayer
	JMP updatePlayerEnd
	
	; See if there are any tiles to redraw
	;
.redrawPlayer
	LDX playerTileList
	BNE tilesToDo
	JMP buildTileTable

.tilesToDo

	; X contains # of tiles to do
	DEX

.drawTilesLoop
	; Get tile index
	STX tf
	LDA playerTileList+1,X
	CMP itemTile
	BNE noItemOnThisTile

	; There is an item here - flag as needing to draw it
	LDX #1
	STX itemRedrawFlag
	BNE step2
	
.noItemOnThisTile

	LDX #0
	STX itemRedrawFlag
	
.step2
	
	; Save tile index again
	TAX
	
	; Set screen address for this tile (into t2,t3)
	ASL A
	TAY
	LDA tileAddressTable,Y
	STA t2
	LDA tileAddressTable+1,Y
	STA t3
	
	; Get the tile index, and multiply by 128 to get to the sprite data
	TXA
	TAY
	LDA tileData,Y
	; N flag set if just a colour
	BMI tileIsColour
	TAX
	LDA collData,Y
	AND #_bitFlipped
	BEQ tileNotFlipped
	
	; The only tile currently flipped in Y is 0.
	; Also see screen.asm and tiles.asm.
	TXA
	AND #_invTileFlagsMask
	BEQ flippedInY
	CMP #8
	BEQ flippedInY

.flippedInX:
	LDA #$80
	PHA
	;JMP skipper
	bne skipper

.flippedInY:
	LDA #$40
	PHA
	;JMP skipper
	bne skipper
	
.tileNotFlipped:
	LDA #0
	PHA
	
.skipper:
	; A tile index >= 8 signifies the generic 4 tile pool
	TXA
	CMP #8
	BCC skipper1
	AND #$7
	LDY #LO(unpackedTileXSprites)
	STY t0
	LDY #HI(unpackedTileXSprites)
	STY t1
	JMP skipper2

.skipper1:
	LDY #LO(unpackedTileSprites)
	STY t0
	LDY #HI(unpackedTileSprites)
	STY t1
	
.skipper2:
	CLC
	ASL A
	TAY
	LDA lookup128,Y
	ADC t0
	STA t0
	LDA lookup128+1,Y
	ADC t1
	STA t1

	;; t0,t1 => sprite ptr (if t1 == 0 then use t0's as colour)
	;; t2,t3 => screen address.
	;; Pull the flipped flags off the stack and or them in.
	PLA
	ORA t1
	STA t1
	JSR plotTileDirect
	JMP doMore
	
.tileIsColour
	AND #&0f
	sta t0
	lda #0
	STA t1
	JSR fastColourPlotDirect16x16
	
.doMore
	LDA itemRedrawFlag
	BEQ noItemToDraw
        
    JSR drawItemOnScreen
	    
.noItemToDraw
	LDX tf
	DEX
	BMI buildTileTable
	JMP drawTilesLoop

	; Build the table of tiles the player is on : ((Hx,Hy),(Hx+16,Hy),(Hx+16,Hy+16),(Hx,Hy+16))
.buildTileTable
	LDA playerPosX
	STA getTileX
	LDA playerPosY
	STA getTileY
	JSR getTile
	TYA
	; Base tile stored in X as we'll be ANDing it away
	TAX
	; We always store the tile the player is on
	CLC
	LDY #1
	STA playerTileList,Y
	; Add 1 if not at end
	AND #7
	CMP #7
	BEQ ok1
	; NEW - TEST FOR /16=0, when climbing a ladder this should always be the case now
	LDA playerPosX
	AND #&0f
	BEQ ok1
	TXA
	ADC #1
	INY
	STA playerTileList,Y
.ok1
	; Only draw lower tiles if Y isn't divisible by 16
	LDA playerPosY
	AND #15
	BEQ ok
	TXA
	CMP #&58
	BCS ok ; last row, no need for any more
	ADC #8
	INY
	STA playerTileList,Y
.ok2
	TXA
	AND #7
	CMP #7
	BEQ ok
	LDA playerPosX
	AND #&0f
	BEQ ok
	TXA
	ADC #9
	INY
	STA playerTileList,Y
.ok
	STY playerTileList

	; Draw the rope base if required

;IF DEBUGRASTERS
;	LDA #&00 + PAL_cyan:STA &FE21
;ENDIF
	
	;LDA redrawRopeBaseFlag
	;BEQ drawRope

;.drawRopeBase
	;LDA #LO(itemSprites+32)
	;STA t0
	;LDA #HI(itemSprites+32)
	;STA t1
	;LDA #2
	;STA adjustPos+4
	;LDX ropeOrgDir
	;BEQ adjustPos
	;LDX #4
	;STX adjustPos+4
	; Adjust position
;.adjustPos
	;LDA ropeOrgPosX
	;SEC
	;SBC #4
	;STA t2
	;LDA ropeOrgPosY
	;STA t3
	;LDA #0
	;STA t4
	;CLC
	;JSR plotSprite8x8 ; these are costly

	;;  items
	LDA #&FF
	CMP itemTile
	BNE itemsToDo
	JMP noItems
	;beq noItems
	
.itemsToDo:
	LDA playerPosX
	STA getTileX
	LDA playerPosY
	STA getTileY
	JSR getTile
	CPY itemTile
	BEQ itemsToDo2
	JMP noItems

.itemsToDo2:
	LDA #LO(pickupSound):STA notereq+4
	LDA #HI(pickupSound):STA notereq+5
	
	; Item pickup : First just check for elder sign
	LDA itemID
    AND #$f0
    CMP #_itemElderSign
    BNE checkHealth
    LDA itemExtra
    ORA playerInventory
    STA playerInventory
    JSR drawElderSign
    JMP clearItems

	; If not an elder sign, display some text
.checkHealth:
	LDX #50:STX dynTextFrames
	CMP #_itemHealth
	BNE checkForRope
	
	; Increase player health
	LDA playerEnergy
	CMP #28-8
	BCS pippin
	LDA playerEnergy
	CLC
	ADC #8
	STA playerEnergy
	JMP refill
.pippin:
	LDA #28
	STA playerEnergy
.refill:
	JSR refillHealthBars
	JMP clearItems

.checkForRope:
	LDA itemID
	CMP #_itemRope
	BNE normalItem
	LDA playerInventory
	TAX
	AND #_bitRope
	BEQ firstRope
	LDA currentRopeLength
	CLC
	ADC #10
	STA currentRopeLength
	LDA #_itemRope
	STA playerUsingItem
	JMP endChecks
	
.firstRope:
	TXA
	ORA #_bitRope
	STA playerInventory
	LDA #_itemRope
	STA playerUsingItem
	JMP endChecks

IF 0
.itemTable:
    EQUB _itemRope,_bitRope
    EQUB _itemTorch,_bitTorch
    EQUB _itemGemRed,_bitGemRed
    EQUB _itemGemBlue,_bitGemBlue
ENDIF        
	
.normalItem:
    STA playerUsingItem
    LDX #$00

.lookForItem:
    CMP itemTable,X
    BEQ foundItem
    INX
    INX
    JMP lookForItem

.foundItem:        
    INX
    LDA itemTable,X
    ORA playerInventory
    STA playerInventory
        
.endChecks:
    JSR drawItem

.clearItems:
	LDA itemTile
	JSR redrawTile
	LDA #&ff
	STA itemTile

	STY t0
	LDY #2
	LDA (curScreenLO),Y
	AND #$ff EOR SCREEN_FLAGS_ITEM_PRESENT
	STA (curScreenLO),Y
	LDY t0

.noItems:

	; Finally, redraw the player sprite
.drawNewPlayer

	LDA #1
	STA redrawPlayerFlag
	
	DEC animDelay
	BNE updatePlayerEnd
	;LDA #1 ; A is already 1 (15/05/2013)
	EOR animFlag
	STA animFlag
	LDA #5
	STA animDelay

	; Save old state and return
.updatePlayerEnd
	LDA playerState
	STA playerOldState

	RTS
	}
	
.drawPlayer:
	{
	; Collision should set redrawPlayerFlag.
	LDA redrawPlayerFlag
	;AND #1 ; removed for memory (27/10/2013)
	BEQ noDraw

.drawHim:
	LDA playerState
	LSR A
	TAX
	LDA playerAnimDrawTable,X
	CPX #4
	BCS noAnimOnThisState
	
.normalAnim:
	CLC
	ADC animFlag

.noAnimOnThisState:
	ASL A
	TAY
	LDA (lookup128LO),Y
	INY
	CLC
	ADC #LO(manSprite)
	STA t0
	LDA (lookup128LO),Y
	ADC #HI(manSprite)
	STA t1
	
.draw:
	LDA playerPosX
	STA t2
	LDA playerPosY
	STA t3
	
.chooseSpriteRoutine:
	LDA playerFlags
	AND #1
	BNE notFlipped
	JSR plotSprite16x16TransFlippedNew
	RTS
	
.notFlipped:
	JSR plotSprite16x16TransNew
	
.noDraw:
	RTS
	}

.updatePlayerFalling
	{
	LDA playerPosY
	CMP #&D0
	BCC notAtBottom
	LDA #_screenChangeDown
	JSR checkForScreenChange
	LDX #0
	RTS
	
.notAtBottom	
	LDA playerPosX
	CLC
	ADC #7
	STA getTileX
	LDA playerPosY
	ADC #16
	STA getTileY
	JSR getTile
	LDA collData,Y
	AND #_bitCollidable
	BNE hitFloor

        ; 03/03/2012 : Player drop speed is 4 pixels
        LDA playerPosY
	TAX
	AND #3
	BNE onlyAdd2
	INX
	INX
	
.onlyAdd2:
	INX
	INX
        STX playerPosY
	LDA playerPosX
	STA getTileX
	LDA playerPosY
	STA getTileY
	JSR getTile
	STY tf

	LDX #1
	RTS
	
.hitFloor
	LDA #_playerStateNormal
	STA playerState
	RTS
	}

.updatePlayerFiringRope
	{
	LDX #0
	RTS
	}

.updatePlayerClimbingRope
	{
	; Save key flags
	STX t0

	; Z = Move Up/Down rope depending on direction, or come off if going left and at bottom
.handleLeft
	LDA #_keyLeft
	BIT t0
	BEQ handleRight
	LDA ropeOrgDir 		; 0 if left
	BEQ ropeGoingLeft
.ropeGoingRight
	; If (rope is going right: x-=2, y+=2, check tile at foot)
	LDA playerFlags
	ORA #1
	STA playerFlags

	LDA playerPosX
	CLC
	ADC #8
	STA getTileX
	LDA playerPosY
	CLC
	ADC #16
	STA getTileY
	JSR getTile
	LDA collData,Y
	AND #(_bitCollidable OR _bitClimbable)
	BNE comeOffRopeRight
	
	DEC playerPosX
	DEC playerPosX
	INC playerPosY
	INC playerPosY
	LDX #1
	RTS

.comeOffRopeRight
	LDA #_playerStateNormal
	STA playerState
	RTS

	; If (rope is going left: x-=2, y-=2, check tile is rope)
.ropeGoingLeft
	LDA playerFlags
	AND #&FE
	STA playerFlags
	LDA playerPosX
	STA getTileX
	LDA playerPosY
	STA getTileY
	JSR getTile
	LDA collData,Y
	AND #_bitRope
	BEQ noMove
	DEC playerPosX
	DEC playerPosX
	DEC playerPosY
	DEC playerPosY
	LDX #1
	RTS
.noMove
	LDX #0
	RTS
	
	; X = Move Up/Down rope depending on direction, or come off if going right and at bottom
.handleRight
	LDA #_keyRight
	BIT t0
	BEQ handleUp
	LDA ropeOrgDir
	BEQ ropeGoingLeft1
.ropeGoingRight1
	; If (rope is going right: x+=2, y-=2)
	LDA playerFlags
	ORA #1
	STA playerFlags
	LDA playerPosX
	CLC
	ADC #16
	STA getTileX
	LDA playerPosY
	STA getTileY
	JSR getTile
	LDA collData,Y
	AND #_bitRope
	BEQ noMove1
	INC playerPosX
	INC playerPosX
	DEC playerPosY
	DEC playerPosY
	LDX #1
	RTS

.noMove1
	LDX #0
	RTS
	
.ropeGoingLeft1
	; If (rope is going left: x+=2, y+=2, check tile at foot)
	LDA playerPosX
	CLC
	ADC #8
	STA getTileX
	LDA playerPosY
	CLC
	ADC #16
	STA getTileY
	JSR getTile
	LDA collData,Y
	AND #(_bitCollidable OR _bitClimbable)
	BNE comeOffRopeLeft
	INC playerPosX
	INC playerPosX
	INC playerPosY
	INC playerPosY
	LDX #1
	RTS
.comeOffRopeLeft
	LDA #_playerStateNormal
	STA playerState
	RTS

	; Up = Climb tile here if climbable and has rope (eg colltype = &81)
.handleUp
	LDA #_keyUp
	BIT t0
	BEQ handleDown
	; check tile at playerposX+8, playerPosY
	LDA playerPosX
	CLC
	ADC #8
	STA getTileX
	LDA playerPosY
	STA getTileY
	JSR getTile
	LDA collData,Y
	AND #(_bitHookable OR _bitCollidable)
	CMP #(_bitHookable OR _bitCollidable)
	BNE upOut
	LDA #_playerStateClimbingScene
	STA playerState
	LDX #1
.upOut
	RTS

	; Drop off rope at any position (ie player state = falling)
.handleDown
	LDA #_keyDown
	BIT t0
	BEQ outNoUpdate
	
	LDA #_playerStateFalling
	STA playerState

.outNoUpdate
	LDX #0
	RTS
	}

.updatePlayerNormal
	{
	; Check we're still on a platform
	LDA playerPosX
	CLC
	ADC #7
	STA getTileX
	LDA playerPosY
	ADC #16
	STA getTileY
	JSR getTile
	LDA collData,Y
	AND #(_bitCollidable OR _bitClimbable)
	BNE onPlatform
	LDA #_playerStateFalling
	STA playerState
	RTS

.temp
	;EQUB 2

.onPlatform

	;DEC temp
	;beq ok
	;ldx #0
	;RTS
.ok
	;LDA #2
	;STA temp
	
	; Save keyflags
	STX t0

	; By default, do not update player sprite
	LDX #0

.handleRight	
	LDA #_keyRight
	BIT t0
	BEQ handleLeft

	; Set right flag in player flags
	LDA playerFlags
	ORA #1
	STA playerFlags

	; Check for edge of screen
	LDA playerPosX
	CMP #(128-16)
	BNE movePlayerRight

	; See if there's an exit here
	LDA #_screenChangeRight
	JSR checkForScreenChange
	LDX #0
	RTS

.movePlayerRight

	; Test collision code
	LDA playerPosX
	CLC
	ADC #16
	STA getTileX
	LDA playerPosY
	STA getTileY
	JSR getTile
	LDA collData,Y
	AND #_bitCollidable
	BNE rightOut

    LDA playerPosX
    CLC
    ADC #2
    STA playerPosX
    JSR playWalkSound

	LDX #1
.rightOut:	
	RTS

.handleLeft
	LDA #_keyLeft
	BIT t0
	BEQ handleUp

	; Clear flag in player flags
	LDA playerFlags
	AND #&FE
	STA playerFlags

	; Check for X=0
	LDA playerPosX
	BNE movePlayerLeft

	; See if there's an exit here
	LDA #_screenChangeLeft
	JSR checkForScreenChange
	LDX #0
	RTS

.movePlayerLeft

	; Test collision code
	LDA playerPosX
	SEC
	SBC #2
	STA getTileX
	LDA playerPosY
	STA getTileY
	JSR getTile
	LDA collData,Y
	AND #_bitCollidable
	BNE leftOut

    LDA playerPosX
    SEC
    SBC #2
    STA playerPosX
    JSR playWalkSound
	
	LDX #1
.leftOut
	RTS

.handleUp
	LDA #_keyUp
	BIT t0
	BEQ handleDown
	
	; Check tile is climbable at px+8,py. 
	LDA playerPosX
	CLC
	ADC #8
	STA getTileX
	LDA playerPosY
	STA getTileY
	JSR getTile
	LDA collData,Y
	AND #_bitClimbable
	BEQ upOut
	JMP startClimbing

.upOut
	LDA ropeState
	CMP #_ropeStateAttached
	BNE ropeNotAttached
	CPY ropeTile
	BEQ getOnRope
.ropeNotAttached
	RTS
	
.getOnRope
	; Align player with rope's position
	LDA ropeOrgDir
	BNE alignPlayerLeft
	LDA playerFlags
	AND #&FE
	STA playerFlags
	JMP aligned
.alignPlayerLeft
	LDA #1
	ORA playerFlags
	STA playerFlags
.aligned
	LDA #_playerStateClimbingRope
	STA playerState
	LDA ropeOrgPosX
	SEC
	SBC #8
	STA playerPosX
	LDA ropeOrgPosY
	SEC
	SBC #8
	STA playerPosY
	LDX #1
	RTS

.handleDown
	LDA #_keyDown
	BIT t0
	BEQ outNoUpdate

	; Check tile is climbable at px+7,py. 
	LDA playerPosX
	CLC
	ADC #7
	STA getTileX
	LDA playerPosY
	ADC #16
	STA getTileY
	JSR getTile
	LDA collData,Y
	AND #_bitClimbable
	BEQ downOut

.startClimbing
	;  If so, "snap" to ladder to ensure we only redraw 2 tiles when climbing a ladder
	TYA
	AND #7
	ASL A
	ASL A
	ASL A
	ASL A
	STA playerPosX
	LDA #_playerStateClimbing
	STA playerState
	LDX #1
.downOut:	
	RTS
	
.outNoUpdate
	LDX #0
	RTS
	}

.updatePlayerClimbingScene
	{
	; Save off key flags
	STX t0

	; By default do not update player sprite
	LDX #0
	
.handleUp
	LDA #_keyUp
	BIT t0
	BEQ out

	;DEC playerPosY
	;DEC playerPosY
	LDA playerPosY
	SEC
	SBC #2
	STA playerPosY
	JSR playWalkSound

	; Check top tile
	LDA playerPosX
	CLC
	ADC #7
	STA getTileX
	LDA playerPosY
	CLC
	ADC #15
	STA getTileY
	JSR getTile
	LDA collData,Y
	TAX
	AND #(_bitCollidable OR _bitRope)
	BEQ step2
	LDX #1
	RTS
.step2
	TXA
	AND #_bitClimbable
	BEQ outOffLadder
	LDX #1
	RTS
	
.outOffLadder
	LDA #_playerStateNormal
	STA playerState
	LDX #1
.out
	RTS
	}

.updatePlayerLadder
	{
	; Save off key flags
	STX t0
	
	; By default, do not update player sprite
	LDX #0

	; Collision points = px+7, py+15 - check top tile isn't climbable
.handleUp
	LDA #_keyUp
	BIT t0
	BEQ handleDown

	; Check for Y=32 - Then screenchange
	LDA playerPosY
	CMP #&22
	BCS notAtTop
	LDA #_screenChangeUp
	JSR checkForScreenChange
	LDX #0
	RTS

.notAtTop:
    LDA playerPosY
    SEC
    SBC #2
    STA playerPosY
    JSR playWalkSound
	;DEC playerPosY
	;DEC playerPosY

	; Check top tile
	LDA playerPosX
	CLC
	ADC #7
	STA getTileX
	LDA playerPosY
	CLC
	ADC #15
	STA getTileY
	JSR getTile
	LDA collData,Y
	TAX
	AND #(_bitCollidable); OR _bitRope)
	BEQ step2
	LDX #1
	RTS
.step2
	TXA
	AND #_bitClimbable
	BEQ outOffLadder
	LDX #1
	RTS
	
	; Collision points = px+7, py+15 - check bottom tile is collidable
.handleDown
	LDA #_keyDown
	BIT t0
	BEQ outNoUpdate

	; Check for Y=208 - Then screenchange
	LDA playerPosY
	CMP #&D0
	BCC notAtBottom
	LDA #_screenChangeDown
	JSR checkForScreenChange
	LDX #0
	RTS
	
.notAtBottom

	; Check bottom tile
	LDA playerPosX
	STA getTileX
	LDA playerPosY
	CLC
	ADC #16
	STA getTileY
	JSR getTile
	
	LDA collData,Y
	AND #_bitClimbable
	BEQ outOffLadder

    LDA playerPosY
    CLC
    ADC #2
    STA playerPosY
    JSR playWalkSound

	LDX #1
	RTS
	
.outOffLadder
	LDA #_playerStateNormal
	STA playerState
	LDX #1
	RTS
	
.outNoUpdate
	LDX #0
	RTS
	}
	
	; A contains direction
.checkForScreenChange
	{
	CMP #_screenChangeDown
	BEQ down
	
	CMP #_screenChangeRight
	BEQ right

	CMP #_screenChangeUp
	BEQ up
	
.left
	; Offset into screentable
	LDY #6
	LDA (curScreenLO),Y
    BNE stob
    ;JMP noExit
	rts
        
.stob:
	STA playerScreen

	; Set carry
	LDA t4
	EOR #1
	ASL A

	LDA #LO(manSprite)
	STA t0
	LDA #HI(manSprite)
	STA t1
	LDA playerPosX
	STA t2
	LDA playerPosY
	STA t3

	; set up new position
	LDA #128-16
	STA playerPosX
	JMP out
	
.right:
    LDY playerScreen
    CPY #45
    BNE notLastScreen

    ; Gone right from Shoggoth - set up congratulations screen
    LDX #49
    STX titleScreenNumber
    LDX #25:STX titleScreenTextOne
    DEX:STX titleScreenTextTwo
    LDX #1:STX titleScreenTextThree

    ; Since we are nested 3 JSRs deep, pull return addresses off the stack.
    LDX #6
.clearStack:        
    PLA
    DEX
    BNE clearStack
    JMP drawTitle

.notLastScreen:
	LDY #5
	LDA (curScreenLO),Y
	BEQ noExit
	STA playerScreen
	LDA #0
	STA playerPosX
	JMP out

.up:
	LDY #3
	LDA (curScreenLO),Y
	BEQ noExit
	STA playerScreen
	LDA #208
	STA playerPosY
	JMP out
	
.down:
	LDY #4
	LDA (curScreenLO),Y
	BEQ noExit
    ;BRK
    TAX;save
    LDA playerScreen
    CMP #41
    BNE normalScreen
    LDA playerInventory
    AND #$f0 ; check all elder bits
    CMP #$f0
    BEQ normalScreen
    LDX #41 ; drop into same screen

.normalScreen:
    TXA
	STA playerScreen
	LDA #&20
	STA playerPosY
.out:
	LDA #_ropeStateOff
	STA ropeState
	JSR drawScreen

IF FALSE
	; Temp stuff for demo build
	LDA #12
	CMP playerScreen
	BNE drawNewPlayer

	JMP demoMsg
ENDIF

.drawNewPlayer
	LDA #&ff
	STA playerOldState

.noExit
	RTS

IF FALSE
.demoMsg
	LDA #2
	STA t0
.clearHUDLoopEvenOuter
	LDA #0
	LDY #8
.clearHUDLoopOuter
	LDX #0
.clearHUDLoop
	STA &4000,X
	DEX
	BNE clearHUDLoop
	INC clearHUDLoop+2
	DEY
	BNE clearHUDLoopOuter
	
	LDA #&78
	STA clearHUDLoop+2
	DEC t0
	BNE clearHUDLoopEvenOuter

.drawText
	LDA #LO(screenStrings)
	STA t0
	LDA #HI(screenStrings)
	STA t1
	LDA #LO(&4000+(512*15)+32)
	STA t2
	LDA #HI(&4000+(512*15)+32)
	STA t3
	LDA #14
	STA t4
	JSR writeText

.drawText2
	LDA #LO(screenStringsTemp1)
	STA t0
	LDA #HI(screenStringsTemp1)
	STA t1
	LDA #LO(&4000+(512*19))
	STA t2
	LDA #HI(&4000+(512*19))
	STA t3
	LDA #16
	STA t4
	JSR writeText

.drawText3
	LDA #LO(screenStringsTemp2)
	STA t0
	LDA #HI(screenStringsTemp2)
	STA t1
	LDA #LO(&4000+(512*21)+32)
	STA t2
	LDA #HI(&4000+(512*21)+32)
	STA t3
	LDA #14
	STA t4
	JSR writeText
	
.hangMachine
	LDA irqCounter
	BEQ hangMachine
	LDA #0
	STA irqCounter
	JSR snowFlakes
	JMP hangMachine
ENDIF
	}
