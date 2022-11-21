#include <iostream>
#include<unistd.h>
#include <stdlib.h>
#include<sys/wait.h>
#include<sys/types.h>
#include<signal.h>
#include <sys/param.h>
#include <sys/stat.h>
#include <syslog.h>
#include <string.h>
#include <termios.h>
using std::cout;
using std::endl;
int fin;
char getch();
void finalizar(int param);
int crearDemonio(); 
pid_t pidHijo1;
pid_t pidHijo2;
int main(int argc,char* argv[])
{
	
	
	if(argc>=2&&(!strcmp(argv[1],"-h")||!strcmp(argv[1],"--help")))
	{
		printf("El programa genera los siguientes procesos:");
		printf("\n2 procesos hijos  \n3 procesos nietos \n5 procesos bisnietos \n2 procesos zombies \n1 proceso demonio\n");
		printf("\nPor cada proceso, excepto el demonio, genera un mensaje:");
		printf("\nSoy el proceso con PID .... y pertenezco a la generación Nº .... Pid: .... Pid padre: ....Parentesco/Tipo: [nieto, hijo, zombie]\n");
		return 0;
				
	}else if(argc>=2)
	{
		printf("\nEl programa no requiere parametros use el parametro -h o --help para obetener una descripcion del programa\n");
		return 0;
	}
	pidHijo1=fork();
	signal(SIGUSR1,finalizar);		
	if(pidHijo1==0)
	{	
		pidHijo1=fork();
		if(pidHijo1==0)	
		{
				printf("Soy el proceso con PID %d y pertenezco a la generación Nº 2 Pid: %d Pid padre: %d Tipo:Zombie\n",getpid(),getpid(),getppid());
			return 0;
		}else
		{	
			printf("Soy el proceso con PID %d y pertenezco a la generación Nº 1 Pid: %d Pid padre: %d Parentesco:hijo\n",getpid(),getpid(),getppid());
			pidHijo2=fork();
			if(pidHijo2==0)
			{
				printf("Soy el proceso con PID %d y pertenezco a la generación Nº 2 Pid: %d Pid padre: %d Parentesco:Nieto\n",getpid(),getpid(),getppid());
				 pidHijo1=fork();
					if(pidHijo1==0)
					{
						printf("Soy el proceso con PID %d y pertenezco a la generación Nº 3 Pid: %d Pid padre: %d Parentesco:bisnieto\n",getpid(),getpid(),getppid());
					}else
					{
						pidHijo2=fork();
						if(pidHijo2==0)
						{
							printf("Soy el proceso con PID %d y pertenezco a la generación Nº 3 Pid: %d Pid padre: %d Parentesco:Zombie\n",getpid(),getpid(),getppid());
							crearDemonio();
							return 1;

						}
					
					}
						
			}
		}
	}
	else
	{
		
		pidHijo2=fork();
		
		if(pidHijo2==0)
		{
			printf("Soy el proceso con PID %d y pertenezco a la generación Nº 1 Pid: %d Pid padre: %d Parentesco:hijo\n",getpid(),getpid(),getppid());
				

			pidHijo1=fork();
			if(pidHijo1==0)
			{
				printf("Soy el proceso con PID %d y pertenezco a la generación Nº 2 Pid: %d Pid padre: %d Parentesco:nieto\n",getpid(),getpid(),getppid());
				pidHijo1=fork();
					if(pidHijo1==0)
					{
						printf("Soy el proceso con PID %d y pertenezco a la generación Nº 3 Pid: %d Pid padre: %d Parentesco:bisnieto\n",getpid(),getpid(),getppid());
					}else
					{
						pidHijo2=fork();
						if(pidHijo2==0)
						{
							printf("Soy el proceso con PID %d y pertenezco a la generación Nº 3 Pid: %d Pid padre: %d Parentesco:bisnieto\n",getpid(),getpid(),getppid());
						}
					}

			}else{
				pidHijo2=fork();
				
				if(pidHijo2==0)
				{
					printf("Soy el proceso con PID %d y pertenezco a la generación Nº 2 Pid: %d Pid padre: %d Parentesco:nieto\n",getpid(),getpid(),getppid());
					pidHijo1=fork();
					if(pidHijo1==0)
					{
						printf("Soy el proceso con PID %d y pertenezco a la generación Nº 3 Pid: %d Pid padre: %d Parentesco:bisnieto\n",getpid(),getpid(),getppid());
						
					}else
					{
						pidHijo2=fork();
						if(pidHijo2==0)
						{
							printf("Soy el proceso con PID %d y pertenezco a la generación Nº 3 Pid: %d Pid padre: %d Parentesco:bisnieto\n",getpid(),getpid(),getppid());
						}	
					}
				}
			}
					
		}else
		{
			sleep(3);
			printf("\nPresione alguna tecla para finalizar:");
			fflush(stdin);
			getch();
			finalizar(0);
			return 1;
		}
		
	}
	fin=0;
	while(fin==0)
	{
		
	}
	return 0;
}
void finalizar(int num)
{	
	//printf("\n\n pid1: %d y pid2:%d ",pidHijo1,pidHijo2);
	if(pidHijo1!=0)
		kill(pidHijo1,SIGUSR1);
	if(pidHijo2!=0)
		kill(pidHijo2,SIGUSR1);
	fin=1;
}
int crearDemonio() 
{ 
	int pid; 
	int i; 
	signal(SIGTTOU,SIG_IGN);
	signal(SIGTTIN,SIG_IGN);
	signal(SIGTSTP,SIG_IGN);
	signal(SIGHUP,SIG_IGN);
	
	setsid();
	pid=fork();
	if( pid > 0) {
		exit(0);
	}
	else if( pid< 0) {
		return -1;
	}
 

	for(i=0;i< NOFILE;close(i++));
 

	chdir("/");
	umask(0);
	signal(SIGCHLD,SIG_IGN); 
	while(1)
	{

	}	
	return 0;
}


char getch()
{
    char buf = 0;
    struct termios old = {0};
    fflush(stdout);
    if(tcgetattr(0, &old) < 0)
        perror("tcsetattr()");
    old.c_lflag &= ~ICANON;
    old.c_lflag &= ~ECHO;
    old.c_cc[VMIN] = 1;
    old.c_cc[VTIME] = 0;
    if(tcsetattr(0, TCSANOW, &old) < 0)
        perror("tcsetattr ICANON");
    if(read(0, &buf, 1) < 0)
        perror("read()");
    old.c_lflag |= ICANON;
    old.c_lflag |= ECHO;
    if(tcsetattr(0, TCSADRAIN, &old) < 0)
        perror("tcsetattr ~ICANON");
    printf("%c\n", buf);
    return buf;
 }
