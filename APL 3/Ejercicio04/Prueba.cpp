#include <fstream>
#include <iostream>
#include <stdlib.h>
#include <string>
#include <string.h>
#include <stdio.h>

using namespace std;

typedef struct {
    char nombre[20];
    char raza[20];
    char sexo;    // M o H
    char estado[2]; // CA (castrado) o SC (sin castrar) 
}gato;

int mostrarGato(const char[20]);

int main(){
    int pos = mostrarGato("Lola Mora");
    cout << "posicion: " << pos << endl;
}

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