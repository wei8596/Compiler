all: parser

parser: y.tab.c lex.yy.c
	gcc -o parser lex.yy.c y.tab.c -ly -lfl

y.tab.c: parser.y
	bison -y -d parser.y

lex.yy.c: scanner.l
	flex scanner.l

clean:
	rm -f parser y.tab.* *.o *.c *~*.*~
