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
#include <string.h>
#include <time.h>
#include <fcntl.h>
#include <cstring>
#include <sys/types.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <string>


typedef struct {
    char situacion[5]; // ALTA (ingreso/rescatado) BAJA (adopcion/egreso)
    char nombre[21];
    char raza[21];
    char sexo[2];    // M o H
    char estado[3]; // CA (castrado) o SC (sin castrar) 
}gato;

#define SERV_HOST_ADDR "127.0.0.1"     /* IP, only IPV4 support  */

using namespace std;

string realizar_Actividades(const char[]);

int main(int argc, char *argv[]){
    string respuesta = realizar_Actividades(argv[1]);
    cout << respuesta << endl;
}

string realizar_Actividades(const char mensaje[]){
    char aux[2000];
    strcpy(aux,mensaje);
    char *p = strtok(aux,"|");
    if(strcmp(p,"ALTA") == 0){
        gato *g = (gato*)malloc(sizeof(gato));
        if(g == NULL)
            exit(EXIT_FAILURE);
        strcpy(g->situacion,p);
        p = strtok(NULL,"|");
        strcpy(g->nombre,p);
        p = strtok(NULL,"|");
        strcpy(g->raza,p);
        p = strtok(NULL,"|");
        strcpy(g->sexo,p);
        p = strtok(NULL,"|");
        strcpy(g->estado,p);
        puts(g->situacion);
        puts(g->nombre);
        puts(g->raza);
        puts(g->sexo);
        puts(g->estado);
        free(g);
        return "esta es una string por alta";
    }
    else{
        if(strcmp(p,"BAJA") == 0){
            char *ptr_nombre = strtok(NULL,"|");
            puts(p);
            puts(ptr_nombre);
            return "esta es una string por baja";
        }
        else{
            // La accion a realizar es consultar en este caso.
            char *ptr_nombre = strtok(NULL,"|");
            puts(p);
            puts(ptr_nombre);
            return "esta es una string por consulta";
        }
    }
    return NULL;
}
