PAL_black	= (0 EOR 7)
PAL_blue	= (4 EOR 7)
PAL_red		= (1 EOR 7)
PAL_magenta 	= (5 EOR 7)
PAL_green	= (2 EOR 7)
PAL_cyan	= (6 EOR 7)
PAL_yellow	= (3 EOR 7)
PAL_white	= (7 EOR 7)

OP_CLC 		 = &18
OP_SEC		 = &38
OP_LDA_Y_INDEX	 = &B9
OP_LDA_IMMEDIATE = &A9
OP_NOP		 = &EA

	; Copy tile data down (setup in loader)
	; Includes the tile table at 0xC00.
IF FALSE
.copyTiles:
	{
	LDX #5
	
.packedTileLoop:
	LDA &C00,X
	STA packedTileTable,X
	DEX
	BPL packedTileLoop

	; Unpack X tiles (stored in &A00 from loader) to &700
	LDX #$0A
	LDY #$02
	JSR unpack

	; Copy tileset1 and 2 down from &4800 to "tileSpritesPacked"
	LDX &C00 + 4
	LDY &C00 + 5
	STX t0
	STY t1
	
.copyLoop:
	LDA &4800+224
	STA tileSpritesPacked

	CLC
	LDA copyLoop+1
	ADC #1
	STA copyLoop+1
	BCC okCopy1
	INC copyLoop+2
	
.okCopy1:
	CLC
	LDA copyLoop+4
	ADC #1
	STA copyLoop+4
	BCC okCopy2
	INC copyLoop+5

.okCopy2:
	SEC
	LDA t0
	SBC #1
	STA t0
	BCS copyLoop
	DEC t1
	BPL copyLoop

	LDX #0
.copyItems
	LDA $4800,X
	STA itemSprites,X
	INX
	CPX #224 ; 7 (4*8) items
	BNE copyItems
	
.doneAllCopy:
	RTS
	}
ENDIF

IF FALSE        
.hardwareSetup:
	{
    LDA machineType
	CMP #3
	BNE normalBBC

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

.normalBBC:

	SEI
	
	; Disable all interrupts
        LDA #&7F
	STA &FE4E
        
	LDA #0
	STA irqCounter
	STA joyTemp
	STA joyTemp2

IF TRUE 			; disable this lot for proper sound on real h/w
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

	; Set our handler.  In theory this can also go as it is EQUB'd
	;LDA #LO(irq)
	;STA &204
	;LDA #HI(irq)
	;STA &205

	; Copy data down - not needed now after relocation
IF FALSE        
	JSR copyTiles

	; Copy aliens down : A loop of 5*128 bytes.
	LDY #4
	
.outerLoop:
	LDX #127
	
.alienLoop:
	LDA &5000,X
	STA alienData,X
	DEX
	BPL alienLoop

	CLC
	LDA alienLoop+1
	ADC #128
	STA alienLoop+1
	BCC noCarry
	INC alienLoop+2
	CLC
	
.noCarry:
	LDA alienLoop+4
	ADC #128
	STA alienLoop+4
	BCC noCarry2
	INC alienLoop+5

.noCarry2:
	DEY
	BPL outerLoop
ENDIF

	CLI
	RTS
	}
ENDIF
