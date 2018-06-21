_keyLeft		= 1
_keyRight		= 2
_keyFire		= 4
_keyUp			= 8
_keyDown		= 16
_keyInventory		= 32
_keyJoystickUsed        = 128 ; 27/10/2013 - Set so that we can set joystick enable
_joystickDeadZone	= &28

.updateKeys
	;{
	LDA #&03
	STA &FE40
	LDA #0
	STA keyFlags
	LDA #&7f
	STA &FE43

	; 27/10/2013 Only check joystick if we are enabled
	LDA joystickEnabledFlag
	BEQ keyCheckLeft

.startJoystickPatch:        
.checkJoyFire
	LDA &FE40
	AND #16
	BNE notFired

.fired
	LDA keyFlags
	ORA #(_keyFire OR _keyJoystickUsed)
	STA keyFlags
	
.notFired
	LDA joyTemp
	TAX
	CMP #_joystickDeadZone
	BCS notJoyLeft

.joyLeft
	LDA keyFlags:ORA #_keyLeft:STA keyFlags
	
.notJoyLeft
	TXA
	CMP #&ff - _joystickDeadZone
	BCC notJoyRight
	
.joyRight
	LDA keyFlags:ORA #_keyRight:STA keyFlags
	
.notJoyRight
	LDA joyTemp2
	TAX
	CMP #&ff - _joystickDeadZone
	BCC notJoyUp

.joyUp
	LDA keyFlags:ORA #_keyUp:STA keyFlags
	
.notJoyUp
	TXA
	CMP #_joystickDeadZone
	BCS keyCheckLeft
.joyDown
	LDA keyFlags:ORA #_keyDown:STA keyFlags

.endJoystickPatch:        
.keyCheckLeft:
	LDA #97:STA &FE4F:LDA &FE4F  ; N flag = whether 'Z' pressed
	BPL keyCheckRight
	LDA keyFlags
	ORA #_keyLeft
	STA keyFlags
        
.keyCheckRight:
	LDA #66:STA &FE4F:LDA &FE4F  ; N flag = whether 'X' pressed
	BPL keyCheckRET
	LDA keyFlags
	ORA #_keyRight
	STA keyFlags
        
.keyCheckRET:
	LDA #73:STA &FE4F:LDA &FE4F  ; N flag = whether 'RET' pressed
	BPL keyCheckUp
	LDA keyFlags
	ORA #_keyFire
	STA keyFlags
        
.keyCheckUp:
	LDA #72:STA &FE4F:LDA &FE4F  ; N flag = whether ':' pressed
	BPL keyCheckDown
	LDA keyFlags
	ORA #_keyUp
	STA keyFlags
        
.keyCheckDown:
	LDA #104:STA &FE4F:LDA &FE4F  ; N flag = whether '/' pressed
	BPL keyCheckSpace
	LDA keyFlags
	ORA #_keyDown
	STA keyFlags
        
.keyCheckSpace:
	LDA #98:STA &FE4F:LDA &FE4F
	BPL notSpace
	LDA keyFlags
	ORA #_keyInventory
	STA keyFlags
        
.notSpace:
	; PULL KEYBOARD ENABLE HIGH AGAIN FOR SOUND
	LDA #&ff
	STA &FE43
	LDA #&0B
	STA &FE40
	RTS
	;}

PRINT "* Keys size: ", P%-updateKeys
	
