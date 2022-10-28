#!/bin/bash
# =========================== Encabezado =======================

# Nombre del script: ejercicio5.sh
# Número de ejercicio: 5
# Trabajo Práctico: 1
# Entrega: Tercera Entrega

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
    echo "Es importante saber que los parametros --notas y --materias son OBLIGATORIOS"
    echo "Para poder utilizar este script"
    echo "Debemos tener en cuenta lo siguiente"
    echo "--notas es la ruta del archivo a procesar."
    echo "--materias es la ruta del archivo con los datos de las materias que quiera"
    echo "a continuacion se pondran ejemplos de recopilaciones:"
    echo "./ejercicio5.sh --notas ./notas.txt --materias ./materias.txt"
    echo "tambien puede probar un ejemplo con un archivo desordenado"
    echo "./ejercicio5.sh --notas ./notas.txt --materias ./materias2.txt"
    echo "recorda que los parametros son unicos y solo debe haber un parametro de cada seccion"
}

function errorParam(){
    echo "Cantidad de parametros erronea, recuerde que siempre puede utilizar -h o --help para solicitar asistencia de uso"
}

function validar() {

    if [[ "$#" -eq 0 ]]
    then
        errorParam
        help
        exit 1
    fi

    if [[ "$#" -eq 3 ]]
    then
        errorParam
        help
        exit 1
    fi
	# if [ ! -f "$1" ];
	# then
	# 	echo "Error: \"$1\" no es un fichero"
	# 	exit 1
	# fi
	
	# if [ ! -r "$1" ];
	# then
	# 	echo "Error, \"$1\" no tiene permisos de lectura"
	# 	exit 1
	# fi

	# if [ ! -w "$1" ];
	# then
	# 	echo "Error, \"$1\" no tiene permisos de escritura"
	# 	exit 1
	# fi

	# if [ ! -f "$2" ];
	# then
	# 	echo "Error: \"$2\" no es un fichero"
	# 	exit 1
	# fi
	
	# if [ ! -r "$2" ];
	# then
	# 	echo "Error, \"$2\" no tiene permisos de lectura"
	# 	exit 1
	# fi

	# if [ ! -w "$2" ];
	# then
	# 	echo "Error, \"$2\" no tiene permisos de escritura"
	# 	exit 1
	# fi
}

# validar


ARGUMENT_LIST=(
  "notas"
  "materias"
  "help"
)

opts=$(getopt \
  --longoptions "notas:,materias:,help" \
  --name "$(basename "$0")" \
  --options "h" \
  -- "$@"
)

if [ "$#" == "0" ]
then
    errorParam
    help
    exit 1
fi

eval set --$opts

while [[ $# -gt 0 ]]; do
  case "$1" in
        --notas)  
            notas="$2"
            lengthNotas=$(cat $2 | wc -l)
            shift 2
            ;;
        --materias)  
            materias="$2"
            lengthMaterias=$(cat $2 | wc -l)
            shift 2
            ;;
        --help)  
            help
            exit 0
            ;;
        -h)
            help
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            help
            exit 1
            ;;
    esac
done

sort -k 3 -t "|" -n "$materias" > /dev/null

awk -v variable1="$lengthNotas" -v variable2="$lengthMaterias" -F, -f ejercicio5.awk $notas $materias > "./salida.json"
