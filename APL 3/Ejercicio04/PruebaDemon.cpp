#include <iostream>
#include <fstream>
#include <sys/mman.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctime>
#include <cerrno>
#include <unistd.h>
#include <semaphore.h>
#include <fcntl.h>
#include <cstring>
#include <signal.h>
#include <vector>
#include <string>
#include <string.h>
#include <sys/types.h>
#include <linux/fs.h>
#include <sys/param.h>
#include <time.h>
#include <syslog.h>
 
int init_daemon(void) 
{ 
	int pid; 
	int i; 
    printf("paso por aca daemon");
	// Ignora la señal de E / S del terminal, señal de PARADA
	signal(SIGTTOU,SIG_IGN);
	signal(SIGTTIN,SIG_IGN);
	signal(SIGTSTP,SIG_IGN);
	signal(SIGHUP,SIG_IGN);
	
	pid = fork();
	if(pid > 0) {
		exit(0); // Finaliza el proceso padre, haciendo que el proceso hijo sea un proceso en segundo plano
	}
	else if(pid < 0) { 
		return -1;
	}
 
	// Cree un nuevo grupo de procesos, en este nuevo grupo de procesos, el proceso secundario se convierte en el primer proceso de este grupo de procesos, de modo que el proceso se separa de todos los terminales
	setsid();
 
	// Cree un nuevo proceso hijo nuevamente, salga del proceso padre, asegúrese de que el proceso no sea el líder del proceso y haga que el proceso no pueda abrir una nueva terminal
	pid=fork();
	if( pid > 0) {
		exit(0);
	}
	else if( pid< 0) {
		return -1;
	}
 
	// Cierre todos los descriptores de archivos heredados del proceso padre que ya no son necesarios
	for(i=0;i< NOFILE;close(i++));
 
	// Cambia el directorio de trabajo para que el proceso no contacte con ningún sistema de archivos
	chdir("/");
 
	// Establece la palabra de protección del archivo en 0 en el momento
	umask(0);
 
	// Ignora la señal SIGCHLD
	signal(SIGCHLD,SIG_IGN); 
	
	return 0;
}
 
int main() 
{ 
	time_t now;
	init_daemon();
    printf("paso por aca main");
	syslog(LOG_USER|LOG_INFO,"TestDaemonProcess! \n");
	while(1) { 
		sleep(8);
		time(&now); 
		syslog(LOG_USER|LOG_INFO,"SystemTime: \t%s\t\t\n",ctime(&now));
	} 
}