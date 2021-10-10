
manyColsToDummy<-function(search_terms, search_columns,
                          output_table){
    #initialize output table
    temp_table<-data.frame(matrix(ncol=length(search_terms),
                                  nrow= nrow(search_columns)))
    colnames(temp_table)<-search_terms
    
    #make table
    for (i in 1:length(search_terms)){
        vec<-rowSums(sapply(search_columns,
                            function(x) grepl(search_terms[i], x, ignore.case = TRUE)
        ))>0
        temp_table[,i]<-vec
    }
    temp_table<-sapply(temp_table, as.integer, as.logical)
    temp_table<-as.data.frame(temp_table)
    assign(x = output_table, value = temp_table, envir = globalenv())
}
