# Mountain Panic

In 2013 I finally completed a small game I had been working on for the BBC Micro.  It was very much a labour of love but with time at such a premium it became a real struggle to finish.  

The code isn't particularly neat and certainly isn't an example of how to write 6502! However, it is (as far as I know) bug free and did get released on a physical disk in a nice box with cover art.

A few years have passed and I thought it would be a good idea to preserve the source code for the game.  So after a bit of tidying up of the build system, here it is!

# Tools required

To build the game you'll need these tools, all of which just require a C/C++ compiler and should compile for any OS:

* [beebasm](https://github.com/stardot/beebasm)
* [png2bbc](https://github.com/dave-f/png2bbc)
* [pucrunch](https://github.com/dave-f/pucrunch)

# Building

Edit the `makefile` to point at the tools detailed above and running `make` should build `panic.ssd` which can then be loaded into a BBC Micro emulator. 

# Thanks

Many thanks to Roger Coe and Chris Hogg for the artwork.

Also Dave Moore and Pete Edwards for their tireless enthusiasm.
