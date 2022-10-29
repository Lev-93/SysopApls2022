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
 
typedef struct {
    char situacion[4]; // ALTA (ingreso/rescatado) BAJA (adopcion/egreso)
    char nombre[20];
    char raza[20];
    char sexo[1];    // M o H
    char estado[2]; // CA (castrado) o SC (sin castrar) 
}gato;
 using namespace std;
//necesitamos un identificador para la memoria compartida para que los diferentes procesos que vayan a utilizarla tengan una manera de referenciarla
#define NombreMemoria "miMmemoria"

int main() 
{ 
//crear la memoria compartida
    int idMemoria = shm_open(NombreMemoria, O_CREAT | O_RDWR, 0600); // obtenemos un numero que nos identifica esta memoria.
    //me va a determinar/setear el tamaño de la memoria, asociara los tamaños y nos limpiara un poco lo que hay allí dentro.
    ftruncate(idMemoria,sizeof(gato));

    // definir nuestra variable que es la variable que estara mapeada a memoria compartida.
    // la memoria compartida ya esta creada y tenermos un identificador, pero no podemos accederla..

    //me va a mapear, o a relacionar un segmento de memoria a una variable. agarra un espacio de memoria y mapearlo/darnos la direccion de memoria de ese espacio de memoria.
    gato *memoria = (gato*)mmap(NULL, sizeof(gato), PROT_READ | PROT_WRITE, MAP_SHARED, idMemoria,0);

    close(idMemoria);

    // con esto ya no estara relacionado más a la memoria compartida. Quizas cambiarlo ya que tendremos que cerrarla cuando se envie la señal
    munmap(memoria, sizeof(gato));

}