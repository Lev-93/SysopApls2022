#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <stdlib.h>
#include <ctype.h>
 

char sender_name[] = "CLIENTE";
char receiver_name[] = "SERVIDOR";
#define SEND_FIFO "FIFO1"
#define RECEIVE_FIFO "FIFO2"


void ayuda()
{
        char opcion[25];
        int num;

        printf ("\nINGRESE UNA OPCIÓN (1-6): \n");
        printf("1) Integrantes\n2) Sinopsis\n3) Parámetros\n4) Descripción\n5) Ejemplo de funcionamiento\n6) Salir\n");

        do{
                printf("\nOpción elegida: ");
                scanf("%s", opcion);
                num = atoi(opcion);

                while ((num == 0) || (num < 1 || num > 6)){
                        printf ("Error, ingrese un número comprendido entre 1 y 6.\n");
                        printf("Opción elegida: ");
                        scanf("%s", opcion);
                        num = atoi(opcion);
                }

                switch(num){
                        case 1:
                                printf("\n=========================== Encabezado =======================\n");

                                printf("\nNombre del script: cliente.cpp");
                                printf("\nNúmero de ejercicio: 3");
                                printf("\nTrabajo Práctico: 3");
                                printf("\nEntrega: Primer entrega");
								printf("\n\n==============================================================\n");

                                printf("\n------------------------ Integrantes ------------------------\n\n");

                                printf("Matías Beltramone - 40.306.191\n");
                                printf("Eduardo Couzo Wetzel - 43.584.741\n");
                                printf("Brian Menchaca - 40.476.567\n");
                                printf("Ivana Ruiz - 33.329.371\n");
                                printf("Lucas Villegas - 37.792.844\n");
                                
								printf("\n-------------------------------------------------------------\n\n");
                                break;
                        case 2:
                                printf("\n##SINOPSIS##\nUn supermercado desea poder generar algunas consultas sobre los productos que comercializa utilizando una serie de comandos.\n");
                                break;
                        case 3:
                                printf("\n##PARÁMETROS##\n");
                                printf("El proceso cliente no recibe parámetros.\n");
								printf("El proceso servidor recibe un solo parámetro: el nombre del archivo de productos (archivo de texto plano).\n");
								break;
                        case 4:
                                printf("\n##DESCRIPCIÓN##\n\n");
								printf("Se ponen a correr dos procesos (cliente y servidor) que se comunicarán mediante dos FIFOS.\n");
								printf("El proceso cliente recibe comandos que se enviarán al proceso servidor que consultará un archivo de texto.\n");
								printf("Comandos que puede recibir el proceso cliente:\n");
								printf("STOCK producto_id: Muestra DESCRIPCIÓN y STOCK para un producto dado.\n");
								printf("SIN_STOCK: Muestra ID, DESCRIPCIÓN y COSTO de los productos con STOCK cero.\n");
								printf("REPO cantidad: Muestra el costo total de reponer una cantidad dada para cada producto sin stock.\n");
								printf("LIST: Muestra ID, DESCRIPCIÓN y PRECIO de todos los productos existentes.\n");
								printf("QUIT: Finaliza la ejecución.\n");
                                break;
                        case 5:
                                printf("\n##EJEMPLO DE FUNCIONAMIENTO##\n");
								printf("En una terminal correr el siguiente comando:\n");
                                printf("./cliente\n");
                                printf("Abrir otra terminal y correr el siguiente comando de ejemplo:\n");
								printf("./servidor productos.txt\n");
								printf("En caso de que no se encuentren los archivos ejecutables, se debe compilar y linkeditar arrojando el siguiente comando por consola:\n");
								printf("make\n");
                                break;
           }
        }
        while(num != 6);
}


void comunicacion_fifos()
{	
	pid_t pid;
	
	//Creamos dos fifos para enviar y recibir mensajes
	mkfifo(SEND_FIFO, 0666);
	mkfifo(RECEIVE_FIFO, 0666);
 
	pid = fork();

	if(pid < 0)
	{
		perror("fork");
	}

	else if (pid == 0) // recibir información
	{
		int receive_fd;
		receive_fd = open(RECEIVE_FIFO, O_RDONLY);

		while(1)
		{
			char tmp[255] = "";
			//int ret;
			//ret = read(receive_fd, tmp, sizeof(tmp));
			//if(ret == 0)
			//{
			//	break;
			//}
			while(read(receive_fd,tmp,sizeof(tmp))){

			}
			//if(ret > 0)
				printf("%s\n",tmp);
			//printf("\r\e[K%s:\n%s\n", receiver_name, tmp);
			//printf("%s: ", sender_name);
			fflush (stdout); 
		}
	}

	else if (pid > 0) // enviar mensaje
	{
		int send_fd;
		send_fd = open(SEND_FIFO, O_WRONLY);
		
		while(1)
		{
			char tmp[255] = "";
 
			printf("%s: ", sender_name);
			fflush(stdout);
			fgets(tmp, sizeof(tmp), stdin);
			
			tmp [strlen (tmp) -1] = 0; // cambia el \n de fgets a \0
			
			for (int i = 0; i < strlen(tmp); i++) {
				tmp[i] = toupper(tmp[i]);
			}
			
			if(strcmp(tmp, "LIST") == 0 || strcmp(tmp, "SIN_STOCK") == 0 || strcmp(tmp, "QUIT")==0)
			{
				write(send_fd, tmp, strlen(tmp));
			}

			if(tmp[0]=='R' && tmp[1]=='E' &&tmp[2]=='P' && tmp[3]=='O' && tmp[4]==' ')
			{
				char aux[249];

    			strncpy(aux, &tmp[5], strlen(tmp)-1 );

				int num = atoi(aux);
			
				if(num > 0)
					write(send_fd, tmp, strlen(tmp));
				else{
					printf("Error, la cantidad debe ser mayor o igual a cero.\n");
					printf("Consulte la ayuda con ./cliente -h ó ./cliente --help");
				}				
			}

			if (tmp[0]=='S' && tmp[1]=='T' &&tmp[2]=='O' && tmp[3]=='C' && tmp[4]=='K' && tmp[5]==' ')
			{
    			char aux[249];

    			strncpy(aux, &tmp[6], strlen(tmp)-1 );
				int num = atoi(aux);

				if(num >0)
					write(send_fd, tmp, strlen(tmp));
				else{
					printf("Error, el ID del producto es mayor o igual a cero.\n");
					printf("Consulte la ayuda con ./cliente -h ó ./cliente --help");
				}								
			}

			if(strcmp(tmp, "QUIT") == 0)
			{
                system("clear");
				kill(0, SIGTERM);
			}
		}
	}
}

void comunicacion_fifos2(){
	//Creamos dos fifos para enviar y recibir mensajes
	mkfifo(SEND_FIFO, 0666);
	mkfifo(RECEIVE_FIFO, 0666);
	int receive_fd;
	receive_fd = open(RECEIVE_FIFO, O_RDONLY);
	int send_fd;
	send_fd = open(SEND_FIFO, O_WRONLY);
		
	while(1)
	{
		char tmp[255] = "";
		int ban = 0;
		printf("%s: ", sender_name);
		fflush(stdout);
		fgets(tmp, sizeof(tmp), stdin);
			
		tmp [strlen (tmp) -1] = 0; // cambia el \n de fgets a \0
			
		for (int i = 0; i < strlen(tmp); i++) {
			tmp[i] = toupper(tmp[i]);
		}
			
		if(strcmp(tmp, "LIST") == 0 || strcmp(tmp, "SIN_STOCK") == 0 || strcmp(tmp, "QUIT")==0)
		{
			write(send_fd, tmp, strlen(tmp));
			ban = 1;
		}

		if(tmp[0]=='R' && tmp[1]=='E' &&tmp[2]=='P' && tmp[3]=='O' && tmp[4]==' ')
		{
			char aux[249];
			ban = 1;
    		strncpy(aux, &tmp[5], strlen(tmp)-1 );

			int num = atoi(aux);
			
			if(num > 0)
				write(send_fd, tmp, strlen(tmp));
			else{
				printf("Error, la cantidad debe ser mayor o igual a cero.\n");
				printf("Consulte la ayuda con ./cliente -h ó ./cliente --help");
			}				
		}
		if (tmp[0]=='S' && tmp[1]=='T' &&tmp[2]=='O' && tmp[3]=='C' && tmp[4]=='K' && tmp[5]==' ')
		{
   			char aux[249];
			ban = 1;
   			strncpy(aux, &tmp[6], strlen(tmp)-1 );
			int num = atoi(aux);
				if(num >0)
					write(send_fd, tmp, strlen(tmp));
			else{
				printf("Error, el ID del producto es mayor o igual a cero.\n");
				printf("Consulte la ayuda con ./cliente -h ó ./cliente --help");
			}								
		}
		if(strcmp(tmp, "QUIT") == 0)
		{	
			ban = 1;
            system("clear");
			kill(0, SIGTERM);
		}
		if(ban == 1){
			char tmp[255] = "";
			while(read(receive_fd,tmp,sizeof(tmp)))
			{}
			printf("%s\n",tmp);
			fflush (stdout); 
		}
		else
			printf("Error, accion erronea.\nVuelva a intentarlo.\n");
			
	}
}
 
int main(int argc, char * argv[])
{
	//Ignora el ctrl+C
	signal(SIGINT,SIG_IGN);

	//Se validan los parámetros
	if(argc == 2 && ( (strcmp(argv[1], "-h")==0) || (strcmp(argv[1], "--help")==0) ))
	{
		ayuda();
		return EXIT_FAILURE;
	}

	if(argc >= 2)
	{
		printf("Error en el ingreso de parámetros.\n");
		printf("Ingrese \"-h\" o \"--help\" como único parámetro para obtener la ayuda.\n");
		return EXIT_FAILURE;
	}

	//comunicacion_fifos();
	comunicacion_fifos2();
	unlink(SEND_FIFO);
	unlink(RECEIVE_FIFO);	

	return EXIT_SUCCESS;
}



