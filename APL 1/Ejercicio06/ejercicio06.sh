#! /bin/bash
#**********************************************************
##  Ejercicio nro 6 del APL 1 - 2c 2022 - Entrega nro 1
##  Script: Ejercicio06.sh
##
##  Integrantes del grupo
##  Villegas Lucas Ezequiel, 37792844
##  Menchaca Brian Angel, 40476567
#**********************************************************


########################### CASOS DE PRUEBA: ##########################################
#****     Caso 1. Caso Común:
#     ./Ejercicio06.sh --eliminar ./Lote_de_Pruebas/1_Elimina_y_Recupera/prueba.txt
#     ./Ejercicio06.sh --listar
#     ./Ejercicio06.sh --recuperar prueba.txt
#     ./Ejercicio06.sh --listar

#****     Caso 2. Caso archivos con mismo nombre:
#     ./Ejercicio06.sh --eliminar ./Lote_de_Pruebas/2_Archivos_mismo_nombre/prueba1/prueba.txt
#     ./Ejercicio06.sh --eliminar ./Lote_de_Pruebas/2_Archivos_mismo_nombre/prueba2/prueba.txt
#     ./Ejercicio06.sh --recuperar prueba.txt

#****     Caso 3. Caso ruta con espacios
#     ./Ejercicio06.sh --eliminar ./Lote_de_Pruebas/3_Ruta_con_espacios/Prueba 1/prueba.txt
#     ./Ejercicio06.sh --recuperar prueba.txt

#****     Caso 4. Caso donde creamos un archivos, para luego eliminarlo y vaciamos la papelera(utilizando una copia de otro archivo)
#     cp ./Lote_de_Pruebas/1_Elimina_y_Recupera/prueba.txt ./Lote_de_Pruebas/4_Prueba_Vaciar_Palelera
#     ./Ejercicio06.sh --eliminar ./Lote_de_Pruebas/4_Prueba_Vaciar_Palelera/prueba.txt
#     ./Ejercicio06.sh --listar
#     ./Ejercicio06.sh --vaciar
#     ./Ejercicio06.sh --listar

# Función Ayuda
ayuda()
{
    echo "************************************************"
    echo " Este script simula una papelera de reciclaje   "
    echo " al borrar un archivo se tiene la posibilidad   "
    echo " de recuperarlo en un futuro.                   "
    echo " La papelera de reciclaje será un archivo zip   "
    echo " y la misma se guarda en el home del usuario    "
    echo " que ejecuta el script.                         "
    echo "                                                "
    echo " Ejemplo de invocación al script                "
    echo "  1) Consultar la ayuda:                        "
    echo "      ./Ejercicio6.sh -h                        "
    echo "      ./Ejercicio6.sh -?                        "
    echo "      ./Ejercicio6.sh --help                    "
    echo "                                                "
    echo "  2) Listar contenido de papelera:              "
    echo "      ./Ejercicio6.sh --listar                  "
    echo "                                                "
    echo "  3) Vaciar contenido de papelera:              "
    echo "      ./Ejercicio6.sh --vaciar                  "
    echo "                                                "
    echo "  4) Recuperar archivo de papelera:             "
    echo "      ./Ejercicio6.sh --recuperar archivo       "
    echo "                                                "  
    echo "  5) Eliminar archivo (Se envía a la papelera): "
    echo "      ./Ejercicio6.sh --eliminar archivo        "
    echo "                                                "        
    echo "************************************************"
}

# Función eliminar archivo
eliminar()
{
    archivoEliminar=$(realpath "$2")
    cant=$#
    for (( i = 3; i<=$cant; i++))
    do
        shift
        archivoEliminar+=" "
        archivoEliminar+=$2
    done
    papelera="${HOME}/papelera.zip"
    if [ ! -f "$archivoEliminar" ];
    then
        echo "Parámetro archivo en función eliminar no es válido"
        echo "Por favor consulte la ayuda"
        exit 1
    fi
    if [ ! -f "$papelera" ];
    then
        tar -cvPf "$papelera" "$archivoEliminar" > /dev/null
    else
        tar -rvPf "$papelera" "$archivoEliminar" > /dev/null
    fi
    rm "$archivoEliminar"
    echo "Archivo eliminado"
}

# Función listar elementos de la papelera
listar()
{
    papelera="${HOME}/papelera.zip"

    if [ ! -f "$papelera" ];
    then
        echo "Archivo papelera.zip no existe en el home del usuario"
        echo "No existe archivo a listar"
        exit 1
    fi

    if [ $(tar -tPf "$papelera" | wc -c) -eq 0 ];
    then
        echo "Papelera se encuentra vacía"
        exit 1
    fi

    IFS=$'\n'
    for archivo in $(realpath $(tar -tPf "$papelera"))
    do
        rutaArchivo=$(dirname "$archivo")
        nombreArchivo=$(basename "$archivo")
        echo "$nombreArchivo $rutaArchivo"
    done
}

# Función vaciar papelera
vaciar()
{
    papelera="${HOME}/papelera.zip"

    if [ ! -f "$papelera" ];
    then
        echo "Archivo papelera.zip no existe en el home del usuario"
        echo "No existe archivo papelera a vaciar"
        exit 1
    fi

    if [ $(tar -tPf "$papelera" | wc -c) -eq 0 ];
    then
        echo "Papelera ya se encuentra vacía"
        exit 1
    fi

    rm "$papelera"
    tar -cf "$papelera" --files-from /dev/null
}

# Función recuperar archivo
recuperar()
{
    archivoParaRecuperar="$1"
    papelera="${HOME}/papelera.zip"
    
    if [ ! -f "$papelera" ];
    then
        echo "Archivo papelera.zip no existe en el home del usuario"
        echo "No existen archivos a recuperar"
        exit 1
    fi
    if [ $(tar -tPf "$papelera" | wc -c) -eq 0 ];
    then
        echo "Papelera se encuentra vacía"
        echo "No se puede recuperar archivo indicado"
        exit 1
    fi
    if [ "$archivoParaRecuperar" == "" ];
    then
        echo "Parámetro archivo a recuperar sin informar"
        exit 1
    fi

    contadorArchivosIguales=0
    archivosIguales=""
    declare -a arrayArchivos
    archivo_a_recuperar=""

    IFS=$'\n'
    for archivo in $(realpath $(tar -tPf "$papelera"))
    do
        rutaArchivo=$(dirname "$archivo")
        nombreArchivo=$(basename "$archivo")
        if [ "$nombreArchivo" == "$archivoParaRecuperar" ];
        then
            let contadorArchivosIguales=contadorArchivosIguales+1
            archivosIguales="$archivosIguales$contadorArchivosIguales - $nombreArchivo $rutaArchivo;"
            arrayArchivos[$contadorArchivosIguales]="$archivo"
            archivo_a_recuperar="$archivo"
        fi
    done

    if [ "$contadorArchivosIguales" -eq 0 ];
    then
        echo "No existe el archivo en la papelera"
        exit 1
    else
        if [ "$contadorArchivosIguales" -eq 1 ];
        then
            tar -xvPf "$papelera" "$archivo_a_recuperar" 1> /dev/null 
            tar --delete --file="$papelera" "$archivo_a_recuperar" 
        else
            echo "$archivosIguales" | awk 'BEGIN{FS=";"} {for(i=1; i < NF; i++) print $i}'
            echo "¿Qué archivo desea recuperar?"
            read opcion

            seleccion="${arrayArchivos[$opcion]}"

            elementoNumero=0
            indice=0
            IFS=$'\n'
            for archivo in $(realpath $(tar -tPf "$papelera"))
            do
                let indice=$indice+1
                if [ "$seleccion" == "$archivo" ];
                then
                    elementoNumero=$indice
                fi
            done
            indice=0
            IFS=$'\n'
            for archivo in $(tar -tPf "$papelera")
            do
                let indice=$indice+1
                if [ "$indice" == "$elementoNumero" ];
                then
                    tar -xvPf "$papelera" "$archivo" 1> /dev/null
                    tar --delete --file="$papelera" "$archivo"
                fi
            done
        fi
    fi
    echo "Archivo recuperado"
}

# Se valida parámetros
if ([ $# -eq 0 ]);
then
    echo "Error en invocar al script"
    echo "Por favor consulte la ayuda"
    exit 1
fi
case "$1" in 
    "-h")
        ayuda
        exit 0
        ;;
    "-?")
        ayuda
        exit 0
        ;;
    "--help")
        ayuda
        exit 0
        ;;
    "--listar")
        listar
        exit 0
        ;;
    "--vaciar")
        vaciar
        exit 0
        ;;
    "--eliminar")
        eliminar "$@"
        exit 0
        ;;
    "--recuperar")
        recuperar "$2"
        exit 0
        ;;
    *) 
        echo "Error en invocar al script"
        echo "Por favor consulte la ayuda"
        exit 1
        ;;
esac
