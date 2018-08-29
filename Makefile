run: calc
	./calc
calc: adt/adt.exe adt/primitive.c calc.c lex.c parser.tab.c
	gcc adt/primitive.c lex.c parser.tab.c calc.c -o calc
calc.c: calc.adt
	./adt/adt.exe -h -c -e calc.adt
lex.c: parser.tab.c lex.l
	flex -o lex.c lex.l
parser.tab.c: parser.y
	bison -d parser.y
adt/adt.exe:
	cd adt; make
clean:
	rm -rf *.o calc.c calc.h parser.tab.* lex.c
	cd adt; make clean
distclean:
	rm -rf *.o calc.c calc.h parser.tab.* lex.c calc
	cd adt; make distclean
	