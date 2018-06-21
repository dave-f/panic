
_itemHook		= (0*(4*8))
_itemGemRed		= (1*(4*8))
_itemRope		= (2*(4*8))
_itemHealth		= (3*(4*8))
_itemGemBlue	= (4*(4*8))
_itemTorch		= (5*(4*8))
_itemElderSign	= (6*(4*8))

_bitRope		= $01
_bitTorch		= $02
_bitGemRed      = $04
_bitGemBlue     = $08
_bitElderOne    = $80
_bitElderTwo    = $40
_bitElderThree  = $20
_bitElderFour   = $10

MACRO DEFITEM itemID,itemX,itemY,textID,tileID
    EQUB itemX
    EQUB itemY
    EQUB itemID
    EQUB textID
    EQUB tileID
ENDMACRO

.drawItemOnScreen:
    {
	; Item was here; redraw it
	; Work out x/y pos from tile #...
	; Also need to check collected flag
    LDA screenDarkFlag
    BNE out
	CLC
	LDA #LO(itemSprites)
	ADC itemID
	STA t0
	LDA #HI(itemSprites)
	ADC #0
	STA t1
	LDA itemX
	STA t2
	LDA itemY
	STA t3
	LDA #0
	STA t4
	CLC
	JSR plotSprite8x8 ; might corrupt tc?
.out:        
    RTS
    }
