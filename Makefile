# Makefile for BBC Micro B "Mountain Panic"
#

ifeq ("$(OS)","Windows_NT")
BEEBEM     := "C:/Program Files (x86)/BeebEm/BeebEm.exe"
BEEBASM    := "../../hg/beebasm/beebasm.exe"
CRUNCHER   := "../../git/pucrunch/pucrunch/Release/pucrunch.exe"
PNG2BBC    := "../../git/png2bbc/release/png2bbc.exe"
PANIC_SSD  := panic.ssd
RM         := del
ETAGS      := "C:/emacs/emacs-26.1/bin/etags"
else
BEEBEM     := "/Applications/BeebEm3/BeebEm3.app/Contents/MacOS/BeebEm3"
BEEBASM    := "../../hg/beebasm/beebasm"
CRUNCHER   := "../../git/pucrunch/pucrunch"
PNG2BBC    := "../../git/png2bbc/png2bbc"
PANIC_SSD  := panic.ssd
RM         := rm
ETAGS      := etags
endif

#
# Input files
ASM_SOURCES := $(wildcard *.asm)
GFX_OBJECTS := $(shell $(PNG2BBC) -l gfxscript)
RES_OBJECTS := $(wildcard RES/*)

#
# Phony targets
.PHONY: all clean run sound tags

all: $(PANIC_SSD)

$(PANIC_SSD): $(ASM_SOURCES) $(GFX_OBJECTS) $(RES_OBJECTS) Makefile
	$(BEEBASM) -i intro.asm -di RES/BLANK.SSD -do temp.ssd
	$(BEEBASM) -i panic.asm -di temp.ssd -do temp2.ssd
	$(BEEBASM) -i title.asm -di temp2.ssd -do panic.ssd
	$(RM) temp.ssd
	$(RM) temp2.ssd

$(GFX_OBJECTS): gfxscript
	$(PNG2BBC) gfxscript
	$(CRUNCHER) -d -c0 -l0xE00 BBCTLE1.BIN BBCTLE1.PAK
	$(CRUNCHER) -d -c0 -l0xE00 BBCTLE2.BIN BBCTLE2.PAK

run : 
	$(BEEBEM) $(PANIC_SSD)

clean:
	$(RM) $(PANIC_SSD)
	$(RM) sound.ssd
	$(RM) *.BIN
	$(RM) *.PAK

sound: sound.ssd

sound.ssd: soundtest.asm
	$(BEEBASM) -i soundtest.asm -do sound.ssd

tags:
	$(ETAGS) --regex="/[ \t]*\.\([^: \t]+\)/\1/i" $(ASM_SOURCES)

