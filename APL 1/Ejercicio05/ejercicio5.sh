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
declare -a notas
declare -a materias
declare -a datos
inicio="1"
todoOk="1"
function ayuda(){
    echo "Es importante saber que los parametros --notas y --materias son OBLIGATORIOS"
    echo "Para poder utilizar este script"
    echo "Debemos tener en cuenta lo siguiente"
    echo "--notas es la ruta del archivo de notas a procesar."
    echo "--materias es la ruta del archivo con los datos de las materias que quiera generar informes"
    echo "a continuacion se pondran ejemplos de recopilaciones:"
    echo "./ejercicio5.sh --notas ./notas.txt --materias ./materias.txt"
    echo "Recuerde que los parametros son unicos y solo debe haber un parametro de cada seccion"
}
if test "$1" == "-h" || test "$1" == "--help" ||test  "$1" == "-"
then
	ayuda
	todoOk="0"
fi
if test "$todoOk" -eq "1" && test "$#" -ne "4"
then
	if test "$#" -lt "2"
	then
		echo "Faltan parametros use $0 --help para recibir ayuda"
	else
		echo "Se excedio la cantidad de parametros use $0 --help para recibir ayuda"
	fi
	todoOk="0"
fi


cargarNotas()
{	
	local contador=0
	while IFS= read linea
	do
	notas[contador]="$linea"
	(( contador = contador +1 ))
	done <"$1"
}
cargarMaterias()
{	
	local contador=0
	while IFS= read linea
	do
	materias[contador]="$linea"

	(( contador = contador +1 ))
	done <"$1"
	materias[0]="0"
}
calcularMat()
{
	mat="$1"
	local contador="$inicio"
	datos[0]=0
	datos[1]=0
	datos[2]=0
	datos[3]=0
	while(test "$contador" -lt ${#notas[*]})
	do
		mat2=`echo "${notas[$contador]}" | cut -f 2 -d"|"`
		parcial1=`echo "${notas[$contador]}" | cut -f 3 -d"|"`
		parcial2=`echo "${notas[$contador]}" | cut -f 4 -d"|"`
		recu=`echo "${notas[$contador]}" | cut -f 5 -d"|"`
		final=`echo "${notas[$contador]}" | cut -f 6 -d"|"`

		if test "$mat" -eq "$mat2"
		then
			if ( (test "$parcial1" == "" || test "$parcial2" == "") && test "$recu" == "")
			then
				(( datos[2] = datos[2] +1 ))
			fi
			if test "$recu" == ""
			then
				recu="0"
			fi
			if test "$parcial1" ==  ""
			then
				parcial1="0"
			fi
			if test "$parcial2" == ""
			then
				parcial2="0"
			fi
			if test "$final" == "" &&( (test "$recu" -ge "4"&& test "$recu" -lt "7") ||( (test "$parcial1" -lt 7 && test "$parcial1" -ge "4")&&(test "$parcial2" -lt 7 && test "$parcial2" -ge "4") ) )
			then
			(( datos[0] = datos[0] + 1))
			fi
			if ( (test "$final" == "") && ( (test "$recu" != "0" && test "$recu" -lt "4") || ( ( test "$parcial1" != "0" &&test "$parcial1" -lt "4" ) &&( test "$parcial2" != "0" &&test "$parcial2" -lt "4" ) ) ) ) || (test "$final" != "" && test "$final" -lt "4")
then
	(( datos[1] = datos[1] + 1))
fi
			if (test "$final" == "") && (((test $recu -ge 7) || ( (test "$parcial2" -ge "7" || test "$parcial1" -ge "7"))) || (test "$parcial2" -ge "7" && test "$parcial1" -ge "7"))
			then
				(( datos[3] = datos[3] +1 ))
			fi
			
		fi
		(( contador = contador +1 ))
		
	done
	
}
generarJson()
{
	
	echo '{
	"departamentos": ['>>salida
	local contador="$inicio"
	while test "$contador" -lt "${#materias[*]}"
	do
		deptoActual=`echo "${materias[$contador]}" | cut -f 3 -d"|"`
		deptoAnterior=`echo "${materias[$contador]}" | cut -f 3 -d"|"`
		echo "	{">>salida
		echo '		"id":' "$deptoActual,">>salida
		echo '		"notas":['>>salida
		while test "$contador" -lt "${#materias[*]}" && test "$deptoActual" == "$deptoAnterior"
		do
			materia=`echo "${materias["$contador"]}" | cut -f 1 -d"|"`
			nombre=`echo "${materias["$contador"]}" | cut -f 2 -d"|"`
			calcularMat "$materia"
			
			echo '		{'>>salida
			echo '			"id_materia":' "$materia,">> salida
			echo '			"descripcion":' \"$nombre\",>> salida
			echo '			"final":' "${datos[0]},">> salida
			echo '			"recursan":'"${datos[1]},">> salida
			echo '			"abandonaron":'"${datos[2]},">> salida
			echo '			"promocionan":'"${datos[3]}">> salida
			(( contador = contador + 1))
			deptoActual=`echo "${materias[$contador]}" | cut -f 3 -d"|"`
			if test "$deptoActual" == "$deptoAnterior"
			then
				echo '		},'>>salida
			else
				echo '		}'>>salida
			fi
		done
	if test "$contador" -lt "${#materias[*]}"
	then
		echo "            ]
	},">>salida
	else
		echo "            ]
	}">>salida
	fi	
	done
	echo "     ]
}">>salida
}



if test "$todoOk" -eq "1" && test "$1" != "--notas"
then
	echo "No existe el comando $1"
	todoOk="0"
fi
if test "$todoOk" -eq "1" && test "$3" != "--materias"
then
	echo "No existe el comando $3"
	todoOk="0"
fi

if test "$todoOk" -eq "1" && ! test -f "$2"
then
	echo "El archivo de notas "$2" no existe"
	todoOk="0"
fi

if test "$todoOk" -eq "1" && ! test -r "$2"
then
	echo "El archivo "$2" no tiene permiso de lectura"
	todoOk="0"
fi
if test "$todoOk" -eq "1" && ! test -f "$4"
then
	echo "El archivo de materias "$4" no existe"
	todoOk="0"
fi

if test "$todoOk" -eq "1" && ! test -r "$4"
then
	echo "El archivo $4 no tiene permiso de lectura"
	todoOk="0"
fi

if test "$todoOk" == "1"
then
	cargarNotas "$2"
	cargarMaterias "$4"
	IFS=$'\n' materias=($(sort -k 3 -t "|" <<< "${materias[*]}"))
	unset IFS
	generarJson
fi



