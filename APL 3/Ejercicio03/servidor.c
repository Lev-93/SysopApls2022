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

 
char sender_name[] = "SERVIDOR";
char receiver_name[] = "CLIENTE";
#define SEND_FIFO "FIFO2"
#define RECEIVE_FIFO "FIFO1"


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

void comunicacion_fifos(FILE * arch)
{    
	pid_t pid;
	
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
			int ret;
 
			ret = read(receive_fd, tmp, sizeof(tmp));
			if(ret == 0)
			{
				break;
			}
			printf("\r\e[K%s:%s\n", receiver_name, tmp);
			printf("Respuesta de consulta %s enviada exitosamente al %s.\n", tmp, receiver_name);
		
			if(strcmp(tmp, "LIST")==0)
			{
				int send_fd;
				send_fd = open(SEND_FIFO, O_WRONLY);
				
				char linea[100];
				int primerPase=0;

				while(fgets(linea, sizeof(linea), arch))
				{
					if (primerPase > 0)
						write(send_fd, linea, strlen(linea));
					primerPase++;
				}

				fseek(arch, 0L, SEEK_SET);				
			}

			if(strcmp(tmp, "SIN_STOCK")==0)
			{
				int send_fd;
				send_fd = open(SEND_FIFO, O_WRONLY);
				
				char linea[100];
				int primerPase = 0;

				while(fgets(linea, sizeof(linea), arch))
				{
					if (primerPase > 0)
					{
						int longitudLinea = strlen(linea);
						
						//me fijo que luego del último punto y coma haya un 0
                        if(linea[longitudLinea-3]=='0' && linea[longitudLinea-4]==';'){
                            write(send_fd, linea, strlen(linea));
                        }
					}
					primerPase++;
				}

				fseek(arch, 0L, SEEK_SET);
			}


            if(tmp[0]=='R' && tmp[1]=='E' &&tmp[2]=='P' && tmp[3]=='O' && tmp[4]==' ')
			{
				int total=0;
				int send_fd;

				send_fd = open(SEND_FIFO, O_WRONLY);
				
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
		
                write(send_fd, "$", 1);
                write(send_fd, mandar, strlen(mandar));
				write(send_fd, "\n", 1);

				fseek(arch, 0L, SEEK_SET);										
			}


            if(tmp[0]=='S' && tmp[1]=='T' &&tmp[2]=='O' && tmp[3]=='C' && tmp[4]=='K' && tmp[5]==' ')
			{
				int total=0;
				int send_fd;

				send_fd = open(SEND_FIFO, O_WRONLY);
				
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
						{
							write(send_fd, linea, strlen(linea));
							write(send_fd, " ", 1);
							write(send_fd, nombre, strlen(nombre));
							write(send_fd, " ", 1);
							write(send_fd, unidades, strlen(unidades));
							write(send_fd, "u", 1);
							write(send_fd, "\n", 1);
						}

					}
					primerPase++;
				}

				fseek(arch, 0L, SEEK_SET);										
			}


			if(strcmp(tmp, "QUIT")==0)
			{
				fclose(arch);
                system("clear");
				kill(pid, SIGTERM);
			}
			
			printf("AGUARDANDO CONSULTA DEL CLIENTE..");
			fflush (stdout); 
		}
	}
	
	else if (pid> 0) // enviar mensaje
	{
		int send_fd;
		send_fd = open(SEND_FIFO, O_WRONLY);

		while(1)
		{
			char tmp[255] = "";

			printf("AGUARDANDO CONSULTA DEL CLIENTE..");
			fflush(stdout);
			fgets(tmp, sizeof(tmp), stdin);
			tmp[strlen (tmp) -1] = 0; 						
		}
	}
}
 
int main(int argc, char * argv[])
{
	//Ignora el ctrl+C
	signal(SIGINT,SIG_IGN);

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
		
	comunicacion_fifos(arch);

	unlink(SEND_FIFO);
	unlink(RECEIVE_FIFO);

	return EXIT_SUCCESS;
}