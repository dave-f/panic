;RectRectCollision
;Input
;	Rect1	Rectangle	First Rectangle   : PLAYER
;	Rect2	Rectangle	Second Rectangle  : CURRENT ENEMY
;Output
;	True if the rectangles collide
;Method
;OutsideBottom = Rect1.Bottom < Rect2.Top
;OutsideTop = Rect1.Top > Rect2.Bottom
;OutsideLeft = Rect1.Left > Rect2.Right
;OutsideRight = Rect1.Right < Rect2.Left
;	return NOT (OutsideBottom OR OutsideTop OR OutsideLeft OR OutsideRight)

; this can be condensed thus:	

;	return NOT ( 
;		(Rect1.Bottom < Rect2.Top) OR 
;		(Rect1.Top > Rect2.Bottom) OR 
;		(Rect1.Left > Rect2.Right) OR 
;		(Rect1.Right < Rect2.Left) )

.checkPlayerColl:
{
	;
	; t0 : Rect1.Top
	; t1 : Rect1.Left
	; t2 : Rect1.Bottom
	; t3 : Rect1.Right
    CLC        
	LDA playerPosY
	STA t0
	ADC #16
	STA t2
	LDA playerPosX
	STA t1
	ADC #12
	STA t3

    LDA playerScreen
    CMP #45
    bne notShogs

.shoggothSetup:
    LDA shogState
    CMP #_shogStateDead
    BEQ noCollisions
        
    LDA shogY:STA t4
    CLC:ADC #12:STA t6
    LDA shogX:STA t5
    ADC#(16*3):STA t7
    LDX #1
    jmp collisionLoop ; once these are set up we're ok to jump straight in

.notShogs:        
	;CLC
	LDX numAliens
	BEQ noCollisions

.doCollisions:
	LDA enemyDataPtrs,X
	STA setupAlienCollision2+1
	CLC
	ADC #1
	STA setupAlienCollision+1

	;
	; t4 : Rect2.Top
	; t5 : Rect2.Left
	; t6 : Rect2.Bottom
	; t7 : Rect2.Right
.setupAlienCollision:
	LDA alien1+1
	STA t4
	ADC #16
	STA t6
        
.setupAlienCollision2:
	LDA alien1
	STA t5
	ADC #12
	STA t7
        
.collisionLoop:
	LDA t1
	CMP t7
	BCS loopEnd
	
	LDA t3 
	CMP t5 
	BCC loopEnd

	LDA t0
	CMP t6
	BCS loopEnd

	LDA t2
	CMP t4
	BCS collidedOut ; skip to end, leaving C flag set, this tells us we have collided

.loopEnd:
	;
	; Loop around for next alien
	DEX
	BNE doCollisions

.noCollisions:
	CLC
        
.collidedOut:
	RTS
}
