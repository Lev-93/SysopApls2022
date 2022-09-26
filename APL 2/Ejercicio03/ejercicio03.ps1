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

.PARAMETER c
Indica el directorio a monitorear.    

.PARAMETER a
Indica la lista de acciones separadas por coma, la acción publicar no puede estar si no se encuentra compilar.
Si el directorio donde se guarda el archivo generando en compilar no se encuentra se crea.

.PARAMETER s
Indica el directorio a copiar el archivo generado luego de haber compilado, este parametro es opcional, es decir, solo debe estar si se envía publicar como una de las acciones.  
Si el directorio indicado en -s no existe, se creara automáticamente.

.DESCRIPTION
    Este script, dado un directorio y acciones (listar,peso,compilar,peso) se encarga de monitorear un directorio
    al detectarse una creación/modificación/Eliminación/renombrado/modificación de contenido de un archivo
    se dejen ejecutas dichas acciones pasadas por parametro.
    El script se invoca de la siguiente forma:
    ./Ejercicio03.ps1 -c <directorio a monitorear> -a <lista de acciones> -s <directorio donde copiar el archivo generado luego de haber compilado>

.EXAMPLE

.\Ejercicio03.ps1 -c "\directoriomonitorizar" -a "listar,peso"   
.EXAMPLE

.\Ejercicio03.ps1 -c "\directoriomonitorizar" -a "listar,peso,compilar"
.EXAMPLE

.\Ejercicio03.ps1 -c "\directoriomonitorizar" -a "listar,peso,compilar,publicar" -s "\directoriodestino"
.EXAMPLE

Get-Help .\Ejercicio03.ps1 -Detailed
.EXAMPLE

.\Ejercicio03.ps1 -d ".\directorioAFinalizarMonitoreo"

#>

Param(
    [Parameter(Mandatory=$false)] [ValidateNotNullOrEmpty()] [String] $c,
    [Parameter(Mandatory=$false)] [ValidateNotNullOrEmpty()]
    [ValidateSet("listar","peso","compilar",'listar,peso',"listar,compilar","peso,listar","compilar,listar","compilar,peso","peso,compilar","compilar,publicar","publicar,compilar"
    ,"listar,peso,compilar","listar,compilar,peso","peso,listar,compilar","peso,compilar,listar","compilar,listar,peso","compilar,peso,listar"
    ,"listar,compilar,publicar","listar,publicar,compilar","compilar,listar,publicar","compilar,publicar,listar","publicar,compilar,listar","publicar,listar,compilar"
    ,"peso,compilar,publicar","peso,publicar,compilar","publicar,compilar,peso","publicar,peso,compilar","compilar,peso,publicar","compilar,publicar,peso"
    , "listar,peso,compilar,publicar","listar,peso,publicar,compilar","listar,publicar,compilar,peso","listar,publicar,peso,compilar","listar,compilar,peso,publicar","listar,compilar,publicar,peso"
    ,"peso,listar,compilar,publicar","peso,listar,publicar,compilar","peso,compilar,listar,publicar","peso,compilar,publicar,listar","peso,publicar,compilar,listar","peso,publicar,listar,compilar"
    , "compilar,peso,listar,publicar","compilar,peso,publicar,listar","compilar,listar,peso,publicar","compilar,listar,publicar,peso","compilar,publicar,listar,peso","compilar,publicar,peso,listar"
    , "publicar,listar,peso,compilar","publicar,listar,compilar,peso","publicar,peso,listar,compilar","publicar,peso,compilar,listar","publicar,compilar,listar,peso","publicar,compilar,peso,listar"
    )]
    [string]$a,
    [Parameter(Mandatory=$false)] [String] $s, #la validación de este parametro la haremos únicamente en caso de tener que publicar algo.
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
        if($acciones['listar'] -eq $true){
            #write-host "$Fecha $FullPath was $accion"
            Add-content "$Arch" "$Fecha $FullPath was $accion"
        }
        if($acciones['peso'] -eq $true -and $accion -ne "DELETED"){
            $peso=(gci "$FullPath" | measure Length -s).sum / 1kb
            #Write-Host "$FullPath pesa: $peso kilobytes"
            Add-content "$Arch" "$FullPath pesa: $peso kilobytes"
        }
        if($acciones['compilar'] -eq $true){
            $array = @()
            $array += (Get-ChildItem -Path "$PAT" -Attributes "Archive" -Filter "*.*" -Recurse | %{$_.FullName})
            #concatenar todos los archivos de la lista en otro localizado en una carpeta bin ubicada en el directorio de la script
            for ($i = 0; $i -lt $array.Count ; $i++){
                type $array[$i] >> "$PWD\bin\$PID.txt"
            }
        }
        if($acciones['publicar'] -eq $true){
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


$Global:as="$a"
$Global:PAT=(Resolve-Path -LiteralPath "$c").ToString()
$Global:nombre = split-path -leaf "$c"
Get-validardir "$PAT"

$cadena=$PAT.Replace('\','')

existe -Nom $cadena



if($s){
    $Global:SUB=(Resolve-Path -LiteralPath "$s").ToString()
}

$Global:acciones = @{ }

$acc=Write-Output $a | Select-String -Pattern 'listar'
if($acc){
    $acciones.Add('listar',"True")
}
else{
    $acciones.Add('listar',"False")
}

$acc=Write-Output $a | Select-String -Pattern 'peso'
if($acc){
    $acciones.Add('peso',"True")
} else {
    $acciones.Add('peso',"False")
}

$acc=Write-Output $a | Select-String -Pattern 'compilar'
if($acc){
    $acciones.Add('compilar',"True")
} else {
    $acciones.Add('compilar',"False")
}

$acc=Write-Output $a | Select-String -Pattern 'publicar'
if($acc){
    $acciones.Add('publicar',"True")
} else {
    $acciones.Add('publicar',"False")
}

if($acciones['compilar'] -eq $true){
    $var=Test-Path -Path "$PWD\bin"
    if($var -eq $false){
        #crear el directorio \bin
        New-Item "$PWD\bin" -Type Directory
    }
}

if($acciones['publicar'] -eq $true ){
    $var=Test-Path -Path "$SUB"
    if($var -ne $true){
        #crear el directorio
        New-Item "$SUB" -Type Directory
    }
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