#!/bin/bash
# =========================== Encabezado =======================

# Nombre del script: Ejercicio4.sh
# Número de ejercicio: 1
# Trabajo Práctico: 1
# Entrega: Primera entrega

# ==============================================================

# ------------------------ Integrantes ------------------------
# 
#	Nombre			|	Apellido			    |	DNI
#	Matías			|	Beltramone	    |	40.306.191
#	Eduardo		|	Couzo Wetzel			|	43.584.741
#	Brian				|	Menchaca			    |	40.476.567
#	Ivana				|	Ruiz				       |	33.329.371
#	Lucas				|	Villegas			    |	37.792.844
# -------------------------------------------------------------


ErrorS()
{
echo "Error. La sintaxis del script es la siguiente:"
echo "Para determinar cantidad de lineas del archivo: $0 nombre_archivo L" # COMPLETAR
echo "Para determinar cantidad de caracteres del archivo: $0 nombre_archivo C" # COMPLETAR
echo "Para determinar longitud de la linea más larga: $0 nombre_archivo M" # COMPLETAR
}
ErrorP()
{
echo "Error. nombre_archivo $0 no tiene permiso de lectura" # COMPLETAR
}
if test $# -lt 2; then
ErrorS
fi
if ! test -r $1; then
ErrorP
elif test -f $1 && (test "$2" == "L" || test "$2" == "C" || test "$2" == "M"); then
if test $2 == "L"; then
res=`wc -l $1`
echo "Cantidad de lineas de: $res" # COMPLETAR
elif test $2 == "C"; then
res=`wc -m $1`
echo "Cantidad de caracteres de es: $res" # COMPLETAR
elif test $2 == "M"; then
res=`wc -L $1`
echo "La longitud de la linea mas larga es: $res" # COMPLETAR
fi
else
ErrorS
fi
 #1) El objetivo es mostrar distinta informacion de un determinado archivo que contenga texto.
 #
 #2) Recibe la direccion del archivo y el tipo de dato que queremos representado por las letras "L",
 # "C" y "M" 
 #
 #3) El script verifica inicialmente que se hayan enviado al menos 2 parametros, en caso contrario
 # muestrestra un mensaje con la sintaxis correcta para la dstinta informacion que podemos pedir, si 
 # los parametros son 2 o mas se verifica terner permisos de lectura sobre el archivo pasado por
 # el parametro 1. En caso contrario,  se muestra un mensaje indicando que no se posee permisos de
 # lectura. Una vez verificado el permiso de lectura se valida que cual es la informacion que 
 # solicita el usuario("L", "C", "M") de no solicitar una opcion valida se le vuelve a
 # mostrar la sintaxis correcta. Si se trata de una opcicion valida se verefica de cual de las 
 # 3 se trata y se la mustra la informacion solicitada.
 #
 #5) $# es una variable que nos brinda la cantidad  de parametros que recibio el script.
 #Conocemos $@ y $* que nos lista todos los parametros recibido y $? que nos da el valor 
 #de ejecucion del ultimo comando.
 #
 #6) Las comillas dobles (" ") permiten manejar un String que puede contener caracteres y valores 
 #  de variables, por ejemplo si escribo los comandos:
 # var1="eduardo"
 # echo "Hola $var1"
 # se muestra en la terminal:
 # Hola eduardo
 # 
 #Las comillas simples (' ') un String que contiene exactamente los caracteres con los que se escribe,
 # en el ejemplo anterior:
 # var1="eduardo"
 # echo 'Hola $var1'
 # Se muestra en la terminal:
 # Hola $var1
 #
 #Las comillas invertidas (` `) sirven para ejecutar los comandos que se encuentren en el String
 #por ejemplo:
 # var1="eduardo"
 # echo "Hola `echo $var1`"
 # Se muestra en la terminal:
 # Hola eduardo
