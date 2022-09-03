
BEGIN {
    
    printf "{ "    
    for (items in ARGV)
        nombres[ARGV[items]]++
    
}

{
    n = substr(tolower($1),2)

    m = toupper(substr($1,1,1))

    $1 = m n


    if (nombres[FILENAME] == 2)  
        array[$1] = array[$1] - $2    
   
     array[$1] = array[$1] + $2
     


}
END {
    
    for (items in array)
    {
        if(tolower(items) == tolower("NombreProducto"))
            delete array[items]

        if(array[items] == 0)
            delete array[items]
    }


     i = 1
    
    for (items in array)
    {

        if(length(array) != i) 
            # if(items != "")
                printf "\""items"\""":"array[items]", "  | "sort"  
        else
            # if(items != "")
                printf "\""items"\""":"array[items]" }"  | "sort"
        i++
        
    }

}
