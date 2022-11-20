#include <iostream>
#include <fstream>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string>
#include <semaphore.h>

#define SEND_FIFO "FIFO2"
#define RECEIVE_FIFO "FIFO1"

void swap(char *, char *);
char* reverse(char*, int, int);
char* itoa(int, char*, int);
void comunicacion_fifos2(FILE*);
void inicializarSemaforo();
void ayuda();

sem_t* semaforo;

using namespace std;
 
int main(int argc, char * argv[])
{
	//Ignora el ctrl+C
	signal(SIGINT,SIG_IGN);

	if(argc == 2 && ( (strcmp(argv[1], "-h")==0) || (strcmp(argv[1], "--help")==0) ))
	{
		ayuda();
		return EXIT_FAILURE;
	}

	FILE * arch;
	arch = fopen(argv[1], "rt");
	if(argc != 2)
	{
		printf("Cantidad incorrecta de parámetros.\n");
		printf("Consulte la ayuda en el proceso de cliente ejecutando el siguiente comando:\n");
		printf("./cliente --help\n");
		return EXIT_FAILURE;
	}
	if (!arch)
		{
			printf("No existe archivo.\n");
			return EXIT_FAILURE;
		}
		
	//comunicacion_fifos(arch);
	comunicacion_fifos2(arch);
	unlink(SEND_FIFO);
	unlink(RECEIVE_FIFO);

	return EXIT_SUCCESS;
}

void swap(char *x, char *y) {
    char t = *x; *x = *y; *y = t;
}
 
char * reverse(char *buffer, int i, int j)
{
    while (i < j) {
        swap(&buffer[i++], &buffer[j--]);
    } 
    return buffer;
}

char * itoa(int value, char* buffer, int base)
{
	int n=value;
    int i = 0;
    while (n)
    {
        int r = n % base;
 
        if (r >= 10) {
            buffer[i++] = 65 + (r - 10);
        }
        else {
            buffer[i++] = 48 + r;
        }
 
        n = n / base;
    }

    if (i == 0) {
        buffer[i++] = '0';
    }
 
    buffer[i] = '\0'; 

    return reverse(buffer, 0, i - 1);
}

void comunicacion_fifos2(FILE * arch)
{    
	pid_t pid;	
	pid = fork();

	if(pid < 0)
	{
		perror("fork");
	}
	
	else if (pid == 0) // recibir información
	{
		inicializarSemaforo();
		sem_wait(semaforo);
        mkfifo(SEND_FIFO, 0666);
	    mkfifo(RECEIVE_FIFO, 0666);

		while(1)
		{
            ifstream fifo1(RECEIVE_FIFO);
			char tmp[255] = "";
			string temp;
			getline(fifo1,temp);
            strcpy(tmp,temp.c_str());
            fifo1.clear();
			fifo1.close();
			if(strcmp(tmp, "LIST")==0)
			{
                ofstream fifo2(SEND_FIFO);
				
				char linea[100];
				int primerPase=0;

				while(fgets(linea, sizeof(linea), arch))
				{
					if (primerPase > 0){
						char *p = strtok(linea,";");
						string tmp_id(p);
						p = strtok(NULL,";");
						string tmp_nombreProd(p);
						p = strtok(NULL,";");
						string tmp_precio(p);
                        fifo2 << tmp_id + " " + tmp_nombreProd + " $" + tmp_precio + "\n" << ends;
					}
					primerPase++;
				}
				fseek(arch, 0L, SEEK_SET);
                fifo2.close();			
			}

			if(strcmp(tmp, "SIN_STOCK")==0)
			{
                ofstream fifo2(SEND_FIFO);
				
				char linea[100];
				int primerPase = 0;

				while(fgets(linea, sizeof(linea), arch))
				{
					if (primerPase > 0)
					{
						int longitudLinea = strlen(linea);
						
						//me fijo que luego del último punto y coma haya un 0
                        if(linea[longitudLinea-3]=='0' && linea[longitudLinea-4]==';'){
                            //write(send_fd, linea, strlen(linea));
							char *p = strtok(linea,";");
							char res[100];
							strcpy(res,p);
							string tmp_id(res);
							p = strtok(NULL,";");
							strcpy(res,p);
							string tmp_nombreProd(res);
							p = strtok(NULL,";");
							p = strtok(NULL,";");
							strcpy(res,p);
							string tmp_costo(res);
                        	fifo2 << tmp_id + " " + tmp_nombreProd + " $" + tmp_costo + "\n" << ends;
                        }
					}
					primerPase++;
				}
                fifo2.close();
				fseek(arch, 0L, SEEK_SET);
			}


            if(tmp[0]=='R' && tmp[1]=='E' &&tmp[2]=='P' && tmp[3]=='O' && tmp[4]==' ')
			{
				int total=0;

                ofstream fifo2(SEND_FIFO);
				
				char linea[100];
				int primerPase=0;
				
				char mandar[20];
                
				while(fgets(linea, sizeof(linea), arch))
				{
					if (primerPase>0){
				
						//elimino el último punto y coma, que no me sirve
						int largo = strlen(linea);
						linea[largo-2]='\0';
						
						char * aux;
						//busco el siguiente punto y coma (del último al primero)
						//y me fijo si el número del stock es 0
						aux= strrchr(linea, ';');
						if(strcmp(aux+1, "0")==0){
							
							largo = strlen(linea);
							linea[largo-2]='\0';
							largo = strlen(linea);
							aux= strrchr(linea, ';');
							
							int costo = atoi(aux+1);
                            char subtext[249];
                            strncpy(subtext, &tmp[5], strlen(tmp)-1 );

                            int num = atoi(subtext);                            
                            total+= (num*costo);
							
							itoa(total, mandar, 10);								
						}
						
					}
					primerPase++;
				}
				string aux(mandar);
                fifo2 << "$" + aux << endl;
                //write(send_fd, "$", 1);
                //write(send_fd, mandar, strlen(mandar));
				//write(send_fd, "\n", 1);
                fifo2.close();
				fseek(arch, 0L, SEEK_SET);										
			}


            if(tmp[0]=='S' && tmp[1]=='T' &&tmp[2]=='O' && tmp[3]=='C' && tmp[4]=='K' && tmp[5]==' ')
			{
				int total=0;

                ofstream fifo2(SEND_FIFO);
				
				char nombre[20];
				char linea[100];
				int primerPase=0;
				char stock[10];
				int larg= strlen(tmp);
				
				char subtext[249];
				strncpy(subtext, &tmp[6], strlen(tmp)-1 );
                                
				char mandar[20];
                char unidades[10]= "";
						
				while(fgets(linea, sizeof(linea), arch))
				{
					if (primerPase>0){
							
						int largo = strlen(linea);
						linea[largo-2]='\0';
						
						char * aux;

						for(int i=0; i<4; i++)
						{
							aux= strrchr(linea, ';');
							*aux= '\0';

							if(i==0)
								strcpy(unidades, aux+1);
							
							if(i==3)
								strcpy(nombre, aux+1);							
						}
						
						if(strcmp(linea, subtext)==0)
                            fifo2 << string(linea) + " " + string(nombre) + " " + string(unidades) + "u\n" << ends;
					}
					primerPase++;
				}
                fifo2.close();
				fseek(arch, 0L, SEEK_SET);										
			}


			if(strcmp(tmp, "QUIT")==0)
			{
				fclose(arch);
                system("clear");
				sem_close(semaforo);
				sem_unlink("servidorFIFO");
				unlink(SEND_FIFO);
				unlink(RECEIVE_FIFO);
				exit(EXIT_SUCCESS);
			}
			fflush (stdout); 
		}
	}
	else if (pid> 0)
		exit(EXIT_SUCCESS);
}

void inicializarSemaforo(){
    semaforo = sem_open("servidorFIFO",O_CREAT,0600,1);
    
    // Si dicho semaforo vale 0 en ese momento significa que ya hay otra instancia de semaforo ejecutando por lo que cerramos el proceso.
    int valorSemServi = 85;
    sem_getvalue(semaforo,&valorSemServi);
    if(valorSemServi == 0)
        exit(EXIT_FAILURE);
}

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