
$Global:llamadas=New-Object System.Collections.ArrayList
$Global:cantLineas
function cargarVector()
{  
    param()
    (
        [Parameter(Mandatory=$True, Position=1)] [string] $archivo
    )
$contador=0;
   foreach($line in Get-Content "$args") {
    if($line -match $regex){
        $cantLineas = $llamadas.add("$line")
        }
    }
    
}
function mostrarVectorLlamadas()
{
    param()
    {
    }
    foreach($llamada in $llamadas)
    {
        echo "$llamada"
    }
}
cargarVector "pruebaEjercicio2-1-W"
Write-Host  $llamadas[0]
mostrarVectorLlamadas
$llamadas.sort()
Write-Host " \n\n"
mostrarVectorLlamadas


