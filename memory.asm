
ORG &0

.LZPOS              EQUW &9e ; 2 ZeroPage temporaries
.bitstr	            EQUB &fb ; 1 temporary (does not need to be ZP)
.irqTmp             EQUB 0
.runLenCnt          SKIP 1
.joystickEnabledFlag SKIP 1 ; 27/10/2013 - Flag to use the joystick
.snowWindow         SKIP 4   ; Actual x1,y1,x2,y2 values of the window : default is 0,0,128,192
.packedTileTable    SKIP 6
.itemExtra          SKIP 1   ; used for elder sign and OR'd directly into playerInventory
.itemTile		    SKIP 1
.itemID			    SKIP 1
.itemX			    SKIP 1
.itemY			    SKIP 1
.numAliens		    SKIP 1
.currentAlien       SKIP 1	 ; current alien we are updating
.alien1			    SKIP 6 + 2  ; 3 * alien work data
.alien2			    SKIP 6 + 2
.alien3			    SKIP 6 + 2
.spriteBitMasks		SKIP 2
        
; PLAYER
.playerPosX         SKIP 1	; 0
.playerPosY         SKIP 1 	; 1
.playerFlags 		SKIP 1	; 2 Player Direction (left/right)
.playerScreen 		SKIP 1	; 3 Screen player is currently on
.playerState 		SKIP 1	; 4
.playerOldDir 		SKIP 1	; 5
.playerInventory 	SKIP 1	; 6 One bit for each item
.playerUsingItem 	SKIP 1	; 7 Item ID currently using
.currentRopeLength	SKIP 1  ; 8 Rope length (20, 30, 50)
.keyFlags           SKIP 1	; 9 Current state of keys
.playerGems         SKIP 1  ; a temp gems
.playerOldState		SKIP 1  ; b
.playerEnergy		SKIP 1  ; c
.playerWalkSfxFlag	SKIP 1  ; d
.playerCollFlag		SKIP 1
.playerHPLoss		SKIP 1  ; f LOAD THIS WITH # OF FRAMES TO FLASH HP LOSS.
        
; ROPE
.ropeState 		    SKIP 1	; 0 = off, 1 = firing, 2 = set, 4...
.ropeLength 		SKIP 1	; rope's length
.ropePosX 		    SKIP 1
.ropePosY 		    SKIP 1
.ropeOrgPosX 		SKIP 1
.ropeOrgPosY 		SKIP 1
.ropeOrgDir 		SKIP 1
.ropeCounter 		SKIP 1	; Set up to be 30 or 40 depending on rope length
.ropeAttachFrames 	SKIP 1
.ropeTile		    SKIP 1
.screenDarkFlag		SKIP 1
.playerTileList		SKIP 1
			        SKIP 4
	
; TEMP WORK REGISTERS
.t0                 SKIP 1
.t1                 SKIP 1
.t2                 SKIP 1
.t3                 SKIP 1
.t4                 SKIP 1
.t5                 SKIP 1
.t6                 SKIP 1
.t7                 SKIP 1
.t8                 SKIP 1
.t9                 SKIP 1
.ta                 SKIP 1
.tb                 SKIP 1
.tc                 SKIP 1
.td                 SKIP 1
.te                 SKIP 1
.tf                 SKIP 1

; VARIOUS LOOKUP TABLES
.curScreenLO 		SKIP 1	; Current screen pointer LO
.curScreenHI 		SKIP 1	; Current screen pointer HI
.sinTableLO 		SKIP 1	; Sin table LO			\ 
.sinTableHI 		SKIP 1	; Sin table HI			  ---- These can both just be variables
.flakesLO 		    SKIP 1	; Flakes position LO		/
.flakesHI		    SKIP 1	; Flakes position HI
.unused1 		    SKIP 1  ; Spare..
.shogSignWhenStun   SKIP 1
.lookup128LO		SKIP 1
.lookup128HI		SKIP 1
.irqCounter		    SKIP 1
.getTileX		    SKIP 1
.getTileY		    SKIP 1
.getTileWork		SKIP 1
.joyTemp		    SKIP 1
.joyTemp2		    SKIP 1
.maskTable		    SKIP 4
.maskTableInverted	SKIP 4
;.scanLineOffset		SKIP 8 ; 0,8,16,24,32,40,48,56
.hpLossFrameDelay
	EQUB _hpLossFrameDelayLatch

; 7 spare
	SKIP 7

; SOUND WORKSPACE
.soundtemp			EQUB 0
.notereq			EQUW 0, 0, 0, 0		; addresses of note request sound blocks for each channel

.pitch				EQUB 0				; pitch channel 0
.volume				EQUB 0				; volume channel 0
					EQUB 0				; pitch channel 1
					EQUB 0				; volume channel 1
					EQUB 0				; pitch channel 2
					EQUB 0				; volume channel 2
					EQUB 0				; pitch channel 3
					EQUB 0				; volume channel 3					

.pitchenv			EQUB 0				; pitch envelope channel 0
.volenv				EQUB 0				; volume envelope channel 0
					EQUB 0				; pitch envelope channel 1
					EQUB 0				; volume envelope channel 1
					EQUB 0				; pitch envelope channel 2
					EQUB 0				; volume envelope channel 2
					EQUB 0				; pitch envelope channel 3
					EQUB 0				; volume envelope channel 3
			
.pitchenvindex		EQUB 0				; pitch envelope index channel 0
.volenvstage		EQUB 0				; volume envelope stage channel 0
					EQUB 0				; pitch envelope index channel 1
					EQUB 0				; volume envelope stage channel 1
					EQUB 0				; pitch envelope index channel 2
					EQUB 0				; volume envelope stage channel 2
					EQUB 0				; pitch envelope index channel 3
					EQUB 0				; volume envelope stage channel 3

PRINT "* Sound workspace (zp):", P%-soundtemp
	
; DYNAMIC TEXT
.dynTextFrames      SKIP 1
.dynTextString      SKIP 1
.dynTextTileIndex   SKIP 1

 ; SPARE       
.lastDrawnPlayerItem SKIP 1
.animFlag            SKIP 1
.redrawPlayerFlag    SKIP 1
        
; SHOGGOTH
.shogX SKIP 1
.shogY SKIP 1 ; 192?
.shogMoveDelta SKIP 1
.shogState SKIP 1 ; moving/stuck by sign/been hit(waiting)/running off (smashes exit block)
.shogWaitFrames SKIP 1 ; waiting frames
.shogTilesToRedraw SKIP 3 ; max 3
.shogDrawElderSigns SKIP 1 ; do we need to draw elder signs?
.shogForceElderDraw SKIP 1
.shogSignsDropped SKIP 1

; ICICLE DROP IN HELL        
.icicleDropFlag SKIP 1              ; load with 1 to drop an icicle
.icicleDropX SKIP 1                 ; icicle dropping x pos
.icicleDropY SKIP 1                 ; icicle dropping y pos
.icicleDropFrames SKIP 1

.titleScreenNumber SKIP 1
.titleScreenTextOne SKIP 1
.titleScreenTextTwo SKIP 1
.titleScreenTextThree SKIP 1

.spriteWorkZP SKIP 2
.animWorkZP SKIP 1
.tileWorkZP SKIP 1
.itemRedrawFlag SKIP 1

.numElderSigns SKIP 1 ; max 4
.elderSignsPos SKIP 2*4 ; x,y co-ords for 4 elders

.currentTileBank SKIP 1
.unpackTable SKIP 32
.colours SKIP 18
        
PRINT "* Zero page ends at ", ~P%-1, "Spare block (zp): ", &FC-sep
	
.sep:
SKIPTO &FC
                    SKIP 1 ; OS irq
        
.animDelay:
        SKIP 1
.wasPressedFlagGems:
	    SKIP 1
.wasPressedFlagInventory:
        SKIP 1
        
ORG &100
.start:        
.stackStart:
        SKIP 33
.stackEnd:

timerlength = 76*8*26

.irq:
	LDA &FE4D:AND #&10:BNE irqadc
	LDA &FE4D:AND #&02:BNE irqvsync
	
.irqtimer:
	LDA #&40:STA &FE4D
	
	; 'force' vsync here
	INC irqCounter
	LDA &FC
	RTI
.irqadc
	; clear irq
	LDA #&10
	STA &FE4D

	; get channel
.getADCChannel
	LDA &FEC0
	AND #3
	BEQ channel1ADC
	
.channel2ADC
	LDA &FEC1
	STA joyTemp2
.chan2Out
	LDA &FC
	RTI

	; channel 1 - left/right channel
.channel1ADC
	LDA &FEC1
	EOR #&FF
	STA joyTemp
	; chain in channel 2 read
	LDA #1
.channel1ADCa
	STA &fec0
	LDA &FC
	RTI
	
.irqvsync
	STA &FE4D
	LDA #LO(timerlength):STA &FE44
	LDA #HI(timerlength):STA &FE45
	
	; Cycle the bottom cols if player is experiencing HP/SAN loss
	TXA
	PHA
	TYA
	PHA

	JSR updatesound

	LDA #0
	STA irqTmp
	LDA playerHPLoss
	BEQ noSanLoss
	INC irqTmp
	LDX #0
        
.noSanLoss:
	LDA irqTmp
	BEQ irqOut

.palChangeLoop:
	DEC irqCounters,X
	BNE irqLoopEnd
	
	; Dropped to 0 - reprogram palette
	LDA irqIndices,X
	EOR #1
	STA irqIndices,X

	TAY
	LDA irqColours,Y
	STA $fe21

	; And reload latch
	LDA #5
	STA irqCounters,X

.irqLoopEnd:
	;LDX #0
	DEC irqTmp
	BNE palChangeLoop

.irqOut:
	PLA
	TAY
	PLA
	TAX
	LDA &FC
	RTI

	; Indices into tables for HP/SAN
.irqIndices:
	EQUB 0
	;EQUB 3
	
.irqColours:
	EQUB &e0 + PAL_red
	EQUB &e0 + PAL_white
	;EQUB &90 + PAL_white
	;EQUB &90 + PAL_red
	
.irqCounters:
	EQUB 5
	;EQUB 5

	; This little table maps playerstates to base animation pointers.
	; Notice that on X>=4, no animation is performed, i.e. firing rope or falling.
.playerAnimDrawTable
	EQUB 0,2,4,2,6,1

.textPixelTable:
	EQUB &00,&2a,&55,&3c

INCLUDE "inventory.asm"

.shogPatchOne:
   EQUB 8 OR _bitFlipped,0,1,8 OR _bitCollidable
.shogPatchTwo:
   EQUB 1 OR _bitCollidable,1,8 OR _bitFlipped,0
.enemyDataPtrs:
	EQUB 0,alien1,alien2,alien3
.colSound:
    EQUB 255
    EQUB 1
    EQUB 1
        
; pitch, pitch envelop, volume envelope
.itemUseSound:
    EQUB 80
    EQUB 0
    EQUB 1

.ropeAttachSound:
EQUB 238  ; pitch
EQUB 0    ; pitch envelope
EQUB 4    ; volume envelope

PRINT "* Spare block (after $100 stack, irq, inventory):", &204-P%
	
SKIPTO &204
        EQUW irq

.congratulationsScreen:
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB $81,$f0,10
	EQUB $81,$f0,0
	EQUB $81,$f0,2
	EQUB $99,2,5,5 OR _bitFlipped,2
	EQUB $99,2,6,6 OR _bitFlipped,2
	EQUB &FF,$f0,11

.gameOverText:
    {
	LDX #0
	LDY #23
	LDA #LO((&4000+(512*13))+96-16)
	STA t2
	LDA #HI((&4000+(512*13))+96-16)
	STA t3
	JSR drawStringWithOSFont

	LDX #0
	LDY #22
	LDA #LO((&4000+(512*14))+96-16)
	STA t2
	LDA #HI((&4000+(512*14))+96-16)
	STA t3
	JSR drawStringWithOSFont

	LDX #0
	LDY #23
	LDA #LO((&4000+(512*15))+96-16)
	STA t2
	LDA #HI((&4000+(512*15))+96-16)
	STA t3
	JSR drawStringWithOSFont
	RTS
    }

.localElderSignPos:
    EQUB 48,208
    EQUB 48+8,208
    EQUB 48,208+8
    EQUB 48+8,208+8
	
PRINT "* Spare block ($206 - $257), probs congratulations page code: ",&258-P%

SKIPTO &258
        EQUB 2
	
.itemSprites:
        INCBIN "BBCITMS.BIN" ; 224 bytes.. so a little spare (32 bytes...)

.tileAddressTable:		; 96 * 2 = 192 bytes of tile lookup
	FOR i,0,11,1
	  FOR j,0,7,1
	    EQUW &4800+(i*1024)+(j*64)
	  NEXT
	NEXT
        
;SKIPTO &4C0
.lookup128:			; 128* lookup data (0..31 * 128)
	FOR n,0,31,1
	  EQUB LO(n*128)
	  EQUB HI(n*128)
	NEXT

INCLUDE "snowflakes.asm"

.playerStateJumpTables
	EQUW updatePlayerNormal
	EQUW updatePlayerLadder
	EQUW updatePlayerClimbingRope
	EQUW updatePlayerClimbingScene
	EQUW updatePlayerFiringRope
	EQUW updatePlayerFalling

.alienPointerTable:
	EQUB alien1
	EQUB alien2
	EQUB alien3

.shogRedrawTiles:
	EQUB (8*9)-1
	EQUB (8*10)-1
	EQUB (8*11)-1

PRINT "* Spare block (post snowflakes, pre Y lookup):", &500-P%
	
SKIPTO &500
.spriteYLookup:
	FOR i,0,255,1
	  EQUB LO(&4000+((i DIV 8)*512)+(i AND 7))
	NEXT

	FOR i,0,255,1
	  EQUB HI(&4000+((i DIV 8)*512)+(i AND 7))
	NEXT

PRINT "Sanity: ",~P%
;SKIPTO &700
.unpackedTileXSprites:
	INCBIN "BBCTLEX.BIN"

SKIPTO &900
.sinTable:
FOR n, 0, 255
	EQUB (SIN(n/128*PI)) * 6
NEXT

SKIPTO &A00
.collData			; 96 bytes of collision data
SKIP 12*8
        
.tileData:			; 96 bytes of tile data
SKIP 12*8
.flakes:    		; 64 bytes spare here.
FOR n, 0, 10
   IF (n <> 9)
     EQUB 5+(n+1)*11      ; x
   ELSE
     EQUB (38)
   ENDIF

   IF (n <> 9)
     EQUB RND(210-33)+33  ; y
   ELSE
     EQUB 33
   ENDIF
NEXT
        
.flakeActiveList:		; needed = 1+(2*12)=37          = &AD8
   SKIP 1+(2*12)

; Rope Data Format
; 0 - Number of rope elements (max 40 here, eg 1+(40*3) = 121)
; Element data:
;               (n+1) : Transformed pixel address LO
;  		        (n+2) : Transformed pixel address HI
;               (n+3) : Mask of this pixel (used when redrawing rope)
	
SKIPTO &B00
.ropeData:
; Rope Data Format
; 0 - Number of tiles used by rope
; Element data:
;               (n+1) : Tile index

SKIP 88

;SKIPTO &C00
.ropeTileList:
        SKIP 16
        
.stringTable:
{        
	EQUW s1-stringTable
	EQUW s2-stringTable
	EQUW s3-stringTable
	EQUW s4-stringTable
	EQUW s5-stringTable
	EQUW s6-stringTable
	EQUW s7-stringTable
	EQUW s8-stringTable
	EQUW s9-stringTable
	EQUW s10-stringTable
	EQUW s11-stringTable
	EQUW s12-stringTable
	EQUW s13-stringTable
	EQUW s14-stringTable
	EQUW s15-stringTable
	EQUW s16-stringTable
	EQUW s17-stringTable
	EQUW s18-stringTable
    EQUW s19-stringTable
    EQUW s20-stringTable
    EQUW s21-stringTable
    EQUW s22-stringTable
    EQUW s23-stringTable
    EQUW s24-stringTable
    EQUW s25-stringTable
    EQUW s26-stringTable
    EQUW s27-stringTable

MAPCHAR '0','9',16
MAPCHAR 'A','Z',33
MAPCHAR 'a','z',33+26+6
MAPCHAR '(',8
MAPCHAR ')',9
MAPCHAR '+',11
MAPCHAR '!',1
MAPCHAR '-',13
MAPCHAR '/',15
        
.s1:
	EQUS "MOUNTAIN PANIC",0
.s2:
	EQUS " Press fire",0
.s3:
	EQUS "Base Camp",0
.s4:
	EQUS "Waste Land",0
.s5:
	EQUS "Cave Mouth",0
.s6:
	EQUS "In The Cave",0
.s7:
	EQUS "Catacombs",0
.s8:
	EQUS "Under The Camp",0
.s9:
	EQUS "A Strange Cave",0
.s10:
	EQUS "(c) 2013",0
.s11:
	EQUS "Retro Software",0
.s12:
	EQUS "The Gate",0
.s13:
	EQUS "Poor Lake",0
.s14:
	EQUS "Poor Gedney",0
.s15:
	EQUS "The East Tower",0
.s16:
	EQUS "The West Tower",0
.s17:
	EQUS "The Abyss",0
.s18:
    EQUS "A Final Vision",0
.s19:
	EQUS "Rope",0
.s20:
    EQUS "Rope +",0
.s21:
    EQUS "Gem",0
.s22:
    EQUS "Lamp",0
.s23:
    EQUS " Game over ",0
.s24:
    EQUS "           ",0
.s25:
    EQUS "Game complete!",0
.s26:
    EQUS "Amazing!",0
.s27:
    EQUS "Ration",0
	
MAPCHAR '0','9','0'
MAPCHAR 'A','Z','A'
MAPCHAR 'a','z','a'
MAPCHAR '(','('
MAPCHAR ')',')'
MAPCHAR '+','+'
MAPCHAR '!','!'
MAPCHAR '-','-'
MAPCHAR '/','/'
}

\ *******************************************************************
\ *  Sound frequency table
\ *******************************************************************
	
.freqlo
	FOR n, 0, 47
		EQUB LO(INT(1016 / 2^(n/48) + 0.5))
	NEXT

IF HI(freqlo)<>HI(freqlo+47)
	PRINT "Warning: freqlo table crosses page boundary"
ENDIF

.itemTable:
        EQUB _itemRope, _bitRope
        EQUB _itemTorch, _bitTorch
        EQUB _itemGemRed, _bitGemRed
        EQUB _itemGemBlue, _bitGemBlue
        EQUB 0

PRINT "* Spare after text,sound frequency and item lookup:",&D00-P%        
	
.pageD:
SKIPTO &D00
        RTI
	
INCLUDE "text.asm"

.icicleSprite:
        INCBIN "BBCITMS2.BIN"

.elderSignPositions:
        EQUB 80,237
        EQUB 88,237
        EQUB 80,245
        EQUB 88,245
	
PRINT "* Spare block (page D, after RTI and text PUT SPRITE HERE FOR ICICLE):", &E00-P%

SKIPTO &e00
.unpackedTileSprites:

SKIPTO &1200
.tileSpritesPacked:
        INCBIN "BBCTLE1.PAK"
.tileSpritesPacked2:
        INCBIN "BBCTLE2.PAK"
.tileSpritesPacked3:
        
.alienData:
.enemyData:
	INCBIN "BBCALN.BIN"
	INCBIN "BBCALN2.BIN"
.shoggothData:
    INCBIN "BBCSHOG.BIN"
        
GUARD &7fff
        
