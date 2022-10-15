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
//necesitamos un identificador para la memoria compartida para que los diferentes procesos que vayan a utilizarla tengan una manera de referenciarla
#define NombreMemoria "miMmemoria"

acciones accion*;

bool Ayuda(const char *);
void int_Handler(int);
void ctrl_Handler(int);
int consultarArchivo(const char[20]);
int escribirArchivo(gato);
int modificar_Archivo(char[20]);
gato devolver_gato(char[20]);
void obtener_Rescatados(const char[]);

int main(){

    signal(SIGINT, ctrl_Handler);
    signal(SIGUSR1, int_Handler);

    /* Declaramos nuestro ID de proceso y nuestro ID de sección */
    pid_t pid, sid;
    /*
        Al usar el comando fork el padre obtendra un PID del hijo mientras que el hijo obtendra un 0
        si el valor lanzado por el fork es menor a 0 entonces hubo algun error...
        mientras que el padre cierra exitosamente, el hijo quedara ejecutando.
    */
    pid = fork();
    if (pid < 0) {
        exit(EXIT_FAILURE);
    }
    if (pid > 0) {
        exit(EXIT_SUCCESS);
    }

    /* a partir de aqui comienza la ejecución del proceso hijo */

    /* Con umask garantizas que se puedan leer y escribir correctamente los archivos creado por el demonio */
    umask(0);

    /* aqui abrimos los registros para escritura*/       
                
    /* Create a new SID for the child process */
    /*
        con setid le damos al proceso secundario un SID unico del kernel para poder operar,
        sino lo ponemos, el proceso queda como un proceso huerfano en el sistema,
        usamos la variable "sid" para crear un nuevo SID para el proceso hijo
        El sid tiene el mismo retorno que el fork por lo que el manejo de este es similar,
        si el valor es menor a 0 hubo un error.
    */
    sid = setsid();
    if (sid < 0) {
         exit(EXIT_FAILURE);
    }
        
    /* Cambiamos el directorio de trabajo actual por uno que garantize que siempre estara alli
        por lo tanto lo cambiamos por el directorio raíz,
        si ocurre alguna falla cerramos el programa */
    if ((chdir("/")) < 0) {
        exit(EXIT_FAILURE);
    }
        
    /* Debemos cerrar los descriptores estandar, ya que un demonio no puede usar una terminal */
    close(STDIN_FILENO);
    close(STDOUT_FILENO);
    close(STDERR_FILENO);
        
    /* A partir de aqui comenzamos con el código de enunciado */

    /* creamos el archivo que contendrá toda la información acerca de cada gato que quiera adoptarse */

    ofstream archivo;
    archivo.open("gatos.txt",ios::out); // abre o crea el archivo
    if(archivo.fail()){
        cout << "no se pudo abrir el archivo" << endl;
        exit(1);
    }
    archivo.close();

    /*************************************************************************************************/
    
    //crear la memoria compartida
    int idMemoria = shm_open(NombreMemoria, 0_CREAT | 0_RDWR, 0600); // obtenemos un numero que nos identifica esta memoria.
    //me va a determinar/setear el tamaño de la memoria, asociara los tamaños y nos limpiara un poco lo que hay allí dentro.
    ftruncate(idMemoria,sizeof(acciones));

    // definir nuestra variable que es la variable que estara mapeada a memoria compartida.
    // la memoria compartida ya esta creada y tenermos un identificador, pero no podemos accederla..

    //me va a mapear, o a relacionar un segmento de memoria a una variable. agarra un espacio de memoria y mapearlo/darnos la direccion de memoria de ese espacio de memoria.
    acciones *memoria = (acciones*)mmap(NULL, sizeof(acciones), PROT_READ | PROT_WRITE, MAP_SHARED, idMemoria,0);

    close(idMemoria);

    // con esto ya no estara relacionado más a la memoria compartida. Quizas cambiarlo ya que tendremos que cerrarla cuando se envie la señal
    munmap(memoria, sizeof(acciones));

    while (1) {
        
        while(memoria->alta == 0 && memoria->baja == 0 && memoria->consultar == 0);

        if(memoria->alta == 1){
            if(escribirArchivo(memoria->g) == -1){
                strcpy(memoria->notialta,"El nombre ya existe, pruebe con otro");
            }
            memoria->alta = 0;
        }

        if(memoria->baja == 1){
            if(modificar_Archivo(memoria->g.nombre) == -1){
                strcpy(memoria->notibaja,"El gato no se encuentra registrado, vuelva a intentarlo");
            }
            memoria->baja = 0;
        }

        if(memoria->consultar == 1){
            if(strcmp(memoria->consulta,"") != 0){ //significa que se ingreso el nombre
                if(consultarArchivo(memoria->consulta) == -1){
                    strcpy(memoria->consulta,"El gato no se encuentra registrado");
                }
                else{   //si el gato si fue encontrado...
                    memoria->g = devolver_gato(memoria->consulta);
                }
            }
            else{ //mostrar toda la tabla de TODOS LOS GATOS RESCATADOS, es decir, los que poseen ALTA
                obtener_Rescatados(memoria->rescatados);
            }
            memoria->consultar = 0;
        }

        sleep(5); /* wait 5 seconds */
    }
   exit(EXIT_SUCCESS);
}

void int_Handler(int signum)
{
    /*
    liberarSemaforos();
    usleep(1000000);
    cerrarEliminarSem();
    shmdt(datoPartida);
    shmctl(shmid,IPC_RMID,NULL);
    exit(0);
    */
}

void ctrl_Handler(int signum){

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

int consultarArchivo(const char nombre[20]){
    gato g;
    ifstream archivo;
    string texto;
    chat gatito[60];
    char *pch;
    archivo.open("gatos.txt",ios::in);
    if(archivo.fail()){
        cout << "no se pudo abrir el archivo" << endl;
        exit(1);
    }

    int cont = 0;

    while(!archivo.eof()){
        getline(archivo,texto);
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

int escribirArchivo(gato g){
    if(consultarArchivo(g.nombre) >= 0){
        return -1;  //si ya esta, se debe escribir el mensaje en memoria->notialta que ya esta el nombre usado y este es único.
    }
    ofstream archivo;
    archivo.open("gatos.txt",ios::app);
    if(archivo.fail()){
        cout << "no se pudo abrir el archivo" << endl;
        exit(1);
    }
    archivo << g.situacion + "|" + g.nombre + "|" + g.raza + "|" + g.sexo + "|" + g.estado << endl;
    archivo.close();
    return 1;
}

int modificar_Archivo(char nombre[20]){
    ofstream archivo;
    if(archivo.fail()){
        cout << "no se pudo abrir el archivo" << endl;
        exit(1);
    }
    if(consultarArchivo(g.nombre) < 1){
        return -1;  //si no existe, se debe escribir el mensaje en memoria->notibaja que ya esta el nombre usado y este es único.
    }

    //cambiamos el ALTA, por BAJA en dicho gato

    archivo.close();
    return 0;
}

gato devolver_gato(char nombre[20]){
    gato g;
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

    while(!archivo.eof()){
        getline(archivo,texto);
        strcpy(gatito,texto.c_str());

        //aqui obtenemos la situacion del gato
        pch = strtok(gatito, "|");
        //aqui obtenemos el nombre del gato
        strcpy(situacion,pch);
        pch = strtok(NULL, "|");
        if(strcmp(nombre,pch) == 0){
            strcpy(g.situacion,situacion);
            strcpy(g.nombre,pch);
            pch = strtok(NULL, "|");
            strcpy(g.raza, pch);
            pch = strtok(NULL, "|");
            strcpy(g.sexo,pch);
            pch = strtok(NULL, "|");
            strcpy(g.estado, pch);
            archivo.close();
            return g;
        }
    }

    archivo.close();

    return NULL;
}

void obtener_Rescatados(const[] path){
    ifstream archivo1;
    ofstream archivo2;
    string texto;
    char gatito[60];
    char *pch;

    archivo1.open("gatos.txt",ios::in);
    if(archivo1.fail()){
        cout << "no se pudo abrir el archivo gatos.txt" << endl;
        exit(1);
    }

    archivo2.open(path,ios::out);
    if(archivo2.fail()){
        cout << "no se pudo abrir el archivo rescatados.txt" << endl;
        exit(1);
    }

    while(!archivo1.eof()){
        getline(archivo,texto);
        strcpy(gatito,texto.c_str());
        pch = strtok(gatito, "|");
        if(strcpy(pch,"ALTA") == 0) {     //consideramos a los gatos en situación de ALTA como rescatados.
            archivo2 << texto << endl;
        }
    }
    archivo1.close();
    archivo2.close();
}
