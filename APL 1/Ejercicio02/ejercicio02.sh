#!/bin/bash

declare -a llamadas
declare -a cantidadLlamadas
declare -a estado




todoOk="1"
ayuda()
{
	
	echo "El script necesita el parametro --logs y el directorio del archivo de logs de llamadas. Formato: --logs '"directorio"'"
 	#echo "El scrip tiene por objetivo generar los siguiente"
}

if test "$1" == "-h" || test "$1" == "--help" ||test  "$1" == "-"
then
	ayuda
	todoOk="0"
fi
if test "$todoOk" -eq "1" && test "$#" -ne "2"
then
	if test "$#" -lt "2"
	then
		echo "Faltan parametros"
	else
		echo "Se excedio la cantidad de parametros"
	fi
	todoOk="0"
	ayuda	
fi
if test "$todoOk" -eq "1" && test "$1" != "--logs"
then
	echo "No existe el comando $1"
	todoOk="0"
	ayuda
fi

if test "$todoOk" -eq "1" && ! test -f "$2"
then
	echo "El archivo "$2" no existe"
	todoOk="0"
fi

if test "$todoOk" -eq "1" && ! test -r "$2"
then
	echo "El archivo no tiene permiso de lectura"
	todoOk="0"
fi


cargarVectorParalelo()
{	
	for (( i=0; i<${#llamadas[*]}; i++ ))
	do
		estado[$i]="1"
	done
}
cargarVector()
{	
	contador=0
	while IFS= read linea
	do
	llamadas[$contador]="$linea"
	(( contador = contador +1 ))
	done <"$1"
}


restarFechas()
{	
	t1=$(date -d "$1" +%s)
	t2=$(date -d "$2" +%s)
	echo $(( $t1 - $t2 ))
		
}
buscarPrimeraOcurrencia()
{
	pos="$1"
	(( pos = pos + 1 ))
	buscado=`echo "${llamadas[$1]}" | cut -f 4 -d"-"`
	valorActual=`echo "${llamadas[$pos]}" | cut -f 4 -d"-"`
	
	while test $pos -lt ${#llamadas[*]} && (test "$buscado" != "$valorActual") 
	do 
		(( pos = pos + 1 ))
		valorActual=`echo "${llamadas[$pos]}" | cut -f 4 -d"-"`
	done
	echo "$pos"	
}


promedioTiempoDia()
{	
	
	contador=0
	while [ $contador -lt ${#llamadas[*]} ]
	do
		promedio=0;
		cantLLamadas=0
		dia=$( echo ${llamadas[$contador]} | cut -c -10 )
		diaActual=$( echo ${llamadas[$contador]} | cut -c -10 )
		while  test "$contador" -lt "${#llamadas[*]}" && ( test "$dia" == "$diaActual")
		do	
			(( cantLLamadas = cantLLamadas + 1 ))
			posicion=`buscarPrimeraOcurrencia $contador`
			t1=`echo "${llamadas[$posicion]}"| cut -c -19`
			t2=`echo "${llamadas[$contador]}" | cut -c -19`
			estado[$posicion]="0"
			(( promedio = promedio +`restarFechas "$t1" "$t2"` ))
			(( contador = contador + 1 ))
			diaActual=$( echo ${llamadas[$contador]} | cut -c -10 )
			while test "$contador" -lt "${#llamadas[*]}" && test "${estado[$contador]}" -ne "1"
			do
				(( contador = contador +1 ))
			
				diaActual=$( echo ${llamadas[$contador]} | cut -c -10 )
			done
		done
		if [ $cantLLamadas != 0 ]
		then
			(( promedio = promedio / cantLLamadas ))
			echo "Promedio del dia $dia: $promedio segundos"
		fi
	done
}
buscarPersonaDispo()
{
	local persona=0  
	while  test "$persona" -lt "${#estado[*]}" && test "${estado[$persona]}" != "1"
	do
		(( persona = persona + 1 ))
	done
	echo "$persona" >> "./salida" 
	echo "$persona"
}
promedioUsuarioDia()
{	
	local fin
	local inicio=`buscarPersonaDispo`
	while test "$inicio" -lt "${#llamadas[*]}"
	do
		echo " "
		echo "Usuario: `echo "${llamadas[$inicio]}" | cut -f 4 -d"-"`" 
		while test "$inicio" -lt "${#llamadas[*]}"
		do
			dia=`echo "${llamadas[$inicio]}" | cut -c -10` 
			diaActual=`echo "${llamadas[$inicio]}" | cut -c -10`
			cantidad=0
			promedio=0
			while test "$inicio" -lt "${#llamadas[*]}" && (test "$dia" == "$diaActual")
			do
				
				estado[$inicio]="0"
				pos="$inicio"
				(( pos = pos + 1 ))
				buscado=`echo "${llamadas[$inicio]}" | cut -f 4 -d"-"`
				valorActual=`echo "${llamadas[$pos]}" | cut -f 4 -d"-"`
				while test $pos -lt ${#llamadas[*]} && (test "$buscado" != "$valorActual") 
				do 
					(( pos = pos + 1 ))
					valorActual=`echo "${llamadas[$pos]}" | cut -f 4 -d"-"`
				done
				fin="$pos"
				t1=`echo "${llamadas[$fin]}"| cut -c -19`
				t2=`echo "${llamadas[$inicio]}" | cut -c -19`
				(( cantidad = cantidad + 1 ))
				(( promedio = promedio +`restarFechas "$t1" "$t2"` ))
				estado[$fin]="0"
				pos="$fin"
				(( pos = pos + 1 ))
				buscado=`echo "${llamadas[$fin]}" | cut -f 4 -d"-"`
				valorActual=`echo "${llamadas[$pos]}" | cut -f 4 -d"-"`
				while test $pos -lt ${#llamadas[*]} && (test "$buscado" != "$valorActual") 
				do 
					(( pos = pos + 1 ))
					valorActual=`echo "${llamadas[$pos]}" | cut -f 4 -d"-"`
				done
				inicio="$pos"
				diaActual=`echo "${llamadas[$inicio]}" | cut -c -10`
			done
			(( promedio = promedio / cantidad ))
			echo "Dia: $dia Cantidad llamadas: $cantidad Promedio: $promedio segundos"
		done
		
		inicio=`buscarPersonaDispo`
	done 
}

contarOcurrencias()
{
	posPersona=`buscarPersonaDispo`
	contPerson="0"
	
	while test "$posPersona" -lt "${#llamadas[*]}"
	do
		cantLlamadas=0
		personaActual=`echo "${llamadas[$posPersona]}" | cut -f 4 -d"-"`
		while test "$posPersona" -lt "${#llamadas[*]}"
		do
			estado[$posPersona]="0"
			finLlam="$posPersona"
			(( finLlam = finLlam + 1 ))
			buscando=`echo "${llamadas[$finLlam]}" | cut -f 4 -d"-"`
			while test $finLlam -lt "${#llamadas[*]}" && (test "$personaActual" != "$buscando")
			do
				(( finLlam = finLlam + 1 ))
				buscando=`echo "${llamadas[$finLlam]}" | cut -f 4 -d"-"`
			done
			estado[$finLlam]="0"
			(( finLlam = finLlam + 1 ))
			buscando=`echo "${llamadas[$finLlam]}" | cut -f 4 -d"-"`
			while test $finLlam -lt "${#llamadas[*]}" && test "$personaActual" != "$buscando"
			do
				(( finLlam = finLlam + 1 ))
				buscando=`echo "${llamadas[$finLlam]}" | cut -f 4 -d"-"`
			done
			estado[$finLlam]="0"
			posPersona=$finLlam
			(( cantLlamadas = cantLlamadas + 1 ))
		done
		cantidadLlamadas[$contPerson]="$personaActual $cantLlamadas"
		(( contPerson = contPerson + 1 ))
		posPersona=`buscarPersonaDispo`
	done
	
}

buscarTop()
{	
	topNum=$1
	contar="0"
	while test $contar -lt $topNum
	do
		
		recorrer="0"
		mayor=0
		numA=`echo "${cantidadLlamadas["$recorrer"]}" | cut -f 2 -d" "`
		(( recorrer = recorrer + 1 ))
		numB="`echo "${cantidadLlamadas[$recorrer]}" | cut -f 2 -d" "`"

		while test "$recorrer" -lt "${#cantidadLlamadas[*]}"
		do	
			
			if test "$numB" -gt "$numA" 
 			then
 				numA="$numB"
 				mayor="$recorrer"
			fi
			(( recorrer = recorrer + 1 ))
			numB="`echo "${cantidadLlamadas[$recorrer]}" | cut -f 2 -d" "`"

		done
		if(test $numA != "0")
		then
			echo " "
			echo "Usuario: `echo "${cantidadLlamadas["$mayor"]}" | cut -f 1 -d" "` Cantidad Llamadas: $numA"
			
		fi
		(( contar = contar + 1 ))
		cantidadLlamadas[$mayor]="0 0"
	done		
}
calcularLlamadasNoPromedio()
{
	contador=0
	cantantidadNoProm=0

	while [ $contador -lt ${#llamadas[*]} ]
	do
		promedio=0;
		cantLLamadas=0
		dia=$( echo ${llamadas[$contador]} | cut -c -10 )
		diaActual=$( echo ${llamadas[$contador]} | cut -c -10 )
		while  test "$contador" -lt "${#llamadas[*]}" && ( test "$dia" == "$diaActual")
		do	
			
			posicion=`buscarPrimeraOcurrencia $contador`
			t1=`echo "${llamadas[$posicion]}"| cut -c -19`
			t2=`echo "${llamadas[$contador]}" | cut -c -19`
			estado[$posicion]="0"
			(( promedio = promedio + `restarFechas "$t1" "$t2"`))
			(( contador = contador + 1 ))
			tiempoLlamadas[$cantLLamadas]=`restarFechas "$t1" "$t2"`
			(( cantLLamadas = cantLLamadas + 1 ))
			diaActual=$( echo ${llamadas[$contador]} | cut -c -10 )
			while test "$contador" -lt "${#llamadas[*]}" && test "${estado[$contador]}" -ne "1"
			do
				(( contador = contador +1 ))
			
				diaActual=$( echo ${llamadas[$contador]} | cut -c -10 )
			done
		done
		
		if [ $cantLLamadas != 0 ]
		then
			cantantidadNoProm=0
			(( promedio = promedio / cantLLamadas ))
			for (( i=0; i<$cantLLamadas; i++ ))
			do
				if test "${tiempoLlamadas[$i]}" -le "$promedio"
				then
					(( cantantidadNoProm = cantantidadNoProm + 1 ))		
				fi
			done
			echo " "
			echo "Dia: $dia Cantidad de llamadas que no superan la media ($promedio seg) es: $cantantidadNoProm"
			
		fi
	done
}
cargarPromediosPorSemana()
{
	local fin
	local inicio=`buscarPersonaDispo`
	declare -a usuarioProm
	contador=0
	while test "$inicio" -lt "${#llamadas[*]}"
	do
		noProm=0	
		while test "$inicio" -lt "${#llamadas[*]}"
		do

			estado[$inicio]="0"		
			pos="$inicio"
			(( pos = pos + 1 ))
			buscado=`echo "${llamadas[$inicio]}" | cut -f 4 -d"-"`
			valorActual=`echo "${llamadas[$pos]}" | cut -f 4 -d"-"`
			
			while test $pos -lt ${#llamadas[*]} && (test "$buscado" != "$valorActual") 
			do 
				(( pos = pos + 1 ))
				valorActual=`echo "${llamadas[$pos]}" | cut -f 4 -d"-"`
			done
			fin="$pos"
			t1=`echo "${llamadas[$fin]}"| cut -c -19`
			t2=`echo "${llamadas[$inicio]}" | cut -c -19`
			t1=$(date -d "$t1" +%s)
			t2=$(date -d "$t2" +%s)
			tiempo=`echo $(( $t1 - $t2 ))`

			if test "$tiempo" -lt "$media"
			then
				(( noProm = noProm + 1 ))
			fi
			estado[$fin]="0"
			pos="$fin"
			(( pos = pos + 1 ))
			buscado=`echo "${llamadas[$fin]}" | cut -f 4 -d"-"`
			valorActual=`echo "${llamadas[$pos]}" | cut -f 4 -d"-"`
			while test $pos -lt ${#llamadas[*]} && (test "$buscado" != "$valorActual") 
			do 
				(( pos = pos + 1 ))
				valorActual=`echo "${llamadas[$pos]}" | cut -f 4 -d"-"`
			done
			inicio="$pos"
		done
		usuarioProm[$contador]="$buscado $noProm"	
		inicio=`buscarPersonaDispo`
		(( contador = contador + 1 ))
	done

	numA=`echo "${usuarioProm[0]}" | cut -f 2 -d" "`
	mayor=0
	for (( i="1"; i<${#usuarioProm[*]}; i++ ))
	do
		numB=`echo "${usuarioProm[$i]}" | cut -f 2 -d" "`
		if test "$numB" -gt "$numA"
		then
			mayor="$i"
			numA="$numB"
		fi
	done
	echo ""
	echo "El usuario com más llamadas por debajo de la media en la semana: `echo "${usuarioProm[$mayor]}" | cut -f 1 -d" "` (`echo "${usuarioProm[$mayor]}" | cut -f 2 -d" "` llamada/s)"
}
calcularMediaSemana()
{
		local fin
	local inicio=`buscarPersonaDispo`
	declare -a usuarioProm
	cantidad=0
	promedio=0
	while test "$inicio" -lt "${#llamadas[*]}"
	do
		
		while test "$inicio" -lt "${#llamadas[*]}"
		do
			estado[$inicio]="0"
			pos="$inicio"
			(( pos = pos + 1 ))
			buscado=`echo "${llamadas[$inicio]}" | cut -f 4 -d"-"`
			valorActual=`echo "${llamadas[$pos]}" | cut -f 4 -d"-"`
			while test $pos -lt ${#llamadas[*]} && (test "$buscado" != "$valorActual") 
			do 
				(( pos = pos + 1 ))
				valorActual=`echo "${llamadas[$pos]}" | cut -f 4 -d"-"`
			done
			fin="$pos"
			t1=`echo "${llamadas[$fin]}"| cut -c -19`
			t2=`echo "${llamadas[$inicio]}" | cut -c -19`
			(( cantidad = cantidad + 1 ))
			(( promedio = promedio +`restarFechas "$t1" "$t2"` ))
			estado[$fin]="0"
			pos="$fin"
			(( pos = pos + 1 ))
			buscado=`echo "${llamadas[$fin]}" | cut -f 4 -d"-"`
			valorActual=`echo "${llamadas[$pos]}" | cut -f 4 -d"-"`
			while test $pos -lt ${#llamadas[*]} && (test "$buscado" != "$valorActual") 
			do 
				(( pos = pos + 1 ))
				valorActual=`echo "${llamadas[$pos]}" | cut -f 4 -d"-"`
			done
			inicio="$pos"
		done

		inicio=`buscarPersonaDispo`
	done
	(( promedio = promedio / cantidad ))
	echo "$promedio"
	
		
}


if test "$todoOk" -eq "1"
then
	cargarVector "$2"
	if  test ${#llamadas[*]} -eq 0
	then
		echo "Archivo vacío"
		todoOk=0
	fi
	if test "$todoOk" -eq "1"
	then
		cargarVectorParalelo
		promedioTiempoDia

		cargarVectorParalelo
		promedioUsuarioDia

		cargarVectorParalelo
		contarOcurrencias
		buscarTop 3

		cargarVectorParalelo
		calcularLlamadasNoPromedio
		
		cargarVectorParalelo
		media=`calcularMediaSemana`
		cargarVectorParalelo
		cargarPromediosPorSemana
	fi
fi






