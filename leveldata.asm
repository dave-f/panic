.mapData:
	; Effect flags:
	;		1 Snow
	;       2 Room is dark unless have lamp
	;		3 Colour cycling takes place
	;       4 Shoggoth

	; Screen 0 : Title page
	EQUB &00 		 ; High nibble: Tile set number | Low nibble: Index into string table
	EQUB 0			 ; Index into screen table and flip bit (7bits index + 1 flip bit)
	EQUB _effectSnow	 ; FX Flag (5) | ITEM COLLECTED BIT | [1..0] : Number aliens present   *** NEW REWORK
	EQUB 0,0,0,0		 ; Exit screens NSEW
	EQUB 0			 ; Use one of these bits to restore the item bits on a game over *** NEW REWORK : xxxxx %011 <- high nibble+1: san lose(max25), 1 bit spare, 1 bit for sanloss, 1 for item!

	; Screen 1 : Base camp
	EQUB &02 		 ; High nibble: Tile set number | Low nibble: Index into string table
	EQUB 1			 ; Index into screen table and flip bit (7bits index + 1 flip bit)
	EQUB _effectSnow ; Snow, no items
	EQUB 0,0,2,40    ; Exit screens NSEW
	EQUB 0           ; Use one of these bits to restore the item bits on a game over *** NEW REWORK

	; Screen 2 : Wasteland
	EQUB &03		 ; Index into string table
	EQUB 2			 ; Index into screen table and flip bit (7bits index + 1 flip bit)
	EQUB _effectSnow OR 0	 ; FX Flag (5)
	EQUB 0,0,3,1		 ; Exit screens NSEW
	EQUB 0		 ; Use one of these bits to restore the item bits on a game over *** NEW REWORK

	; Screen 3 : Wasteland
	EQUB &03		 ; Index into string table
	EQUB 2			 ; Index into screen table and flip bit (7bits index + 1 flip bit)
	EQUB _effectSnow OR 1	 ; FX Flag (5) 
	EQUB 0,0,4,2		 ; Exit screens NSEW
	EQUB 0			 ; Use one of these bits to restore the item bits on a game over *** NEW REWORK

	; Screen 4 : Wasteland with ladder
	EQUB &03
	EQUB 3
	EQUB _effectSnow OR 0
	EQUB 0,0,5,3
	EQUB &00

	; Screen 5 : Cave mouth
	EQUB 4			 ; Index into string table
	EQUB 4			 ; Index into screen table and flip bit (7bits index + 1 flip bit)
	EQUB _effectSnow OR 0	 ; FX Flag (5) 
	EQUB 0,12,6,4		 ; Exit screens NSEW
	EQUB 0			 ; Spare byte

	; Screen 6 : Right of cave mouth
	EQUB &03
	EQUB 5
	EQUB _effectSnow OR 0
	EQUB 0,0,7,5
	EQUB 0

	; Screen 7 : Right of cave mouth w/ ladder
	EQUB &03
	EQUB 6
	EQUB _effectSnow OR 0
	EQUB 8,0,9,6
	EQUB 0

	; Screen 8 : Above 6
	EQUB &03
	EQUB 7
	EQUB _effectSnow OR 0
	EQUB 0,7,11,10
	EQUB 0

	; Screen 9 : The clearing
	EQUB &03
	EQUB 8
	EQUB _effectSnow OR 0
	EQUB 0,15,22,7
	EQUB 0

	; Screen 10 : Cave to left
	EQUB 8
	EQUB 9
	EQUB 0 OR SCREEN_FLAGS_ITEM_PRESENT OR 1
	EQUB 0,0,8,0
	EQUB $01 		; item

	; Screen 11 : Cave to right
	EQUB 8
	EQUB 10
	EQUB 0 OR SCREEN_FLAGS_ITEM_PRESENT OR 2
	EQUB 0,0,0,8
	EQUB $01 ; item

	; Screen 12 : In the cave
	EQUB &25
	EQUB 11
	EQUB _effectSnow OR 1
	EQUB 0,20,13,16
	EQUB %110 ; sanity + no item

	; Screen 13 : Right of "In the cave"
	EQUB &25
	EQUB 12
	EQUB 1
	EQUB 0,0,15,12
	EQUB 0

	; Screen 14 : east tower entrance
	EQUB &20 OR 14
	EQUB 19
	EQUB _effectSnow OR 1
	EQUB 0,0,23,15
	EQUB 0

	; Screen 15 : Poor Lake
	EQUB &20 OR 12
	EQUB 13
	EQUB _effectSnow OR SCREEN_FLAGS_ITEM_PRESENT
	EQUB 9,0,14,13
	EQUB 1

	; Screen 16 : Left of "In the cave"
	EQUB &25
	EQUB 14
	EQUB 0 OR 2
	EQUB 0,0,12,17
	EQUB 0

	; Screen 17 : Left again
	EQUB &25
	EQUB 15
	EQUB 1 OR SCREEN_FLAGS_ITEM_PRESENT
	EQUB 0,0,16,18
	EQUB 1

	; Screen 18 : Left yet again
	EQUB &25
	EQUB 14
	EQUB 0 OR 2
	EQUB 0,0,17,19
	EQUB 0

	; Screen 19 : Under base camp
	EQUB &20 OR 7
	EQUB 16
	EQUB 0 OR 1
	EQUB 0,0,18,25
	EQUB 0

	; Screen 20 : 2 Down from cave mouth
	EQUB &25
	EQUB 17
	EQUB 0 OR SCREEN_FLAGS_ITEM_PRESENT
	EQUB 12,0,0,21
	EQUB 1

	; Screen 21 : Left of 20
	EQUB &25
	EQUB 18
	EQUB 0 OR SCREEN_FLAGS_ITEM_PRESENT
	EQUB 0,0,20,0
	EQUB $01

	; Screen 22 : Above east tower entrance
	EQUB &20 OR 14
	EQUB 20
	EQUB _effectSnow OR 0
	EQUB 46,14,0,9
	EQUB 0

	; Screen 23 : East tower base
	EQUB &20 OR 14
	EQUB 21
	EQUB 0 OR 1
	EQUB 27,28,29,14
	EQUB 0
	
	; Screen 24 : Poor Gedney
	EQUB &00 OR 13
	EQUB 22
	EQUB _effectSnow OR 1 OR SCREEN_FLAGS_ITEM_PRESENT
	EQUB 0,0,0,48
	EQUB %111 ; sanity + item

	; Screen 25 : Left of 'under the camp'
	EQUB &20 OR 7
	EQUB 23
	EQUB 0 OR 2
	EQUB 0,31,19,0
	EQUB 0

	; Screen 26 : Top of east tower
	EQUB &20 OR 14
	EQUB 24
	EQUB _effectSnow OR 1 OR SCREEN_FLAGS_ITEM_PRESENT
	EQUB 0,27,0,46
	EQUB 1

	; Screen 27 : East tower midrif
	EQUB &20 OR 14
	EQUB 25
	EQUB 0
	EQUB 26,23,0,0
	EQUB 0

	; Screen 28 : Gate to hell
	EQUB &20 OR 11
	EQUB 26
	EQUB _effectGems
	EQUB 23,0,41,0
	EQUB 0

	; Screen 29 : East of east Tower
	EQUB &20 OR 14
	EQUB 27
	EQUB _effectSnow OR 0
	EQUB 0,0,30,23
	EQUB 0

	; Screen 30 : Wasteland east
	EQUB &0 OR 3
	EQUB 2
	EQUB _effectSnow OR 0
	EQUB 0,0,48,29
	EQUB 0

	; Screen 31 : Bottom left of under camp quadrant
	EQUB &20 OR 7
	EQUB 28
	EQUB _effectPaletteChange2 OR SCREEN_FLAGS_ITEM_PRESENT OR 2
	EQUB 25,34,32,0
	EQUB %111 ; sanity+item

	; Screen 32 : Bottom right of under camp quadrant
	EQUB &20 OR 7
	EQUB 29
	EQUB _effectPaletteChange2 OR 2 OR SCREEN_FLAGS_ITEM_PRESENT
	EQUB 0,33,0,31
	EQUB 1 ; item

	; Screen 33 : Catacombs one
	EQUB &20 OR 6
	EQUB 30
	EQUB _effectPaletteChange2 OR _effectDark OR 1
	EQUB 32,0,0,34
	EQUB %110 ; sanity

	; Screen 34 : Catacombs two
	EQUB &20 OR 6
	EQUB 31
	EQUB _effectPaletteChange2 OR _effectDark OR 1 OR SCREEN_FLAGS_ITEM_PRESENT
	EQUB 0,47,33,35
	EQUB $01

	; Screen 35 : West tower base
	EQUB &20 OR 15
	EQUB 32
	EQUB 0 OR 2
	EQUB 36,0,34,0
	EQUB 0

	; Screen 36 : West tower middle #1
	EQUB &20 OR 15
	EQUB 33
	EQUB 0
	EQUB 37,35,0,0
	EQUB 0

	; Screen 37 : West tower middle #2
	EQUB &20 OR 15
	EQUB 33
	EQUB 0 OR 1
	EQUB 38,36,0,0
	EQUB 0

	; Screen 38 : West tower top
	EQUB $20 OR 15
	EQUB 34
	EQUB _effectSnow OR SCREEN_FLAGS_ITEM_PRESENT
	EQUB 0,37,39,0
	EQUB 1 ; item

	; Screen 39 : Out of west tower (left of base camp)
	EQUB $20 OR $03
	EQUB 35
	EQUB _effectSnow
	EQUB 0,0,40,38 ; Exit back to base camp
	EQUB 0

	; Screen 40 : Wasteland to base camp
	EQUB $00 OR $03
	EQUB 2
	EQUB _effectSnow
	EQUB 0,0,1,39
	EQUB 0

	; Screen 41 : Hell #1
	EQUB $20 OR 16
	EQUB 36
	EQUB _effectPaletteChange OR 0
	EQUB 0,44,42,28
	EQUB $0

	; Screen 42 : Hell #2
	EQUB $20 OR 16
	EQUB 37
	EQUB _effectPaletteChange OR SCREEN_FLAGS_ITEM_PRESENT OR 1
	EQUB 0,0,0,41
	EQUB $01

	; Screen 43 : Shoggoth #1
	EQUB $20 OR 16
	EQUB 38
	EQUB _effectPaletteChange OR 1
	EQUB 0,0,44,0
	EQUB $00
	
	; Screen 44 : Shoggoth #2 (Drop in here from hell #1)
	EQUB $20 OR 16
	EQUB 39
	EQUB _effectPaletteChange OR 0
	EQUB 0,0,45,43
	EQUB %110 ; sanity
	
	; Screen 45 : Shoggoth #3 (END GAME)
	EQUB $20 OR 17
	EQUB 40
	EQUB _effectPaletteChange OR 0
	EQUB 0,0,49,44
	EQUB $00

IF FALSE        
	; Screen 46 : Secret room #1 (REMOVED)
	EQUB $20 OR 8
	EQUB 41
	EQUB _effectPaletteChange OR 0
	EQUB 15,0,43,0
	EQUB $00
ENDIF        
	
	; Screen 47 (Now 46) : Just left of east tower top
	EQUB $20 OR 14
	EQUB 42
	EQUB _effectSnow
	EQUB 0,22,26,0
	EQUB $00

IF FALSE        
	; Screen 48 : Secret room #2 (REMOVED)
	EQUB $20 OR 8
	EQUB 43
	EQUB _effectPaletteChange2 OR 0
	EQUB 0,0,0,33
	EQUB 0
ENDIF        

	; Screen 49 (Now 47): Catacombs extra #1
	EQUB $20 OR 6
	EQUB 44
	EQUB _effectPaletteChange2 OR _effectDark
	EQUB 34,0,0,0
	EQUB 0

	; Screen 50 (Now 48) : Wasteland to Gedney #2
	EQUB $00 OR 3
	EQUB 2
	EQUB _effectSnow OR 0
	EQUB 0,0,24,30
	EQUB 0

    ; Screen 51 (Now 49) : Congratulations
    EQUB $20 OR 0
    EQUB 45
    EQUB _effectSnow OR 0
    EQUB 0,0,0,0
    EQUB 0
	
.screenTable:
	EQUW screen1Data ; title, uses same screen = 0
	EQUW screen1Data
	EQUW screen2Data
	EQUW screen3Data
	EQUW screen4Data
	EQUW screen5Data
	EQUW screen6Data
	EQUW screen7Data
	EQUW screen8Data
	EQUW screen9Data
	EQUW screen10Data
	EQUW screen11Data
	EQUW screen12Data
	EQUW screen13Data
	EQUW screen14Data
	EQUW screen15Data
	EQUW screen16Data
	EQUW screen17Data
	EQUW screen18Data
	EQUW screen19Data
	EQUW screen20Data
	EQUW screen21Data
	EQUW screen22Data
	EQUW screen23Data
	EQUW screen24Data
	EQUW screen25Data
	EQUW screen26Data
	EQUW screen27Data
	EQUW screen28Data
	EQUW screen29Data
	EQUW screen30Data
	EQUW screen31Data
	EQUW screen32Data
	EQUW screen33Data
	EQUW screen34Data
	EQUW screen35Data
	EQUW screen36Data
	EQUW screen37Data
	EQUW screen38Data
	EQUW screen39Data
	EQUW screen40Data
	EQUW 0 ;screen41Data
	EQUW screen42Data
	EQUW 0 ;screen43Data
	EQUW screen44Data
    EQUW congratulationsScreen ; currently 45

IF FALSE	
	; Title screen
.titleScreenData
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB &03,1,1 OR _bitFlipped
	EQUB &07,10,3,3 OR _bitFlipped
	EQUB &FF,$f0,2
ENDIF

	; Base camp
.screen1Data
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB &60, 1, _bitFlipped OR 1
	EQUB &62, 3, _bitFlipped OR 3,7
    EQUB $FF, $F0, _bitCollidable OR 2 ; New tile packing

	; Wasteland
.screen2Data
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB &FF,$f0,_bitCollidable OR 2

	; Alien data 1 here
	EQUB 16*5		; x
	EQUB 16*12		; y
	EQUB %00110001		; Flags ( %1111, movetype, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB $80		; anim frame flag ($80) and sprite id (0=snowball,1=penguin,2=elder)
	EQUB 0			; current counter
	EQUB 24			; max counter

	; Wasteland 3rd screen - snow and ladder
.screen3Data
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB &1f,_bitCollidable OR 2,_bitClimbable OR 2,$f0,_bitCollidable OR 2
	EQUB &1f,5,_bitClimbable OR 4,$f0,5
	EQUB &1f,5,_bitClimbable OR 4,5,6,5
	EQUB &1f,5,_bitClimbable OR 4,$f0,5
	EQUB &1f,5,_bitClimbable OR 4,5,5,6
	EQUB &1f,5,_bitClimbable OR 4,$f0,5
	EQUB &1f,5,_bitClimbable OR 4,$f0,5
	EQUB &1f,5,_bitClimbable OR 4,$f0,5
	EQUB &FF,$f0,_bitCollidable OR 2


	; Cave mouth
.screen4Data
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB &FF,_bitCollidable OR 9,_bitCollidable OR 9 OR _bitFlipped, $f0,_bitCollidable OR 2 ; new tile packing
	EQUB &3f,$f0,5
	EQUB &3f,$f0,5
	EQUB &3f,$f3,_bitHookable OR 9,$f3,_bitHookable OR 5
	EQUB &07,_bitHookable OR 9,5,5
	EQUB &03,9 OR _bitHookable, 5
	EQUB &01,_bitCollidable OR 6
	EQUB &09,2 OR _bitCollidable,_bitCollidable OR 5
	EQUB &F9,$f4,_bitCollidable OR 2,_bitCollidable OR 5,_bitCollidable OR 5

	; Right of cave mouth
.screen5Data
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB &FF,$f0,2 OR _bitCollidable
	EQUB &FF,$f0,5
	EQUB &FF,$f0,5
	EQUB &FF,5,6,$f6,5
	EQUB &FF,$f0,5
	EQUB &FF,$f4,5,6,$f3,5
	EQUB &FF,$f0,5
	EQUB &FF,$f0,5
	EQUB &FF,$f0,5

	; Right of cave mouth, with ladder up etc
.screen6Data
	EQUB &10,_bitClimbable OR 0
	EQUB &10,_bitClimbable OR 0
	EQUB &10,_bitClimbable OR 0
	EQUB &FF,$f5,_bitCollidable OR 2,_bitClimbable OR _bitCollidable OR 2,_bitCollidable OR 2,_bitCollidable OR 2
	EQUB &FF,$f5,5,_bitClimbable OR 4,5,5
	EQUB &FF,$f5,5,_bitClimbable OR 4,5,5
	EQUB &FF,5,6,$f3,5,_bitClimbable OR 4,5,5
	EQUB &FF,$f3,5,6,5,_bitClimbable OR 4,5,5
	EQUB &FF,$f5,5,_bitClimbable OR 4,5,5
	EQUB &FF,$f4,5,_bitCollidable OR 5,_bitClimbable OR 4,5,5
	EQUB &FF,$f5,5,$f0,_bitCollidable OR 2
	EQUB &FF,$f0,5

	; Above ladder
.screen7Data
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB &FF,$f3,_bitCollidable OR 9,_bitCollidable OR _bitClimbable OR 0,$f0,_bitCollidable OR 9

	; Right of screen 6 : clearing
.screen8Data
	EQUB &00
	EQUB &18,_bitHookable OR 9,_bitHookable OR 9
	EQUB &0
	EQUB &80,_bitHookable OR _bitCollidable OR 9
	EQUB 0
	EQUB 7,_bitHookable OR _bitCollidable OR 9,_bitClimbable OR _bitCollidable OR 0,_bitHookable OR _bitCollidable OR 9
	EQUB 2,_bitClimbable OR 0
	EQUB 2,_bitClimbable OR 0
	EQUB 2,_bitClimbable OR 0
	EQUB &12,_bitCollidable OR 2,_bitClimbable OR 0
	EQUB &f2,$f3,_bitCollidable OR 2, _bitCollidable OR 5, _bitClimbable OR 0
	EQUB &f2,6,$f3,5,_bitClimbable OR 0

	; Outside - cave left (contains food and snowball)
.screen9Data
	EQUB &ff,_bitCollidable OR 6,$f0,_bitHookable OR 9
	EQUB &80,_bitCollidable OR 5
	EQUB &80,_bitCollidable OR 5
	EQUB &80,_bitCollidable OR 6
	EQUB &80,_bitCollidable OR 6 OR _bitFlipped
	EQUB &80,_bitCollidable OR 5
	EQUB &f8,_bitCollidable OR _bitHookable OR 5,$f0,_bitCollidable OR _bitHookable OR 9
	EQUB &80,_bitCollidable OR 5
	EQUB &80,_bitCollidable OR 6
	EQUB &80,_bitCollidable OR 5
	EQUB &c0,_bitCollidable OR 5,_bitCollidable OR 2
	EQUB &FF,_bitCollidable OR 5,_bitCollidable OR 6,$f0,_bitCollidable OR 2

	; Item one
	EQUB (16*1)+4
	EQUB (16*7)+8
	EQUB _itemElderSign OR 8 ; not sure about this placement.
	EQUB 0,0

	; Alien one
	EQUB 32			; x
	EQUB 16*12		; y
	EQUB &81		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &80		; anim frame + sprite type
	EQUB 32			; min x
	EQUB 16*7		; max x

	; Outside - cave right (contains rope)
.screen10Data
	EQUB &ff,$f7,_bitHookable OR 9,_bitHookable OR 6
	EQUB &01,_bitCollidable OR 6
	EQUB &01,_bitCollidable OR 5
	EQUB &7f,_bitHookable OR _bitCollidable OR 9,_bitHookable OR _bitCollidable OR 9,_bitClimbable OR 0,$f3,_bitCollidable OR _bitHookable OR 9,_bitCollidable OR 5
	EQUB &11,_bitClimbable OR 0,_bitCollidable OR 5
	EQUB &11,_bitClimbable OR 0,_bitCollidable OR 6
	EQUB &11,_bitClimbable OR 0,_bitCollidable OR 5
	EQUB &3f,$f3,_bitHookable OR _bitCollidable OR 9,_bitClimbable OR 0,_bitHookable OR _bitCollidable OR 9,_bitCollidable OR 5
	EQUB &05,_bitClimbable OR 0,_bitCollidable OR 5
	EQUB &05,_bitClimbable OR 0,_bitCollidable OR 5
	EQUB &07,_bitClimbable OR 0,_bitCollidable OR 2, _bitCollidable OR _bitFlipped OR 6 
	EQUB &FF,$f6,_bitCollidable OR 2,_bitCollidable OR 5,_bitCollidable OR 5

    DEFITEM _itemRope,16*6+4,(16*4)+8,18,5+8
        
	; Alien data 1 here
	EQUB 32			; org x
	EQUB 16*4		; org y
	EQUB %11000001	; Flags ( %1111, move type, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB %10000000	; anim frame flag ($80) and sprite id (0=snowball,1=penguin,2=elder)
	EQUB 16			; current counter
	EQUB 16*5		; max counter

	EQUB 16*2		; x
	EQUB 16*12		; y
	EQUB %00110001		; Flags ( %1111, movetype, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB $80		; anim frame flag ($80) and sprite id (0=snowball,1=penguin,2=elder)
	EQUB 0			; current counter
	EQUB 16			; max counter
        
	; In the cave
.screen11Data
	EQUB &F1,$f0,_bitHookable OR 9
	EQUB &00
	EQUB &00
	EQUB &00
	EQUB &00
	EQUB &bf,1 OR _bitCollidable,_bitClimbable OR 3,_bitCollidable OR _bitFlipped OR 1,$f3,_bitCollidable OR 11, _bitCollidable OR 1
	EQUB &bf,1 OR _bitCollidable, _bitClimbable OR 3,$f0,_bitCollidable OR 1
	EQUB &bf,9,_bitClimbable OR 3,$f0,_bitCollidable OR 1
	EQUB &3f,_bitClimbable OR 3,$f0,_bitHookable OR 9
	EQUB &20,_bitClimbable OR 3
	EQUB &20,_bitClimbable OR 3
	EQUB &FF,$f6,_bitCollidable OR 1,_bitCollidable OR _bitClimbable OR 3,_bitCollidable OR 1

	; Alien data here
	EQUB 48			; x
	EQUB 16*12		; y
	EQUB %11000001		; flags
	EQUB $81		; anim frame+sprite type.  here 1 for a penguin.
	EQUB 48			; min x
	EQUB 16*7		; max x

	; Right of in the cave
.screen12Data
	EQUB &Ff,$f0,_bitHookable OR 9
	EQUB &00
	EQUB &00
	EQUB &00
	EQUB &00
	EQUB &e0,_bitCollidable OR 1,_bitCollidable OR 1,_bitClimbable OR 3
	EQUB &e0,_bitCollidable OR 1,_bitCollidable OR 1,_bitClimbable OR 3
	EQUB &e0,_bitFlipped OR 9, _bitCollidable OR 1, _bitClimbable OR 3
	EQUB &7f,_bitHookable OR _bitFlipped OR 9,$f2,_bitCollidable OR 1,_bitClimbable OR 3,$f0,_bitCollidable OR 1
	EQUB &3F,_bitHookable OR _bitFlipped OR 9, _bitHookable OR _bitFlipped OR 9,_bitClimbable OR 3,$f0,_bitHookable OR 9
	EQUB &08,3 OR _bitClimbable
	EQUB &FF,$f0,_bitCollidable OR 1
	
	; Alien data 1 here
	EQUB 16*3		; x
	EQUB 16*9		; y
	EQUB %01000001	; flags ( %1111, move type, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB $81		; anim frame + sprite type
	EQUB 0		; min x
	EQUB 30		; max x
	
	; Right(2) of in the cave : contains first note : "Poor Lake"
.screen13Data
	EQUB &F2,$f4,_bitHookable OR 9,_bitClimbable OR 3
	EQUB &02,_bitClimbable OR 3
	EQUB &02,_bitClimbable OR 3
	EQUB &0f,$f0,_bitCollidable OR 11;,_bitCollidable OR 11,_bitCollidable OR 11,_bitCollidable OR 11
	EQUB &0f,_bitHookable OR _bitCollidable OR 9, _bitHookable OR _bitCollidable OR 9, _bitCollidable OR 1, _bitCollidable OR 1
	EQUB &03,_bitCollidable OR 1, _bitCollidable OR 1
	EQUB &03,_bitCollidable OR 1, _bitCollidable OR 1
	EQUB &03,_bitCollidable OR 1, _bitCollidable OR 1
	EQUB &Fb,_bitCollidable OR 1,_bitClimbable OR 3,_bitCollidable OR 1,_bitCollidable OR 1, _bitClimbable OR 3,8 OR _bitFlipped,_bitCollidable OR 1
	EQUB &F9,9 OR _bitHookable, 3 OR _bitClimbable,_bitCollidable OR 1,8 OR _bitFlipped,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &6b,_bitClimbable OR 3,_bitCollidable OR 1,_bitClimbable OR 3,10,_bitCollidable OR 1
	EQUB &FF,$f0,_bitCollidable OR 1
	
    DEFITEM _itemHealth,16*5+4,(16*12)+8,26,(12*6)+4

	; Left of in the cave; this is this repeated twice
.screen14Data
	EQUB &ff,$f0,_bitHookable OR 9
	EQUB &00
	EQUB &00
	EQUB &00
	EQUB &00
	EQUB &ff,$f3,_bitCollidable OR 8 OR _bitFlipped,_bitCollidable OR 1,_bitCollidable OR 1,$f0,_bitCollidable OR _bitFlipped OR 8
	EQUB &18,_bitCollidable OR 1,_bitCollidable OR 1
	EQUB &18,_bitCollidable OR 1,_bitCollidable OR 1
	EQUB &18,_bitHookable OR 9,_bitHookable OR 9
	EQUB &00
	EQUB &00
	EQUB &FF,$f0,_bitCollidable OR 1

	; 2 penguins - one on top, one on bottom
	EQUB 16*3		; org x
	EQUB 16*12		; org y
	EQUB %11000001		; Flags ( %1111, move type, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB $81		; anim frame + sprite type
	EQUB 0			; min x
	EQUB 16*7		; max x

	EQUB 16*4		; org x
	EQUB 16*6		; org y
	EQUB %11010001		; Flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB $81		; anim frame + sprite type
	EQUB 0			; min x
	EQUB 16*7		; max x

	; Left of in the cave (2)
.screen15Data
	EQUB &ff,$f0,_bitHookable OR 9
	EQUB &0
	EQUB &0
	EQUB &00
	EQUB &10, _bitCollidable OR 0
	EQUB &9f, _bitCollidable OR _bitFlipped OR 8,_bitHookable OR 2,_bitCollidable OR 1,$f0,_bitCollidable OR 8 OR _bitFlipped
	EQUB &18, 2,0
	EQUB &18, 2,2
	EQUB &18, 2,2
	EQUB &18, 2,2
	EQUB &18, _bitFlipped OR 0, _bitFlipped OR 0
	EQUB &FF,$f0, _bitCollidable OR 1

	EQUB (16*5)-8
	EQUB (16*7)-8
	EQUB _itemGemRed
	EQUB 20 ; text id
	EQUB 4+(8*3) ; tile id

	; Alien data
	EQUB 16+8		; x
	EQUB 16*12		; y
	EQUB %00110001		; Flags (movetype,altering x,altering y,sign bit) and anim delay in bottom nibble
	EQUB &80		; anim frame
	EQUB 0			; current counter
	EQUB 24	

	; Under base camp - first contact with elder things
.screen16Data
	EQUB &ff,$f0,_bitHookable OR 9
	EQUB &00
	EQUB &00
	EQUB &0c,_bitCollidable OR 8,_bitCollidable OR 8
	EQUB &1c,_bitCollidable OR 8,_bitHookable OR 9,9 OR _bitHookable
	EQUB &93,_bitCollidable OR 1, _bitHookable OR 9,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &83,9,_bitClimbable OR 3,1 OR _bitCollidable
	EQUB &07,$f0,_bitCollidable OR 1
	EQUB &17,_bitCollidable OR 0,_bitCollidable OR 0,_bitHookable OR 9,_bitCollidable OR 0
	EQUB &55,_bitCollidable OR 0,$f0,2
	EQUB &55,$f0,_bitFlipped OR 0
	EQUB &FF,$f0,_bitCollidable OR 1

	; Alien data : Elder thing on platform?
	EQUB 0		; x
	EQUB 16*9		; y
	EQUB &01		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &82		; anim frame + sprite type
	EQUB 0			; current counter
	EQUB 32			; max counter

	; 2 down from cave mouth
.screen17Data
	EQUB &ff,$f6,_bitHookable OR 9,_bitClimbable OR 3,1
	EQUB &03,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &03,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &03,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &7f,_bitCollidable OR _bitClimbable OR 3,$f4,_bitCollidable OR 8 OR _bitFlipped,$f2,1 OR _bitCollidable
	EQUB &43,_bitClimbable OR 3,_bitFlipped OR _bitHookable OR 9,_bitCollidable OR 1
	EQUB &41,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &41,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &41,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &41,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &43,_bitClimbable OR 3,_bitCollidable OR 8,_bitCollidable OR 1
	EQUB &FF,$f0,_bitCollidable OR 1

    DEFITEM _itemHealth,16*5+4,(16*12)+8,26,(12*6)+4

	; Left of 2 down from cave mouth
.screen18Data
	EQUB &ff,$f3,_bitCollidable OR 1,$f0,_bitHookable OR 9
	EQUB &e0,_bitCollidable OR 1,1,9
	EQUB &c0,_bitCollidable OR 1,9
	EQUB &80,_bitCollidable OR 1
	EQUB &c0,_bitCollidable OR 1,_bitCollidable OR 1
	EQUB &c0,_bitCollidable OR 1,_bitHookable OR _bitCollidable OR 9
	EQUB &80,_bitCollidable OR 1
	EQUB &80,_bitCollidable OR 1
	EQUB &80,_bitCollidable OR 1
	EQUB &80,_bitCollidable OR 1
	EQUB &c0,_bitCollidable OR 1,_bitCollidable OR 8
	EQUB &FF,$f0,_bitCollidable OR 1

	; Item - elder sign piece
	EQUB 18 		; x
	EQUB 80+6		; y
	EQUB _itemElderSign OR 4
	EQUB 0,0

	; Right of 'poor lake', entrance to east tower
.screen19Data
	EQUB &1,_bitCollidable OR 1
	EQUB &1,_bitCollidable OR 1
	EQUB &1,_bitCollidable OR 1
	EQUB &c1,_bitCollidable OR 11,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &c1,_bitCollidable OR 1,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &c1,_bitCollidable OR 1,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &c1,_bitCollidable OR 1,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &c3,_bitCollidable OR 1,_bitClimbable OR 3,_bitCollidable OR 11, _bitCollidable OR 1
	EQUB &c3,_bitCollidable OR 1,_bitClimbable OR 3,$f0,_bitHookable OR _bitCollidable OR 9
	EQUB &c0,_bitCollidable OR 1,_bitClimbable OR 3
	EQUB &c0,_bitCollidable OR 1,_bitClimbable OR 3
	EQUB &FF,_bitCollidable OR 1,$f0,_bitCollidable OR 11

	; Alien data here
	EQUB 16*5		; org x
	EQUB 16*12		; org y
	EQUB %00110001          ; flags (movetype, altering x, altering y, sign bit; anim delay)
	EQUB &80		; anim frame + sprite type
	EQUB 0		; cur counter
	EQUB 16		; max  counter

	; Above east tower entrance
.screen20Data
	EQUB &03,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &07,_bitHookable OR _bitCollidable OR 9,_bitHookable OR _bitCollidable OR 9,_bitCollidable OR 1
	EQUB &21,_bitHookable OR 9,_bitCollidable OR 1
	EQUB &81,_bitHookable OR 9,_bitCollidable OR 1
	EQUB &01,_bitCollidable OR 1
	EQUB &c1,_bitCollidable OR 9,_bitCollidable OR 9 OR _bitFlipped,_bitCollidable OR 1
	EQUB &29,_bitCollidable OR 9,_bitCollidable OR 9,_bitCollidable OR 1
	EQUB &01,_bitCollidable OR 1
	EQUB &01,_bitCollidable OR 1
	EQUB &01,_bitCollidable OR 1
	EQUB &01,_bitCollidable OR 1
	EQUB &01,_bitCollidable OR 1

	; East tower base
.screen21Data
	EQUB &F5,_bitCollidable OR 1,$f3,2,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &f5,_bitCollidable OR 1,$f3,0 OR _bitFlipped,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &f7,_bitCollidable OR 1,$f5,1 OR _bitCollidable,_bitCollidable OR 1
	EQUB &f7,_bitCollidable OR 1,$f5,8 OR _bitFlipped OR _bitHookable,_bitCollidable OR 1
	EQUB &81,_bitCollidable OR 1,_bitCollidable OR 1
	EQUB &81,_bitCollidable OR 1,_bitCollidable OR 1
	EQUB &81,_bitCollidable OR 1,_bitCollidable OR 1
	EQUB %10111101,1,$f4,_bitHookable OR _bitCollidable OR 9, 1
	EQUB &81,_bitHookable OR 9,_bitHookable OR 9
	EQUB &00
	EQUB &00
	EQUB &e7,$f3,_bitCollidable OR 1,_bitClimbable OR 3,_bitCollidable OR 1,_bitCollidable OR 1

	EQUB 16*3		; x
	EQUB 16*6		; y
	EQUB %01000001	; Flags ( %1111, movetype, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &82		; anim frame + sprite type
	EQUB 0			; current counter
	EQUB 18
	
	; Poor Gedney : Contains torch
.screen22Data
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB 0
	EQUB $08,10
	EQUB $38,$f0,_bitHookable OR _bitCollidable OR 9
	EQUB &03, 1, _bitFlipped OR 1
	EQUB &03, 3, _bitFlipped OR 3
	EQUB &FF,$f0,_bitCollidable OR 2

	; Item - torch
	EQUB 18+(16*2)
	EQUB 80+6+(16*4)
	EQUB _itemTorch
	EQUB 21
	EQUB 3+(8*6)

	; alien
	EQUB 32			; org x
	EQUB 16*12		; org y
	EQUB %11000001	; Flags ( %1111, movetype, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB $80		; anim frame
	EQUB 16			; min X
	EQUB 16*5		; max X
	
	; Left of 'under the camp'
.screen23Data
	EQUB &ff,1,$f0,_bitHookable OR 9
	EQUB &80,_bitCollidable OR 1
	EQUB &80,_bitCollidable OR 1
	EQUB &80,_bitCollidable OR 1
	EQUB &8C,_bitCollidable OR 1,9 OR _bitHookable OR _bitCollidable, 9 OR _bitHookable OR _bitCollidable
	EQUB &c3,_bitCollidable OR 1,$f0,0 OR _bitCollidable
	EQUB &c3,_bitCollidable OR 1,2 OR _bitHookable,2,2
	EQUB &c3,_bitCollidable OR 1,2 OR _bitHookable,2,2
	EQUB &c3,_bitCollidable OR 1,0 OR _bitFlipped,2,2
	EQUB &e3,_bitCollidable OR 1,_bitCollidable OR 1,_bitCollidable OR 11,2,2 
	EQUB &e3,$f3,_bitCollidable OR 1,0 OR _bitFlipped,0 OR _bitFlipped
	EQUB &fF,$f4,_bitCollidable OR 1, _bitClimbable OR 3,$f0,_bitCollidable OR 1

	; Item data here
	; EQUB 16*4		; x
	; EQUB (16*5)+8		; y
	; EQUB 3*(4*8)		; item id

	; Alien data : Elder thing on platform?
	EQUB 32			; x
	EQUB 16*9		; y
	EQUB &01		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &82		; anim frame + sprite type
	EQUB 0			; current counter
	EQUB 24

	EQUB 64+16		; x
	EQUB 16*8		; y
	EQUB &11		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &82		; anim frame + sprite type
	EQUB 0			; current counter
	EQUB 24
	
	; East Tower top
.screen24Data
	EQUB &0
	EQUB 0
	EQUB &81,_bitCollidable OR 11,_bitCollidable OR 11
	EQUB &ff,_bitCollidable OR 1,_bitCollidable OR 11,_bitCollidable OR 11,_bitClimbable OR 3,$f3,_bitCollidable OR 11,_bitCollidable OR 1
	EQUB &ff,$f3,1,_bitClimbable OR 3,$f0,1
	EQUB &ff,9 OR _bitFlipped,1,1,_bitClimbable OR 3,$f3,1,9
	EQUB &6e,$f0,1
	EQUB &6e,1,_bitHookable OR _bitFlipped OR 9,_bitHookable OR 9,_bitFlipped OR _bitHookable OR 9,1
	EQUB &42,_bitCollidable OR 1,_bitCollidable OR 1
	EQUB &c3,_bitCollidable OR 11,_bitCollidable OR 1, _bitCollidable OR 1,_bitCollidable OR 11
	EQUB &c3,$f0,_bitCollidable OR 1
	EQUB &ff,$f5,1 OR _bitCollidable, 3 OR _bitClimbable,1,1

	EQUB (16*2)+2
	EQUB &c0+8
	EQUB _itemElderSign OR 2
	EQUB 0,0

	EQUB 32			; x
	EQUB 16*10		; y
	EQUB %01000001		; flags
	EQUB $82		; anim frame+sprite type.  here 1 for a penguin.
	EQUB 0			; min x
	EQUB 24  		; max x

	; East Tower middle
.screen25Data
	EQUB &ff,$f4,_bitCollidable OR 1,9 OR _bitHookable,3 OR _bitClimbable,_bitHookable OR _bitFlipped OR 9,_bitCollidable OR 1
	EQUB &85,_bitCollidable OR 1,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &85,_bitCollidable OR 1,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &bf,$f0,_bitCollidable OR 1
	EQUB &a7,_bitCollidable OR 1,_bitHookable OR 0,_bitHookable OR 0,8 OR _bitFlipped,1
	EQUB &a5,_bitCollidable OR 1,_bitHookable OR 2,_bitHookable OR 2,1
	EQUB &a5,_bitCollidable OR 1,2,2,1
	EQUB &e5,_bitCollidable OR 1,_bitCollidable OR 8,_bitFlipped OR 0,_bitFlipped OR 0,1
	EQUB &ed,$f0,_bitCollidable OR 1
	EQUB &85,_bitCollidable OR 1,8 OR _bitHookable OR _bitFlipped,_bitCollidable OR 1
	EQUB &f1,_bitCollidable OR 1,$f3,4,_bitCollidable OR 1
	EQUB &f7,_bitCollidable OR 1,$f3,_bitCollidable OR 0,_bitClimbable OR 3,_bitCollidable OR 1,_bitCollidable OR 1

IF FALSE        
	; Alien data : Elder thing on platform?
	EQUB 16			; x
	EQUB 16*9		; y
	EQUB &81		; Top nibble - flags ( %1111, elder, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &80		; anim frame
	EQUB 0			; current counter
	EQUB 40

	EQUB 16			; x
	EQUB 16*4		; y
	EQUB &81		; Top nibble - flags ( %1111, elder, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &80		; anim frame
	EQUB 0			; current counter
	EQUB 24
ENDIF        
	
	; Gate to hell
.screen26Data
	EQUB &85,1 OR _bitCollidable,_bitClimbable OR 3,1
	EQUB &FD,1 OR _bitCollidable,$f4,4,_bitClimbable OR 3,1
	EQUB &FD,1 OR _bitCollidable,$f4,8 OR _bitFlipped OR _bitCollidable OR _bitHookable,_bitClimbable OR 3, 1
	EQUB &85,1 OR _bitCollidable,_bitClimbable OR 3,1
	EQUB &85,1 OR _bitCollidable,_bitClimbable OR 3,1
	EQUB &95,_bitCollidable OR 1,10,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &ff,_bitCollidable OR 1,_bitClimbable OR 3,$f0,_bitCollidable OR 1
	EQUB &ff,_bitCollidable OR 1,_bitClimbable OR 3,$f0,1 OR _bitCollidable
	EQUB $ff,_bitCollidable OR 1,_bitClimbable OR 3,$f0,8 OR _bitFlipped OR _bitHookable;,$f2,8 OR _bitFlipped
	EQUB &C3,_bitCollidable OR 1,_bitClimbable OR 3,_bitHookable OR 5,_bitHookable OR _bitFlipped OR 5
	EQUB &C3,_bitCollidable OR 1,_bitClimbable OR 3,_bitCollidable OR 6,_bitFlipped OR 6
	EQUB &FF,$f0,_bitCollidable OR 1

	; East of east tower
.screen27Data
	EQUB &80,_bitCollidable OR 1
	EQUB &80,_bitCollidable OR 1
	EQUB &80,_bitCollidable OR 1
	EQUB &80,_bitCollidable OR 1
	EQUB &80,_bitCollidable OR 1
	EQUB &80,_bitCollidable OR 1
	EQUB &80,_bitCollidable OR 1
	EQUB &c0,_bitCollidable OR 1,_bitCollidable OR 11
	EQUB &c0,_bitHookable OR _bitFlipped OR 9,_bitHookable OR _bitCollidable OR 9
	EQUB &00
	EQUB &00
	EQUB &FF,$f0,_bitCollidable OR 11

	; Bottom left corner of 'under camp' quadrant
.screen28Data
	EQUB &88,_bitCollidable OR 1,_bitClimbable OR 3
	EQUB &89,_bitCollidable OR 1,_bitClimbable OR 3,_bitCollidable OR 8
	EQUB &ff,_bitCollidable OR 1,_bitClimbable OR 3,$f0,_bitCollidable OR 1
	EQUB &ff,_bitCollidable OR 1,_bitClimbable OR 3,$f0, _bitHookable OR _bitFlipped OR 8
	EQUB &c0,_bitCollidable OR 1,_bitClimbable OR 3
	EQUB &c0,_bitCollidable OR 1,_bitClimbable OR 3
	EQUB &c0,_bitCollidable OR 1,_bitClimbable OR 3
	EQUB &fb,$f0,_bitCollidable OR 1
	EQUB &fb,$f0,_bitCollidable OR 1
	EQUB &81,_bitCollidable OR 1,_bitCollidable OR 0
	EQUB &9d,_bitCollidable OR 1,8 OR _bitCollidable,4,4,2
	EQUB &9d,_bitCollidable OR 1,$f3,_bitCollidable OR 0,2

	; another rope
	EQUB 16*6+4
	EQUB (16*3)+8
	EQUB _itemRope
	EQUB 19 ; text id
	EQUB 5 ; tile id

	EQUB 32			; x
	EQUB 16*8		; y
	EQUB %11000001		; Top nibble - flags ( %1111, movetype, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &82		; anim frame + sprite type
	EQUB 32			; min
	EQUB 32+16*2		; max
	
	EQUB 64+16		; x
	EQUB (16*10)+6 		; y
	EQUB %00110001		; Top nibble - flags ( %1111, movetype, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &80		; anim frame + sprite type
	EQUB 0			; min
	EQUB 36
	
	; Bottom right corner of 'under camp' quadrant
.screen29Data
	EQUB &0
	EQUB &01,_bitCollidable OR 8
	EQUB &3f,$f0,_bitCollidable OR 1
	EQUB &3c,$f0,_bitHookable OR _bitCollidable OR _bitFlipped OR 8
	EQUB &0
	EQUB &0
	EQUB &03,_bitCollidable OR _bitFlipped OR 8,_bitClimbable OR 3
	EQUB &c1,_bitCollidable OR 1,_bitCollidable OR 1,_bitClimbable OR 3
	EQUB &c1,_bitCollidable OR 1,_bitCollidable OR 1,_bitClimbable OR 3
	EQUB &41,0,_bitClimbable OR 3
	EQUB &41,2,_bitClimbable OR 3
	EQUB &4f,2,_bitClimbable OR 3,$f0, _bitCollidable OR 1

		; Item - Food
    DEFITEM _itemHealth,16*6+4,(16*3)+8,26,(8-3)
	
	; alien 1
	EQUB 48-16		; x
	EQUB 16*9		; y
	EQUB &01		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &82		; anim frame + sprite type
	EQUB 0			; current counter
	EQUB 32

	EQUB 48-16+32		; org x
	EQUB 192		; org y
	EQUB %11010001		; Flags ( %1111, move type, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB %10000010		; anim frame + sprite type
	EQUB 48-16		; min x
	EQUB 16*6		; max x

	
	; Catacombs - one - big san loss here
.screen30Data
	EQUB &49,2,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &e9,10,0 OR _bitFlipped,10,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &f9,_bitHookable OR _bitCollidable OR _bitFlipped OR 8,$f0,_bitCollidable OR 1
	EQUB &01,1
	EQUB &03,10,_bitCollidable OR 1
	EQUB &6f,$f0,_bitCollidable OR 1
	EQUB &7b,$f4,_bitCollidable OR 1,_bitHookable OR _bitFlipped OR 8, _bitCollidable OR 1
	EQUB &01,_bitCollidable OR 1
	EQUB &f9,$f4,_bitCollidable OR 1,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &09,3 OR _bitClimbable, _bitCollidable OR 1
	EQUB &0f,3 OR _bitClimbable, 10,4,1 OR _bitCollidable
	EQUB &ff,$f0,_bitCollidable OR 1

	EQUB 0			; x
	EQUB 96			; y
	EQUB %11000001		; Flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB $82		; anim frame + sprite type
	EQUB 0			; min x
	EQUB 16*5		; max x

	; Catacombs - two - more san loss here?
.screen31Data
	EQUB &9d,_bitCollidable OR 1,_bitFlipped OR 0,8,_bitFlipped OR 0,2
	EQUB &9d,_bitCollidable OR 1,$f3,10,_bitFlipped OR 0
	EQUB &bf,_bitCollidable OR 1,_bitClimbable OR 3,$f0,_bitCollidable OR 1
	EQUB &e0,1 OR _bitCollidable,4,_bitClimbable OR 3
	EQUB &fe,1 OR _bitCollidable OR _bitHookable,8 OR _bitFlipped OR _bitHookable OR _bitCollidable,8 OR _bitFlipped OR _bitHookable OR _bitCollidable,1 OR _bitFlipped OR _bitCollidable OR _bitHookable,1 OR _bitCollidable,1 OR _bitCollidable ,3 OR _bitClimbable
	EQUB &82,1,3 OR _bitClimbable
	EQUB &82,1,3 OR _bitClimbable
	EQUB &aa,1,4,4,3 OR _bitClimbable
	EQUB &bf,$f0,_bitCollidable OR 1
	EQUB $30,_bitHookable OR _bitFlipped OR 8,_bitCollidable OR 1
	EQUB &1C,_bitCollidable OR 1,4,10
	EQUB &ff,_bitCollidable OR 1,_bitCollidable OR 1,_bitClimbable OR 3,$f3,1 OR _bitCollidable, 3 OR _bitClimbable,_bitCollidable OR 1

	EQUB (16*3)+4 		; x
	EQUB 192-(16*3)+7	; y
	EQUB _itemElderSign OR 1
	EQUB 0,0

	EQUB 16			; x
	EQUB 16*7+8		; y
	EQUB &01		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &82		; anim frame + sprite type
	EQUB 0			; current counter
	EQUB 30
	
	; West tower base
.screen32Data
	EQUB &C3,_bitCollidable OR 1,_bitClimbable OR 3,3 OR _bitClimbable,_bitCollidable OR 1
	EQUB &f3,$f0,_bitCollidable OR 1
	EQUB &f3,_bitCollidable OR 1,$f3,_bitCollidable OR _bitHookable OR 9,_bitHookable OR 9,_bitCollidable OR 1
	EQUB &81,_bitCollidable OR 1,_bitCollidable OR 1
	EQUB &85,_bitCollidable OR 1,8 OR _bitCollidable,_bitCollidable OR 1
	EQUB &cd,_bitCollidable OR 1,_bitHookable OR _bitCollidable OR 9, _bitCollidable OR _bitHookable OR 9, 0,_bitCollidable OR 1
	EQUB &85,_bitCollidable OR 1,2,_bitCollidable OR 1
	EQUB &85,_bitCollidable OR 1,2,_bitCollidable OR 1
	EQUB &b7,_bitCollidable OR 1,_bitHookable OR _bitCollidable OR 9,_bitCollidable OR _bitHookable OR 9,2,_bitFlipped OR _bitCollidable OR _bitHookable OR 9,_bitCollidable OR 1
	EQUB &84,_bitCollidable OR 1,2
	EQUB &84,_bitCollidable OR 1,_bitFlipped OR 0
	EQUB &ff,$f0,_bitCollidable OR 1

	EQUB 16			; x
	EQUB 96			; y
	EQUB &01		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &82		; anim frame + sprite type
	EQUB 0			; current counter
	EQUB 24

	EQUB 16			; x
	EQUB 192		; y
	EQUB &01		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &81		; anim frame + sprite type
	EQUB 0			; current counter
	EQUB 22
	
	; West tower middle (need two of these)
.screen33Data
	EQUB &c3,_bitCollidable OR 1,_bitClimbable OR 3,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &C3,_bitCollidable OR 1,_bitClimbable OR 3,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB &ff,_bitCollidable OR 1,8 OR _bitFlipped OR _bitCollidable,3 OR _bitClimbable,$f2,8 OR _bitCollidable OR _bitFlipped, 3 OR _bitClimbable,8 OR _bitFlipped OR _bitCollidable,1 OR _bitCollidable
	EQUB &a5,_bitCollidable OR 1,3 OR _bitClimbable,3 OR _bitClimbable,1 OR _bitCollidable
	EQUB &a5,_bitCollidable OR 1,3 OR _bitClimbable,3 OR _bitClimbable,1 OR _bitCollidable
	EQUB &a5,_bitCollidable OR 1,3 OR _bitClimbable,3 OR _bitClimbable,1 OR _bitCollidable
	EQUB &a5,_bitCollidable OR 1,3 OR _bitClimbable,3 OR _bitClimbable,1 OR _bitCollidable
	EQUB &a5,_bitCollidable OR 1,3 OR _bitClimbable,3 OR _bitClimbable,1 OR _bitCollidable
	EQUB &a5,_bitCollidable OR 1,3 OR _bitClimbable,3 OR _bitClimbable,1 OR _bitCollidable
	EQUB &a5,_bitCollidable OR 1,3 OR _bitClimbable,3 OR _bitClimbable,1 OR _bitCollidable
	EQUB &a5,_bitCollidable OR 1,3 OR _bitClimbable,3 OR _bitClimbable,1 OR _bitCollidable
	EQUB &ff,_bitCollidable OR 1,_bitClimbable OR 3,$f4,1 OR _bitCollidable,3 OR _bitClimbable,1 OR _bitCollidable

IF FALSE	
	EQUB 16*6		; x
	EQUB 192+16;-(16*5)	; y
	EQUB &31		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &80		; anim frame + sprite type
	EQUB 0			; current counter
	EQUB 46
ENDIF

	EQUB 16*2		; x
	EQUB 16*3	        ; y
	EQUB &41		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &80		; anim frame + sprite type
	EQUB 0			; current counter
	EQUB 40-16
	
	; West tower top
.screen34Data
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $a0,$f0,_bitCollidable OR 11
	EQUB $e0,_bitCollidable OR 1,_bitCollidable OR 11,_bitCollidable OR 1
	EQUB $ec,$f3,_bitCollidable OR 1,$f0,11 OR _bitCollidable
	EQUB $ec,1 OR _bitCollidable,1 OR _bitCollidable, 8 OR _bitCollidable OR _bitFlipped,9 OR _bitHookable OR _bitCollidable,9 OR _bitHookable OR _bitCollidable OR _bitFlipped
	EQUB $C3,_bitCollidable OR 1,_bitCollidable OR _bitFlipped OR 8,_bitCollidable OR 11, _bitCollidable OR 11
	EQUB $83,$f0,_bitCollidable OR 1
	EQUB $8f,_bitCollidable OR 1,$f2,_bitCollidable OR 8,_bitCollidable OR 1,_bitCollidable OR 1
	EQUB $89,$f0,_bitCollidable OR 1
	EQUB $ff,_bitCollidable OR 1,_bitClimbable OR 3,$f4,_bitCollidable OR 1,3 OR _bitClimbable,1 OR _bitCollidable

	; Item one
	EQUB (16*5)+4
	EQUB (16*12)+8
	EQUB _itemGemBlue
	EQUB 20 ; text id
	EQUB 4+(8*8) ; tile id

	; In between west tower and base camp
.screen35Data
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $c0,11 OR _bitCollidable, 11 OR _bitCollidable
	EQUB $c0,1 OR _bitCollidable, 9 OR _bitHookable OR _bitCollidable
	EQUB $80,1 OR _bitCollidable
	EQUB $80,1 OR _bitCollidable
	EQUB &ff,_bitCollidable OR 1,$f0,_bitCollidable OR 11

	; Hell #1
.screen36Data
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $3c,$f0,1 OR _bitCollidable
	EQUB $3c,$f0,7 OR _bitHookable OR _bitCollidable
	EQUB $00
	EQUB $00
	EQUB $24,10,10
	EQUB $66,_bitCollidable OR 8,_bitCollidable OR 1,_bitCollidable OR 1,_bitCollidable OR 8
	EQUB &e7,$f0,_bitCollidable OR 1
	
	; Hell #2 : Contains LAST piece of rope, and maybe elder sign.
.screen37Data
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $81,8 OR _bitCollidable,8 OR _bitCollidable
	EQUB $c3,$f0,1 OR _bitCollidable
	EQUB $c3,$f3,7 OR _bitHookable OR _bitCollidable,1 OR _bitCollidable
	EQUB $01,1 OR _bitCollidable
	EQUB $01,1 OR _bitCollidable
	EQUB $7d,$f5,8 OR _bitFlipped OR _bitCollidable OR _bitHookable, 1 OR _bitCollidable
	EQUB $01,1 OR _bitCollidable
	EQUB &ff,$f0,_bitCollidable OR 1

	EQUB 16*6+4
	EQUB (16*6)+8
	EQUB _itemRope
	EQUB 19
	EQUB 5+(8*3)

	EQUB 16	  	; x
	EQUB 16*10		; y
	EQUB &01		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &82		; anim frame + sprite type
	EQUB 0			; current counter
	EQUB 24+8
	
	; Shoggoth #1
.screen38Data
	EQUB $ff,1,1,$f0,8 OR _bitFlipped OR _bitHookable
	EQUB $c0,1 OR _bitHookable OR _bitCollidable,7 OR _bitHookable
	EQUB $80,1 OR _bitCollidable
	EQUB $80,1 OR _bitCollidable
	EQUB $83,$f0,1 OR _bitCollidable
	EQUB $82,1 OR _bitCollidable, 7 OR _bitHookable OR _bitCollidable
	EQUB $80,1 OR _bitCollidable
	EQUB &80,1 OR _bitCollidable
	EQUB $80,1 OR _bitCollidable
	EQUB $80,1 OR _bitCollidable
	EQUB $c0,1 OR _bitCollidable,8 OR _bitCollidable
	EQUB &ff,$f0,_bitCollidable OR 1

    ; Elder thing at bottom
	EQUB 32			; x
	EQUB 16*12		; y
	EQUB &41		; Top nibble - flags ( %1111, spare, altering x, altering y, sign bit ), bottom nibble anim delay
	EQUB &82		; anim frame + sprite type
	EQUB 0          ; counter
	EQUB 40
	
	; Shoggoth #2
.screen39Data
	EQUB $e7,$f0,1 OR _bitCollidable
	EQUB $27,8 OR _bitFlipped,$f0,1 OR _bitCollidable
	EQUB $07,$f0,1 OR _bitCollidable
	EQUB $07,1 OR _bitCollidable,$f0,8 OR _bitFlipped
	EQUB $fc,$f0,1 OR _bitCollidable
	EQUB $fc,8 OR _bitFlipped, 8 OR _bitFlipped, 7 OR _bitHookable, 7 OR _bitHookable,$f0,8 OR _bitFlipped
	EQUB $00
	EQUB $07,3 OR _bitClimbable,$f0,1 OR _bitCollidable
	EQUB &06,3 OR _bitClimbable,8 OR _bitFlipped
	EQUB $04,3 OR _bitClimbable
	EQUB $06,3 OR _bitClimbable,8 OR _bitCollidable
	EQUB &ff,$f0,_bitCollidable OR 1
	
	; Shoggoth #3 (END)
.screen40Data
	EQUB $ff,$f0,1
	EQUB $ff,$f0,1
	EQUB $ff,$f0,1 OR _bitCollidable
	EQUB $ff,$f2,7 OR _bitHookable,8 OR _bitCollidable OR _bitFlipped,$f4,7 OR _bitHookable,8 OR _bitFlipped OR _bitCollidable
	EQUB $00
	EQUB $00
	EQUB $01,8 OR _bitCollidable
	EQUB &dd,$f0,_bitCollidable OR 1
	EQUB $dd,$f5,7 OR _bitHookable OR _bitCollidable
.screen40DataEx: ; patch
    EQUB 8 OR _bitFlipped OR _bitCollidable
	EQUB 0 ; swap these two lines
	EQUB $01,$08 OR _bitCollidable

	EQUB $ff,$f3,_bitCollidable OR 1,8 OR _bitCollidable,$f0,1 OR _bitCollidable

	; Secret screen #1
IF FALSE        
.screen41Data
	EQUB $02,_bitClimbable OR 3
	EQUB $02,_bitClimbable OR 3
	EQUB $02,_bitClimbable OR 3
	EQUB $02,_bitClimbable OR 3
	EQUB $02,_bitClimbable OR 3
	EQUB $02,_bitClimbable OR 3
	EQUB $06,_bitCollidable OR 8,_bitClimbable OR 3
	EQUB &07,$f0,_bitCollidable OR 1
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
ENDIF        

	; Just west of east tower top
.screen42Data
	EQUB $0
	EQUB $0
	EQUB $03,_bitClimbable OR 3,_bitCollidable OR 11
	EQUB $03,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB $03,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB $03,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB $03,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB $03,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB $03,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB $03,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB $03,_bitClimbable OR 3,_bitCollidable OR 1
	EQUB $03,_bitClimbable OR 3,_bitCollidable OR 1

IF FALSE        
.screen43Data
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $f0,$f0,_bitCollidable OR 1
	EQUB $10,_bitCollidable OR 1
	EQUB $10,_bitCollidable OR 1
	EQUB $30,_bitCollidable OR 8,_bitCollidable OR 1
	EQUB $f0,$f0,1 OR _bitCollidable
ENDIF
	
.screen44Data:
	EQUB $22,3 OR _bitClimbable,3 OR _bitClimbable
	EQUB $22,3 OR _bitClimbable,3 OR _bitClimbable
	EQUB $63,8 OR _bitCollidable, 3 OR _bitClimbable,3 OR _bitClimbable,8 OR _bitCollidable
	EQUB &7f,$f0,_bitCollidable OR 1
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	EQUB $00
	
; These values are per screen and copied into the zp 'snowwindow' memory on a screen change
.snowWindowValueTable
			EQUB 12,15,26,38	; in the cave, poor lake, east tower, west tower
			EQUB 0
.snowWindowValues	
			EQUB 16*4, 16*0, 16*7, 16*7  	; In the cave
			EQUB 16*4, 16*0, 16*8, 16*5  	; Poor lake
			EQUB 0, 16*0, 16*8, 16*5 	; Top of east tower
			EQUB 0, 0, 128, (16*8)-8	; Top of west tower
	
.endLevelData
PRINT "Level data takes ", P%-mapData
;SAVE "LVLDATA",mapData,endLevelData
