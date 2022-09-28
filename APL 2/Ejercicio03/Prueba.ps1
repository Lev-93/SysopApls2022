Param(
    [Parameter(Mandatory=$false)] [ValidateNotNullOrEmpty()]
    [string[]]$acciones
)

$Global:Vacciones = @{listar= "False"; peso= "False"; compilar= "False";publicar="False" }

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

foreach ($cadena in $Vacciones){
    Write-Output $cadena
}