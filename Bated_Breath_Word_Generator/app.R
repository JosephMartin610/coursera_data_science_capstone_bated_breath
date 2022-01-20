# This is the user-interface definition of a Shiny web application.
# You can run the application by clicking "Run App" to the above right.
# Find out more about building applications with Shiny here:
# http://shiny.rstudio.com/

library(shiny)

library(tibble)
library(dplyr)
library(ggplot2)

source("pred_text_ngrams_kbo_gtd.R")

ui <- fluidPage(

  # application title
  titlePanel("Bated Breath Next Word Generator"),
            
  sidebarLayout(
    sidebarPanel(
      p("This app takes a sequence of words (a sentence fragment) and predicts the most probable possibilities for the next word."),
      p("Please enter a sequence of words all in lowercase without punctuation (apostrophes for contractions and possessives are acceptable), numbers, or spaces leading or trailing the sequence."),
      textInput(inputId = "text_input", label = "Enter the known sequence of words here and click on Submit and wait up to 10 to 15 seconds:", width = "150%"),
      actionButton(inputId = "click", label = "Submit"),
      sliderInput(inputId = "num_preds", label = "Adjust number of predicted words displayed:",
                   value = 10, min = 1, max = 30)
    ),
    mainPanel(
      plotOutput("hist_words_probs")
    )
  )

)

server <- function(input, output) {

  # load the corpora data just one time (not in reaction to an input change)
  # this loads in a single tibble: ns_ngrams_counts
  # this will load the data while the user is looking at the app for the first time,
  # and reading the instructions
  load("ns_ngrams_counts_for_model_gtd_merge_4.RData")
  
  # rewrite part of pred_text_ngrams_kbo_gtd to accept ngrams counts as argument
  pred_words_probs <- eventReactive(input$click,{pred_text_ngrams_kbo_gtd(input$text_input,4,ns_ngrams_counts,30)})
  
  # make histogram of the top word predictions and their probabilities
  output$hist_words_probs <- renderPlot({
    pred_words_probs()[1:input$num_preds,] %>%
    # need this trick to get ggplot to plot by probability order 
    # see https://www.r-graph-gallery.com/267-reorder-a-variable-in-ggplot2.html
    arrange(prob) %>% 
    mutate(word=factor(word,levels=word)) %>%
    ggplot(aes(x = word, y = 100*prob)) +
    geom_bar(stat = "identity", fill = "black", width = 0.85) +
    coord_flip() +
    theme_bw() +
    theme(text        = element_text(face="bold", size = 15), 
          axis.text.x = element_text(face="bold", size = 15, color="black"),
          axis.text.y = element_text(face="bold", size = 15, color="black")) +
    labs(x = "Predicted Next Word", face="bold") +
    labs(y = "Probability (%)", face="bold") +
    labs(title = paste0("Top ",  as.character(input$num_preds), " Most Probable Next Words")) +
    theme(plot.title = element_text(hjust = 0.5))  
  })

}

shinyApp(ui = ui, server = server)