bison -d -y -v 1505052.y	
echo '1'
g++ -w -c -o y.o y.tab.c
echo '2'
flex 1505052.l
echo '3'
g++ -w -c -o l.o lex.yy.c
echo '4'
g++ -o a.out y.o l.o -lfl -ly
echo '5'
./a.out	input11.c
echo '6'
mv y.o .y.o
mv y.tab.c .y.tab.c
mv l.o .l.o
mv lex.yy.c .lex.yy.c
mv a.out .a.out
mv y.output .y.output
mv y.tab.h .y.tab.h
mv token.txt .token.txt
mv parserlog.txt .parserlog.txt
