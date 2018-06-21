
NUM_BYTES_PER_ALIEN_EXTRA = 8
NUM_BYTES_PER_ALIEN = 6
ENEMY_COLLISIONS = FALSE

;; Alien data stored thus:
;;
;; x			: Start X
;; y			: Start Y
;; flags		: 1 (Movement type)
;; , 1 Altering X, 1 Altering Y, 1 Sign bit.  %1111 animation delay.
;; animFrame & spriteTyee   : Anim frame (always set to ensure immediate animation) + sprite type (0 snowball,1 penguin,2 elder)
;; counter		: Current counter
;; max counter	: Max counter before sign bit reverses.
        
MACRO DEFENEMY enemyType,startX,startY,moveType,alterX,alterY,signBit,currentCounter,maxCounter
    EQUB startX
    EQUB startY
    EQUB moveType<<7 OR alterX<<6 OR alterY<<5 OR signBit<<4 OR %0001 ; Delay always starts ready to go
    EQUB $80 OR enemyType ; 0=snowballs,1=penguin,2=elder
    EQUB currentCounter
    EQUB maxCounter
ENDMACRO        

; tc contains offset into screen data
.initialiseEnemiesForScreen:
	{
	LDY #2
	LDA (curScreenLO),Y
	
	 ; Bottom 2 bits contain # enemies (0..3)
	AND #$3
	BEQ exitNoAliens

	CMP #1
	BNE mustBeTwo
	BEQ mustOut
	
.mustBeTwo:
	LDA #2
	
.mustOut:
	STA numAliens
	STA t8

	; Initialise alien we are currently working with
	LDA #0
	STA currentAlien

	; Copy to zeropage workspaces
	LDA #LO(alien1)
	
.copyAliens:
	LDX #0

	STA t6
	STX t7 			; eh?!
	STX td

.copyLoop:
	LDY tc
	LDA (te),Y
	STA t0
	INY
	STY tc
	LDY td
	STA (t6),Y
	INC td
	INX
	CPX #NUM_BYTES_PER_ALIEN
	BNE copyLoop

	; Initialise work-bytes
	INY
	LDA #0
	STA (t6),Y
	INY
	STA (t6),Y

	; Ensure we skip the 2 work bytes
	LDA t6
	CLC
	ADC #NUM_BYTES_PER_ALIEN_EXTRA
	
	DEC t8
	BNE copyAliens
        
.exit:
	RTS
	
.exitNoAliens:
	; LDA #0 ; DCF A is already 0
	STA numAliens
	RTS
	}

.frameTable:
	EQUW enemyData
	EQUW enemyData+128
	EQUW enemyData+256
	EQUW enemyData+256+128
	EQUW enemyData+512

.updateEnemies:
	{
	LDA numAliens
	BEQ updateAliensOut
	;RTS
	
.aliensPresent:
	; Get the alien we're updating.
	LDX currentAlien

	; Get lo-byte based on that table,X
	LDA alienPointerTable,X
	STA te
	
	; Initialise high-byte of enemy pointer
	LDA #0
	STA tf

	; Do the update
	JSR updateEnemy

	; Increment enemy number for next frame
	LDX currentAlien
	INX
	CPX numAliens
	BNE moreAliensToUpdate
	LDX #0
	
.moreAliensToUpdate:
	STX currentAlien
        
.updateAliensOut:
	RTS
	}
	
.updateEnemy:
	{
	LDY #2
	LDA (te),Y
	AND #$80
	BEQ classicMovement
	JSR updateEnemyMagicMushroomStyle
	JMP updateOut
	
.classicMovement:
	JSR updateEnemyClassicStyle

.updateOut:
    LDA screenDarkFlag
    BNE doneAliens
	JSR drawEnemy
        
.doneAliens:
	RTS
	}

.updateEnemyMagicMushroomStyle:
	{
	JSR updateEnemyAnimation
	
	LDY #2
	LDA (te),Y ; get current sign bit, 0 = increasing x
	LDY #0
	AND #$10
	BEQ positive
	
.negative:
	LDA (te),Y
	SEC
	SBC #2
	STA (te),Y
	JMP doneMovement
	
.positive:
	LDA (te),Y
	CLC
	ADC #2
	STA (te),Y

	; Done movement; change direction if x==startX or x==endX
.doneMovement:
	LDY #0
	LDA (te),Y ; a=x pos
	LDY #4
	CMP (te),Y ; 
	BEQ flip   ; if a==min flip
	LDY #5
	CMP (te),Y ; if a==max flip
	BEQ flip

	; Otherwise, been a while since we flipped, so maybe flip
.notAtLimits:
	LDY #7
	LDA (te),Y
	CLC
	ADC #1 ; frames since change++
	CMP #10 ; if (framesSinceChange==framesToChange)
	BEQ changeDirection
	STA (te),Y
	RTS
	
.changeDirection:
	; Re-init counter
	LDA #0
	STA (te),Y
	LDA #16*2

	; Flip on rnd(3)==0
	LDA &FE44
	AND #%11
	BEQ flip
	RTS

	; Flip sign bit
.flip:
	LDY #2
	LDA (te),Y
	EOR #%00010000
	STA (te),Y
	RTS
	}

.updateEnemyAnimation:
	{
	; decrement anim delay first
	LDY #2
	LDA (te),Y
	TAX
	AND #&f0
	STA animWorkZP ; save flags
	TXA
	AND #&0f
	SEC
	SBC #1
	TAX
	ORA animWorkZP
	STA (te),Y

	CPX #0
	BNE animDone

	; re-init anim delay
	LDA (te),Y
	ORA #&08
	STA (te),Y

	; See which type of alien it is, flip frame if necessary
	LDY #3
	LDA (te),Y
	AND #%11
	BEQ snowBall

	; ...else flip frame
	LDA (te),Y
	EOR #&80
	STA (te),Y

	AND #$80
	BEQ frameTwo
	
.frameOne
	LDY #3
	LDA (te),Y
	AND #%11
	CMP #1
	BEQ penguinFrameOne
	JMP elderThingFrameOne
	
.snowBall
	LDA #8
	LDY #6
	STA (te),Y
	;JMP animDone
	rts
	
.penguinFrameOne
	LDA #0
	LDY #6
	STA (te),Y
	;JMP animDone
	rts

.elderThingFrameOne
	LDA #4
	LDY #6
	STA (te),Y
	;JMP animDone
	rts

.frameTwo
	LDY #3
	LDA (te),Y
	AND #%11
	CMP #2
	BEQ elderThingFrameTwo

.penguinFrameTwo
	LDA #2
	LDY #6
	STA (te),Y
	;JMP animDone
	rts
	
.elderThingFrameTwo
	LDA #6
	LDY #6
	STA (te),Y
	
.animDone:
	RTS
	}
	
.updateEnemyClassicStyle
	{
	JSR updateEnemyAnimation
	
	; Update alien position
	LDY #2
	LDA (te),Y
	TAX 			; new
	AND #&10
	BNE skipper
	TXA
	LDY #0
	AND #&20		; check for y delta
	BEQ doX
	INY			; Instead of LDY #1, saves a byte
.doX
	LDA (te),Y
	CLC
	ADC #2
	STA (te),Y		; alien.x += 2
	JMP pop
	
.skipper
	TXA
	LDY #0
	AND #&20
	BEQ doX2
	INY			; Instead of LDY #1, saves a byte
.doX2
	LDA (te),Y		; else..
	SEC
	SBC #2
	STA (te),Y		; alien.x -= 2

.pop
	LDY #4
	LDA (te),Y
	CLC
	ADC #1
	STA (te),Y		; current counter++

	STA td			; td = current counter
	LDY #5
	LDA (te),Y		; A = max counter
	CMP td
	BNE earlyOut		; if ne, quit
	
	LDA #0
	LDY #4
	STA (te),Y		; .. else set counter=0

	LDY #2
	LDA (te),Y
	EOR #&10
	STA (te),Y		; .. and flip the sign

	
.earlyOut
	RTS
	}

	; t0 - Low of sprite
	; t1 - High of sprite
.drawEnemy
	; Get offset into table
	LDY #6
	LDA (te),Y
	TAY
	TAX ; save index for snowball, all a bodge really
	LDA frameTable,Y
	STA t0
	LDA frameTable+1,Y
	STA t1
	
	LDY #0
	LDA (te),Y		; x (+0)
	STA t2
	INY
	LDA (te),Y		; y (+1)
	STA t3
	CPX #8 ; no flip on snowball
	BEQ nocarry
	INY
	LDA (te),Y 		; sign (+2)
	AND #&10
	BEQ nocarry
	CLC
	BNE done
.nocarry
	SEC
.done
	JSR plotSprite16x16
	RTS
