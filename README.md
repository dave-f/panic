# Mountain Panic

In 2013 I finally completed a small game I had been working on for the BBC Micro.  It was very much a labour of love but became a real struggle to finish.  As such, the code isn't particularly neat and certainly no example of how to write 6502.  However, it is (as far as I know) bug free and did get released on a physical disk in a nice box with cover art.

Some years later I thought it would be a good idea to preserve the source code for the game.  So after a bit of tidying up of the build system, here it is!

# Tools required

* beebasm : assembler 
* png2bbc : graphics builder
* pucrunch : data compression

# Building

Edit the `makefile` to point at the tools detailed above and running `make` should build `panic.ssd` which can then be loaded into a BBC Micro emulator. 

# Credits

Dave Rog and Chris.
Dave and Pete.
