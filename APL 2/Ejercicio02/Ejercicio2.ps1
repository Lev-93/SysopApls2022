<#
       .Synopsis
  	 El script tiene por objetivo generar informes de las llamadas provenientes de archivos de log:
	   		
      .Description
Informes:
1. Promedio de tiempo de las llamadas realizadas por día.
2. Promedio de tiempo y cantidad por usuario por día.
3. Los 3 usuarios con más llamadas en la semana
4. Cuántas llamadas no superan la media de tiempo por día
5. El usuario que tiene más cantidad de llamadas por debajo de la media en la semana.
	.Inputs
2022-08-09 14:22:00-aerodriguez
2022-08-09 14:22:10-fmarino
2022-08-09 14:22:11-vbo
2022-08-09 14:25:00-fmarino
2022-08-09 14:25:10-aerodriguez
2022-08-09 14:26:40-aerodriguez
2022-08-09 14:26:41-vbo
2022-08-09 14:32:00-aerodriguez	
.Example
./Ejercicio2.ps -logs "./Prueba"
	
------------Promedio de las llamadas de cada dia--------------
 
Promedio del dia 2022-08-09 : 237.5 segundos
 
------------Promedio de tiempo de las llamadas Usuario por Día--------------
 
Usuario: aerodriguez
Dia: 2022-08-09 Cantidad llamadas: 2 Promedio: 255 segundos
 
Usuario: fmarino
Dia: 2022-08-09 Cantidad llamadas: 1 Promedio: 170 segundos
 
Usuario: vbo
Dia: 2022-08-09 Cantidad llamadas: 1 Promedio: 270 segundos
 
------------3 usuarios con mas llamadas en la semana--------------
 
  Usuario: aerodriguez Cantidad Llamadas: 2 
 
  Usuario: fmarino Cantidad Llamadas: 1 
 
  Usuario: vbo Cantidad Llamadas: 1 
 
------------Llamadas que no superan la de tiempo por dia--------------
 
Dia: 2022-08-09 Cantidad de llamadas que no superan la media (237.5 seg) es: 2
 
El usuario com más llamadas por debajo de la media en la semana es: aerodriguez con 1 llamada/s
#>
# =========================== Encabezado =======================

# Nombre del programa: Ejercicio1.cpp
# Número de ejercicio: 2
# Trabajo Práctico: 2
# Entrega: Primera entrega

# ==============================================================

# ------------------------ Integrantes ------------------------
# 
#	Nombre				|	Apellido			|	DNI
#	Matías				|	Beltramone			|	40.306.191
#	Eduardo				|	Couzo Wetzel			|	43.584.741
#	Brian				|	Menchaca			|	40.476.567
#	Ivana				|	Ruiz				|	33.329.371
#	Lucas				|	Villegas			|	37.792.844
# -------------------------------------------------------------
Param(
	[Parameter(Mandatory=$false,Position=1)][string]$logs
)
$llamadas=New-Object System.Collections.ArrayList
$llamadas2=New-Object System.Collections.ArrayList
$llamadasSinFin=New-Object System.Collections.ArrayList
$estado=New-Object System.Collections.ArrayList
$estado2=New-Object System.Collections.ArrayList
$cantidadLlamadas=New-Object System.Collections.ArrayList
$archivos=New-Object System.Collections.ArrayList
$media
$todoOk=$true
function ayuda()
{
	
	Write-Host "El script necesita el parametro --logs y el directorio del archivo de logs de llamadas."
	Write-Host "Formato: "$0" --logs ubicacionLogs"
}

function cargarVector()
{  
    param
    (
        [Parameter(Mandatory=$True, Position=1)] [string] $archivo
    )
   foreach($line in Get-Content "$archivo") {
    if($line -match $regex){
        	$cantLineas = $llamadas2.add("$line")
		$cantLineas=$estado2.add(1)
		$cantLineas=$estado.add(1)
		
        }
    }
    
}
function cargarVectorParalelo()
{	
	for ($i=0; $i -lt $llamadas.count; $i++)
	{
		$estado[$i]=1
    	}
}
function mostrarVectorLlamadas()
{

    foreach($llamada in $llamadas)
    {
        Write-Host "$llamada"
    }
}
function buscarPrimeraOcurrencia2()
{
	param
	(
		[int] $pos
	)
	
	$buscado=$llamadas2[$pos].Split("-")[3]
	$pos++
	if($pos -lt $llamadas2.count)
	{
		$valorActual=$llamadas2[$pos].Split("-")[3]
	}	
	while ($pos -lt $llamadas2.count -and "$buscado" -ne "$valorActual") 
	{
		$pos++;
		if($pos -lt $llamadas2.count)
		{
			$valorActual=$llamadas2[$pos].Split("-")[3]
		}
	}
	return $pos	
}
function buscarPrimeraOcurrencia()
{
	param
	(
		[int] $pos
	)
	
	$buscado=$llamadas[$pos].Split("-")[3]
	$pos++
	$valorActual=$llamadas[$pos].Split("-")[3]	
	while ($pos -lt $llamadas.count -and "$buscado" -ne "$valorActual") 
	{
		$pos++;
		if($pos -lt $llamadas.count)
		{
			$valorActual=$llamadas[$pos].Split("-")[3]
		}
		
	}
	return $pos	
}
function buscarPersonaDispo2()
{
	$persona=0  
	while($persona -lt $llamadas2.count -and $estado2[$persona] -ne 1)
    	{
		$persona++;
    	}
	return $persona;
}
function buscarPersonaDispo()
{
	$persona=0  
	while($persona -lt $llamadas.count -and $estado[$persona] -ne 1)
    	{
		$persona++;
    	}
	return $persona;
}
function obtenerFechaYhora()
{
	$t1=$Args[0].Split(" ")[0]+" "+$Args[0].Split("-")[2].Split(" ")[1]
	$fecha=[DateTime]$t1
	return $fecha
}
function promedioTiempoDia()
{	
	
	$contador=0
	Write-Host " "
	Write-Host "------------Promedio de las llamadas de cada dia--------------"
	Write-Host " "
	while($contador -lt $llamadas.count)
	{
		$promedio=0;
		$cantLLamadas=0
		$dia=$llamadas[$contador].Split(" ")[0]
		$diaActual=$llamadas[$contador].Split(" ")[0]
		while($contador -lt $llamadas.count -and "$dia" -eq "$diaActual")
		{	
		    $cantLLamadas++
			$posicion=buscarPrimeraOcurrencia $contador
			$t1= obtenerFechaYhora $llamadas[$posicion]
			$t2= obtenerFechaYhora $llamadas[$contador]
			$estado[$posicion]=0
			$restarTiemp=(New-TimeSpan -Start $t2 -End $t1).TotalSeconds;
			$promedio = $promedio+$restarTiemp;
			$contador++
			$diaActual=$llamadas[$contador].Split(" ")[0]
			while ($contador -lt $llamadas.count -and $estado[$contador]  -ne 1)
			{
				$contador++
				if($llamadas[$contador])
				{
					$dia=$llamadas[$contador].Split(" ")[0]
				}
            }
        }
		if ($cantLLamadas -ne 0)
		{
			 $promedio = $promedio / $cantLLamadas
			Write-Host "Promedio del dia $diaActual : $promedio segundos"
        	}
    }
}
function promedioUsuarioDia()
{	
	Write-Host " "
	Write-Host "------------Promedio de tiempo de las llamadas Usuario por Día--------------"
	$fin
	$inicio=buscarPersonaDispo
	
	while($inicio -lt $llamadas.count)
	{
		Write-Host " "
	 	$mensaje= "Usuario: " + $llamadas[$inicio].Split("-")[3]
		Write-Host $mensaje	   
		while ($inicio -lt $llamadas.count)
		{
			$dia=$llamadas[$inicio].Split(" ")[0] 
			$diaActual=$llamadas[$inicio].Split(" ")[0] 
			$cantidad=0
			$promedio=0
			while ($inicio -lt $llamadas.count -and $dia -eq $diaActual)
			{
				
				$estado[$inicio]="0"
				$pos=$inicio
				$pos++
				$buscado=$llamadas[$inicio].Split("-")[3]
				$valorActual=$llamadas[$pos].Split("-")[3]
				while ($pos -lt $llamadas.count -and "$buscado" -ne "$valorActual") 
				{ 
					$pos++
					if($pos -lt $llamadas.count)
					{
						$valorActual=$llamadas[$pos].Split("-")[3]
					}

				}
				$fin=$pos
				$t1= obtenerFechaYhora $llamadas[$inicio]
				$t2= obtenerFechaYhora $llamadas[$fin]
				$cantidad++
				$restarTiemp=(New-TimeSpan -Start $t1 -End $t2).TotalSeconds;
				$promedio = $promedio+$restarTiemp;
				$estado[$fin]=0
				$pos=$fin
				$pos++
				$buscado=$llamadas[$fin].Split("-")[3]
				if($pos -lt $llamadas.count)
				{
					$valorActual=$llamadas[$pos].Split("-")[3]
				}
				while($pos -lt $llamadas.count -and "$buscado" -ne "$valorActual") 
				{
					$pos++
					if($pos -lt $llamadas.count)
					{
						$valorActual=$llamadas[$pos].Split("-")[3]
					}
				}
				$inicio=$pos
				if($inicio -lt $llamadas.count)
				{
						$diaActual=$llamadas[$inicio].Split(" ")[0]
				}
			}
			$promedio = $promedio / $cantidad 
			Write-Host "Dia: $dia Cantidad llamadas: $cantidad Promedio: $promedio segundos"
		}
		
		$inicio=buscarPersonaDispo
	}
}

function contarOcurrencias()
{
	$posPersona=buscarPersonaDispo
	while ($posPersona -lt $llamadas.count)
	{
		$cantLlamadas=0
		$personaActual=$llamadas[$posPersona].Split("-")[3]
		while ($posPersona -lt $llamadas.count)
		{
			$estado[$posPersona]=0
			$finLlam=$posPersona
			$finLlam++
			$buscando=$llamadas[$finLlam].Split("-")[3]
			while ($finLlam -lt $llamadas.count -and "$personaActual" -ne "$buscando")
			{
				$finLlam++
				if($finLlam -lt $llamadas.count)
				{
					$buscando=$llamadas[$finLlam].Split("-")[3]
				}
			}
			$estado[$finLlam]=0
			$finLlam++ 
			if($finLlam -lt $llamadas.count)
			{
				$buscando=$llamadas[$finLlam].Split("-")[3]
			}
			
			while ( $finLlam -lt $llamadas.count -and $personaActual -ne $buscando)
			{
				$finLlam++
				if($finLlam -lt $llamadas.count)
				{
					$buscando=$llamadas[$finLlam].Split("-")[3]
				}
			}
			if($finLlam -lt $llamadas.count)
			{
					$estado[$finLlam]=0
			}
		
			$posPersona=$finLlam
			$cantLlamadas++ 
		}
		$cantLineas=$cantidadLlamadas.add("$personaActual $cantLlamadas")
		$posPersona=buscarPersonaDispo
	}
}

function buscarTop()
{	
	$topNum=[int]$Args[0]
	$contar=0
	Write-Host " "
	Write-Host "------------$Args usuarios con mas llamadas en la semana--------------"
	while ( $contar -lt $topNum)
	{
		
		$recorrer=0
		$mayor=0
		$numA=[int]$cantidadLlamadas[$recorrer].Split(" ")[1]
		$numB=[int]$cantidadLlamadas[$recorrer].Split(" ")[1]

		while ($recorrer -lt $cantidadLlamadas.count)
		{	
			
			if ($numB -gt $numA)
 			{
 				$numA=$numB
				$mayor=$recorrer
			}
		 	$recorrer++
			if($recorrer -lt $cantidadLlamadas.count)
			{
				$numB=[int]$cantidadLlamadas[$recorrer].Split(" ")[1]
			}
			

		}
		if($numA -ne 0)
		{
			Write-Host " "
			Write-Host " "Usuario: $cantidadLlamadas[$mayor].Split(" ")[0] Cantidad Llamadas: $numA" " 
			
		}
		$contar++
		$cantidadLlamadas[$mayor]="0 0"
	}		
}
function calcularLlamadasNoPromedio()
{
	$contador=0
	$cantantidadNoProm=0
	$tiempoLlamadas=New-Object System.Collections.ArrayList
	Write-Host " "
	Write-Host "------------Llamadas que no superan la de tiempo por dia--------------"
	while ($contador -lt $llamadas.count)
	{
		$promedio=0;
		$cantLLamadas=0
		$dia=$llamadas[$contador].Split(" ")[0]
		$diaActual=$llamadas[$contador].Split(" ")[0]
		while($contador -lt $llamadas.count -and $dia -eq $diaActual)
		{	
			
			$posicion = buscarPrimeraOcurrencia $contador
			$t1=obtenerFechaYhora $llamadas[$posicion]
			$t2=obtenerFechaYhora $llamadas[$contador]
			$restarTiemp=(New-TimeSpan -Start $t2 -End $t1).TotalSeconds;
			$estado[$posicion]=0
			$promedio = $promedio + $restarTiemp
			$contador++
			$cantLineas=$tiempoLlamadas.add($restarTiemp)
			$cantLLamadas++
			if($cantidadLlamadas -lt $llamadas.count)
			{
				$diaActual=$llamadas[$contador].Split(" ")[0]
			}
			while($contador -lt $llamadas.count -and $estado[$contador] -ne 1)
			{
				$contador++
				if($contador -lt $llamadas.count)
				{
					$diaActual=$llamadas[$contador].Split(" ")[0]
				}

			}
		}
		
		if ($cantLLamadas -ne 0)
		{
			$cantantidadNoProm=0
			$promedio = $promedio / $cantLLamadas
			for ($i=0; $i -lt $cantLLamadas; $i++)
			{
				if ($tiempoLlamadas[$i] -le $promedio)
				{
					$cantantidadNoProm++	
				}
			}
			Write-Host " "
			Write-Host "Dia: $dia Cantidad de llamadas que no superan la media ($promedio seg) es: $cantantidadNoProm"
			
		}
	}
}
function cargarPromediosPorSemana()
{
	$fin
	$inicio=buscarPersonaDispo
	
	$usuarioProm=New-Object System.Collections.ArrayList
	$contador=0
	while ($inicio -lt $llamadas.count)
	{
		$noProm=0	
		while ($inicio -lt $llamadas.count)
		{

			$estado[$inicio]=0		
			$pos=$inicio
			$pos++
			$buscado=$llamadas[$inicio].Split("-")[3]
			$valorActual=$llamadas[$pos].Split("-")[3]
			while($pos -lt $llamadas.count -and $buscado -ne $valorActual)
			{ 
				$pos++
				if($pos -lt $llamadas.count)
				{
					$valorActual=$llamadas[$pos].Split("-")[3]
				}
			}
			
			$fin=$pos
			$t1=obtenerFechaYhora $llamadas[$inicio]
			$t2=obtenerFechaYhora $llamadas[$fin]
			$restarTiemp=(New-TimeSpan -Start $t1 -End $t2).TotalSeconds;
			$tiempo=$restarTiemp
			if ($tiempo -lt $media)
			{
				$noProm++
			}
			$estado[$fin]=0
			$pos=$fin
			$pos++
			$buscado=$llamadas[$fin].Split("-")[3]
			if($pos -lt $llamadas.count)
			{				
				$valorActual=$llamadas[$pos].Split("-")[3]
			}
			while($pos -lt $llamadas.count -and $buscado -ne $valorActual)
			{ 
				$pos++
				if($pos -lt $llamadas.count)
				{				
					$valorActual=$llamadas[$pos].Split("-")[3]
				}
			}
			$inicio=$pos
		}
		$cantLineas=$usuarioProm.add("$buscado-$noProm")	
		$inicio=buscarPersonaDispo
	}
	$numA=$usuarioProm[0].Split("-")[1]
	$mayor=0
	for ($i=1; $i -lt $usuarioProm.count; $i++)
	{
		$numB=$usuarioProm[$i].Split("-")[1]
		if ($numB -gt $numA)
		{
			$mayor=$i
			$numA=$numB
		}
	}
	Write-Host " "
	Write-Host El usuario com más llamadas por debajo de la media en la semana es: $usuarioProm[$mayor].Split("-")[0] con $usuarioProm[$mayor].Split("-")[1] llamada/s
}
function calcularMediaSemana()
{
	$contador=0
	$cantantidadNoProm=0
	$promedio=0;
	$cantLLamadas=0
	while ($contador -lt $llamadas.count)
	{
		
		
		$posicion = buscarPrimeraOcurrencia $contador
		$t1=obtenerFechaYhora $llamadas[$posicion]
		$t2=obtenerFechaYhora $llamadas[$contador]
		$restarTiemp=(New-TimeSpan -Start $t2 -End $t1).TotalSeconds;
		$estado[$posicion]=0
		$promedio = $promedio + $restarTiemp
		$contador++
		$cantLLamadas++
		while($contador -lt $llamadas.count -and $estado[$contador] -ne 1)
		{
			$contador++
			if($contador -lt $llamadas.count)
			{
				$diaActual=$llamadas[$contador].Split(" ")[0]
			}

		}
	}
	$promedio= $promedio/$cantLLamadas
	return $promedio
}	


function depurarVector()
{
	$contador=0
	$pos=-1
	while($contador -lt $llamadas2.count)
	{
		$estado2[$contador]=0
		$pos=buscarPrimeraOcurrencia2 $contador
		if($pos -eq $llamadas2.count)
		{
			$cantLineas=$llamadasSinFin.add($llamadas2[$contador])
		}
		else
		{
			
			$num=$llamadas.add($llamadas2[$contador])
			$num=$llamadas.add($llamadas2[$pos])
			
			$estado2[$pos]=0
		}
		$contador=buscarPersonaDispo2
	}
}

function informarErrores()
{
	$cant=$llamadasSinFin.count
	Write-Host " "
	Write-Host "Se encontraron $cant  llamadas sin inicio o fin"
	Write-Host "Las siguientes llamadas no fueron tenidas en cuenta como registros validos para el informe:"
	for($i=0;$i -lt $llamadasSinFin.count;$i++)
	{
		Write-Host $llamadasSinFin[$i]
	}
}
if((Test-Path -Path $logs) -eq $false)
{	
	Write-Host "No existe el Path $logs"
	$todoOK=$false
}
$i=0
Get-ChildItem -Path "$logs" -File |
Foreach-Object{
	$nada=$archivos.add("$_")
	$i++
}

for($i=0;$i -lt $archivos.count;$i++)
{
	Write-Host ""
	Write-Host ""
	Write-Host "Archivo N° $i"
	Write-Host "Ubicacion:" $archivos[$i]
if($todoOK -eq $true)
{
	cargarVector $archivos[$i]
}

if($todoOK -eq $true -and$llamadas2.count -eq 0)
{
	Write-Host "Archivo vacio"
	$todoOK=$false
}
if($todoOK -eq $true)
{
	$llamadas2.sort()
	depurarVector
	if($llamadas.count -ne 0)
	{
		$llamadas.sort()
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
		$media=calcularMediaSemana
		cargarVectorParalelo
		cargarPromediosPorSemana
	}else
	{
		Write-Host "No hay registros validos para realizar el informe"
	}
	if($llamadasSinFin.count -ne 0)
	{
		informarErrores
	}
}
	$llamadas.clear()
	$llamadas2.clear()
	$llamadasSinFin.clear()
	$estado.clear()
	$estado2.clear()
	$cantidadLlamadas.clear()
	$todoOK=$true
}
