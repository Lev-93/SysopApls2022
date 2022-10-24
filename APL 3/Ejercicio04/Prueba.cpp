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

using namespace std;

typedef struct {
    char situacion[4]; // ALTA (ingreso/rescatado) BAJA (adopcion/egreso)
    char nombre[20];
    char raza[20];
    char sexo;    // M o H
    char estado[2]; // CA (castrado) o SC (sin castrar) 
}gato;

//int mostrarGato(const char[20]);

void hola(int);


int main(){
    pid_t pid, sid;
    int i;

    // Ignora la señal de E / S del terminal, señal de PARADA
	signal(SIGTTOU,SIG_IGN);
	signal(SIGTTIN,SIG_IGN);
	signal(SIGTSTP,SIG_IGN);
	signal(SIGHUP,SIG_IGN);

    pid = fork();
    if (pid < 0) {
        exit(EXIT_FAILURE); // Finaliza el proceso padre, haciendo que el proceso hijo sea un proceso en segundo plano
    }
    if (pid > 0) {
        exit(EXIT_SUCCESS);
    }

    //umask(0);
    
    // Cree un nuevo grupo de procesos, en este nuevo grupo de procesos, el proceso secundario se convierte en el primer proceso de este grupo de procesos, de modo que el proceso se separa de todos los terminales    

    sid = setsid();

    if (sid < 0) {
         exit(EXIT_FAILURE);
    }

	// Cree un nuevo proceso hijo nuevamente, salga del proceso padre, asegúrese de que el proceso no sea el líder del proceso y haga que el proceso no pueda abrir una nueva terminal
	pid=fork();
	if( pid > 0) {
		exit(EXIT_SUCCESS);
	}
	else if( pid< 0) {
		exit(EXIT_FAILURE);
	}

    /* close(STDIN_FILENO); close(STDOUT_FILENO); close(STDERR_FILENO); */

     
	// Cierre todos los descriptores de archivos heredados del proceso padre que ya no son necesarios
	for(i=0;i< NOFILE;close(i++));

    // Cambia el directorio de trabajo para que el proceso no contacte con ningún sistema de archivos
    if ((chdir("/")) < 0) {
        exit(EXIT_FAILURE);
    }    

	// Establece la palabra de protección del archivo en 0 en el momento
	umask(0);

    // Ignora la señal SIGCHLD
	signal(SIGCHLD,SIG_IGN); 

    while(1){
        /*
        ofstream archivo;
        archivo.open("demonPrueba.txt",ios::app); // abre o crea el archivo
        if(archivo.fail()){
            cout << "no se pudo abrir el archivo" << endl;
            exit(1);
        }
        archivo << "Ejecutando el demonio" << endl;
        archivo.close();
        */
    }
}

//int main(){
//    printf("ejecutando el proceso Prueba");
//    signal(SIGUSR1, hola);
//    signal(SIGINT,SIG_IGN);
//    while(1){
//        printf("cabra");
//        sleep(5);
//    }
//    printf("hi...\n");
//    signal(SIGINT,hola);
//        while(true){
//         //if(signal(SIGINT,&hola) != SIG_ERR){
//             printf("cabra\n");
//             sleep(2);
         //}
//         }
//}
/*
int mostrarGato(const char nombre[20]){
    gato g;
    ifstream archivo;
    string texto;
    char gatito[60];
    char *pch;
    archivo.open("g.txt",ios::in);
    if(archivo.fail()){
        cout << "no se pudo abrir el archivo" << endl;
        exit(1);
    }

    int cont = 0;

    while(!archivo.eof()){
        getline(archivo,texto);
        strcpy(gatito,texto.c_str());
        cout << texto << endl;
        //aqui obtenemos la situacion del gato
        pch = strtok(gatito, "|");
        //aqui obtenemos el nombre del gato
        pch = strtok(NULL, "|");
        if(strcmp(nombre,pch) == 0){
            cout << "el gato ha sido encontrado" << endl;
            cout << pch << endl;
            archivo.close();
            return cont;
        }
        cont++;
    }
    archivo.close();
    return -1;
}
*/

void hola(int sig){
    cout << "fin de proceso hijo/demonio" << endl;
    exit(EXIT_SUCCESS);
}
