library(shiny)
library(dqshiny)
library(reactable)
library(dplyr)
library(tidyr)
library(stringr)
library(shinycssloaders)

# read data ----
data <- readRDS('data/data.rds')
opts <- readRDS('data/dropdown_options.rds')

# load functions ----
source('utils.R')

shinyApp(
    ui = fluidPage(
        fluidRow(
            column(12,
                      autocomplete_input("inputVal", "Select gene:", opts, max_options = 1000),
                      reactableOutput("table") %>% shinycssloaders::withSpinner(type = 4, color = '#ffc233')
            )
        )
    ),
    server = function(session, input, output) {
        
        inputed_value <- reactive({
            req(input$inputVal)
            
            as.character(detect_input_type(input$inputVal))
        })
    
        output$table <- renderReactable({
            req(input$inputVal)

            if(inputed_value() == 'gene_symbol') {
                reactable(
                    data %>%
                        filter(gene_symbol == input$inputVal) %>%
                        separate_rows(ensembl_transcript_id, sep = ',') %>%
                        separate_rows(ensembl_protein_id,    sep = ',') %>%
                        separate_rows(go_term_label,         sep = ',') %>%
                        separate_rows(go_term_id,            sep = ',') %>%
                        separate_rows(gene_synonyms,         sep = ',') %>%
                        distinct() %>%
                        select(-label),
                    groupBy = c("gene_symbol", "ensembl_transcript_id", "ensembl_protein_id", "go_term_label", "go_term_id")
                )
            } else {
                if(inputed_value() == 'go_id') {
                    reactable(
                        data %>%
                            filter(str_detect(string = go_term_id, pattern = input$inputVal)) %>% 
                            separate_rows(go_term_id, sep = ',') %>% 
                            distinct() %>% 
                            select(-label),
                        groupBy = c("gene_symbol")
                    )
                } else {
                    if(inputed_value() == 'go_label') {
                        reactable(
                            data %>%
                                filter(str_detect(string = go_term_label, pattern = input$inputVal)) %>% 
                                separate_rows(go_term_label, sep = ',') %>% 
                                distinct() %>% 
                                select(-label),
                            groupBy = c("gene_symbol")
                        )
                    } else { NULL }
                }
            }

        })
        
    }
)
