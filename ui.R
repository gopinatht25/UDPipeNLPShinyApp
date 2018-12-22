# Name : Gopinath Thulasidoss   PG ID : 11810136 #
# Name : Sundar Balasubramanian PG ID: 11810130  #
# Name : Karthikeyan Thirumal   PG ID: 11810131  #

#---------------------------------------------------------------------#
#               ui.R UDPIPE with Shiny App                                 #
#---------------------------------------------------------------------#

library("shiny")
library(wordcloud)
library(udpipe)
# Define ui function
ui <- shinyUI(
  fluidPage(
    
    titlePanel("Shiny App around the UDPipe NLP workflow"),
    
    sidebarLayout( 
      
      sidebarPanel(  
        
        fileInput("file1", "Upload data (text file)"),
        
        fileInput("model1", "upload trained udpipe model for different languages"),
        
        checkboxGroupInput(inputId = 'upos1',
                           label = paste("Part-of-speech tags(XPOS)"),
                      choices =list("adjective"= "JJ",
                                    "Noun" = "NN",
                                    "proper noun" = "NNP",
                                    "adverb"="RB",
                                    "verb"= "VB"),
                      selected = c("JJ","NN","NNP"))
        

        
      ),
      
      mainPanel(
        
        tabsetPanel(type = "tabs",
                    
                    tabPanel("Overview",
                             h4("Data input"),
                             p("This app supports only text documents (.txt) data file of different languages. ",align="justify"),
                             br(),
                             p("Sample Files for English, Hindi and Spanish available in the GIT location "),
                             a(href="https://github.com/gopinatht25/UDPipeNLPShinyApp/tree/master/Data"
                               ,"Sample data input files"),
                             h4('How to use this App'),
                             p('Steps as below to use this app, ',
                               br(), '1) Click and upload text file using', 
                               span(strong("Upload data (text file)")),
                               br(), '2) Click and upload the udpipe model using', 
                               span(strong("upload trained udpipe model for different languages")),
                               br(), '3) Select from the list of part-of-speech tags for plotting co-occurances, XPOS for English and UPOS for other languages using ',
                               span(strong("Part-of-speech tags (XPOS/UPOS)"))),
                             br(),
                             h4('Output listed in each tab'),
                             p(span(strong("Coccurrences")), 'tab provides a cooccurence within 3 words distance',
                               br(),
                               span(strong("Word Cloud")), 'tab provides a Cloud of Nouns and Verbs',
                               br(),
                               span(strong("Table of annotated documents")), ' provides the annotated data in table format.')),
                               

                    tabPanel("Co-Occurrences",
                             h3("Co-occurrences (UPOS)"),
                             plotOutput('cooccurance1')),
                    
                    tabPanel("Word Cloud",
                             h3("Nouns"),
                             plotOutput('wcplot1'),
                             h3("Verbs"),
                             plotOutput('wcplot2')),
                    
                    tabPanel("Table of annotated documents", 
                             dataTableOutput('annotatedtableOutput'),
                             downloadButton("annotatedData", "Download Annotated Data"))

        ) # end of tabsetPanel
      )# end of main panel
    ) # end of sidebarLayout
  )  # end if fluidPage
) # end of UI
