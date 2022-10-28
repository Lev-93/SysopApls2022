BEGIN {
    getline
    i=0
    x=0
    cantPrimerArchivo=0
    cantSegundoArchivo=0
    primera=0
    lengthMaterias=variable2
    lengthNotas=variable1
}

{   
    split($1,array,"|")

    if($1 != "")
    {
    cant = 0

    for (items in array)
    {
        cant++
    }

    j = 0
    z = 0

    if(FILENAME == ARGV[1])
    {
        cantPrimerArchivo=cant
        while(j < lengthNotas)
        {
            matDNINotas[i,j] = array[j];
            j++
        }
        
        i++
    }
    else
    {
        cantSegundoArchivo=cant
        if(primera==0)
        {
            primera=1
        }
        else
        {
           while(z < lengthMaterias)
           {
                matDepto[x,z] = array[z]
                z++
           }

           x++
        }
    }
    }  
}

END {
    final=0
    recursan=0
    promocionan=0
    dejaron=0    
    otros=0

    print "{"
    print "    \"departamentos\": ["
    print "        ["
    deptoAnterior = 0
    flag = 0
    primera = 0
   for(j=0;j<lengthMaterias; j++)
    {
        if(deptoAnterior != matDepto[j,3])
        {
            deptoAnterior = matDepto[j,3]
            print "        {"
            print "            \"id\": " matDepto[j,3]","
            print "            \"notas\": ["
        }
        print "                {"
        print "                         \"id_materia\": "  matDepto[j,1]","
        print "                         \"descripcion\": " "\"" matDepto[j,2] "\","

        for(i=0;i<lengthNotas;i++)
        {
            if(matDepto[j,1] == matDNINotas[i,2])
            {
                if(matDNINotas[i,6] != "")
                {
                }
                else if(matDNINotas[i,3] == "" && matDNINotas[i,4] == "" || matDNINotas[i,3] == "" && matDNINotas[i,5] == "" || matDNINotas[i,4] == "" && matDNINotas[i,5] == "")
                {
                    dejaron++
                }
                else if (matDNINotas[i,3] < 4 && matDNINotas[i,4] < 4 || matDNINotas[i,5] < 4 && matDNINotas[i,4] < 4 || matDNINotas[i,5] < 4 && matDNINotas[i,3] < 4)
                {
                    recursan++
                }
                else if(matDNINotas[i,3] > 6 && matDNINotas[i,4] > 6 || matDNINotas[i,3] > 6 && matDNINotas[i,5] > 6 || matDNINotas[i,5] > 6 && matDNINotas[i,4] > 6 )
                {
                    promocionan++
                }
                else
                {
                    final++
                }
            }
        }
        print "                         \"final\": "   final ","
        print "                         \"recursan\": " recursan ","
        print "                         \"abandonaron\": " dejaron ","
        print "                         \"promocionan\": " promocionan
        if(deptoAnterior != matDepto[j+1,3])
        {
           print "                }"

        }
        else
        {
           print "                },"

        }
        if(deptoAnterior != matDepto[j+1,3])
        {
            if(matDepto[j+1,3] != "")
            {
                print "           ]},"
            }
            else
            {
               print "            ]}"
            }
        }
        final=0
        recursan=0
        dejaron=0
        promocionan=0
    }
    print "        ]"
    print "    ]"
    printf "}"

}
