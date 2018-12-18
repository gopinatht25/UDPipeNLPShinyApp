# PGID: 11810136; Name: Gopinath Thulasidoss                          #

#---------------------------------------------------------------------#
#               Server.R UDPIPE with Shiny App                        #
#---------------------------------------------------------------------#

# get data first
require(stringr)
getwd()
#setwd('F:\\ISB\\Residency\\Residency2\\TA\\Session 5 Files-20180418\\TA_Assignment2')

options(shiny.maxRequestSize = 50*1024^2)
windowsFonts(devanew=windowsFont("Devanagari new normal"))

shinyServer(function(input, output, session) {
  
  observe({
    
    # Can use character(0) to remove all choices
    if(is.null(input$model1)){return(NULL)}
    else{
      
      #if (length(input$model1$file) > 0) {
      if (substr(input$model1$name, 1, 7) != 'english') {
        
        
        # Can also set the label and select items
        updateCheckboxGroupInput(session, "upos1",
                                 label = paste("Part-of-speech tags(UPOS)"),
                                 choices =list("adjective"= "ADJ",
                                               "Noun" = "NOUN",
                                               "proper noun" = "PROPN",
                                               "adverb"="ADV",
                                               "verb"= "VERB"),
                                 selected = c("ADJ","NOUN","PROPN"))
      }
      else{
        updateCheckboxGroupInput(session,"upos1",
                                 label = paste("Part-of-speech tags(XPOS)"),
                                 choices =list("adjective"= "JJ",
                                               "Noun" = "NN",
                                               "proper noun" = "NNP",
                                               "adverb"="RB",
                                               "verb"= "VB"),
                                 selected = c("JJ","NN","NNP"))
      }
    }
  })
  
  Dataset <- reactive({
    
    if (is.null(input$file1)) {# locate 'file1' from ui.R
      return(NULL) } 
    else{
      Data <- readLines(input$file1$datapath, encoding = "UTF-8")
      Data = Data[Data!= ""]
      Data  =  str_replace_all(Data, "<.*?>", "") # get rid of html junk
      str(Data)
      return(Data)
    }
  })
  
  udpipe_model <- reactive({
    if (is.null(input$model1)) {  # locate 'model1' from ui.R
      return(NULL) } else{
        #udpipe_model <- udpipe_load_model("english-ud-2.0-170801.udpipe")  # file_model only needed
        udpipe_model <- udpipe_load_model(input$model1$datapath)
        return(udpipe_model)
      }
  })    
  
  annotated_data <- reactive({
    x <- udpipe_annotate(udpipe_model(),x = Dataset())
    x <- as.data.frame(x)
    return(x)
  })
  
  output$cooccurance1 = renderPlot({
    #windowsFonts(devanew=windowsFont("Devanagari new normal"))
    #windowsFonts(Arialnew=windowsFont("Arial Narrow"))
    
    if(is.null(input$file1)){return(NULL)}
    else{
      if (substr(input$model1$name, 1, 7) == 'english') {
        cooc_data <- cooccurrence(   	# try `?cooccurrence` for parm options
          x = subset(annotated_data(), xpos %in% input$upos1), 
          term = "lemma", 
          group = c("doc_id", "paragraph_id", "sentence_id"))}
      else{
        cooc_data <- cooccurrence(   	# try `?cooccurrence` for parm options
          x = subset(annotated_data(), upos %in% input$upos1), 
          term = "lemma", 
          group = c("doc_id", "paragraph_id", "sentence_id"))
      }
      cooc_word <- head(cooc_data, 50)
      cooc_word <- igraph::graph_from_data_frame(cooc_word) # needs edgelist in first 2 colms.
      
      ggraph(cooc_word, layout = "fr") +  
        
        geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
        geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
        
        #theme_graph(base_family = "Arial Narrow") +  
        #theme(legend.position = "none") +
        
        labs(title = "Cooccurrences within 3 words distance", subtitle = "Use Checkbox to view different cooccurance results")
      
    }
  })
  
  output$wcplot1 = renderPlot({
    if(is.null(input$file1)){return(NULL)}
    else{
      if (substr(input$model1$name, 1, 7) == 'english') {
        nouns1 = annotated_data() %>% subset(., xpos %in% "NN")
      }
      else
      {
        nouns1 = annotated_data() %>% subset(., upos %in% "NOUN")
      }
      
      max_nouns = txt_freq(nouns1$lemma)
      
      wordcloud(words = max_nouns$key, 
                freq = max_nouns$freq, 
                min.freq = 2, 
                max.words = 100,
                random.order = FALSE, 
                colors = brewer.pal(6, "Dark2"))
    }
  })  
  
  output$wcplot2 = renderPlot({
    if(is.null(input$file1)){return(NULL)}
    else{
      if (substr(input$model1$name, 1, 7) == 'english') {
        verbs1 = annotated_data() %>% subset(., xpos %in% "VB") 
      }
      else
      {
        verbs1 = annotated_data() %>% subset(., upos %in% "VERB") 
      }
      max_verbs = txt_freq(verbs1$lemma)
      wordcloud(words = max_verbs$key, 
                freq = max_verbs$freq, 
                min.freq = 2, 
                max.words = 100,
                random.order = FALSE, 
                colors = brewer.pal(6, "Dark2"))
    }
  })  
  
  output$annotatedData <- downloadHandler(
    filename = function(){
      "annotated_data.csv"
    },
    content = function(file){
      write.csv(annotated_data(),file,row.names = FALSE)
    }
  )
  
  output$annotatedtableOutput <- renderDataTable({
    if(is.null(input$file1)){return(NULL)}
    else{
      if(is.null(input$model1)){return(NULL)}
      else {
        if (is.null(annotated_data)) {return(NULL)}
        else {
          out = annotated_data()
          return(out)
        }
      }
    }
  })
  
})
