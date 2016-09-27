#################################################################
##                                                             ##
##   (c) Adeline Marinho <adelsud6@gmail.com>                  ##
##                                                             ##
##       Image Processing Division                             ##
##       National Institute for Space Research (INPE), Brazil  ##
##                                                             ##
##                                                             ##
##   R script to view time series using Shiny                  ##
##                                             2016-09-27      ##
##                                                             ##
#################################################################


# open global.r file with global variable
#time <- source("global.r", local = TRUE)


fluidPage(

title = 'Time Series',
  
h2('Time series'),

#-------------------------
tabsetPanel(type = "tabs",
   
    tabPanel("Open file",
      headerPanel(h4('Show Time Series')),
        sidebarLayout(
          sidebarPanel(
            fileInput('file1', 'Choose file to upload',
                        accept = c(
                          'text/csv',
                          'text/comma-separated-values',
                          'text/tab-separated-values',
                          'text/plain',
                          '.csv',
                          '.tsv'
                        )
              ),
              hr(),
              checkboxInput('header', 'Header', TRUE),
              radioButtons('sep', 'Separator',
                           c(Comma=',',
                             Semicolon=';',
                             Tab='\t'),
                           ','),
              radioButtons('quote', 'Quote',
                           c(None='',
                             'Double Quote'='"',
                             'Single Quote'="'"),
                           ''),
              actionButton("clearSelection", label = "Click to clear row selected"),
              actionButton("resetData", label = "Click to reset table")
                  
            ),
            mainPanel(
            #
              div(DT::dataTableOutput('table0'), 
                  style = "height:420px; width:900px; overflow-x: scroll; font-size:70%"),
              hr()
            )),

     
      sidebarPanel(
        radioButtons("vars2", label = "Columns names from dataset", choices="")
      ),
     
     mainPanel(
    
     fluidRow(
       column(2, h5("Rows selected"), verbatimTextOutput('text1')),
       column(4, plotOutput('plot1', height = 300, width = 300)),
       column(4, plotOutput('plot1.2', height = 400, width = 400))
     ),
     
     hr()
     )
),
   
  
    tabPanel("WTSS",
     headerPanel(h4('R client for WTSS service')),
     
     sidebarLayout(
     sidebarPanel(
       radioButtons("coverages", label = "List coverages from WTSS", choices=""),
       radioButtons("dataset", label = "List datasets - coverages", choices=""),
       textInput("lat", "Latitude", "-11.62399"),
       textInput("long", "Longitude", "-56.2397"),
       dateRangeInput("dateRange", label = "Time interval:", 
                      start = "2000-01-01", 
                      end = Sys.Date(),
                      min = "2000-01-01",
                      max = Sys.Date(),
                      format = "yyyy-mm-dd",
                      separator = "-"),
       #dateInput("dateStart", label = "Start Date:", value = "2000-01-01"),
       #dateInput("dateEnd", label = "End Date:", value = "2016-07-15"),
       actionButton("ok", label = "Show Table"),
       actionButton("clearSelection1", label = "Click to clear row selected")
    ),
     
     mainPanel(
       
       fluidRow(
         column(4, h5("Data selected"), verbatimTextOutput('text2')),
         column(4, h5("Rows of the table selected"), verbatimTextOutput('text3'))
      ),
      hr(),
      div(DT::dataTableOutput('table1'), 
          style = "height:420px; width:600px; overflow-x: scroll; font-size:70%"),
      hr(),
      plotOutput('plot2', height = 300, width = 800)
      )       
    )
  )
)

)

