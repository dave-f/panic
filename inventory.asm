.updateInventory:
	{
        LDA keyFlags
        AND #_keyInventory
        BEQ checkWasPressed
        STA wasPressedFlagInventory
        RTS

.checkWasPressed:
        LDA wasPressedFlagInventory
        BNE attemptChange
        RTS

.attemptChange:
        LDA playerUsingItem
        BEQ inventoryOut ; quit if using nothing
        LDX #$0
        
.searchForBit:
        CMP itemTable,X
        BEQ itemLookup
        INX
        INX
        JMP searchForBit

.rescan:
        LDX #$fe

.itemLookup:
        INX

.innerItemLookup:
        INX
        LDA itemTable,X
        BEQ rescan; if this is zero, we've wrapped
        TAY ; Store the item in Y ready
        INX
        LDA itemTable,X
        AND playerInventory
        BNE foundItem
        JMP innerItemLookup

        ; Here we have found an item and it's in Y
.foundItem:
        STY playerUsingItem
        JSR drawItem 
       
.inventoryOut:
        LDA #0
        STA wasPressedFlagInventory
	    RTS
        
        
	}
	
PRINT "* Inventory size: ",P%-updateInventory
	
