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

bool Ayuda(const char *);
int leer_rescatados(const char[]);
bool validar_parametro(const char[]);
string enviarMensaje(const char []);

int main(int argc, char *argv[]){
    if(argc == 1){
        cout << "Error, la script debe recibir parametros, para mas información consulte la ayuda" << endl;
        cout << "./Cliente -h o -/Cliente --help" << endl;
        exit(EXIT_FAILURE);
    }

    if((strcmp(argv[1],"-h") == 0 || strcmp(argv[1],"--help") == 0) && argc == 2){
        Ayuda(argv[1]);
        exit(EXIT_SUCCESS);
    }
    if(strcmp(argv[1],"ALTA") != 0 && strcmp(argv[1],"BAJA") != 0 && strcmp(argv[1],"CONSULTA") != 0){
        cout << "Error, parametro inválido" << endl;
        exit(EXIT_FAILURE);
    }
    if(strcmp(argv[1],"ALTA") == 0){
        if(argc == 6){
            if(validar_parametro(argv[2]) == false || validar_parametro(argv[3]) == false)
                exit(EXIT_FAILURE);
            if(strcmp(argv[4],"M") != 0 && strcmp(argv[4],"H") != 0){
                cout << "Error, el sexo debe ser Macho (M) o Hembra (H)" << endl;
                exit(EXIT_FAILURE);
             }
            if(strcmp(argv[5],"CA") != 0 && strcmp(argv[5],"SC") != 0){
                cout << "Error, el estado debe ser Castrado (CA) o Sin castrar (SC)" << endl;
                exit(EXIT_FAILURE);
            }

            //logica de socket Comunicación
            char mensaje[200] = "";
            strcat(mensaje,argv[1]);
            strcat(mensaje,"|");
            strcat(mensaje,argv[2]);
            strcat(mensaje,"|");
            strcat(mensaje,argv[3]);
            strcat(mensaje,"|");
            strcat(mensaje,argv[4]);
            strcat(mensaje,"|");
            strcat(mensaje,argv[5]);
            string respuesta = enviarMensaje(mensaje);
            //Lógica de respuesta al socket, mi mensaje
            if(strcmp(respuesta.c_str(),"Operacion exitosa") != 0)
                cout << respuesta << endl;
        }
        else{
            cout << "Error, cantidad de parametros erronea junto a la acción alta.";
            exit(EXIT_FAILURE);
        }
    }
    if(strcmp(argv[1],"BAJA") == 0){
        if(argc == 3){
            if(validar_parametro(argv[2]) == false)
                exit(EXIT_FAILURE);
            
            // logica socket
            char mensaje[200] = "";
            strcat(mensaje,argv[1]);
            strcat(mensaje,"|");
            strcat(mensaje,argv[2]);

            string respuesta = enviarMensaje(mensaje);
            //logica socket respuesta
            if(strcmp(respuesta.c_str(),"Operacion exitosa") != 0)
                cout << respuesta << endl;
        }
        else{
            cout << "Error, cantidad de parametros erronea junto a la acción baja";
            exit(EXIT_FAILURE);
        }
    }

    if(strcmp(argv[1],"CONSULTA") == 0){
        if(argc == 3){
            //En caso de mandar un nombre en concreto...
            if(validar_parametro(argv[2]) == false)
                exit(EXIT_FAILURE);
            
            //logica socket
            char mensaje[200] = "";
            strcat(mensaje,argv[1]);
            strcat(mensaje,"|");
            strcat(mensaje,argv[2]);
            string respuesta = enviarMensaje(mensaje);            
            //logica socket respuesta
            if(strcmp(respuesta.c_str(),"Error, el gato no se encuentra registrado") != 0){
                gato *g = (gato*)malloc(sizeof(gato));
                char aux[200];
                strcpy(aux,respuesta.c_str());
                char *p;
                p = strtok(aux,"|");
                strcpy(g->situacion,p);
                p = strtok(NULL,"|");
                strcpy(g->nombre,p);
                p = strtok(NULL,"|");
                strcpy(g->raza,p);
                p = strtok(NULL,"|");
                strcpy(g->sexo,p);
                p= strtok(NULL, "|");
                strcpy(g->estado,p);
                string tmp_situacion(g->situacion);
                string tmp_nombregato(g->nombre);
                string tmp_raza(g->raza);
                string tmp_sexo(g->sexo);
                string tmp_estado(g->estado);

                cout << "Situación: " + tmp_situacion << endl;
                cout << "Nombre: " + tmp_nombregato << endl;
                cout << "Raza: " + tmp_raza << endl;
                cout << "Sexo: " + tmp_sexo << endl;
                cout << "Estado: " + tmp_estado << endl;
                free(g);
            }
            else
                cout << respuesta << endl;
        }
        else{
            if(argc == 2){
                
                //logica de socket, enviarle en el mensaje CONSULTA y el nombre del archivo "rescatados.txt"
                char mensaje[200] = "";
                strcat(mensaje,argv[1]);
                strcat(mensaje,"|");    //para que me lea al menos la palabra consulta.
                strcat(mensaje,"rescatados.txt");
                string respuesta = enviarMensaje(mensaje);
                //logica respuesta socket
                
                if(strcmp(respuesta.c_str(),"No se hallan gatos rescatados") != 0)
                    int r = leer_rescatados("rescatados.txt");
                else
                    cout << respuesta << endl;
            }
            else{
                cout << "Error, cantidad de parametros erronea junto a la acción consultar" << endl;
                exit(EXIT_FAILURE);
            }
        }
    }
    return EXIT_SUCCESS;
}

bool Ayuda(const char *cad)
{
    if (!strcmp(cad, "-h") || !strcmp(cad, "--help") )
    {
        cout << "Esta script permite solicitar al proceso servidor diferentes acciones."<< endl;
        cout << "Alta, si se quiere registrar un gato"<< endl;
        cout << "La manera de ejecutar este modo es ./Cliente ALTA [nombre del gato] [raza] [sexo (M/H)] [castrado(CA)/sin castrar(SC)]"<< endl;
        cout << "Baja, si un gato fue adoptado hay que darle la baja" << endl;
        cout << "La manera de ejecutar este modo es ./Cliente BAJA [nombre del gato]" << endl;
        cout << "Consulta, si se quiere saber sobre un gato en específico o todos aquellos gatos que han sido rescatados" << endl;
        cout << "La manera de saber sobre un gato en específico es: ./Cliente CONSULTA [nombre del gato]" << endl;
        cout << "La manera de saber sobre todos los gatos que han sido rescatados es: ./Cliente CONSULTA" << endl;
        return true;
    }
    return false;
}

int leer_rescatados(const char path[20]){
    ifstream archivo;
    string texto;
    string tmp_path(path);
    char gatito[100];
    archivo.open(tmp_path,ios::in);
    if(archivo.fail()){
        cout << "no se pudo abrir el archivo" << endl;
        return -1;
    }
    while(!archivo.eof()){
        getline(archivo,texto);
        strcpy(gatito,texto.c_str());
        if(strcmp(gatito,"") == 0)
            break;        
        cout << texto << endl;
    }
    archivo.close();
    remove(path);
    return 0;
}

bool validar_parametro(const char nombre[]){
    string tmp_nombre(nombre);
    if(tmp_nombre.length() > 20){
        cout << "Error, el nombre del gato no debe sobrepasar los 20 caracteres" << endl;
        return false;
    }
    return true;
}

string enviarMensaje(const char mensajeCliente[]){
    struct sockaddr_in socketConfig;
    memset(&socketConfig,'0',sizeof(socketConfig));
    
    socketConfig.sin_family = AF_INET;
    //socketConfig.sin_addr.s_addr = htonl(INADDR_ANY);
    socketConfig.sin_port = htons(5000);
    
    //char *ip;
    //ip = inet_ntoa(socketConfig.sin_addr);

    inet_pton(AF_INET, SERV_HOST_ADDR, &socketConfig.sin_addr);
    
    int socketComunicacion = socket(AF_INET,SOCK_STREAM,0);

    int resultadoConexion = connect(socketComunicacion,(struct sockaddr *)&socketConfig,sizeof(socketConfig));
    cout << "243" << endl;
    if(resultadoConexion < 0){
        cout << "Error en la conexión" << endl;
        exit(EXIT_FAILURE);
    }
    cout << "248" << endl;
    puts(mensajeCliente);
    write(socketComunicacion,mensajeCliente,strlen(mensajeCliente));
    char buffer[2000];
    int bytesRecibidos = 0;
    cout << "252" << endl;
    while((bytesRecibidos = read(socketComunicacion,buffer,sizeof(buffer) - 1)) < 1){
        cout << "257" << endl;
    }
    cout << "259" << endl;
    string bu(buffer);
    puts(buffer);
    cout << bu << endl;
    close(socketComunicacion);
    return bu;
}