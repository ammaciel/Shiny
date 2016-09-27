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


in_data <- reactive({ 
  
  file <- input$file1
  if (is.null(file)) return(NULL)
  else time <<- read.csv(file$datapath, header = input$header, sep = input$sep, quote = input$quote)  
  return(NULL)
})


# WTSS 
library(wtss.R)
wtss.ts <- reactive({ 
  obj <<- wtss("http://www.dpi.inpe.br/mds/mds")

#   ts1 <- getTimeSeries(obj, coverages=input$coverages, datasets=input$dataset, latitude=input$lat, longitude=input$long, from=input$dateStart, to=input$dateEnd)
#   temp <- ts1[[input$coverages]]
#   temp1 <<- temp$datasets
#   
})
