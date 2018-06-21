.updateDynamicText:
{
    LDX dynTextFrames
    BEQ dynTextOut

    CPX #50
    BNE inProgress

.setup:
    LDX #0
    LDA dynTextTileIndex
    ASL A
    TAY
    LDA tileAddressTable,Y
    STA t2
    LDA tileAddressTable+1,Y
    STA t3
    LDY dynTextString
    JSR drawStringWithOSFont

.inProgress:
    DEC dynTextFrames
    BNE dynTextOut

    LDA #2 ; do 3 tiles
    STA tf
    LDA dynTextTileIndex
    STA te

.removeText:
    LDA te
    JSR redrawTile
    INC te
    DEC tf
    BPL removeText

.dynTextOut:
    RTS
}

