library(tidyverse)
library(tidyr)

homo_sapiens_tbl <- read_csv('data/Homo+sapiens.csv')
homo_sapiens_tbl


# EDA ----
homo_sapiens_tbl %>% glimpse()
homo_sapiens_tbl %>% View()

# Check NAs ----
colSums(is.na(homo_sapiens_tbl))
map_df(homo_sapiens_tbl, ~sum(is.na(.)))

# Total records
nrow(homo_sapiens_tbl) # 64561


homo_sapiens_tbl$gene_symbol %>% unique()
homo_sapiens_tbl$go_term_id %>% unique()
homo_sapiens_tbl$go_term_label %>% unique()

# Dataset for the further analysis | `homo_sapiens_def_columns_tbl` ----
homo_sapiens_def_columns_tbl <- homo_sapiens_tbl %>% 
    select(label, gene_symbol, ensembl_transcript_id, ensembl_protein_id, go_term_label, go_term_id, gene_synonyms)

saveRDS(homo_sapiens_def_columns_tbl, file = 'data/data.rds')


# Gene symbols list with unique values | `gene_symbols_vector` ----
gene_symbols_vector <- homo_sapiens_def_columns_tbl$gene_symbol %>% unique()
# GO term labels list with unique values | `go_term_labels_vector` ----
go_term_labels_vector <- homo_sapiens_def_columns_tbl %>%
    select(go_term_label) %>%
    drop_na() %>%
    distinct() %>%
    separate_rows(go_term_label, sep = ',') %>%
    distinct() %>%
    pull()
# GO term IDs list with unique values | `go_term_ids_vector` ----
go_term_ids_vector <- homo_sapiens_def_columns_tbl %>%
    select(go_term_id) %>%
    drop_na() %>%
    distinct() %>%
    separate_rows(go_term_id, sep = ',') %>%
    distinct() %>%
    pull()

saveRDS(gene_symbols_vector,   file = 'data/gene_symbols_vector.rds')
saveRDS(go_term_ids_vector,    file = 'data/go_term_ids_vector.rds')
saveRDS(go_term_labels_vector, file = 'data/go_term_labels_vector.rds')

dropdown_options <- c(gene_symbols_vector,go_term_ids_vector,go_term_labels_vector)
saveRDS(dropdown_options, file = 'data/dropdown_options.rds')

# Check number of gene symbols per group
homo_sapiens_def_columns_tbl %>%
    group_by(gene_symbol) %>%
    summarise(n_gene_symbols = n()) %>%
    ungroup() %>%
    arrange(desc(n_gene_symbols)) %>%
    filter(n_gene_symbols > 1)

# Check number of records per GO
homo_sapiens_def_columns_tbl %>%
    select(go_term_id) %>%
    drop_na() %>%
    # distinct() %>%
    separate_rows(go_term_id, sep = ',') %>%
    # distinct() %>%
    group_by(go_term_id) %>%
    summarise(n_go = n()) %>%
    ungroup() %>%
    arrange(desc(n_go)) %>%
    filter(n_go > 1)

# Return tibble by `gene_symbol` selected
# KIR3DL2 - test arg example
homo_sapiens_def_columns_tbl %>% 
    filter(gene_symbol == 'KIR3DL2') %>% 
    separate_rows(ensembl_transcript_id, sep = ',') %>%
    separate_rows(ensembl_protein_id,    sep = ',') %>%
    separate_rows(go_term_label,         sep = ',') %>%
    separate_rows(go_term_id,            sep = ',') %>%
    separate_rows(gene_synonyms,         sep = ',') %>% 
    distinct()

# Return tibble by `GO id` selected
# GO:0070062 - test arg example
homo_sapiens_def_columns_tbl %>%
    filter(str_detect(string = go_term_id, pattern = 'GO:0070062')) %>% 
    separate_rows(go_term_id, sep = ',') %>% 
    distinct()


## Spark installation
# Available for installation
spark_available_versions()

# Install spark version 3.3
spark_install(version = '3.3')

# Installed version
spark_installed_versions()

# Uninstall spark
# spark_uninstall(version = '3.3')

# * Connection to Spark 
# Configuration Setup (Optional)

conf <- list()
conf$`sparklyr.cores.local`         <- 6
conf$`sparklyr.shell.driver-memory` <- "16G"
conf$spark.memory.fraction          <- 0.8


sc <- spark_connect(
    master = 'local',
    version = '3.3',
    config = conf
)

# Spark UI ----
spark_web(sc)
# spark_disconnect_all()

# Adding data to Spark ----
homo_sapiens_def_columns_tbl <- readRDS('data/data.rds')

homo_sapiens_def_columns_tbl_spark_object <- copy_to(sc, homo_sapiens_def_columns_tbl, 'homo_sapiens_def_columns_tbl')

# available tables
src_tbls(sc) 
# view spark table object
tbl(sc, 'homo_sapiens_def_columns_tbl')


homo_sapiens_def_columns_tbl_spark_object %>%
    separate_rows(ensembl_transcript_id, sep = ',') %>%
    separate_rows(ensembl_protein_id,    sep = ',') %>%
    separate_rows(go_term_label,         sep = ',') %>%
    separate_rows(go_term_id,            sep = ',') %>%
    separate_rows(gene_synonyms,         sep = ',') %>% 
    distinct()


write_csv(data, 'data/data.csv')