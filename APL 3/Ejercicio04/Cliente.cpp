#include <iostream>
#include <fstream>
#include <sys/mman.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctime>
#include <cerrno>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <semaphore.h>
#include <fcntl.h>
#include <cstring>
#include <signal.h>
#include <vector>

typedef struct {
    char situacion[4]; // ALTA (ingreso/rescatado) BAJA (adopcion/egreso)
    char nombre[20];
    char raza[20];
    char sexo;    // M o H
    char estado[2]; // CA (castrado) o SC (sin castrar) 
}gato;

typedef struct {
	int baja;
	int alta;
	int consultar;
	char notibaja[100];
	char notialta[100];
	char consulta[100];
    gato g;
    char rescatados[20]; //nombre del archivo que se creara cada ves que se inicie una consulta general
}acciones;

using namespace std;

#define NombreMemoria "miMmemoria"

acciones accion*;

bool Ayuda(const char *);

int main(){
    //crear la memoria
    int idMemoria = shm_open(NombreMemoria, 0_CREAT | 0_RDWR, 0600); // obtenemos un numero que nos identifica esta memoria.

    // definir nuestra variable que es la variable que estara mapeada a memoria compartida.
    // la memoria compartida ya esta creada y tenermos un identificador, pero no podemos accederla..

    //me va a mapear, o a relacionar un segmento de memoria a una variable. agarra un espacio de memoria y mapearlo/darnos la direccion de memoria de ese espacio de memoria.
    acciones *memoria = (acciones *)mmap(NULL, sizeof(acciones), PROT_READ | PROT_WRITE, MAP_SHARED, idMemoria,0);

    close(idMemoria);

    cout << "Valor de la memoria: " << memoria->alta << " " << memoria->notialta << endl;

    // con esto ya no estara relacionado más a la memoria compartida.
    munmap(memoria, sizeof(int));
    return EXIT_SUCCESS;
}

bool Ayuda(const char *cad)
{
    if (!strcmp(cad, "-h") || !strcmp(cad, "--help") )
    {
        cout << endl;
        return true;
    }
    return false;
}