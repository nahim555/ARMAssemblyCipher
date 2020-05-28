all: cw1

cw2: cw1.o
	gcc -o cw1 cw1.o

cw2.o: cw1.s
	as -o cw1.o cw1.s

clean:
	rm cw1 cw1.o