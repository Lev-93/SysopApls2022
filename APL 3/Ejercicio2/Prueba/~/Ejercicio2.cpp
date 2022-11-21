#include <iostream>
#include<unistd.h>
#include <stdlib.h>
#include<sys/types.h>
#include<signal.h>
#include <syslog.h>
#include <string.h>
#include <string>
#include <thread>
#include <mutex>
#include <dirent.h>
#include <sys/inotify.h>
#include <sys/stat.h>
#include <list>
#define EVENT_SIZE  ( sizeof (struct inotify_event) )
#define EVENT_BUF_LEN     ( 1024 * ( EVENT_SIZE + 16 ) )
using std::string;
using namespace std;
mutex archivo;
list<string> listarDirectorios(string ubicacion,list<string> directorios);
void monitorear(string pathCarpeta);
bool isCarpeta(const char* path);
//void crearHiloyMonitoriar(string ubicacion);
void crearHilosyMonitoriar(list<string> directorios);

int main(int argc,char* argv[])
{

		
	if(argc==2&&(!strcmp(argv[1],"-h")||!strcmp(argv[1],"--help")))
	{
		printf("\n Ayuda");
		return  0;
	}
	if(argc>2)
	{
		printf("Se excedió en el número de paramentros use %s -h o --help para recibir ayuda",argv[1]);
		return 0;
	}
	if(!isCarpeta(argv[1]))
	{
		printf("El directorio %s no existe\n",argv[1]);
		return 0;
	}
	string ubi=argv[1];
	//crearHiloyMonitoriar(argv[1]);
	list<string> directorios;
	directorios=listarDirectorios(ubi,directorios);
	//while(!directorios.empty())
	//{
	//	cout<<directorios.front()<<endl;
	//	directorios.pop_front();
	//}
 	crearHilosyMonitoriar(directorios);
	return 0;
}
void monitorear(string pathCarpeta)
{

  int length, i = 0;
  int fd;
  int wd;
  char buffer[EVENT_BUF_LEN];

  fd = inotify_init(); 
  if ( fd < 0 ) {
    perror( "inotify_init" );
  }
  wd = inotify_add_watch( fd,pathCarpeta.c_str(),IN_DELETE_SELF | IN_CREATE | IN_DELETE | IN_MODIFY);



  int todoOk=1;
  list<thread> hilosSubCarp;
  while (todoOk==1) { 
  	
  	read( fd, buffer, EVENT_BUF_LEN );     
  	struct inotify_event *event = ( struct inotify_event * ) &buffer;
  	if (event->mask & IN_DELETE_SELF ) 
    	{
       		todoOk=0;
    	}     
if ( event->len ) {
	
      if ( event->mask & IN_CREATE ) {
      
        if ( event->mask & IN_ISDIR ) {
        	hilosSubCarp.push_back(thread(monitorear,pathCarpeta+"/"+(string)(event->name)));
        	archivo.lock();
        	printf( "Se creó el directorio %s en %s \n", event->name, pathCarpeta.c_str());
       		archivo.unlock();
        }
        else {
                	archivo.lock();
          printf( "Se creó el archivo %s en %s\n", event->name,pathCarpeta.c_str() );
                  	archivo.unlock();
        }
      }
      else if ( event->mask & IN_DELETE ) {
        if ( event->mask & IN_ISDIR ) {
                	archivo.lock();
          printf( "Directorio %s eliminado en %s\n", event->name,pathCarpeta.c_str() );
                  	archivo.unlock();
        }
        else {
                	archivo.lock();
          printf( "Se eliminó el archivo %s  en %s\n", event->name,pathCarpeta.c_str() );
                  	archivo.unlock();
        }
      }else if ( event->mask & IN_MODIFY ) {
        if ( event->mask & IN_ISDIR ) {
                	archivo.lock();
          printf( "Se modificó Directorio %s en %s\n", event->name,pathCarpeta.c_str());
                  	archivo.unlock();
        }
        else {
                	archivo.lock();
         	 	printf( "Se modificó el archivo %s en %s\n"  , event->name,pathCarpeta.c_str());
                  	archivo.unlock();
        }

    }
  }

 }

   inotify_rm_watch( fd, wd );
   close( fd );
  while(!hilosSubCarp.empty())
  {
  	hilosSubCarp.front().join();
  	hilosSubCarp.pop_front();
  }
}
bool isCarpeta(const char* nombre)
{
  struct stat path_stat;
  stat(nombre,&path_stat);
  return S_ISDIR(path_stat.st_mode);
   
}
list<string> listarDirectorios(string ubicacion,list<string> directorios)
{
	DIR* directorio;
	struct dirent* elemento;
	string nombreElem;
	string pathElem=ubicacion;
	directorios.push_back(ubicacion);
	if(directorio=opendir(ubicacion.c_str()))
	{
		while(elemento=readdir(directorio))
		{
			
			
			nombreElem=elemento->d_name;
			pathElem=(string)ubicacion+"/"+(string)nombreElem;
			if(nombreElem!="."&&nombreElem!=".."&&isCarpeta(pathElem.c_str()))
			{
				directorios=listarDirectorios(pathElem,directorios);

			}
		}
		

	}	
	closedir(directorio);
	return directorios;
	
	
}
void crearHilosyMonitoriar(list<string> directorios)
{
	int tamanio=directorios.size();
	thread hilosMonitores[tamanio];
	for(int i=0;i<tamanio;i++)
	{
		cout<<directorios.front()<<endl;
		hilosMonitores[i]=thread(monitorear,directorios.front());	
		directorios.pop_front();
		
	}
	for(int i=0;i<tamanio;i++)
	{
		hilosMonitores[i].join();	
	}
}
/*void crearHiloyMonitoriar(string ubicacion)
{
	DIR* directorio;
	struct dirent* elemento;
	string nombreElem;
	string pathElem=ubicacion;
	cout<<"hola"<<endl;
	if(directorio=opendir(ubicacion.c_str()))
	{
		while(elemento=readdir(directorio))
		{
			
			
			nombreElem=elemento->d_name;
			pathElem=(string)ubicacion+"/"+(string)nombreElem;
			if(nombreElem!="."&&nombreElem!=".."&&isCarpeta(pathElem.c_str()))
			{
				crearHiloyMonitoriar(pathElem);	

			}
		}
		

	}
	thread hiloMonitor=thread(monitorear,pathElem);	
	closedir(directorio);
	hiloMonitor.join();

	
}*/
