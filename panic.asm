	;;
	;;  MOUNTAIN PANIC
	;;  --------------
	;;
	;;  Started:    January 2008
	;;  Finished: 	13:00 May 31st 2013 (RC)
	;;              22:00 July 1st 2013 (RC_1)
    ;;              17:00 Sept 11th 2013 (RC_2)
	;; 
    ;;  Released:   Play Expo 2013

 INCLUDE "memory.asm"

_startingScreen   = 1 ; 23 ; 45 = Shoggoth, 41 = entrance to abyss
_playerStartPosX  = 16+4
_playerStartPosY  = 192;16*2;16*6;192 ;16*6

SCREEN_FLAGS_ITEM_PRESENT = $04

.mainEntryPoint:
    LDX #0
    STX titleScreenNumber
    INX
    STX titleScreenTextThree
    LDX #9
    STX titleScreenTextOne
    INX
    STX titleScreenTextTwo
	
.drawTitle:
	JSR setupPlayer

	LDA titleScreenNumber
	STA playerScreen

    ; Refresh item and elder sign
    JSR drawItem
    JSR drawElderSign

	; Restore HP & San bars
    JSR refillHealthBars
        
	; Palette
	LDA #$90 + PAL_red
	STA $fe21
	LDA #$e0 + PAL_red
	STA $fe21

    ; Draw screen
	JSR drawScreen

    ; Text
.textOne:        
	LDX #0
	LDY titleScreenTextOne
    BEQ textTwo
	LDA #LO((&4000+(512*9))+32*4)
	STA t2
	LDA #HI((&4000+(512*9))+32*4)
	STA t3
	JSR drawStringWithOSFont

.textTwo:        
	LDX #0
	LDY titleScreenTextTwo
	LDA #LO((&4000+(512*10))+32*1)
	STA t2
	LDA #HI((&4000+(512*10))+32*1)
	STA t3
	JSR drawStringWithOSFont

.textThree:        
	LDX #0
	LDY titleScreenTextThree
	LDA #LO(&4000+(512*20)+64)
	STA t2
	LDA #HI(&4000+(512*20)+64)
	STA t3
	JSR drawStringWithOSFont

	lda #1
	sta joystickEnabledFlag ; initially we always attempt to read joystick

.titleLoop:
	JSR snowFlakes

.titleVsync:
	LDA irqCounter
	BEQ titleVsync
	LDA #0
	STA irqCounter
	JSR updateKeys
	LDA keyFlags
	AND #(_keyFire OR _keyJoystickUsed)
	BEQ titleLoop

	AND #_keyJoystickUsed	; If we've used a joystick here, assume we're reading one..
	BNE debounce
	LDA #0
	STA joystickEnabledFlag ; otherwise, disable it
	
.debounce:
	JSR updateKeys
	LDA keyFlags
	AND #_keyFire
	BNE debounce

    ; If we are coming from congratulations screen, display main page
    LDA titleScreenNumber
    CMP #49
    BNE notCongrat
    JMP mainEntryPoint
	
.notCongrat:
	; Start game off
	LDA #_startingScreen
	STA playerScreen

	JSR drawScreen

.gameLoop:
	; Check for inventory first
	JSR updateKeys
	JSR updateInventory
	
	; Load effects bit for this screen : Probably can do this in the 'drawScreen' routine
	; when setting the screen up instead of every frame: Save about 20 cycles or so.
	LDY #2
	LDA (curScreenLO),Y
	AND #_effectSnow OR _effectGems
	BEQ effectsDone

.effectsPresent:
	AND #_effectGems
	BEQ fxSnow
	LDA #LO(fxRoutines+2)
	STA effectJump+1
	LDA #HI(fxRoutines+2)
	STA effectJump+2
	JMP pushRet
	
.fxSnow:
	; Load base table address, then INC or ADC jmp address and store at 'effectJump+1'.
	; Perhaps ensure jump table is page-aligned so can just alter LS byte.
	LDA #LO(fxRoutines)
	STA effectJump+1
	LDA #HI(fxRoutines)
	STA effectJump+2

	; ^^^^
	; THIS SHOULD BE DONE IN 'drawScreen'
	; vvvv
.pushRet:
	; Push return address for RTS
	LDA #HI(effectsDone-1)
	PHA
	LDA #LO(effectsDone-1)
	PHA
		
.effectJump:
	JMP (&0000)
	
.effectsDone:
	JSR updateShoggoth

	LDA #0
	STA redrawPlayerFlag

	LDA unused1
	BEQ notThisTime

    JSR updatePlayer
    LDA shogForceElderDraw
    BNE drawElderSigns
    LDA redrawPlayerFlag ; need to check the elder flag here..
    BEQ doneElderSigns

.drawElderSigns:
    LDA numElderSigns
    BEQ doneElderSigns

.elderSignsLoop:
    PHA ; save number of signs
    ASL A
    TAX
    LDA #LO(itemSprites+(6*8*4))
    STA t0
    LDA #HI(itemSprites+(6*8*4))
    STA t1
    LDA #0
    STA t4
    DEX ; x=3, load y, then X
    LDA elderSignsPos,X
    STA t3
    LDA elderSignsPos-1,X
    STA t2
    CLC
    JSR plotSprite8x8
    PLA
    SEC
    SBC #1
    BNE elderSignsLoop
    LDA #0:STA shogForceElderDraw

.doneElderSigns:
	JSR drawPlayer
	JMP doneEnemies
	
.notThisTime:
	JSR updateEnemies
	
.doneEnemies:
	LDA unused1
	EOR #255
	STA unused1
	
	JSR updateRope
	JSR updateHPAndSan
    JSR drawItem
    JSR updateDynamicText


.doRope:        
	LDA ropeState
	CMP #_ropeStateAttached
	BNE vSync
	JSR fastPlotRope

.vSync:
.lockedVsync:
	LDA irqCounter
	BEQ lockedVsync
	LDA #0
	STA irqCounter

.readJoy:
	lda #0
	sta &fec0

	LDA playerEnergy
    BEQ gameOver
	JMP gameLoop

.gameOver:        
    JSR gameOverText
    LDA #200
    STA t0
        
.gameOverWait:
	LDA irqCounter
	BEQ gameOverWait
	LDA #0
	STA irqCounter
    DEC t0
    BNE gameOverWait
	JMP drawTitle

.setupPlayer:
	{
	; Set up player
	LDA #_playerStartPosX
	STA playerPosX
	
	LDA #_playerStartPosY
	STA playerPosY

	LDA #0
	STA ropeState
	STA ropeLength
	STA playerHPLoss
	STA flakeActiveList
	STA playerFlags
	STA playerGems
    STA icicleDropFlag
    ;;  INVENTORY vvvv
    ; LDA #_bitRope OR _bitGemBlue OR _bitGemRed OR _bitTorch 
	STA playerInventory
    ;LDA #_itemRope
    STA playerUsingItem

	; Force an update on first frame
	LDA #&FF
	STA playerOldState
    STA lastDrawnPlayerItem
	
	LDA #28
	STA playerEnergy

	LDA #_playerStateNormal
	STA playerState

	; Reset rope
	LDA #_ropeLengthBasic;+20
	STA currentRopeLength

	JSR initShoggoth

	; Re-initialise all items
	NUM_SCREENS = 49
	
	LDA #LO(mapData)
	STA t0
	LDA #HI(mapData)
	STA t1

	LDX #0

.setupScreenLoop:
	LDY #7
	LDA (t0),Y
    STA t2
	AND #1 ; check for original item bit ... ; lda #1: bit t2 ...   lda #%10 : bit t2...
	BEQ noItem
	LDY #2
	LDA (t0),Y
	ORA #SCREEN_FLAGS_ITEM_PRESENT
	STA (t0),Y
    LDY #7
.noItem:
    LDA t2
    AND #%10 ; check for original sanity bit
    BEQ noSanity
    LDA t2
    ORA #%100 ; set sanity bit again
    STA (t0),Y ; and save back
.noSanity:        
	CLC
	LDA t0
	ADC #8 ; next screen
	STA t0
	LDA t1
	ADC #0
	STA t1
	INX
	CPX #NUM_SCREENS
	BNE setupScreenLoop
	RTS
	}

.fxRoutines
	; Effect routines jump table, remember to align properly so can be sure to just increment the lo byte.
	EQUW snowFlakes		
	EQUW effectGems

.drawElderSign:
        {
        LDA playerInventory
        STA tc ; tc is work byte, check for elder sign bits
        
        LDA #0
        STA tb ; tb is loop counter
        
.drawSignLoop:
        LDA tc
        AND #$80
        BNE haveThisPiece

.clearPiece:
        LDA #0
        STA t0
        STA t1
        BEQ cont

.haveThisPiece:        
	    LDA #LO(itemSprites+_itemElderSign) ; Since these will be different, these will also come from a look-up table
	    STA t0
	    LDA #HI(itemSprites+_itemElderSign) ; Since these will be different, these will also come from a look-up table
	    STA t1
.cont:        
        LDX tb
	    LDA elderSignPositions,X
	    STA t2
        LDA elderSignPositions+1,X
        STX tb
	    STA t3
	    LDA #0
	    STA t4
	    CLC
	    JSR plotSprite8x8
        
        ;LDA tc
        ASL tc
        ;STA tc
        LDX tb
        INX
        INX
        STX tb
        CPX #8
        BNE drawSignLoop
        RTS
        
        }
	
.drawItem:
        {
        LDA #112
        STA t2
        LDA #240
        STA t3
        LDA #0
        STA t4
        LDA playerUsingItem
        CMP lastDrawnPlayerItem
        BNE mustDraw
        RTS
.mustDraw:        
        STA lastDrawnPlayerItem
        CMP #0
        BNE hasItem
.noItem:
        LDA #0
        STA t0
        STA t1
        BEQ drawItemOut
        
.hasItem:
        CLC
        ADC #LO(itemSprites)
        STA t0
	    LDA #HI(itemSprites)
        ADC #0
	    STA t1
        
.drawItemOut:
	    CLC
	    JSR plotSprite8x8
        RTS
        }

PRINT "* Draw item, elder size: ", P%-drawItem, drawItem-drawElderSign

;INCLUDE "inventory.asm"
INCLUDE "items.asm"
INCLUDE "rope.asm"
INCLUDE "sprites.asm"
INCLUDE "hardware.asm"
INCLUDE "tiles.asm"
INCLUDE "player.asm"
INCLUDE "enemy.asm"
INCLUDE "shoggoth.asm"
;INCLUDE "text.asm"
INCLUDE "screen.asm"
;INCLUDE "snowflakes.asm"
INCLUDE "gems.asm"
INCLUDE "keys.asm"
INCLUDE "drawing.asm"
INCLUDE "HPAndSan.asm"
INCLUDE "collision.asm"
INCLUDE "unpack.asm"
INCLUDE "sound.asm"
INCLUDE "dyntext.asm"
	
.codeEnd:
	INCLUDE "LevelData.asm"
	
.manSprite:
	INCBIN "BBCSPRT.BIN"

.realEnd:
ALIGN &100
.end:

NATIVE_ADDR = &100 ; all the memory
RELOAD_ADDR = &1900
OFFSET      = RELOAD_ADDR - NATIVE_ADDR

.relocate:
  LDA #140
  JSR &FFF4 ; *TAPE

  ; Patch in key definitions
  lda &70
  sta keyCheckLeft+1+OFFSET
  lda &71
  sta keyCheckRight+1+OFFSET
  lda &72
  sta keyCheckUp+1+OFFSET
  lda &73
  sta keyCheckDown+1+OFFSET
  lda &74
  sta keyCheckRET+1+OFFSET
  lda &75
  sta keyCheckSpace+1+OFFSET

  LDA #0
  LDX #1
  JSR &FFF4
  STX machineType + OFFSET

  CPX #3
  BCC sTel
        
  LDA #25:LDX #0:JSR &FFF4 ; reset master font definition

.sTel:
  SEI
        
  LDX #LO(stackEnd-1)
  TXS

   ; Set up VIA for sound
	
   ; Disable all interrupts
   LDA #&7F
   STA &FE4E

   LDA #&FF:STA &FE43               ; set DDRA on System VIA to %1111 1111
   LDA #&0F:STA &FE42               ; set DDRB on System VIA to %0000 1111
   LDA #&08:STA &FE40				; sound chip enable pulled high (disabled for now)
   LDA #&0B:STA &FE40				; keyboard enable pulled high (disabled)
   LDA #&00:STA &FE62               ; set DDRB on User VIA (used for master compact joystick)
	
  ;;  zero sound workspace
  LDA #0
  LDY #32
	
.zeroLoop:
  STA soundtemp,Y
  DEY
  BPL zeroLoop

  LDX #HI(end-start)
  LDY #0
  TYA ; ????

.relocateloop:
  LDA RELOAD_ADDR,Y
  STA NATIVE_ADDR,Y
  INY
  BNE relocateloop
  INC relocateloop + 2 + OFFSET   ; address corrected
  INC relocateloop + 5 + OFFSET   ; address corrected
  DEX
  BNE relocateloop

  ; TODO: Move screen setup here to save more memory..?
  LDA #0
  STA packedTileTable+0
  STA packedTileTable+1
  LDA #LO(tileSpritesPacked2-tileSpritesPacked)
  STA packedTileTable+2
  LDA #HI(tileSpritesPacked2-tileSpritesPacked)
  STA packedTileTable+3
  LDA #LO(tileSpritesPacked3-tileSpritesPacked2)
  STA packedTileTable+4
  LDA #HI(tileSpritesPacked3-tileSpritesPacked2)
  STA packedTileTable+5

  LDY #0	
  LDX #8
	
.downloadTopPanel:
  LDA topPanel + OFFSET,Y
  STA &4000,Y
  DEY
  BNE downloadTopPanel
  INC downloadTopPanel + 2 + OFFSET
  INC downloadTopPanel + 5 + OFFSET
  DEX
  BNE downloadTopPanel

  LDY #0	
  LDX #8
	
.downloadBottomPanel:
  LDA bottomPanel + OFFSET,Y
  STA &7800,Y
  DEY
  BNE downloadBottomPanel
  INC downloadBottomPanel + 2 + OFFSET
  INC downloadBottomPanel + 5 + OFFSET
  DEX
  BNE downloadBottomPanel

  LDA #0
  STA dynTextFrames
	
.hardwareSetup:        

    LDA machineType + OFFSET
	CMP #3
	BCC normalBBC

    CMP #5
    BNE patchSheilaADC

    ; Patch for Master Compact Joystick (11/09/2013)
    LDX #0
.joystickPatchLoop:
    LDA masterCompactJoystickRoutineStart + OFFSET,X
    STA startJoystickPatch,X
    INX
    CPX #61
    BNE joystickPatchLoop

	; ADC on Master 128 is at a different SHEILA address (&18)
	; Will also need to patch font in here.
.patchSheilaADC:
	LDA #&18
	STA readJoy+3
	STA getADCChannel+1
	LDA #&19
	STA channel1ADC+1
	STA channel2ADC+1
	LDA #&18
	STA channel1ADCa+1

    LDA #$80
    STA $FE30 ; page in vdu ram bank for master charset

    LDY #0
.copycharsloop:
    LDA &8900,Y:STA &C000,Y
    LDA &8A00,Y:STA &C100,Y
    LDA &8B00,Y:STA &C200,Y
    INY
    BNE copycharsloop

    LDA machineType + OFFSET
    CMP #5
    BNE normalBBC

.normalBBC:
	; Disable all interrupts
    LDA #&7F
	STA &FE4E
        
	LDA #0
	STA irqCounter
	STA joyTemp
	STA joyTemp2

;IF TRUE ; disable this lot for proper sound on real h/w
IF FALSE
	; Keyboard stuff
	LDA #&7F
	STA &FE43
	LDA #&0F
	STA &FE42
	LDA #&03
	STA &FE40
ENDIF

	; Enable vsync, timer1, and adc interrupts
	; $82 - just vsync, $c2 vsync and timer 1, $d2 - adc,vsync and timer1
	LDA #&D2
	STA &FE4E

.setupScreen:
	SEI

IF 0        
	; Full screen clear - ($3000-$7fff) = 40.
    ; Clear to panel address = 38.
	LDX #&28
	LDA #0
	TAY
.clearloop:
	STA &4800,Y
	INY
	BNE clearloop
	INC clearloop + 2 + OFFSET
	DEX
	BNE clearloop
ENDIF        
	
.skipClear:
	LDX #13
        
.crtcloop:
	STX &FE00
	LDA crtcregs + OFFSET,X
	STA &FE01
	DEX
	BPL crtcloop

	; Video ULA
	LDA #&F4
	;STA &248
	STA &FE20

	LDX #8
.palloop
	LDA paldata + OFFSET,X
	STA &FE21
	ORA #&80
	STA &FE21
	DEX
	BPL palloop

	; Set trans
	LDA #&f0 + PAL_black
	STA &FE21
	CLI

	; Set up tables
	LDA #LO(sinTable):STA sinTableLO
	LDA #HI(sinTable):STA sinTableHI
	LDA #LO(flakes):STA flakesLO
	LDA #HI(flakes):STA flakesHI
	;LDA #LO(screenStrings):STA stringTableLO
	;LDA #HI(screenStrings):STA stringTableHI
	LDA #LO(lookup128):STA lookup128LO
	LDA #HI(lookup128):STA lookup128HI

	; Zero-page player sprite routine mask table
	LDA #0
	STA maskTable+0
	STA maskTable+7
	LDA #&55
	STA maskTable+1
	STA maskTable+6
	LDA #&AA
	STA maskTable+2
	STA maskTable+5
	LDA #&FF
	STA maskTable+3
	STA maskTable+4

	; seutp HP & san colours
	LDA #&E0 + PAL_red
	STA &FE21
	LDA #&90 + PAL_red
	STA &FE21

	; Initialise snow window
	LDA #0
	STA snowWindow+0
	STA snowWindow+1
	LDA #16*8
	STA snowWindow+2
	LDA #16*12
	STA snowWindow+3

	; Init bitmasks
	LDA #&55
	STA spriteBitMasks
	LDA #&AA
	STA spriteBitMasks+1

    LDA #0
    STA animFlag
    STA redrawPlayerFlag
    STA wasPressedFlagGems
    STA wasPressedFlagInventory
    STA playerWalkSfxFlag
    STA unused1

    LDA #5
    STA animDelay

    ; init colours for plot pixel
    LDX #17
	
.initColourLoop:
    LDA coloursForPlotPixel+OFFSET,X
    STA colours,X
    DEX
    BPL initColourLoop

    lda #1
    sta playerCollFlag

    lda #_hpLossFrameDelayLatch
    sta hpLossFrameDelay

    ; Enable interrupts and go
    ; CLI
    ; Start us off!
    JMP mainEntryPoint

.machineType:
  EQUB 0
        
.crtcregs:
	EQUB 127		; R0  horizontal total
	EQUB 64			; R1  horizontal displayed - shrunk a little
	EQUB 90			; R2  horizontal position
	EQUB 40			; R3  sync width
	EQUB 38			; R4  vertical total
	EQUB 0			; R5  vertical total adjust
	EQUB 32			; R6  vertical displayed
	EQUB 34			; R7  vertical position
	EQUB 0			; R8  interlace
	EQUB 7			; R9  scanlines per row
	EQUB 32			; R10 cursor start
	EQUB 8			; R11 cursor end
	EQUB HI(&4000/8)	; R12 screen start address, high
	EQUB LO(&4000/8)	; R13 screen start address, low
	
.paldata:
	EQUB &00 + PAL_black
	EQUB &10 + PAL_red
	EQUB &20 + PAL_green
	EQUB &30 + PAL_yellow
	EQUB &40 + PAL_blue
	EQUB &50 + PAL_magenta
	EQUB &60 + PAL_cyan
	EQUB &70 + PAL_white
	EQUB &80 + PAL_green ; Initially green, but red in hell.  This is done in 'drawscreen' so may not be stricly needed to set it up here.

.coloursForPlotPixel: ; for plotpixel
	EQUB 0,0		; Black
	EQUB 2,1		; Red
	EQUB 8,4		; Green
	EQUB &A,5		; Yellow
	EQUB &20,&10		; Blue
	EQUB &22,&11		; Magenta
	EQUB &28,&14		; Cyan
	EQUB &2A,&15		; White
	EQUB &82,&41		; White2!

.masterCompactJoystickRoutineStart:
    LDA &FE60
    TAX
    AND #1 ; fire
	BNE cj1
	LDA keyFlags
	ORA #(_keyFire OR _keyJoystickUsed)
	STA keyFlags

.cj1:
    TXA
    AND #2 ; left
    BNE cj2
    LDA keyFlags
    ORA #_keyLeft
    STA keyFlags

.cj2:
    TXA
    AND #16 ; right
    BNE cj3
    LDA keyFlags
    ORA #_keyRight
    STA keyFlags

.cj3:
    TXA
    AND #8 ; up
    BNE cj4
    LDA keyFlags
    ORA #_keyUp
    STA keyFlags

.cj4:
    TXA
    AND #4 ; down
    BNE cj5
    LDA keyFlags
    ORA #_keyDown
    STA keyFlags

.cj5:
    NOP
    NOP
    NOP

.masterCompactJoystickRoutineEnd:        
.topPanel:
  INCBIN "BBCPAN2.BIN"
	
.bottomPanel:
  INCBIN "BBCPAN.BIN"
	
.veryend:
PRINT "Very end: ",~veryend
PRINT "Total used:",realEnd-start
PRINT "Bytes remaining:",&4000-(realEnd-start)-&100
PRINT "OFFSET: ",OFFSET        
PRINT "Size of joystick code to patch:",endJoystickPatch-startJoystickPatch
PRINT "Size of compact joystick code:",masterCompactJoystickRoutineEnd-masterCompactJoystickRoutineStart
SAVE "Code", &100, veryend, relocate + OFFSET, RELOAD_ADDR
