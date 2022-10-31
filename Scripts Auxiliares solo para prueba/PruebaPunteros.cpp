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

void mostrar_nombre(gato*);

int main(){
    acciones a;
    a.alta = 1;
    strcpy(a.g.nombre,"Snowball");
    
    gato *aux = (gato*)malloc(sizeof(gato));
    strcpy(aux->nombre,a.g.nombre);
    mostrar_nombre(aux);
}

void mostrar_nombre(gato *g){
    string tmp_nombre(g->nombre);
    cout << tmp_nombre << endl;
}
