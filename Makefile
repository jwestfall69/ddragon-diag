all:
	make -f Makefile.ddragon
	make -f Makefile.ddragon2

ddragon:
	make -f Makefile.ddragon

ddragon2:
	make -f Makefile.ddragon2

clean:
	make -f Makefile.ddragon clean
	make -f Makefile.ddragon2 clean

