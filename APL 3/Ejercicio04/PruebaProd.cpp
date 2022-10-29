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
    char situacion[5]; // ALTA (ingreso/rescatado) BAJA (adopcion/egreso)
    char nombre[21];
    char raza[21];
    char sexo[2];    // M o H
    char estado[3]; // CA (castrado) o SC (sin castrar) 
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

#define MemoriaAux "miMmemoriaPrueba"
acciones* abrir_mem_comp();
void cerrar_mem_comp(acciones*);

int main(){
    acciones *memoria = abrir_mem_comp();
    
    string tmp_consulta(memoria->consulta);
    cout << tmp_consulta << endl;
    string tmp_situacion(memoria->g.situacion);
    cout << tmp_situacion << endl;
    
    strcpy(memoria->consulta,"Enviado");
    strcpy(memoria->g.situacion,"ALTA");
    
    cerrar_mem_comp(memoria);
    return EXIT_SUCCESS;
}

acciones* abrir_mem_comp(){
    int idMemoria = shm_open(MemoriaAux, O_CREAT | O_RDWR, 0600); // obtenemos un numero que nos identifica esta memoria.
    // definir nuestra variable que es la variable que estara mapeada a memoria compartida.
    // la memoria compartida ya esta creada y tenermos un identificador, pero no podemos accederla..
    //me va a determinar/setear el tamaño de la memoria, asociara los tamaños y nos limpiara un poco lo que hay allí dentro.
    ftruncate(idMemoria,sizeof(acciones));

    //me va a mapear, o a relacionar un segmento de memoria a una variable. agarra un espacio de memoria y mapearlo/darnos la direccion de memoria de ese espacio de memoria.
    acciones *memoria = (acciones *)mmap(NULL, sizeof(acciones), PROT_READ | PROT_WRITE, MAP_SHARED, idMemoria,0);

    close(idMemoria);
    return memoria;
}

void cerrar_mem_comp(acciones *a){
    munmap(a, sizeof(acciones));
}