#include <fstream>
#include <dirent.h> // para la struct dirent
#include <sys/stat.h> // para la struct stat
#include <windows.h>
#include <thread>
#include <iostream>
#include <map>

#define BUFSIZE 4096
#define TAM 256 // macro TAM de la ruta
#define TODO_OK 0


using namespace std;

int crearRegistro(string rutaActual, string rutaRegistro);
string extraerDirectorioActual(string path);

template<typename Map>

void registrarCarpeta(Map& mapaFecha, Map& mapaModifica, string rutaActual, string rutaRegistro)
{
    char * ruta = (char *)malloc(TAM*sizeof(char));
    strncpy(ruta,rutaActual.c_str(),TAM);
    DIR * dir = opendir(ruta); // abrimos el directorio
    DIR * subDir;
    struct dirent *entrada;
    struct stat status;
    string fecha;
    string head;

    if (!dir) // comprobamos si lo pudimos abrir
    {
        cout << "no se pudo abrir la carpeta" << endl;
        exit(1);
    }
    else
    {
        chdir(ruta);
        while ( (entrada=readdir(dir)) != NULL )   // leemos entradas de directorio hasta que se devuelva puntero a NULL
        {
            if ( ( strcmp(entrada->d_name, ".") == 0 ) || ( strcmp(entrada->d_name, "..") == 0 ) )
                continue; // Saltamos las entradas de directorio actual y directorio raíz
            if (stat(entrada->d_name,&status) == 0) // cargamos la estructura stat (mejor usar lstat() para symbolic links)
            {
                fecha = (string)ctime(&status.st_mtime);
                fecha = fecha.substr(0,24);
                head = rutaActual + entrada->d_name;

                if((subDir=opendir(head.c_str())))
                {
//                    registrarCarpeta(mapaFecha, mapaModifica, head + "\\");
                    thread hilo(crearRegistro, head, rutaRegistro);
                    hilo.join();
                }
                else if (mapaFecha[head] == "")
                {
                    mapaFecha[head] = fecha;
                    mapaModifica[head] = "CREADO    ";
                }
                else if (mapaFecha[head] != fecha)
                {
                    mapaFecha[head] = fecha;
                    mapaModifica[head] = "MODIFICADO";
                }
                else
                {
                    mapaFecha[head] = fecha;
                    mapaModifica[head] = "SIN CAMBIO";
                }
            }
        }
    }
}

int main(int argc, char* argv[])
{
    if(argc == 2)
    {
        string ruta = argv[1];
        if(ruta == (char*)"--help" || ruta == (char*)"-h")
        {
            cout << endl << "*****************************************" << endl;
            cout << "Debe ingresar una ruta de " << endl;
            cout << "un directorio valido como parametro" << endl;
            cout << "para que se cree/actualice el registro." << endl;
            cout << endl;
            cout << "Ejemplo de parametro: ./carpetaEjemplo" << endl;
            cout << "*****************************************" << endl << endl;
            return 0;
        }
        string rutaRegistro = "registro.log";
        DWORD  retvalRegistro=0;
        TCHAR  bufferRegistro[BUFSIZE]=TEXT("");
        TCHAR** lppPartRegistro= {NULL};

        retvalRegistro = GetFullPathName(rutaRegistro.c_str(), BUFSIZE, bufferRegistro, lppPartRegistro);

        if (retvalRegistro == 0)
        {
            cout << "GetFullPathName failed " << GetLastError() << endl;
            return 1;
        }

        return crearRegistro(ruta, bufferRegistro);
    }
    else
    {
        cout << "Ingrese un directorio valido";
    }
    return 0;
}


int crearRegistro(string rutaActual, string rutaRegistro)
{
    string fecha;
    string rutaArchivo;
    string estado;
    string rutaCarpetaArchivoActual;

    map<string,string> mapaFecha;
    map<string,string> mapaModifica;

    std::map<string, string>::iterator it;
    ifstream archivo(rutaRegistro.c_str());
    string linea;
    DWORD  retval=0;
    TCHAR  buffer[BUFSIZE]=TEXT("");
    TCHAR** lppPart= {NULL};

    retval = GetFullPathName(rutaActual.c_str(), BUFSIZE, buffer, lppPart);

    if (retval == 0)
    {
        cout << "GetFullPathName failed " << GetLastError() << endl;
        return 1;
    }

    rutaActual = buffer;
    rutaActual += "\\";

    // Obtener línea de archivo, y almacenar contenido en "linea"
    while (getline(archivo, linea))
    {
        fecha = linea.substr(0,24);
        estado = linea.substr(25,10);
        rutaArchivo = linea.substr(37,linea.length() - 35);
        rutaCarpetaArchivoActual = extraerDirectorioActual(rutaArchivo);
        if(rutaActual == rutaCarpetaArchivoActual)
        {
            if(estado == "CREADO    " || estado == "MODIFICADO")
            {
                mapaFecha[rutaArchivo] = fecha;
                mapaModifica[rutaArchivo] = "ELIMINADO ";
            }
            else
            {
                mapaFecha.erase(rutaArchivo);
                mapaModifica.erase(rutaArchivo);
            }
        }
    }
    archivo.close();

    registrarCarpeta(mapaFecha, mapaModifica, rutaActual, rutaRegistro);


    ofstream archivoRegistro;
    // Abrimos el archivo
    archivoRegistro.open(rutaRegistro, fstream::app);
    for (auto& x: mapaFecha)
    {
        if(mapaModifica[x.first] != "SIN CAMBIO")
            archivoRegistro << x.second << " " << mapaModifica[x.first] << ": "<< x.first << endl;
    }
    archivoRegistro.close();

    return TODO_OK;
}

string extraerDirectorioActual(string path)
{
    char * palabra =  (char*)path.c_str();
    size_t longitud = path.size();
    palabra += longitud - 1;
    const char* delimitador = "\\";
    while (*palabra != *delimitador)
    {
        palabra--;
        longitud--;
    }
    return path.substr(0,longitud);
}


