; indexes 0-19: freqhi=3
; indexes 20-47: freqhi=2
freqhitransition = 20

\ *******************************************************************
\ *  Two interleaved tables mapping sound channel numbers to
\ *  sound chip commands
\ *******************************************************************

.channelfreq
	EQUB &80			; channel 0 pitch (+bass implementation)
.channelvolume
	EQUB &9F			; channel 0 volume
	EQUB &A0			; channel 1 pitch
	EQUB &BF			; channel 1 volume
	EQUB &C0			; channel 2 pitch (which can be used with noise channel)
	EQUB &DF			; channel 2 volume
	EQUB &E0			; noise pitch
	EQUB &FF			; noise volume



\\--------------------------------------------------------------------------

\\ ****************************************************************************
\\ *
\\ *     All the sound related code is here
\\ *
\\ ****************************************************************************


\\ Volume envelope definitions
\\                    1    2    3    4    5    6     7
.ve_attackrate  EQUB  52,  24,  24,  48,  52,  52,   4
.ve_peak        EQUB  52,  48,  24,  48,  52,  52,  44
.ve_sustaintime EQUB  4,    4,   0,   1,   0,  48,   4
.ve_releaserate	EQUB  1,    4,   5,   4,  52,   1,   4


\\ Pitch envelope definitions
\\                    1        2        3        4        5        6        7        8        9
.pe_numsteps    EQUB  6;,       3,       3,       3,       3,       3,       3,       3,       3
.pe_deflo       EQUB  LO(pe1);, LO(pe2), LO(pe3), LO(pe4), LO(pe5), LO(pe6), LO(pe7), LO(pe8), LO(pe9)
.pe_defhi       EQUB  HI(pe1);, HI(pe2), HI(pe3), HI(pe4), HI(pe5), HI(pe6), HI(pe7), HI(pe8), HI(pe9)

.pe1			EQUB 1, 0, 0, 255, 0, 0
;.pe2			EQUB 256-28, 16, 12				; CEG triad
;.pe3			EQUB 256-36, 20, 16				; CFA triad
;.pe4			EQUB 256-36, 12, 24				; DFB triad
;.pe5			EQUB 256-36, 16, 20				; EbGC triad
;.pe6			EQUB 256-28, 12, 16				; CEbG triad
;.pe7			EQUB 256-36, 24, 12				; EbAC triad
;.pe8			EQUB 256-24, 12, 12				; GbAC triad
;.pe9			EQUB 256-32, 20, 12				; GCEb triad


\\ Sound code entry point

.updatesound
	
	LDX #6

.updatesoundloop

	; see if a note has been requested on this channel
	
	LDA notereq+1,X			; notereq MSB<>0 indicated a note request
	BEQ nonewnote
	
	; a note was requested - fill in details
	; at (notereq,X) are:
	;   +0 pitch
	;   +1 pitch envelope number
	;   +2 volume envelope number
	
	LDA (notereq,X)
	STA pitch,X
	
	JSR writepitch
	
	INC notereq,X:BNE P%+4:INC notereq+1,X
	LDA (notereq,X)
	STA pitchenv,X
	
	LDA #8:STA &FE40		; easily used 16 cycles since the JSR writepitch
	
	INC notereq,X:BNE P%+4:INC notereq+1,X
	LDA (notereq,X)
	STA volenv,X
	TAY
	
	LDA #0
	STA notereq+1,X			; clear note request
	STA pitchenvindex,X		; initialise pitch envelope pointer
	STA volenvstage,X		; initialise volume envelope stage	
	
	; send vol/pitch to sound chip
	
	LDA ve_attackrate-1,Y	; get initial volume from attack phase (-1 because valid indices start at 1)
	STA volume,X
	JSR writevolume
	LDA #8					; waste 16 cycles (6 from the RTS + 2
	DEX:DEX					; + 2 + 2
	STA &FE40				; + 4)
	BPL updatesoundloop
	RTS
	
	; No new note requested, so update what is already playing
	
.nonewnote

	; Update volume if necessary
	
	LDY volenv,X
	BEQ novolumeenv
	
	LDA volenvstage,X		; 0, 1-127 or &80
	BMI release
	BNE sustain
	
.attack	
	LDA volume,X
	CMP ve_peak-1,Y	
	BCS sustain				; if already at peak, move to sustain phase
	ADC ve_attackrate-1,Y
	CMP ve_peak-1,Y
	BCC updatevolume
	LDA ve_peak-1,Y			; clamp at peak
	STA volume,X
	BNE updatevolume		; always taken

.sustain
	LDA volenvstage,X
	CMP ve_sustaintime-1,Y
	INC volenvstage,X
	BCC novolumeenv
	
.startrelease
	LDA #128
	STA volenvstage,X
.release
	LDA volume,X
	SEC
	SBC ve_releaserate-1,Y
	BPL P%+4
	LDA #0
	BNE updatevolume
	STA volenv,X			; disable note, but still fall through so we write zero volume
	STA pitchenv,X			; also stop pitch envelope update
	
.updatevolume
	
	; Update volume here and send to sound chip
	; Check against old value to see if anything has actually changed
	
	TAY
	EOR volume,X
	AND #252
	STY volume,X
	BEQ volhasntchanged
	TYA
	JSR writevolume
	LDA (0,X)				; waste 16 cycles (6 from the RTS + 6
	LDA #8:STA &FE40		; + 2 + most of the STA)
	.volhasntchanged

.novolumeenv

	; Update pitch if necessary
	
	LDY pitchenv,X
	BEQ nopitchenv
	
	LDA pe_deflo-1,Y:STA pitchdata+1
	LDA pe_defhi-1,Y:STA pitchdata+2
	LDA pe_numsteps-1,Y:STA pitchsteps+1
	
	LDY pitchenvindex,X
	
	.pitchdata LDA &B9B9,Y		; self-modified
	BEQ nochangepitch
	CLC
	ADC pitch,X
	STA pitch,X
	JSR writepitch

.nochangepitch
	LDY pitchenvindex,X
	INY
	.pitchsteps CPY #0
	BNE P%+4
	LDY #0
	STY pitchenvindex,X

	LDA #8:STA &FE40
	
	; iterate to next channel
	
.nopitchenv
	DEX:DEX
	BMI P%+5
	JMP updatesoundloop
	
.exitsoundupdate

	RTS

	
;-------------------------------------------------

.writevolume

	; A = volume
	; X = channel
	; After calling this, wait at least 5 cycles, and then execute LDA #8:STA &FE40 or similar)
	
	LSR A:LSR A

	EOR channelvolume,X
	STA &FE4F
	LDY #0:STY &FE40

	; Still pending: to pull sound chip enable high again
	; Do it after the RTS to avoid idling unnecessarily
	; (wait at least 5 cycles, and then execute LDA #8:STA &FE40 or similar)

	RTS
	



.writepitchnoise

	; A = note to be written to noise channel
	; Still pending: to pull sound chip enable high again.
	; Do it after the RTS to avoid idling unnecessarily
	; (wait at least 5 cycles, and then execute LDA #8:STA &FE40 or similar)

	ORA #&E0:STA &FE4F
	LDY #0:STY &FE40
	RTS
	
	
.writepitch

	; A = note
	; X = channel
	; After calling this, wait at least 5 cycles, and then execute LDA #8:STA &FE40 or similar)

	; Special handling for noise control
	
	CPX #6
	BEQ writepitchnoise

	STX pitchchannel+1

	; Find the octave and the note within the octave
	
	LDX #0
	CMP #48*4
	BCC div48a
	SBC #48*4
	LDX #4
	.div48a
	CMP #48*2
	BCC div48b
	SBC #48*2
	INX
	INX
	.div48b
	CMP #48
	BCC div48c
	SBC #48
	INX
	.div48c
	
	; X = octave number
	; A = note within the octave

	; Get 10-bit frequency for this note
	; the top 2 bits are either 2 or 3, so we don't use a table for this
	
	TAY
	LDA #2
	CPY #freqhitransition
	ADC #0
	EOR #1
	STA soundtemp
	LDA freqlo,Y
	
	; Shift down according to octave
	
	CPX #0
	BEQ nooctaveshift
.octaveshift
	LSR soundtemp
	ROR A
	DEX
	BNE octaveshift
.nooctaveshift

	; Write pitch to sound chip
	; First, the low 4 bits
	
	TAY				; preserve A
	AND #15
	.pitchchannel LDX #0	; self-modified
	ORA channelfreq,X
	STA &FE4F
	TYA				; get back A
	
	; Pull sound chip enable low
	
	LDY #0:STY &FE40

	; Do some stuff while we have to wait 8us
	
	ASL A:ROL soundtemp
	ASL A:ROL soundtemp
	ASL A:ROL soundtemp
	ASL A:ROL soundtemp
	
	; Pull sound chip enable high
	
	LDA #8:STA &FE40
	
	; Next, the top 6 bits
	
	LDA soundtemp
	STA &FE4F
	
	; Pull sound chip enable low
	
	STY &FE40		; Y=0
	
	; Still pending: to pull sound chip enable high again
	; Do it after the RTS to avoid idling unnecessarily
	; (wait at least 5 cycles, and then execute LDA #8:STA &FE40 or similar)
	
	RTS


\\--------------------------------------------------------------------------



\\ At the beginning of the game, at some point, please configure the VIA as follows
\\ so that it's ready for the sound code.

	\\ Configure sound chip ready for writing
	\\ (Note, to access keyboard, write &03 to &FE40, but afterwards disable it
	\\ again by writing &0B.)
	
	LDA #&FF:STA &FE43
	LDA #&0F:STA &FE42
	LDA #&08:STA &FE40				; sound chip enable pulled high (disabled for now)
	LDA #&0B:STA &FE40				; keyboard enable pulled high (disabled)	



\\--------------------------------------------------------------------------



\\ To play a sound, put the address of a sound block in:
\\    notereq+0/notereq+1  - channel 0 (regular tone channel)
\\    notereq+2/notereq+3  - channel 1 (regular tone channel)
\\    notereq+4/notereq+5  - channel 2 (regular tone channel, also can be used as pitch for the noise channel)
\\    notereq+6/notereq+7  - channel 3 (the noise channel)

\\ Sound block contains:
\\    +0 - note pitch (in quarter semitones 0-255)
\\    +1 - pitch envelope index (0 = no pitch envelope)
\\    +2 - volume envelope index (must be >0, 0 is not valid)

;.testsoundblock:
;EQUB 240    ; pitch
;EQUB 0    ; slightly tremolo note
;EQUB 4    ; 'ding' volume envelope

;	LDA #&FF:STA &FE43
;	LDA #&0F:STA &FE42
;	LDA #&08:STA &FE40				; sound chip enable pulled high (disabled for now)
;	LDA #&0B:STA &FE40				; keyboard enable pulled high (disabled)	

        
;  LDA #LO(testsoundblock):STA notereq+0
;  LDA #HI(testsoundblock):STA notereq+1  ; always store MSB last
