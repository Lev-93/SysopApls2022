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
    gato *g;
    char rescatados[20]; //nombre del archivo que se creara cada ves que se inicie una consulta general
}acciones;

int consultarArchivo(const char[20]);
int escribirArchivo(gato*);
int modificar_Archivo(const char[20]);
gato* devolver_gato(const char[20]);
int obtener_Rescatados(const char*);

acciones* accion;

using namespace std;

int main(){
    string cadena = "BAJA|Mandarina";
    //gato *g = (gato*)malloc(sizeof(gato));
    //if(g == NULL){
    //    exit(EXIT_FAILURE);
    //}
    //strcpy(g->situacion,"ALTA");
    //strcpy(g->nombre,"Snowball");
    //strcpy(g->raza,"siames");
    //strcpy(g->sexo,"M");
    //strcpy(g->estado,"CA");
    //cout << "61" << endl;
    //int res = escribirArchivo(g);
    //printf("%d\n",res);
    //strcpy(g->situacion,"ALTA");
    //strcpy(g->nombre,"Mandarina");
    //strcpy(g->raza,"siames");
    //strcpy(g->sexo,"H");
    //strcpy(g->estado,"SC");
    //cout << "69" << endl;
    //res = escribirArchivo(g);
    //printf("%d\n",res);
    //free(g);
    char gatito[60];
    strcpy(gatito,cadena.c_str());
    char *ptr;
    ptr = strtok(gatito,"|");
    puts(ptr);
    ptr = strtok(NULL,"|");
    puts(ptr);
    int res = modificar_Archivo(ptr);
    printf("%d\n",res);
    //g = devolver_gato("Mandarina");
    //puts(g->nombre);
    //puts(g->raza);
    //free(g);
} 

int consultarArchivo(const char nombre[21]){
    ifstream archivo("gatos.txt");
    if(!archivo.is_open()){
        return -2;
    }
    string texto;
    char gatito[100];
    char *pch;
    int cont = 1;
    getline(archivo,texto);
    while(getline(archivo,texto)){
        strcpy(gatito,texto.c_str());
        //aqui obtenemos la situacion del gato
        pch = strtok(gatito, "|");
        //aqui obtenemos el nombre del gato
        pch = strtok(NULL, "|");
        if(strcmp(nombre,pch) == 0){
            archivo.close();
            return cont;
        }
        cont++;
    }
    archivo.close();
    return -1;
}

int escribirArchivo(gato *g){
    if(consultarArchivo(g->nombre) >= 0){
        return -1;
    }
    ofstream archivo;
    archivo.open("gatos.txt",ios::app);
    if(archivo.fail()){
        return -2;
    }
    string tmp_situacion(g->situacion);
    string tmp_nombre(g->nombre);
    string tmp_raza(g->raza);
    string tmp_sexo(g->sexo);
    string tmp_estado(g->estado);
    archivo << "\n" + tmp_situacion + "|" + tmp_nombre + "|" + tmp_raza + "|" + tmp_sexo + "|" + tmp_estado;
    archivo.close();
    return 1;
}

int modificar_Archivo(const char nombre[21]){
    int pos = consultarArchivo(nombre);
    string texto;
    char gatito[60];
    char *pch;
    if(pos == -1 || pos == -2){
        return -1;
    }
    ifstream archivo;
    archivo.open("gatos.txt",ios::in);
    if(archivo.fail()){
        return -1;
    }
    //cambiamos el ALTA, por BAJA en dicho gato
    ofstream auxiliar;
    auxiliar.open("auxiliar.txt",ios::out);
    if(auxiliar.fail()){
        archivo.close();
        return -1;
    }
    int cont = 1;
    getline(archivo,texto);
    auxiliar << texto;
    while(getline(archivo,texto)){
        strcpy(gatito,texto.c_str());
        //aqui obtenemos la situacion del gato
        if(pos == cont){    // es el gato a cambiar la situacion de ALTA a BAJA
            char *situacionvieja = strtok(gatito,"|");
            if(strcmp(situacionvieja,"BAJA") == 0){
                archivo.close();
                auxiliar.close();
                remove("auxiliar.txt");
                return -2;
            }
            else{
                char *nombregato = strtok(NULL,"|");
                char *raza = strtok(NULL,"|");
                char *sexo = strtok(NULL,"|");
                char *estado = strtok(NULL,"|");
                string tmp_nombregato(nombregato);
                string tmp_raza(raza);
                string tmp_sexo(sexo);
                string tmp_estado(estado);
                auxiliar << "\nBAJA|" + tmp_nombregato+ "|" + tmp_raza + "|" + tmp_sexo + "|" + tmp_estado;
            }
        }
        else{
            auxiliar << "\n" + texto;
        }
        pch = strtok(gatito, "|");
        //aqui obtenemos el nombre del gato
        pch = strtok(NULL, "|");
        cont++;
    }
    archivo.close();
    auxiliar.close();
    remove("gatos.txt");
    rename("auxiliar.txt","gatos.txt");
    return 0;
}

gato* devolver_gato(const char nombre[20]){
    gato *g = (gato*) malloc(sizeof(gato));
    ifstream archivo;
    string texto;
    char gatito[60];
    char *pch;
    char situacion[4];
    archivo.open("gatos.txt",ios::in);
    if(archivo.fail()){
        cout << "no se pudo abrir el archivo" << endl;
        exit(1);
    }

    while(getline(archivo,texto)){
        strcpy(gatito,texto.c_str());

        //aqui obtenemos la situacion del gato
        pch = strtok(gatito, "|");
        //aqui obtenemos el nombre del gato
        strcpy(situacion,pch);
        pch = strtok(NULL, "|");
        if(strcmp(nombre,pch) == 0){
            strcpy(g->situacion,situacion);
            strcpy(g->nombre,pch);
            pch = strtok(NULL, "|");
            strcpy(g->raza, pch);
            pch = strtok(NULL, "|");
            strcpy(g->sexo,pch);
            pch = strtok(NULL, "|");
            strcpy(g->estado, pch);
            archivo.close();
            return g;
        }
    }

    archivo.close();

    return NULL;
}

int obtener_Rescatados(const char *path){
    ifstream archivo1;
    ofstream archivo2;
    string texto;
    char gatito[100];
    char *pch;
    archivo1.open("gatos.txt",ios::in);
    if(archivo1.fail())
        return -1;
    string tempString(path);
    archivo2.open(tempString,ios::out);
    if(archivo2.fail()){
        archivo1.close();
        return -2;
    }
    while(!archivo1.eof()){
        getline(archivo1,texto);
        strcpy(gatito,texto.c_str());
        pch = strtok(gatito, "|");
        if(strcmp(pch,"ALTA") == 0) {     //consideramos a los gatos en situación de ALTA como rescatados.
            archivo2 << texto;
        }
    }
    archivo1.close();
    archivo2.close();
    return 0;
}