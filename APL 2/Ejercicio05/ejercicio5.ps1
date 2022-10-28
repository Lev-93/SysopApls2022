# =========================== Encabezado =======================

# Nombre del script: ejercicio5.ps1
# Número de ejercicio: 5
# Trabajo Práctico: 2
# Entrega: Primera Entrega

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
Brinda informacion relacionada a la tasa de exito de los alumnos por materia.

.Description
Este script necesita OBLIGATORIAMENTE que se pongan los parametros -notas y -materias
El script por programacion no le dejara incluir parametros erroneos, de mas, o de menos a los obligatorios

-notas: Ruta del archivo a procesar
-materias:  Ruta del archivo con los datos de las materias.s

.EXAMPLE
./ejercicio5.ps1 -notas "./notas.txt" -materias ./materias2.txt
.EXAMPLE
./ejercicio5.ps1 -notas ./notas.txt -materias ./materias2.txt
.EXAMPLE
./ejercicio5.ps1 -notas "./notas.txt" -materias "./materias2.txt"

#> 

# using module ./alumno.ps1

param (
    [Parameter(Mandatory = $true)]
    [ValidateScript({Test-Path $_ -PathType leaf})]
    [System.IO.FileInfo]$notas,
    [Parameter(Mandatory = $true)]
    [ValidateScript({Test-Path $_ -PathType leaf})]
    [System.IO.FileInfo]$materias
)   

## CLASES NECESARIAS

class DataAlumno
{
    [string] $dni
    [int] $materia
    [int] $pp
    [int] $sp
    [int] $recu 
    [int] $final

    DataAlumno() {

    }

    DataAlumno([string] $line)
    {
        $this.dni = $line.Split("|")[0];
        $this.materia = $line.Split("|")[1];
        $this.pp = $line.Split("|")[2];
        $this.sp = $line.Split("|")[3];
        $this.recu = $line.Split("|")[4];
        $this.final = $line.Split("|")[5];

        if($this.pp -eq "")
        {
            $this.pp = 0;
        }

        if($this.sp -eq "")
        {
            $this.sp = 0;
        }

        if($this.recu -eq "")
        {
            $this.recu = 0;
        }

        if($this.final -eq "")
        {
            $this.final = 0;
        }

    }
};

class DataMateria
{
    [int] $id_materia
    [string] $descripcion
    [int] $departamento

    DataMateria()
    {

    }

    DataMateria([string] $line)
    {
        $this.id_materia = $line.Split("|")[0];
        $this.descripcion = $line.Split("|")[1];
        $this.departamento = $line.Split("|")[2];

        if($this.id_materia -eq "")
        {
            $this.id_materia = 0
        }
    }

};

class InformeMateria
{
    [int] $departamento
    [int] $id_materia
    [string] $descripcion
    [int] $final
    [int] $recursan
    [int] $abandonaron
    [int] $promocionan

    InformeMateria()
    {

    }

    InformeMateria([int] $departamento, [int] $id, [string] $descripcion, [int] $final, [int] $recursan, [int] $abandonaron, [int] $promocionan)
    {
        $this.departamento = $departamento;
        $this.id_materia = $id;
        $this.descripcion = $descripcion;
        $this.final = $final;
        $this.recursan = $recursan;
        $this.abandonaron = $abandonaron;
        $this.promocionan = $promocionan;
    }

};

class PruebaNota{
    [int]$id_materia;
    [string]$descripcion;
    [int]$promocionan;
    [int]$abandonaron;
    [int]$recursan;
    [int]$final;

    PruebaNota([int]$id_materia,[string]$descripcion,[int]$final, [int]$recursan, [int]$abandonaron, [int]$promocionan)
    {
        $this.id_materia = $id_materia;
        $this.descripcion = $descripcion;
        $this.final = $final;
        $this.recursan = $recursan;
        $this.abandonaron = $abandonaron;
        $this.promocionan = $promocionan;
    }
}


class Departamento{
    [int]$id
    [System.Collections.ArrayList]$notas

    Departamento([int]$id_materia,[string]$descripcion,[int]$id, [int]$final, [int]$recursan, [int]$abandonaron, [int]$promocionan){
        $this.id = $id
        $this.notas = [System.Collections.ArrayList]::new()
        $n = [PruebaNota]::new($id_materia,$descripcion, $final, $recursan, $abandonaron, $promocionan)
        $this.notas.Add($n) > $null
    }

    [void] agregarNota ([int]$id_materia,[string]$descripcion,[int]$id, [int]$final, [int]$recursan, [int]$abandonaron, [int]$promocionan){
        
        $n = [PruebaNota]::new($id_materia,$descripcion, $final, $recursan, $abandonaron, $promocionan)
        $this.notas.Add($n) > $null
    }
}

class Salida{
    [System.Collections.ArrayList]$departamentos
    Salida(){
        $this.departamentos = [System.Collections.ArrayList]::new()
    }
}

## FIN CLASES NECESARIAS

function procesamiento {
    param (
        $notas,
        $materias
    )

    ## Inicio de llenado de array con notas

    $arrayNotas = New-Object System.Collections.Arraylist
    $file_data = Get-Content $notas
    $cant = $file_data.length

    for ($i = 1; $i -lt $cant; $i++) {
        $aux = [DataAlumno]::new($file_data[$i])
        $arrayNotas.Add(($aux)) > $null
    }

    # Write-Host "Inicio de llenado de datos"

    foreach($item in $arrayNotas)
    {
        # Write-Host $item.dni
        # Write-Host $item.materia
        # Write-Host $item.pp
        # Write-Host $item.sp
        # Write-Host $item.recu
        # Write-Host $item.final
        # Write-Host "-------------"
        
    }

    ## Fin llenado de array con notas

    ## Inicio de llenado de array con materias

    $arrayMaterias = New-Object System.Collections.Arraylist
    $file_data = Get-Content $materias
    $cant2 = $file_data.length 

    for ($i = 1; $i -lt $cant2; $i++) {
        $aux = [DataMateria]::new($file_data[$i])
        $arrayMaterias.Add(($aux)) > $null
    }

    $arrayMaterias = $arrayMaterias | Sort-Object -Property departamento

    foreach($item in $arrayMaterias)
    {
    #     Write-Host $item.id
    #     Write-Host $item.descripcion
    #     Write-Host $item.departamento
    #     Write-Host "-------------"
        
    }

    ## Fin llenado de array con materias

    $arrayInformes = New-Object System.Collections.Arraylist
    $arrayDepto = New-Object System.Collections.Arraylist
    $salidaJSON2 = [Salida]::new() 

    $dejaron = 0;
    $recursan = 0;
    $promocionan = 0;
    $final = 0;

    foreach($materia in $arrayMaterias)
    {
        foreach($nota in $arrayNotas)
        {
            if($materia.id_materia -eq $nota.materia)
            {
                if($nota.final -ne 0)
                {

                }
                elseif( $nota.pp -eq 0 -AND $nota.sp -eq 0 -OR $nota.pp -eq 0 -AND $nota.recu -eq 0 -OR $nota.sp -eq 0 -AND $nota.recu -eq 0 )
                {
                    $dejaron = $dejaron + 1;
                }
                elseif( $nota.pp -lt 4 -AND $nota.sp -lt 4 -OR $nota.recu -lt 4 -AND $nota.sp -lt 4 -OR $nota.recu -lt 4 -AND $nota.pp -lt 4 )
                {
                    $recursan++

                }
                elseif( ($nota.pp -in (4,5,6) -and $nota.sp -in (4,5,6)) -or ($nota.pp -in (4,5,6) -and $nota.recu -in (4,5,6) -or ($nota.sp -in (4,5,6) -and $nota.recu -in (4,5,6)) ) )
                {
                    $final++
                }
                else
                {
                    $promocionan++
                }
            }

        }
            $aux = [InformeMateria]::new($materia.departamento, $materia.id_materia, $materia.descripcion, $final, $recursan, $dejaron, $promocionan)
            $arrayInformes.Add($aux) > $null

            $dejaron = 0;
            $recursan = 0;
            $promocionan = 0;
            $final = 0;
    }

    $arrayDeptos = New-Object System.Collections.Arraylist
    $anterior = -1
    $cantidad = $arrayDeptos.length

    foreach ($items in $arrayInformes)
    {
        if($anterior -eq -1)
        {
            $auxiliar = [Departamento]::new($items.id_materia, $items.descripcion, $items.departamento, $items.final, $items.recursan, $items.abandonaron, $items.promocionan)
            $arrayDeptos.Add($auxiliar) > $null
            $anterior = $items.departamento
        }
        else
        {
            if($anterior -eq $items.departamento)
            {
                $arrayDeptos.agregarNota($items.id_materia, $items.descripcion, $items.departamento, $items.final, $items.recursan, $items.abandonaron, $items.promocionan)
                $anterior = $items.departamento
            }
            else
            {
                $auxiliar = [Departamento]::new($items.id_materia, $items.descripcion, $items.departamento, $items.final, $items.recursan, $items.abandonaron, $items.promocionan)
                $arrayDeptos.Add($auxiliar) > $null
                $anterior = $items.departamento
            }
        }
    }

    $salidaJSON2.departamentos.Add($arrayDeptos) > $null

   $salida = $salidaJSON2 | ConvertTo-Json -Depth 5
   Set-Content -Value $salida -Path "./salida.json"

}

procesamiento -notas $notas -materias $materias
