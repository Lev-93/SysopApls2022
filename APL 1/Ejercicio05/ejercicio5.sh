#!/bin/bash
#aca van ejemplos

# inicio integrantes

# fin integrantes

function help(){
    echo "Es importante saber que los parametros --notas y -materias son OBLIGATORIOS"
    echo "Para poder utilizar este script"
    echo "Debemos tener en cuenta lo siguiente"
    echo "-notas es la ruta del archivo a procesar."
    echo "-materias es la ruta del archivo con los datos de las materias que quiera"
    # echo "-o recibe la salida del programa"
    #echo "a continuacion se pondran ejemplos de recopilaciones:"
    #echo "./recopilar.sh -d “./csvs” -e “Moron” -o “./salida.json”"
    #echo "./recopilar.sh -d “./csvs” -o  “./salida.json”"
    echo "recorda que los parametros son unicos y solo debe haber un parametro de cada seccion"
}

function errorParam(){
    echo "Cantidad de parametros erronea, recuerde que siempre puede utilizar -k para solicitar asistencia de uso"
}

notasexiste=0
materiasexiste=0

# while getopts "n:m:h" option
# do
#     case "$option" in
#         n)  
#             if [[ $# -ne 2 ]]
#             then
#                 errorParam
#                 help
#                 exit
#             fi

#             if [ $notasexiste -eq 0 ]
#             then
#                 notasexiste=1
#                 not=${OPTARG}
#                 if [ ! -f "$not" ]
#                 then   
#                     echo "No existe el archivo"
#                     exit 1
#                 elif [ ! -r "$not" ]
#                 then
#                     echo "$not no tiene permiso de lectura"
#                     exit 1
#                 fi
#                 if [ ! "$(ls -A $not)" ]; 
#                 then
#                     echo "El directorio de entrada $not esta vacio, ingrese otro directorio con archivos"
#                     exit 1
#                 fi
#             else
           
#                 errorParam 
#                 exit 0
#             fi
           
#             ;;
#         m)  
#             if [[ $# -ne 2 ]]
#             then
#                 errorParam
#                 help
#                 exit
#             fi

#             if [ $materiasexiste -eq 0 ]
#             then
#                 materiasexiste=1
#                 mat=${OPTARG}

#                 if [ ! -f "$mat" ]
#                 then   
#                     echo "No existe el archivo"
#                     exit 1
#                 elif [ ! -r "$mat" ]
#                 then
#                     echo "$mat no tiene permiso de lectura"
#                     exit 1
#                 fi
#                 if [ ! "$(ls -A $mat)" ]; 
#                 then
#                     echo "El directorio de entrada $mat esta vacio, ingrese otro directorio con archivos"
#                     exit 1
#                 fi
#             else
           
#                 errorParam 
#                 exit 0
#             fi
           
#             ;;
#         h)
#             help
#             exit 0
#             ;;
#     esac

# done

while getopts "n:m:h" option
do
    case "$option" in
        n)  
            notas=${OPTARG}
            ;;
        m)  
            materias=${OPTARG}
            ;;
        h)  
            echo "comela"
            exit 0
            ;;
    esac
done

# awk -F, -f ejercicio5.awk $notas $materias > "./salida.json"
awk -F, -f ejercicio5.awk $notas $materias
