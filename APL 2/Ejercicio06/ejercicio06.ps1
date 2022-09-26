# =========================== Encabezado =======================

# Nombre del script: Ejercicio06.sh
# Número de ejercicio: 6
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
Este script simula una papelera de reciclaje
.DESCRIPTION
Este script simula una papelera de reciclaje
al borrar un archivo se tiene la posibilidad
de recuperarlo en un futuro.
La papelera de reciclaje será un archivo zip
y la misma se guarda en el home del usuario
que ejecuta el script.
.PARAMETER listar
 Lista el contenido de la papelera.zip
.PARAMETER vaciar 
 Deja vacia la papelera.zip
.PARAMETER eliminar 
 Elimina un archivo y lo envia a la papelera.zip
.PARAMETER recuperar 
 recupera un archivo de la papelera.zip
.EXAMPLE
Listar contenido de papelera:
  ./Ejercicio06.ps1 -listar
.EXAMPLE
Vaciar contenido de papelera:
  ./Ejercicio06.ps1 -vaciar  
.EXAMPLE
Recuperar archivo de papelera:  
  ./Ejercicio06.ps1 -recuperar archivo
.EXAMPLE
Eliminar archivo (Se envía a la papelera):
  ./Ejercicio06.ps1 -eliminar archivo 
#>

param(
  [Parameter(Position=1,ParameterSetName='listar')]
  [switch]
  $listar,
  [Parameter(Position=1,ParameterSetName='vaciar')]
  [switch]
  $vaciar,
  [Parameter(Position=1,ParameterSetName='eliminar')]
  [switch]
  $eliminar,
  [Parameter(Position=1,ParameterSetName='recuperar')]
  [switch]
  $recuperar,
  [Parameter(Mandatory=$false,Position=2)]
  [String]
  $archivo
)

function vaciar{
  $papelera="${HOME}/papelera.zip"

  if(!(Test-Path "$papelera")){
    Write-host "Archivo papelera.zip no existe en el home del usuario"
    Write-host "No existe archivo papelera a vaciar"
    exit 1
  }

  Remove-Item "$papelera";
  Add-Type -Assembly 'System.IO.Compression.FileSystem';
  $zip = [System.IO.Compression.ZipFile]::Open("$papelera", 'create');
  $zip.Dispose();
}

function eliminar{
  $papelera="${HOME}/papelera.zip"

  if(!(Test-Path "$archivo")){
    Write-Host "Parámetro archivo en función eliminar no es válido"
    Write-Host "Por favor consulte la ayuda"
    exit 1
  }
  $archivoEliminar=$(Resolve-Path "$archivo");

  if(!(Test-Path "$papelera")){
    $zip = [System.IO.Compression.ZipFile]::Open("$papelera", "create");
    $zip.Dispose();
  }

  $compressionLevel = [System.IO.Compression.CompressionLevel]::Fastest;
  $zip = [System.IO.Compression.ZipFile]::Open("$papelera", "update");
  [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, "$archivoEliminar", "$archivoEliminar", $compressionLevel);
  $zip.Dispose();

  Remove-Item "$archivoEliminar"
  Write-Host "Archivo eliminado"
} 

function listar{
  $papelera="${HOME}/papelera.zip"

  if(!(Test-Path "$papelera")){
    Write-host "Archivo papelera.zip no existe en el home del usuario"
    Write-host "No existe archivo a listar"
    exit 1
  }

  Add-Type -Assembly 'System.IO.Compression.FileSystem';
  $zip = [System.IO.Compression.ZipFile]::Open("$papelera", 'read');

  foreach($archivoDelZip in $zip.Entries){
    Resolve-Path "$archivoDelZip" -ErrorAction SilentlyContinue -ErrorVariable _file
    $archivoListar = $_file[0].TargetObject;
    $rutaArchivo=$(Split-Path -Path "$archivoListar")
    $nombreArchivo=$(Split-Path -Leaf "$archivoListar")
    Write-Host "$nombreArchivo $rutaArchivo"
  }

  $zip.Dispose();
}

function recuperar{
  $archivoParaRecuperar="$archivo"
  $papelera="${HOME}/papelera.zip"
  
  if(!(Test-Path "$papelera")){
    Write-host "Archivo papelera.zip no existe en el home del usuario"
    Write-host "No existen archivos a recuperar"
    exit 1
  }

  if([String]::IsNullOrEmpty("$archivoParaRecuperar")){
    Write-host "Parámetro nombre de archivo a recuperar sin informar"
    exit 1
  }

  $contadorArchivosIguales=0;
  $archivosIguales = "";
  $arrayArchivos = @()

  Add-Type -Assembly 'System.IO.Compression.FileSystem';
  $zip = [System.IO.Compression.ZipFile]::Open("$papelera", 'update');
  
  foreach($archivoDelZip in $zip.Entries){
    Resolve-Path "$archivoDelZip" -ErrorAction SilentlyContinue -ErrorVariable _file
    $archivoListar = $_file[0].TargetObject;
    $nombreArchivo=$(Split-Path -Leaf "$archivoListar")
    $rutaArchivo=$(Split-Path -Path "$archivoListar")

    if("$nombreArchivo".Equals("$archivoParaRecuperar")){
      $contadorArchivosIguales++;
      $archivosIguales="$archivosIguales$contadorArchivosIguales - $nombreArchivo $rutaArchivo;"
      $arrayArchivos += "$archivoListar"
    }
  }

  if($contadorArchivosIguales -eq 0){
    Write-Host "No existe el archivo en la papelera";
    $zip.Dispose();
    exit 1;
  }elseif($contadorArchivosIguales -eq 1){
    $indice=0;
    foreach($archivoDelZip in $zip.Entries){
      Resolve-Path "$archivoDelZip" -ErrorAction SilentlyContinue -ErrorVariable _file
      $archivoRecuperar = $_file[0].TargetObject;
      $nombreArchivo=$(Split-Path -Leaf "$archivoRecuperar")
  
      if("$nombreArchivo".Equals("$archivoParaRecuperar")){
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($zip.Entries[$indice], "$archivoRecuperar", $true);
        break;
      }
      $indice++;
    }
    $zip.Entries[$indice].Delete();
  }else{
    foreach($linea in "$archivosIguales".Split(";")){
      Write-Host "$linea";
    }
    
    $opcion = Read-Host "¿Qué archivo desea recuperar? ";
    if($opcion -le 0){
      Write-Host "Opciòn invalida";
      $zip.Dispose();
      exit 1;
    }
    
    try {
      $seleccion = $arrayArchivos[$opcion-1];
      $indice=0;
    }
    catch {
      Write-Host "Opciòn invalida";
      $zip.Dispose();
      exit 1;
    }

    foreach($archivoDelZip in $zip.Entries){
      Resolve-Path "$archivoDelZip" -ErrorAction SilentlyContinue -ErrorVariable _file
      $archivoRecuperar = $_file[0].TargetObject;
  
      if("$archivoRecuperar".Equals("$seleccion")){
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($zip.Entries[$indice], "$archivoRecuperar", $true);
        break;
      }
      $indice++;
    }
    try {
      $zip.Entries[$indice].Delete();
    }
    catch {
      Write-Host "Opciòn invalida"; 
      $zip.Dispose();
      exit 1;
    }
    
  }

  $zip.Dispose();
  Write-host "Archivo recuperado"
}

if($listar){
  listar;
}elseif ($vaciar) {
  vaciar;
}elseif ($eliminar) {
  eliminar;
}elseif ($recuperar) {
  recuperar;
}else {
  Write-Host "Parametros incorrectos";
  Write-Host "Por favor, consulte la ayuda";
  exit 1;
}