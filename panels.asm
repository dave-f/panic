
ORG &4800
.start
INCBIN "BBCPAN.BIN"
.end

ORG &4000
.start2
INCBIN "BBCPAN2.BIN"
.end2

SAVE "PAN1", start, end
SAVE "PAN2", start2, end2
	
	
	
