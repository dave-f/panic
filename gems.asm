.effectGems
{
.gemEntry:
	; First, see if we need to do anything
	LDA playerGems
	CMP #(_bitGemRed OR _bitGemBlue)
	BNE notDoneYet
    LDA #0
	STA &a56 ; patch collision
	JMP drawGems
	
.notDoneYet:
    LDA playerPosY
    CMP #192
    BNE drawGems
    LDA playerPosX
    CMP #16*5
    BCC drawGems          ; Player must be at x>80 y=192 for us to consider gem use
	LDA keyFlags
	AND #_keyFire
	BEQ checkDebounce
	STA wasPressedFlagGems
	RTS

.checkDebounce:
	LDA wasPressedFlagGems
	BEQ drawGems

.actionHit:
	LDA #0
	STA wasPressedFlagGems

	LDA playerUsingItem
	CMP #_itemGemRed
	BNE checkGemBlue
	LDA #_bitGemRed
    JMP checksDone
	
.checkGemBlue:
	CMP #_itemGemBlue
	BNE drawGems
	LDA #_bitGemBlue

.checksDone:
	TAX
	EOR #$ff
	AND playerInventory
	STA playerInventory
    TXA
	ORA playerGems
	STA playerGems

	; We have placed a gem - set player's item to rope
.placedGem:
	LDA #_itemRope
	STA playerUsingItem
	JSR drawItem

    ; And play a sound
    LDA #LO(itemUseSound)
    STA notereq
    LDA #HI(itemUseSound)
    STA notereq+1

.drawGems:
	LDA #_bitGemRed
	BIT playerGems
	BEQ nextGem

.redGem:
	LDA #&12 		; red/blue
	STA &6fd0-(8*3)+3
	STA &6fd0-(8*3)+4
	LDA #&21		; blue/red
	STA &6fd0-(8*3)+3-8
	STA &6fd0-(8*3)+4-8
	
.nextGem:
	LDA #_bitGemBlue
	BIT playerGems
	BEQ gemsOut

.blueGem:
	LDA #&38  		; cyan/blue
	STA &6fd0-(8*1)+3
	STA &6fd0-(8*1)+4
	LDA #&34		; blue/cyan
	STA &6fd0-(8*1)+3-8
	STA &6fd0-(8*1)+4-8
	
.gemsOut:
	RTS
}

PRINT "* Gems size: ", P%-effectGems
