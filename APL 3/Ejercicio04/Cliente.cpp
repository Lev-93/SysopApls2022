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

#define NombreMemoria "miMmemoria"

bool Ayuda(const char *);
acciones* abrir_mem_comp();
void cerrar_mem_comp(acciones*);
int leer_rescatados(const char[]);

int main(int argc, char *argv[]){
    if((strcmp(argv[1],"-h") == 0 || strcmp(argv[1],"--help") == 0) && argc == 2){
        Ayuda(argv[1]);
        exit(EXIT_SUCCESS);
    }

    //  P(Cliente)
    //  P(TC)
    if(strcmp(argv[1],"ALTA") == 0){
        if(argc == 6){
            // P(MC)
            acciones *a = abrir_mem_comp();
            strcpy(a->g.situacion,argv[2]);
            strcpy(a->g.nombre,argv[3]);
            strcpy(a->g.raza,argv[4]);
            strcpy(a->g.sexo,argv[5]);
            strcpy(a->g.estado,argv[6]);
            a->alta = 1;
            cerrar_mem_comp(a);
            // V(MC)    liberamos la memoria compartida
            // V(TS)    le damos el turno al servidor
            //P(TC)     bloqueamos el turno del cliente, como este estara en 0 en este momento, se bloqueara el proceso a la espera de que el servidor termine su turno.

            // P(MC)
            a = abrir_mem_comp();
            if(strcmp(a->notialta,"") != 0){
                string tmp_notialta(a->notialta);   
                cout << tmp_notialta << endl;   // el servidor le notifico al cliente que el nombre del gato ya existe.
                strcpy(a->notialta,"");
            }
            cerrar_mem_comp(a);
            // V(MC)
        }
        else{
            cout << "Error, cantidad de parametros erronea junto a la acción alta.";
            //V(TC)
            //V(Cliente)
            exit(EXIT_FAILURE);
        }
    }
    if(strcmp(argv[1],"BAJA") == 0){
        if(argc == 3){
            // P(MC)
            acciones *a = abrir_mem_comp();
            strcpy(a->g.nombre,argv[2]);
            a->baja = 1;
            cerrar_mem_comp(a);
            // V(MC)
            // V(TS)
            // P(TC)
            // P(MC)
            a = abrir_mem_comp();
            if(strcmp(a->notibaja,"") != 0){
                string tmp_notibaja(a->notibaja);
                cout << tmp_notibaja << endl;
                strcpy(a->notibaja,"");
            }
            cerrar_mem_comp(a);
            // V(MC)
        }
        else{
            cout << "Error, cantidad de parametros erronea junto a la acción baja";
            //V(TC)
            //V(Cliente)
            exit(EXIT_FAILURE);
        }
    }

    if(strcmp(argv[1],"CONSULTA") == 0){
        if(argc == 3){
            //En caso de no mandar un nombre en concreto...
            // P(MC)
            acciones *a = abrir_mem_comp();
            strcpy(a->g.nombre,argv[2]);
            a->consultar = 1;
            cerrar_mem_comp(a);
            // V(MC)

            // V(TS)
            // P(TC)
            // P(MC)
            a = abrir_mem_comp();
            if(strcmp(a->consulta,"") != 0){
                string tmp_consulta(a->consulta);
                cout << tmp_consulta << endl;
                strcpy(a->consulta,"");
            }
            else{
                    string tmp_situacion(a->g.situacion);
                    string tmp_nombre(a->g.nombre);
                    string tmp_raza(a->g.raza);
                    string tmp_sexo(a->g.sexo);
                    string tmp_estado(a->g.estado);
                    cout << tmp_situacion + "|" + tmp_nombre + "|" + tmp_raza + "|" + tmp_sexo + "|" + tmp_estado;
                    strcpy(a->g.situacion,"");
                    strcpy(a->g.nombre,"");
                    strcpy(a->g.raza,"");
                    strcpy(a->g.sexo,"");
                    strcpy(a->g.estado,"");
            }
            cerrar_mem_comp(a);
            // V(MC)
        }
        else{
            if(argc == 2){
                // P(MC)
                acciones *a = abrir_mem_comp();
                strcpy(a->consulta,"rescatados.txt");
                a->consultar = 1;
                cerrar_mem_comp(a);
                //V(MC)
                // V(TS)
                // P(TC)
                // P(MC)
                a = abrir_mem_comp();
                if(strcmp(a->consulta,"") != 0){
                    string tmp_consulta(a->consulta);
                    cout << tmp_consulta << endl;
                    strcpy(a->consulta,"");
                }
                else
                    int res = leer_rescatados(a->rescatados);
                cerrar_mem_comp(a);
                // V(MC)
            }
            else{
                cout << "Error, cantidad de parametros erronea junto a la acción consultar";
                //V(CS)
                //V(Cliente)
                exit(EXIT_FAILURE);
            }
        }
    }
    // V(Cliente)
    // V(TS)
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

acciones* abrir_mem_comp(){
    int idMemoria = shm_open(NombreMemoria, O_CREAT | O_RDWR, 0600); // obtenemos un numero que nos identifica esta memoria.

    // definir nuestra variable que es la variable que estara mapeada a memoria compartida.
    // la memoria compartida ya esta creada y tenermos un identificador, pero no podemos accederla..

    //me va a mapear, o a relacionar un segmento de memoria a una variable. agarra un espacio de memoria y mapearlo/darnos la direccion de memoria de ese espacio de memoria.
    acciones *memoria = (acciones *)mmap(NULL, sizeof(acciones), PROT_READ | PROT_WRITE, MAP_SHARED, idMemoria,0);

    close(idMemoria);
    return memoria;
}

void cerrar_mem_comp(acciones *a){
    munmap(a, sizeof(acciones));
}

int leer_rescatados(const char path[20]){
    ifstream archivo;
    string texto;
    string tmp_path(path);
    archivo.open(tmp_path,ios::in);
    if(archivo.fail()){
        cout << "no se pudo abrir el archivo" << endl;
        return -1;
    }
    while(!archivo.eof()){
        getline(archivo,texto);
        cout << texto << endl;
    }
    archivo.close();
    remove(path);
    return 0;
}