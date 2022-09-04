#!/bin/bash
# =========================== Encabezado =======================

# Nombre del script: ejercicio5.sh
# Número de ejercicio: 5
# Trabajo Práctico: 1
# Entrega: Primera entrega

# ==============================================================

# ------------------------ Integrantes ------------------------
# 
#	Nombre				|	Apellido			|	DNI
#	Matías				|	Beltramone			|	40.306.191
#	Eduardo				|	Couzo Wetzel		|	43.584.741
#	Brian				|	Menchaca			|	40.476.567
#	Ivana				|	Ruiz				|	33.329.371
#	Lucas				|	Villegas			|	37.792.844
# -------------------------------------------------------------

function help(){
    echo "Es importante saber que los parametros -n y -m son OBLIGATORIOS"
    echo "Para poder utilizar este script"
    echo "Debemos tener en cuenta lo siguiente"
    echo "-n es la ruta del archivo a procesar."
    echo "-m es la ruta del archivo con los datos de las materias que quiera"
    echo "a continuacion se pondran ejemplos de recopilaciones:"
    echo "./ejercicio5.sh -n ./notas.txt -m ./materias.txt"
    echo "recorda que los parametros son unicos y solo debe haber un parametro de cada seccion"
}

function errorParam(){
    echo "Cantidad de parametros erronea, recuerde que siempre puede utilizar -h para solicitar asistencia de uso"
}

<<<<<<< HEAD
validar() {

	if [ ! -f "$1" ];
	then
		echo "Error: \"$1\" no es un fichero"
		exit 1
	fi
	
	if [ ! -r "$1" ];
	then
		echo "Error, \"$1\" no tiene permisos de lectura"
		exit 1
	fi

	if [ ! -w "$1" ];
	then
		echo "Error, \"$1\" no tiene permisos de escritura"
		exit 1
	fi

	if [ ! -f "$2" ];
	then
		echo "Error: \"$2\" no es un fichero"
		exit 1
	fi
	
	if [ ! -r "$2" ];
	then
		echo "Error, \"$2\" no tiene permisos de lectura"
		exit 1
	fi

	if [ ! -w "$2" ];
	then
		echo "Error, \"$2\" no tiene permisos de escritura"
		exit 1
	fi
}


notasexiste=0
materiasexiste=0

=======
>>>>>>> 974c106a6e5925371ae9f847582612063af7f84d
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

<<<<<<< HEAD
validar "$2" "$4"
=======
validar() {

    ruta1=`readlink -e "$1"`
    ruta2=`readlink -e "$2"`

	if [ ! -f "$1" ];
	then
		echo "Error: \"$1\" no es un fichero"
		exit 1
	fi
	
	if [ ! -r "$1" ];
	then
		echo "Error, \"$1\" no tiene permisos de lectura"
		exit 1
	fi

	if [ ! -w "$1" ];
	then
		echo "Error, \"$1\" no tiene permisos de escritura"
		exit 1
	fi

	if [ ! -f "$2" ];
	then
		echo "Error: \"$2\" no es un fichero"
		exit 1
	fi
	
	if [ ! -r "$2" ];
	then
		echo "Error, \"$2\" no tiene permisos de lectura"
		exit 1
	fi

	if [ ! -w "$2" ];
	then
		echo "Error, \"$2\" no tiene permisos de escritura"
		exit 1
	fi
}
>>>>>>> 974c106a6e5925371ae9f847582612063af7f84d

while getopts "n:m:h" option
do
    case "$option" in
        n)  
            if [[ "$#" -ne 4 ]]
            then
                errorParam
                help
                exit
            fi

            validar "$2" "$4"
            notas="${OPTARG}"
            lengthNotas=$(cat ${OPTARG} | wc -l)
            ;;
        m)  

            if [[ $# -ne 4 ]]
            then
                errorParam
                help
                exit
            fi

            validar "$2" "$4"
            materias="${OPTARG}"
            lengthMaterias=$(cat ${OPTARG} | wc -l)
            ;;
<<<<<<< HEAD
        '-h' | '--help' | '-?')  
            echo "comela"
=======
        h)  
>>>>>>> 974c106a6e5925371ae9f847582612063af7f84d
            help
            exit 0
            ;;
    esac
done

# awk -F, -f ejercicio5.awk $notas $materias > "./salida.json"
awk -v variable1="$lengthNotas" -v variable2="$lengthMaterias" -F, -f ejercicio5.awk $notas $materias > "./salida.json"
