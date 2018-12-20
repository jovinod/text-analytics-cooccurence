###Name:
#Vinod Joshi (11810037)
#Avinash Gatty (11810018)
#Yogesh Sharma (11810019)


#Server
#ShinyApp Co-occurence
#This is R file  the shiny app. This app make use of udpipe to perform co-occurance graph of any given text

#The App is extended to support multiple language support

#************
#  Features supported:
#  Provision to Upload text file in any language 
#Provision for the user to select the language
#App Infer the language if user is not sure of the language ( Limitation of the udpipe where it fails to detect few                                                                languages automatically :-))
#Provision for the user to selct XPOS that he is intersted in
#Also it has provision for the user to limit the  co-occureance to be displayed in the graph
#***************
#  Output:
#  Detects and install the language pack in the system if not installed already
#Co-occurance graph in shiny app.
#
#***************
#  
#  Lets start....

# Define Server function
server <- shinyServer(function(input, output) {
  
  
  RawData <- reactive({
    if (is.null(input$file)) { return(NULL) }
    else{
      Data <- readLines(input$file$datapath)
      Data  <-  str_replace_all(Data, "<.*?>", "")
      return(Data)
    }
  })
  
  #Identify the language.
  Language<- reactive({
    
    if (input$KnownLanguage == 'Yes') 
    {  Language<-input$Language }
    else{
      Data <- RawData()
      AllPredictedLanguages <- data.frame(Languages = textcat(RawData()))
      
      AllPredictedLanguages<-AllPredictedLanguages%>% count(Languages) %>% arrange(Languages)
      FinalPredictedLanguage<-data.frame(AllPredictedLanguages)
      Language<-as.character(FinalPredictedLanguage$Languages)[1]
      
    }
    return(Language)
  })
  
  
  #This block will download the language package if it is not already downloaded. The language is decided based on the below logic
  #Language identification: If user has selected the language then it will download user selected language. If user has not 
  #provided the language, the tool will infer the language from the content and download the language pack
  #Here I am reusing the code from class4
  wordnetwork <- reactive({
    if(is.null(RawData()))
    {
      return (NULL)
    }
    else
    {
      if (input$KnownLanguage == 'Yes') 
      {  Language<-input$Language }
      else{
        Data <- RawData()
        AllPredictedLanguages <- data.frame(Languages = textcat(RawData()))
        
        AllPredictedLanguages<-AllPredictedLanguages%>% count(Languages) %>% arrange(Languages)
        FinalPredictedLanguage<-data.frame(AllPredictedLanguages)
        Language<-as.character(FinalPredictedLanguage$Languages)[1]
        
      }
      model<-udpipe_download_model(language = Language,overwrite=FALSE) 
      loadmodel<-udpipe_load_model(model$file_model)
      
      
      
      listlemas <- udpipe_annotate(loadmodel, x = RawData())
      dflemas <- as.data.frame(listlemas)
      
      
      listofstopwords<-as.list(strsplit(input$StopWords, ",")[[1]]) %>% sapply((tolower)) %>% trimws()
      
      dflemas<-dflemas %>% filter(!tolower(lemma) %in% listofstopwords) 
      
      #XPO annd UPO Mapping. this is used to get the UPOS for the respective XPOS selected. For Non English Language, XPOS are not available
      UPOXPOMap <- data.frame("XPOS" = c("JJ", "NNS","NNPS","VBN","WRB"),"UPOS" = c("ADJ","NOUN","PROPN","VERB","ADV") )
      upos<-filter(UPOXPOMap,XPOS ==input$xpos_selected)$UPOS
      
      data_cooc <- cooccurrence(     # try `?cooccurrence` for parm options
        #If Langauge is not English then use UPOS instead of XPOS. the XPOS is available only for English.
        if(Language()=='english')
        {
          dflemas = subset(dflemas, xpos %in% input$xpos_selected)
        }
        else
        {dflemas = subset(dflemas, upos %in% upos)},
        term = "lemma", 
        group = c("doc_id", "paragraph_id", "sentence_id"))  # 0.02 secs
      
      # Visualising  co-occurrences using a network plot. Total number of cooccurences are derived from user input
      wordnetworkdata <- head(data_cooc, input$maxcooccurrence)
      
      
      
      return(wordnetworkdata)
    }
    
    
  })
  
  
  
  maxcooccurrence<- reactive({
    if (is.null(input$maxcooccurrence)) { return(NULL) }
    else{
      return(input$maxcooccurrence)
    }
  })
  
  xpos_selected <- reactive({
    if (is.null(input$xpos_selected)) { return(NULL) }
    else{
      return(input$xpos_selected)
    }
  })
  
  
  
  
  output$plot1 = 
    
    renderPlot({ 
      wordnetwork <- igraph::graph_from_data_frame(wordnetwork()) # needs edgelist in first 2 colms.
      ggraph(wordnetwork, layout = "fr") +  
        
        geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
        geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
        
        theme_graph(base_family = "Arial Narrow") +  
        theme(legend.position = "none") +
        
        labs(title = "Language : ", subtitle = Language())    
    })
  
  
})
