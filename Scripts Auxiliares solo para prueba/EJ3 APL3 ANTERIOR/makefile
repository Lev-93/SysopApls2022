all: servidor cliente Servidor Cliente

servidor: servidor.o
	gcc -o servidor servidor.o

servidor.o: servidor.c
	gcc -c servidor.c

cliente: cliente.o
	gcc -o cliente cliente.o

cliente.o: cliente.c 
	gcc -c cliente.c 

clean:
	rm *.o
