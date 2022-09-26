# =========================== Encabezado =======================

# Nombre del script: Ejercicio4.sh
# Número de ejercicio: 4
# Trabajo Práctico: 2
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

<#
.SYNOPSIS
	Contar la cantidad de líneas de código y las líneas de comentarios que poseen los archivos en una ruta pasada por parámetro.
.DESCRIPTION
    Solo se tendrá en cuenta los archivos con cierta extensión, la cual también se pasará por parámetro.
    Se informará la cantidad de archivos analizados, cantidad total de líneas de código, su porcentaje contra el total de líneas,
    cantidad total de líneas de comentarios, y su porcentaje contra el total de líneas.
.EXAMPLE
    ./Ejercicio4.ps1 -ruta "/home/usuario/Documents/APL2/Test" -ext txt,js,doc
.INPUTS
    ruta
    ext
.PARAMETER ruta
	Directorio que deseamos analizar. También se analizarán los subdirectorios, de manera recursiva.  
.PARAMETER ext
	Listado de extensiones de los archivos que deseamos analizar, separados por coma.
#>

Param (
    [Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[ValidateScript({
            if (($_ -ne "") -and (Test-Path -PATH $_ -PathType Container)) {               
               return $true
            }
            else {
                throw "El directorio no existe."
            }
	})] [string] $ruta,

    [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][String[]] $ext
)

class Reporte{
    [int]$Archivos_Analizados;
    [int]$Total_Lineas;
    [int]$Total_Comentarios;
    [double]$Porcentaje_Comentarios;
    [int]$Total_Codigo;
    [double]$Porcentaje_Codigo;

    Reporte(){
        $this.Archivos_Analizados=0;
        $this.Total_Lineas=0;
        $this.Total_Comentarios=0;
        $this.Total_Codigo=0;
        $this.Porcentaje_Codigo=0;
        $this.Porcentaje_Comentarios=0;
    }
}

### FUNCIONES ###

function contarLineas()
{
    Param ( 
            [string] $arch
            )

    $totalLineas = 0;
    $comentarios=0
    $codigo=0
    $bandera=0	#la bandera sirve para contar los comentarios multilínea
    
    foreach ($LINE in Get-Content $arch) {
        $totalLineas++;
    }
     
    #en el foreach se cuentan las líneas de código y las líneas de comentario de CADA archivo
    foreach ($LINE in Get-Content $arch) 
    {
        if($LINE -match '//' -or $LINE -match '/\*') {  #si la linea contiene // o /* 
            $comentarios++;
            if($LINE -match '/\*') { 
                $bandera=1
            }
            
            #borra espacios al principio de una linea, si los hubiera, ejemplo:    //comentario
            $LINE = $LINE -replace(" ","")
            #lo mismo, pero si ese espacio fue generado por un tab 
            $LINE = $LINE -replace("`t","")
           
            #entra en este if con el siguiente ejemplo: linea de codigo /*linea de comentario*/
            #el caracter ^ evalúa los caracteres con los que empieza la línea
            if (-not ($LINE -match '^//*') -And (-not($LINE -match '^/\**'))) { #si la línea NO empieza con // y NO empieza con /*
                $codigo++;
            }
        }

        else {
            if($bandera -eq 0) {
                $codigo++;
            }
            else {
                $comentarios++;
            }
        }

        if ($LINE -match '\*/$' ) {   #si los últimos dos caracteres de la línea son */
            $bandera=0
        }

    }

    #El ejercicio no pide mostrar la siguiente parte, pero lo dejo para mayor claridad.
	#Descomentar los siguientes Write-Output para realizar pruebas.
    #Write-Output("Archivo analizado: " + $arch)
    #Write-Output("Cantidad de líneas de comentarios :" + $comentarios)
    #Write-Output("Cantidad de líneas de código: " + $codigo)
    #Write-Output("")

    $reporte.Archivos_Analizados++;
    $reporte.Total_Lineas+= $totalLineas;
    $reporte.Total_Comentarios+= $comentarios;
    $reporte.Total_Codigo+= $codigo;
}

### FIN FUNCIONES ###

#agrego el asterisco y el punto a cada extensión
$asterisco = "*."
$ext = foreach ($item in $ext) {
    "$asterisco$item"
}

#de manera recursiva, obtengo todos los archivos con las extensiones que buscamos
$files = Get-ChildItem $ruta -Recurse -Include $ext[0..$ext.Count] 

$reporte = New-Object Reporte;

#recorro cada archivo para analizarlo y crear el reporte con los totales
for($i=0; $i -lt $files.Count; $i++) {
    contarLineas $files[$i]   
}

if ($files) {
    $reporte.Porcentaje_Comentarios= [math]::Round($reporte.Total_Comentarios/$reporte.Total_Lineas*100,2);
    $reporte.Porcentaje_Codigo= [math]::Round($reporte.Total_Codigo/$reporte.Total_Lineas*100,2);
    $reporte    #muestra el reporte por pantalla
}

else {    
    Write-Output("No se encontraron archivos con las extensiones solicitadas.")
}

#FIN DE ARCHIVO