###Name:
#Vinod Joshi (11810037)
#Avinash Gatty (11810018)
#Yogesh Sharma (11810019)


#UI
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

ui <- shinyUI(
  fluidPage(
    
    titlePanel("co-occurrence"),
    
    sidebarLayout( 
      
      sidebarPanel(  
        
        
        #provision to upload the file
        fileInput("file", "Upload text file "),
        
        
        #Option to select if the language is known or unknown
        selectInput(
          "KnownLanguage", "Known language?",
          c(Yes = "Yes",
            No = "No")),
        
        #Conditional panel to select the language if user knows the language
        conditionalPanel(
          condition = "input.KnownLanguage == 'Yes'",
          selectInput(inputId = "Language", label = strong("Language"),
                      choices = c("afrikaans", "ancient_greek-proiel", "ancient_greek", "arabic", "basque", "belarusian", "bulgarian", "catalan", "chinese", "coptic", "croatian", "czech-cac", "czech-cltt", "czech", "danish", "dutch-lassysmall", "dutch", "english-lines", "english-partut", "english", "estonian", "finnish-ftb", "finnish", "french-partut", "french-sequoia", "french", "galician-treegal", "galician", "german", "gothic", "greek", "hebrew", "hindi", "hungarian", "indonesian", "irish", "italian", "japanese", "kazakh", "korean", "latin-ittb", "latin-proiel", "latin", "latvian", "lithuanian", "norwegian-bokmaal", "norwegian-nynorsk", "old_church_slavonic", "persian", "polish", "portuguese-br", "portuguese", "romanian", "russian-syntagrus", "russian", "sanskrit", "serbian", "slovak", "slovenian-sst", "slovenian", "spanish-ancora", "spanish", "swedish-lines", "swedish", "tamil", "turkish", "ukrainian", "urdu", "uyghur", "vietnamese"),
                      selected = "english")),
        conditionalPanel(
          condition = "input.KnownLanguage == 'No'",
          selectInput(inputId = "Language", label = strong("Language"),
                      choices = "Auto Detect",
                      selected = "Auto Detect")),
        
        
        
        
        
        
        #XPos selection
        checkboxGroupInput(inputId="xpos_selected", label="xpos selection:",
                           choices =c("adjective" = "JJ","noun" = "NNS", "proper noun" = "NNPS","VBN"="VERB","Adverb"="WRB")
                           ,selected =c("adjective"= "JJ","noun"= "NNS","proper noun"="NNPS")),
        
        
        
        #How many maximum concurrance you want to see in the UI..by default 30... you can choose select any
        textInput("StopWords","Stop words: Provide the list of stop words with comma seperator"),
        
        sliderInput("maxcooccurrence", "Maximum Number of  co-occurrence to be displayed",
                    min = 2, max = 100,
                    value = 30)
      ),   # end of sidebar panel
      
      #Main panel
      mainPanel(
        
        tabsetPanel(type = "tabs",
                    tabPanel("Features",
                             h2(p("FEATURES")),
                             h3('Text file upload for Co-occurence analysis'),
                             h3('Provision for the user to select the language'),
                             h3('Auto Detection of the language from the text if not known'),
                             h3('Automated language pack installation during runtime. no prerequisite required'),
                             h3('Provision for the user to select XPOS for analysis'),
                             h3('Provision for the user to maximum co-occurence pairs for analysis'),
                             h3('Customized Stopwords for more enhanced experience')
                             
                    ),
                    
                    tabPanel("Instructions",
                             h2(p("Data input")),
                             p("This app supports only txt file as  data file"),
                             p("Please refer to the link below for sample txt file."),
                             a(href="https://raw.githubusercontent.com/avinashgatty15/ShinyApp_cooccurrence_Dependencies/master/Nokia.txt"
                               ,"Sample data input file"),   
                             br(),
                             h2('How to use this App'),
                             h3('Upload text file'),
                             p('Upload the text file using ',span(strong("Upload data (txt file)")),' option'),
                             h3('Select Language'),
                             p('If you know the language of the text uploaded then select ',span(strong("Yes")),' in ',span(strong("Known Language? "),' selection list. If you are not sure then select ',span(strong("No")))),
                             p('If you know the language then select using  ',span(strong("Language")),' selection. Otherwise leave it to the app to infer the language'),
                             p('Note: Infering language might not be that effective always'),
                             br(),
                             h3('XPOS Selection'),
                             p('Select the XPOS that you want to include in the co-occurrence analysis'),
                             
                             h3('Max number of co-occurrence'),
                             p('Select the number of co-occurrence that you want to have it in the graph'),
                             
                             h3('Stop words'),
                             p('Provide list of stop words you want to avoid in the co-occurrence')
                    ),
                    tabPanel("co-occurrence Plot", 
                             plotOutput('plot1'))
                    
                    
                    
        ) # end of tabsetPanel
      )# end of main panel
    ) # end of sidebarLayout
  )  # end if fluidPage
) # end of UI