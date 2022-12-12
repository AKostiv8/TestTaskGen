gene_symbols_vector   <- readRDS('data/gene_symbols_vector.rds')
go_term_ids_vector    <- readRDS('data/go_term_ids_vector.rds')
go_term_labels_vector <- readRDS('data/go_term_labels_vector.rds')

# Return tbl by gene_symbol ----
return_tbl_by_gene_symbol <- function(tbl, gene_symbol) {
    
    tbl_ <- tbl %>% 
        filter(gene_symbol == gene_symbol) %>% 
        separate_rows(ensembl_transcript_id, sep = ',') %>%
        separate_rows(ensembl_protein_id,    sep = ',') %>%
        separate_rows(go_term_label,         sep = ',') %>%
        separate_rows(go_term_id,            sep = ',') %>%
        separate_rows(gene_synonyms,         sep = ',') %>% 
        distinct()
    
    return(tbl_)
}

# Return tbl by go_id ----
return_tbl_by_go_id <- function(tbl, go_id) {
    
    tbl_ <- tbl %>%
        filter(str_detect(string = go_term_id, pattern = go_id)) %>% 
        separate_rows(go_term_id, sep = ',') %>% 
        distinct()
    
    return(tbl_)
}

# Return tbl by go_id ----
return_tbl_by_go_label <- function(tbl, go_label) {
    
    tbl_ <- tbl %>%
        filter(str_detect(string = go_term_label, pattern = go_label)) %>% 
        separate_rows(go_label, sep = ',') %>% 
        distinct()
    
    return(tbl_)
}

# Detect input type function
detect_input_type <- function(x) {
    
    res_ <- case_when(
        x %in% gene_symbols_vector   ~ "gene_symbol",
        x %in% go_term_ids_vector    ~ "go_id",
        x %in% go_term_labels_vector ~ "go_label",
        TRUE ~ NA_character_
    )
    
    return(res_)
    
}