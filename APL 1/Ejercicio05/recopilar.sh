#!/bin/bash
#./recopilar.sh -d “PathsCSV” -e “Moron” -o “dirSalida”
#./recopilar.sh -d “PathsCSV” -o /home/usuario/dirSalida

<< GRUPO

Palabra Script: Ejercicio2.sh
APL: 1
Ejercicio: 2
Entregra: Primera Entrega

INTEGRANTES:

Beltramone, Matias      DNI: 40.306.191
Heize, German           DNI: 35.426.224
Kairala, Nicolas        DNI: 36.822.421
Perrone, Diego			DNI: 40.021.110
Ripamonti, Franco       DNI: 41.543.365

Comisión: Lunes y Miércoles Turno: Noche

GRUPO

function help(){
    echo "Es importante saber que los parametros -d y -o son OBLIGATORIOS"
    echo "Para poder utilizar este script"
    echo "Debemos tener en cuenta lo siguiente"
    echo "-d recibe el parametro de entrada"
    echo "-e es un parametro opcional, la sucursal a excluir"
    echo "-o recibe la salida del programa"
    echo "a continuacion se pondran ejemplos de recopilaciones:"
    echo "./recopilar.sh -d “./csvs” -e “Moron” -o “./salida.json”"
    echo "./recopilar.sh -d “./csvs” -o  “./salida.json”"
    echo "recorda que los parametros son unicos y solo debe haber un parametro de cada seccion"
    
}

function errorParam(){
    echo "Cantidad de parametros erronea, recuerde que siempre puede utilizar -k para solicitar asistencia de uso"
}

dexiste=0
eexiste=0
oexiste=0
#Validacion de parametros

while getopts "d:e:o:h" option
do
    
    case "$option" in
        d)  
            if [[ $# -ne 2 && $# -ne 4 && $# -ne 6 ]]
            then
                errorParam
                help
                exit
            fi

            if [ $dexiste -eq 0 ]
            then
                dexiste=1
                entrada=${OPTARG}

                if [ ! -d "$entrada" ]
                then   
                    echo "No existe el directorio"
                    exit 1
                elif [ ! -r "$entrada" ]
                then
                    echo "$entrada no tiene permiso de lectura"
                    exit 1
                fi
                if [ ! "$(ls -A $entrada)" ]; 
                then
                    echo "El directorio de entrada $entrada esta vacio, ingrese otro directorio con archivos"
                    exit 1
                fi
            else
           
                errorParam 
                exit 0
            fi
           
            ;;
        e)
            if [[ $# -ne 2 && $# -ne 4 && $# -ne 6 ]]
            then
                errorParam
                help
                exit
            fi

            if [ $eexiste -eq 0 ]
            then
                eexiste=1
                sucursal=${OPTARG}

                if [ -f "$entrada/$sucursal.csv" ] 
                then
                    excluido="$entrada/$sucursal.csv" 

                fi
            else
            
                errorParam 
                exit 0
            fi
            ;;
        o)
            if [[ $eexiste -eq 1 ]]
            then
                if [[ $# -ne 2 && $# -ne 4 && $# -ne 6 ]]
                then
                errorParam
                help
                    exit
                fi
            else
                if [[ $# -ne 2 && $# -ne 4 ]]
                then
                errorParam
                help
                    exit
                fi
            fi

            if [ $oexiste -eq 0 ]
            then
                oexiste=1
                salida=${OPTARG}

                if [ $? -ne 0 ]
                then
                    echo "$salida no se pudo crear, reintente."
                    exit 1
                fi
                            
                if [ ! -d "$salida" ]
                then
                    mkdir "$salida"
                fi
            else
            
                errorParam 
                exit 0
            fi
            ;;
        h|*)
            help
            exit 0
            ;;
    esac

done

archivos=$entrada/*.csv

if [ -z "$entrada" ]
then
    help   
    exit 0
elif [ -z "$salida" ]
then
    help
    exit 0
fi

awk -F, -f recopilar.awk $archivos $excluido > "$salida/salida.csv"

