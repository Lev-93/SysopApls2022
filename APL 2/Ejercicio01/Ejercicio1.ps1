Param (
    [Parameter(Position = 1, Mandatory = $false)]
    [String] $pathSalida = ".\procesos.txt ",
   # [Parameter(Position = 2, Mandatory = $false)]
    [int] $cantidad = 3
)
$existe = Test-Path $pathSalida
if ($existe -eq $true) {
$procesos = Get-Process | Where-Object { $_.WorkingSet -gt 100MB }
$procesos | Format-List -Property Id,Name >> $pathSalida
for ($i = 0; $i -lt $cantidad ; $i++) {
Write-Host $procesos[$i].Id - $procesos[$i].Name
}
} else {
Write-Host "El path no existe"
}
#1) El script tiene por objertivo mostrar en pantalla los N procesos (indicados en el parametro $cantidad) (Id y nombre) que utilizen 
#   más de 100MB de me memoría. Además se escriben en un archvio de texto todos los procesos que usen más de 100MB de memoria
#2) Se podria agregar una validacion para asegurar que el parametro segundo parametro es la cantidad de proceso a mostrar en pantalla y 
#   así ejecutar el Script sin usar el -cantidad.
#
#3) Si se ejecuta sin ningun paramentro se inicializan los parametros por defecto ($pathSalida = ".\procesos.txt y $cantidad = 3). En caso
#   de que no exista un archvio \procesos.txt se informar que "El path no existe" y termina la ejecición del script.
