# =========================== Encabezado =======================

# Nombre del script: ejercicio03.sh
# Número de ejercicio: 3
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
El script se encarga de monitorizar un directorio enviado por parametro

.PARAMETER codigo
Indica el directorio a monitorear.    

.PARAMETER acciones
Indica la lista de acciones separadas por coma, la acción publicar no puede estar si no se encuentra compilar.
Si el directorio donde se guarda el archivo generando en compilar no se encuentra se crea.

.PARAMETER salida
Indica el directorio a copiar el archivo generado luego de haber compilado, este parametro es opcional, es decir, solo debe estar si se envía publicar como una de las acciones.  
Si el directorio indicado en -s no existe, se creara automáticamente.

.DESCRIPTION
    Este script, dado un directorio y acciones (listar,peso,compilar,peso) se encarga de monitorear un directorio
    al detectarse una creación/modificación/Eliminación/renombrado/modificación de contenido de un archivo
    se dejen ejecutas dichas acciones pasadas por parametro.
    El script se invoca de la siguiente forma:
    ./Ejercicio03.ps1 -codigo <directorio a monitorear> -acciones <lista de acciones> -salida <directorio donde copiar el archivo generado luego de haber compilado>

.EXAMPLE

.\Ejercicio03.ps1 -codigo "\directoriomonitorizar" -acciones "listar,peso"   
.EXAMPLE

.\Ejercicio03.ps1 -codigo "\directoriomonitorizar" -acciones "listar,peso,compilar"
.EXAMPLE

.\Ejercicio03.ps1 -codigo "\directoriomonitorizar" -acciones "listar,peso,compilar,publicar" -salida "\directoriodestino"
.EXAMPLE

Get-Help .\Ejercicio03.ps1 -Detailed
.EXAMPLE

.\Ejercicio03.ps1 -d ".\directorioAFinalizarMonitoreo"

#>

Param(
    [Parameter(Mandatory=$false)] [ValidateNotNullOrEmpty()] [String] $codigo,
    [Parameter(Mandatory=$false)] [ValidateNotNullOrEmpty()]
    [string[]]$acciones,
    [Parameter(Mandatory=$false)] [String] $salida, #la validación de este parametro la haremos únicamente en caso de tener que publicar algo.
    [Parameter(Mandatory=$false)] [string] $d
)

function Get-validardir() {
    param(
        [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$dir
    )
    
    Begin{
       $resultado=0
    }
    Process{
        $var=Test-Path -Path "$dir" #valida si existe el directorio devuelve "True" si existe y "False" si no existe
        if($var -eq "True"){
           $resultado=1
        }
    }
    End{
        if($resultado -eq 0){
            Write-Output "Directorio inválido"
            exit 1
        }
    }
}

function existe() {
    Param(
        [string] $Nom
    )
    $proceso = get-job -erroraction 'silentlycontinue' | select-object Name | Where-Object { $_.Name -match "$Nom" }

    if ($NULL -ne $proceso -and $proceso.count -ge 0) {
        Write-Host "El directorio ya esta siendo monitorizado"
        exit 1
    }
}

function noExiste() {
        Param(
        [string] $Nom
    )
    $proceso = (get-job -erroraction 'silentlycontinue' | select-object Name | Where-Object { $_.Name -match "$Nom" })
    if ($NULL -eq $proceso) {
        Write-Host "No existe proceso monitorizando el directorio"
        exit 1
    }
}

function Global:RealizarAcciones($FullPath,$accion,$Fecha) {
    $var2=Test-Path -Path "$FullPath" -PathType Leaf -ErrorAction Ignore
    if($var2 -eq $true){
        if($Vacciones['listar'] -eq $true){
            #write-host "$Fecha $FullPath was $accion"
            Add-content "$Arch" "$Fecha $FullPath was $accion"
        }
        if($Vacciones['peso'] -eq $true -and $accion -ne "DELETED"){
            $peso=(gci "$FullPath" | measure Length -s).sum / 1kb
            #Write-Host "$FullPath pesa: $peso kilobytes"
            Add-content "$Arch" "$FullPath pesa: $peso kilobytes"
        }
        if($Vacciones['compilar'] -eq $true){
            $array = @()
            $array += (Get-ChildItem -Path "$PAT" -Attributes "Archive" -Filter "*.*" -Recurse | %{$_.FullName})
            #concatenar todos los archivos de la lista en otro localizado en una carpeta bin ubicada en el directorio de la script
            for ($i = 0; $i -lt $array.Count ; $i++){
                type $array[$i] >> "$PWD\bin\$PID.txt"
            }
        }
        if($Vacciones['publicar'] -eq $true){
            #copiar el archivo obtenido en compilar a la carpeta bin localizada en el mismo directorio donde se se encuentra el script
            Copy-Item -Path "$PWD\bin\$PID.txt" -Destination "$SUB"
        }
    }
}

if ($d -ne "") {
    $directorioAEliminar=split-path -leaf "$d"
    $cadena=$directorioAEliminar.Replace('\','')
    noExiste -Nom $cadena
    Get-Job -erroraction 'silentlycontinue' | Select-Object Name | Where-Object { $_.Name -match "$directorioAEliminar" } | ForEach-Object { remove-job -force -Name $_.Name }
    if (Test-Path -Path "./$directorioAEliminar.txt" -PathType Leaf) {
        get-content -path "./$directorioAEliminar.txt"
        Remove-Item -Path "./$directorioAEliminar.txt"
    }
    else {
        write-host "El Directorio $directorioAEliminar no ha sufrido cambios."
    }
    Write-Host "El proceso ha sido finalizado."
    exit 1;
}


$Global:as="$acciones"
$Global:PAT=(Resolve-Path -LiteralPath "$codigo").ToString()
$Global:nombre = split-path -leaf "$codigo"
Get-validardir "$PAT"

$cadena=$PAT.Replace('\','')

existe -Nom $cadena


$Global:Vacciones = @{listar= "False"; peso= "False"; compilar= "False";publicar="False" }

if($acciones.Count -lt 1 -or $acciones.Count -gt 4){
    write-output "error, cantidad de acciones inválida"
    exit 1;
}

for ($i = 0; $i -lt $acciones.Count ; $i++){
     if($acciones[$i] -ne "listar" -and $acciones[$i] -ne "peso" -and $acciones[$i] -ne "compilar" -and $acciones[$i] -ne "publicar"){
        Write-Output "Error, Acción inválida"
        exit 1;
     }
     else{
       $Vacciones.Remove($acciones[$i])
       $Vacciones.Add($acciones[$i],"True")
     }
}

if($Vacciones['compilar'] -ne $true -and $Vacciones['publicar'] -eq "true"){
    Write-Output "Error, no puede haber no haber un compilar y si un publicar"
    exit 1;
}

if($Vacciones['publicar'] -eq "true" -and -Not $salida){
    Write-Output "Error, si esta la acción publicar, debe haber un directorio en salida"
    exit 1;
}

if($Vacciones['compilar'] -eq $true){
    $var=Test-Path -Path "$PWD\bin"
    if($var -eq $false){
        #crear el directorio \bin
        New-Item "$PWD\bin" -Type Directory
    }
}

if($Vacciones['publicar'] -eq $true ){
    $var=Test-Path -Path "$salida"
    if($var -ne $true){
        #crear el directorio
        New-Item "$salida" -Type Directory
    }
}

if($salida){
    $Global:SUB=(Resolve-Path -LiteralPath "$salida").ToString()
}


$global:Arch = ".\$nombre.txt"


$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $PAT
$watcher.Filter = "*.*"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

$action = {
        $details = $event.SourceEventArgs
        $Name = $details.Name
        $FullPath = $details.FullPath
        $OldFullPath = $details.OldFullPath
        $OldName = $details.OldName
        # tipo de cambio:
        $ChangeType = $details.ChangeType

        # cuándo ocurrió el cambio:
        $Timestamp = $event.TimeGenerated

        $global:all = $details
        $ev = ""
        switch ($ChangeType)
        {
            "Changed"  { $ev="CHANGED" }
            "Created"  { $ev="CREATED" }
            "Deleted"  { $ev="DELETED" }
            "Renamed"  { $ev="RENAMED" }  
            # cualquier superficie de tipo de cambio no controlada aquí:
            default   {}
        }
        $FullPath = $all.FullPath
        $Timestamp = $event.TimeGenerated
        
        RealizarAcciones "$FullPath" $ev $Timestamp
}

Register-ObjectEvent -InputObject $watcher -EventName Created -Action $action -SourceIdentifier "$cadena-Created" | out-null
Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action -SourceIdentifier "$cadena-Changed" | out-null
Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action $action -SourceIdentifier "$cadena-Deleted" | out-null
Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $action -SourceIdentifier "$cadena-Renamed" | out-null 