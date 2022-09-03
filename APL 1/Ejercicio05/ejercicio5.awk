
BEGIN {
    getline
    i=0
    x=0
    cantPrimerArchivo=0
    cantSegundoArchivo=0
    primera=0
}

{
    split($1,array,"|")

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
        while(j <= 7)
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
           while(z < 5)
           {
                matDepto[x,z] = array[z]
                z++
           }

           x++
        }
    }  

}

END {
    
    # for(i=0;i<=7;i++)
    # {
    #     for(j=0;j<=6;j++)
    #     {
    #         print matDNINotas[i,j]

    #     }
    # }

    # print "fin matriz notas"
    # print "-----------------------"
    # printf ""

    # for(i=0;i<=4;i++)
    # {
    #     for(j=0;j<=cantSegundoArchivo;j++)
    #     {
    #         print matDepto[i,j]

    #     }
    # }

    final=0
    recursan=0
    promocionan=0
    dejaron=0    
    otros=0

    print "{"
    print "    “departamentos“: ["

   for(j=0;j<=4; j++)
    {
        print "        {"
        print "            “id“: " matDepto[j,3]","
        print "            “notas“: ["
        print "                 {"
        print "                         “id_materia“: "  matDepto[j,1]","
        print "                         “descripcion“: " "“" matDepto[j,2] "“,"

        for(i=0;i<=7;i++)
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
        print "                         “final“: "   final ","
        print "                         “recursan“: " recursan ","
        print "                         “abandonaron“: " dejaron ","
        print "                         “promocionan“: " promocionan

        final=0
        recursan=0
        dejaron=0
        promocionan=0
    }
    # print "        {"
    # print "            “id“: " matDepto[0,3]","
    # print "            “notas“: ["
    # print "                 {"
    # print "                         “id_materia“: "  matDNINotas[0,2]","
    # print "                         “descripcion“: " "“" matDepto[0,2] "“,"
    # print "                         “recursan“: " recursan ","
    # print "                         “abandonaron“: " dejaron ","
    # print "                         “promocionan“: " promocionan
    # print "                 },"
    # print "             ]"
    # print "         }"
    print "     ]"
    print "}"

}
