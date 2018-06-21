_shogStateMoving  = 1
_shogStateStunned = 2
_shogStateDying   = 3
_shogStateDead    = 4

_shogsWaitFrames  = 50*5
        
; Basic idea is you hit shoggoth with an icicle at the right of the screen to stun him
; When he's stunned, drop down the centre will drop one elder sign piece.
; When all four signs are dropped, shoggoth dies and melts downwards.
; Player can now exit this way into congratulations screen.

.initShoggoth:
    {
    LDX #0
    STX shogSignsDropped
    STX shogForceElderDraw
    STX shogX
    INX
    STX shogMoveDelta
    LDX #192
    STX shogY
    LDX #_shogStateMoving
    STX shogState
    LDX #3
.patch:
    LDA shogPatchOne,X
    STA screen40DataEx,X
    DEX
    BPL patch
.fixedUp:       
    RTS
    }
    
.updateShoggoth:
    {
    ; Update any icicles
    LDA icicleDropFlag
    BEQ doneIcicle
    JSR updateIcicle
        
.doneIcicle:
    LDA playerScreen
    CMP #45
    BNE doNothing
        
    ; Do we need to draw signs?
    LDA shogDrawElderSigns
    BEQ doneElderDraw
    LDA shogSignsDropped
    STA numElderSigns
    ASL A ; *2
    TAX

.sCRLoop:
    LDA localElderSignPos,X
    STA elderSignsPos,X
    DEX
    BPL sCRLoop

    LDA #0
    STA shogDrawElderSigns ; no need now
    LDA #1
    STA shogForceElderDraw

.doneElderDraw:        
    LDA shogState
    CMP #_shogStateMoving
    BNE notMoving    
    JMP updateMoving
        
.notMoving:
    CMP #_shogStateDying
    BNE notDying
    JMP updateDying

.notDying:
    CMP #_shogStateStunned
    BNE doNothing ; Only remaining state is dead, so do nothing
    JMP updateStunned

.doNothing:
    ; Do nothing
    RTS
    }

.drawShoggoth:
    LDA #LO(shoggothData)
    STA t0
    LDA #HI(shoggothData)
    STA t1
    LDA shogX
    STA t2
    LDA shogY
    STA t3
    CLC
    JSR plotSprite16x16

    LDA #LO(shoggothData+128)
    STA t0
    LDA #HI(shoggothData+128)
    STA t1
    LDA shogX
    CLC
    ADC #16
    STA t2
    LDA shogY
    STA t3
    JSR plotSprite16x16

    LDA #LO(shoggothData)
    STA t0
    LDA #HI(shoggothData)
    STA t1
    LDA shogX
    CLC
    ADC #32
    STA t2
    LDA shogY
    STA t3
    SEC
    JSR plotSprite16x16
    RTS

.updateMoving:
    {
    LDA shogMoveDelta
    BEQ movingLeft
    
.movingRight:
    INC shogX
    LDA shogX
    CMP #(16*8)-(16*4)+1
    BNE shogsOut
    LDA #0
    STA shogMoveDelta
    JMP drawShoggoth

.movingLeft:
    DEC shogX
    BNE shogsOut
    LDA #1
    STA shogMoveDelta
    
.shogsOut:
    JMP drawShoggoth
    }

.updateDying:
    {
    INC shogY
    LDA shogY
    CMP #192+16
    BNE okYet
    LDA #_shogStateDead
    STA shogState
        
    ; unlock the collision map here
    LDX #3
.patch:
    LDA shogPatchTwo,X
    STA screen40DataEx,X
    DEX
    BPL patch
    
    ; now, dynamic patch of the tilemap...
    LDA #0 OR _bitColour
    STA $ab7
    LDA #8
    STA $aaf
    LDX #0
    STX $a57 ; a57=0
    INX
    STX $aa7 ; aa7=1
    LDA #_bitFlipped
    STA $a4f

    ; And redraw the tiles..
    INX ; x=2
.sMLoop:
    TXA
    PHA
    LDA shogRedrawTiles,X
    JSR redrawTile
    PLA
    TAX
    DEX
    BPL sMLoop
    RTS
    
.okYet: 
    JSR drawShoggoth
    LDA #(8*11)+4
    JSR redrawTile
    LDA #(8*11)+5
    JSR redrawTile
    LDA #(8*11)+6
    JSR redrawTile
    RTS
    }

.updateStunned:
    {
    LDA playerPosY 
    CMP #192                ; if player.y == 192 (ie is on floor)...
    BNE doneSignDrop
    LDA playerPosX
    CMP #24                 ; and player.x >= 24...
    BCC doneSignDrop
    CMP #42                 ; and player.x < 42
    BCS doneSignDrop
        
.compare:                       
    LDA shogSignsDropped    ; now check 'shogSignsDropped' against 'shogSignWhenStun', if they are different, we can drop a sign.
    CMP shogSignWhenStun
    BNE doneSignDrop 

.dropSign:
    CLC
    ADC #1
    STA numElderSigns
    STA shogSignsDropped
    LDA #1
    STA shogDrawElderSigns ; update them
    ; and remove a bit from elder inventory
    LDA playerInventory
    TAX ; save
    LSR A
    AND #$f0 
    STA t0 ; t0=new elder bits
    TXA
    AND #$0f
    ORA t0
    STA playerInventory
    JSR drawElderSign

    ; And play a sound
    LDA #LO(itemUseSound)
    STA notereq
    LDA #HI(itemUseSound)
    STA notereq+1

.doneSignDrop:
    DEC shogWaitFrames
    BNE stillStunned
        
    ; when shogwait=0, set state=moving
.checkForDead:
    LDA shogSignsDropped
    CMP #4
    BNE notDeadYet
    LDA #_shogStateDying
    STA shogState
    JMP drawShoggoth

.notDeadYet:
    LDA #_shogStateMoving
    STA shogState

.stillStunned:        
    JMP drawShoggoth
    }
    
.updateIcicle:
    {
    LDA icicleDropFrames
    CMP #40 ; first pass?
    BEQ skipErase

    ; Erase last one with an xor
    LDA #LO(icicleSprite)
    STA t0
    LDA #HI(icicleSprite)
    STA t1
    LDA icicleDropX
    STA t2:PHA
    LDA icicleDropY
    STA t3:PHA
    LDA #1
    STA t4
    CLC
    JSR plotSprite8x8

    ; Have we collided with a tile?    
    PLA:CLC:ADC #8
    STA getTileY
    PLA
    STA getTileX
    JSR getTile
    LDA collData,Y
    AND #_bitCollidable
    BNE lastFrame
    LDA getTileY
    CMP #192+16
    BCS lastFrame ; check end of screen


.skipErase:
    LDA icicleDropY:CLC:ADC#3:STA icicleDropY
    DEC icicleDropFrames
    BEQ lastFrame

    ; Draw new one
    LDA #LO(icicleSprite)
    STA t0
    LDA #HI(icicleSprite)
    STA t1
    LDA icicleDropX
    STA t2
    LDA icicleDropY
    STA t3
    LDA #1
    STA t4
    CLC
    JSR plotSprite8x8
    RTS

.lastFrame:
    LDA #0
    STA icicleDropFlag

    LDA icicleDropY
    CMP #192
    BCC noCollisionIcicle
    LDA icicleDropX
    CMP #58+(16*2)
    BCC noCollisionIcicle

    ; Check for shogs collision if 
    LDA shogState
    CMP #_shogStateMoving
    BNE noCollisionIcicle
    LDA shogX
    CMP #58
    BCS hitShogs
    
.noCollisionIcicle:
    RTS

.hitShogs:
    LDA #(8*10)+3
    JSR redrawTile ; blank out tile prior
    LDA #16*4 ; force x pos
    STA shogX
    LDA #_shogStateStunned
    STA shogState
    LDA #_shogsWaitFrames
    STA shogWaitFrames
    LDA shogSignsDropped
    STA shogSignWhenStun ; 24/04/2013 : Take a copy of the original number of signs so we can determine if player can drop a new sign
    LDA #LO(shoggothHitSound)
    STA notereq
    LDA #HI(shoggothHitSound)
    STA notereq+1
    RTS
        
.shoggothHitSound:
    EQUB 0 ; pitch
    EQUB 1 ; pitch envelope
    EQUB 1 ; vol envelope
    }
