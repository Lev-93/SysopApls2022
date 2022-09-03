#! /bin/bash

# =========================== Encabezado =======================

# Nombre del script: Ejercicio4.sh
# Número de ejercicio: 4
# Trabajo Práctico: 1
# Entrega: Primera entrega

# ==============================================================

# ------------------------ Integrantes ------------------------
# 
#	Nombre				|	Apellido			|	DNI
#	Matías				|	Beltramone			|	40.306.191
#	Eduardo				|	Couzo Wetzel			|	43.584.741
#	Brian				|	Menchaca			|	40.476.567
#	Ivana				|	Ruiz				|	33.329.371
#	Lucas				|	Villegas			|	37.792.844
# -------------------------------------------------------------



#función recursiva
function analizarDirectorio()
{
	IFS=$'\n' #para tomar archivos y carpetas con espacio en el nombre
	for archivo in $(ls "$1")
        do
		#entra por el if cuando es un nuevo subdirectorio para analizar, y se efectúa la recursividad
		if [ -d "$1/$archivo" ]; then
		
                    analizarDirectorio "$1/$archivo" 
		#si es un archivo, entra por el else y lo analiza
                else
			#extraigo la extensión de cada archivo para buscarlo en el vector de extensiones
			extension=$(echo "$archivo" | rev | cut -d'.' -f1 | rev)

			for elem in ${vectorExtensiones[@]}
			do
				#entra al if solo si el archivo tiene una extensión que esté en el vector de extensiones
				if [ "$elem" == "$extension" ]; then

					cantLineasArchivo=0
					(( cantArchivosTotal=cantArchivosTotal+1 ))
					while read -r linea; do		#en este while solo cuenta las líneas de cada archivo
						((cantLineasArchivo=cantLineasArchivo+1))
					done < "$1/$archivo"

					(( cantLineasTotal=cantLineasTotal+cantLineasArchivo ))

					comentarios=0
					codigo=0
					bandera=0	#la bandera sirve para contar los comentarios multilínea

					#en el while se cuentan las líneas de código y las líneas de comentario de CADA archivo
					while read -r linea; do
						if [[ $linea = *//* ]] || [[ $linea = */\** ]]; then #si la linea contiene // o /*
							((comentarios=comentarios+1))
							if [[ $linea = */\** ]]; then
								bandera=1
							fi

							#borra espacios al principio de una linea, si los hubiera, ejemplo:    //comentario
							linea="${linea#"${linea%%[![:space:]]*}"}"

							#entra en este if con el siguiente ejemplo: linea de codigo /*linea de comentario*/
							if ! [[ $linea = //* ]] && ! [[ $linea = /\** ]]; then
								((codigo=codigo+1))
							fi
						else
							if [[ $bandera -eq 0 ]]; then
								((codigo=codigo+1))
							else
								((comentarios=comentarios+1))
							fi
						fi

						if [[ ${linea: -2} = "*/" ]]; then  #si los últimos dos caracteres de la línea es */
							bandera=0
						fi
					done < "$1/$archivo" #cierro while

					((cantComentariosTotal=cantComentariosTotal+comentarios))
					((cantCodigoTotal=cantCodigoTotal+codigo))
					#El ejercicio no pide mostrar la siguiente parte, pero lo dejo para mayor claridad.
					#Descomentar los siguientes echo para hacer pruebas.
					#echo "Archivo analizado: $1/$archivo"
					#echo "Cantidad de líneas: $cantLineasArchivo"
					#echo "Cantidad de líneas de comentarios: $comentarios"
					#echo "Cantidad de líneas de código: $codigo"
					#echo
				fi	##cierro el if donde se analiza cada archivo
			done
		fi
        done
}
########################

ayuda()
{
echo "AYUDA:"
echo "El script cuenta la cantidad de líneas de código y de comentarios que poseen los archivos en una ruta pasada por parámetro."
echo "Solo se tendrá en cuenta los archivos con cierta extensión, la cual también se pasará por parámetro."
echo "Se informará la cantidad de archivos analizados, cantidad de líneas de código totales, su porcentaje contra el total de líneas,"
echo "cantidad de líneas de comentarios totales, y su porcentaje contra el total de líneas."
echo "Para correr correctamente el script debe invocarlo de la siguiente manera:"
echo "./Ejercicio4.sh --ruta RUTA --ext EXTENSIONES" 
echo "Por ejemplo: ./Ejercicio4.sh --ruta /home/usuario/Documents/APL1 --ext txt,js,doc"
echo "Donde RUTA será la ruta a analizar. Y además se analizarán los subdirectorios."
echo "Las EXTENSIONES será un listado de extensiones de los archivos a analizar, separados por coma."
echo "Para volver a solicitar la ayuda, ejecutar ./Ejercicio4.sh -h (también puede ser --help o -?)"
}

#######################

if [ $# -ne 4 ]; then
	if [ $1 = "--help" ] || [ $1 = "-h" ] || [ $1 = "-?" ]; then
	ayuda
	exit 0
	fi

	echo "Entradas inválidas."
	echo "Para mas ayuda ejecute ./Ejercicio4.sh --help"
	exit 1
fi




while [ $# -gt 0 ]; do
	case "$1" in
		--ruta)
			directorio="$2"
			if [[ ! -d $directorio ]]; then
				echo -e "$2 NO existe o no es una ruta válida."
				exit 1
			elif [[ ! -r $directorio ]]; then
				echo -e "$2 NO tiene permisos de lectura."
				exit 1
			fi
			shift
			;;
		--ext)
			extensiones="$2"
			shift
			;;
		*)
			echo -e "Error. Parámetros inválidos: $1"
			exit 1
			;;
	esac
	shift
done

##############


declare -a vectorExtensiones

#lleno el vector con las extensiones pasadas por parámetro
IFS="," read -r -a vectorExtensiones <<< "$extensiones"


cantArchivosTotal=0
cantLineasTotal=0
cantComentariosTotal=0
cantCodigoTotal=0

analizarDirectorio "$directorio"

echo
if [ $cantArchivosTotal -gt 0 ]; then
	echo "#################################"
	echo "Cantidad de archivos leídos: $cantArchivosTotal"
	echo "Cantidad de líneas totales: $cantLineasTotal"
	echo "Cantidad de comentarios totales: $cantComentariosTotal"
	porcentaje=$(echo "scale=4; $cantComentariosTotal/$cantLineasTotal*100" | bc)
	echo "Porcentaje de comentarios sobre el total de líneas: ${porcentaje:0:5}%"
	echo "Cantidad de codigo total: $cantCodigoTotal"
	porcentaje=$(echo "scale=4; $cantCodigoTotal/$cantLineasTotal*100" | bc)
	echo "Porcentaje de código sobre el total de líneas: ${porcentaje:0:5}%"
	echo "#################################"
	echo
else
	echo "No se encontraron archivos con las extensiones solicitadas."
	echo
fi

#FIN DE ARCHIVO
