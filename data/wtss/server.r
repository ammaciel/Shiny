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


# install packages
packages <- c("devtools","shiny","DT","fields","miscTools","sp","rgdal","raster","dplyr","rjson", "testthat")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())), dependencies = TRUE)
}

# install wtss
packagesWTSS <- c("wtss.R")
if (length(setdiff(packagesWTSS, rownames(installed.packages()))) > 0) {
  devtools::install_github("e-sensing/wtss.R")
}


library(shiny)
library(DT)
library(fields)
library(miscTools) # inserir linha no final do arquivo
library(sp)
library(rgdal)
library(raster)
library(dplyr)
library(devtools)
library(wtss.R)


#-------------------------
# plot raster from file togheter with time series
#-------------------------

options(shiny.maxRequestSize=1000*1024^2)#,shiny.error = browser)#,shiny.error=recover)

shinyServer(function(input, output, session) {
  
  # This code will be run once per user
  users_data <- data.frame(START = Sys.time())
  
  time <- NULL
  
  # global variable 
  source("global.r", local = TRUE) 
  
  output$table0 <- renderDataTable({ 
    call.me = in_data()
    time 
  })
    
  proxy = dataTableProxy('table0')
  
  observeEvent(input$clearSelection, {
    selectRows(proxy, NULL)
  })
    
  observeEvent(input$resetData,{
    output$table0 <- renderDataTable({ 
      call.me = in_data()
      time 
    })
  })
  
 selection <<- reactive ({
    input$table0_rows_selected
  })

 # time series plot  
 EVI1<- reactive({
   call.me = in_data()
   time
   which(colnames(time)=="EVI.1")
 })
 
 EVI23 <- reactive({
   call.me = in_data()
   time
   which(colnames(time)=="EVI.23")
 })

  # plot time series for each row selected in table. Limit is 10 time series 
  output$plot1 <- renderPlot({
    #s = t(time[input$table1_rows_selected,c(1:23)])
    s <- t(time[selection(),c(EVI1():EVI23())])
    new1 <- insertRow( s, 1, 0.0000 )
    new2 <- insertRow( new1, 25, 0.0000 )
    
    plot.ts(new2, main = "Time Series")
  }) 
  
  output$text1 <- renderPrint({
    s = selection()
    if (length(s)) {
      cat('These rows were selected:\n\n')
      cat(s, sep = ', ')
    }
  })
  
 observe({ 
    call.me = in_data()
    time
    updateRadioButtons(session, "vars2", choices = names(time), inline=TRUE)
  })

  a <- reactive({
    call.me = in_data()
    time
    which(colnames(time)==input$vars2)
  })
  
  # table contains columns longitude and latitude
  long<- reactive({
    call.me = in_data()
    time
    which(colnames(time)=="longitude")
  })
  
  lat <- reactive({
    call.me = in_data()
    time
    which(colnames(time)=="latitude")
  })
  
  
  #-------------------------
  #plot point show raster pixel     
  output$plot1.2 = renderPlot({ # era 1.2
    ss = time[selection(), c(long():lat(),a())] # long:lat e mean
    
    s = time[c(long():lat(),a())] # long:lat e mean
    colnames(s) <- c('x', 'y', 'z')
    
    #Convert the data frame to a SpatialPointsDataFrame
    library(sp)
    library(rgdal)
    library(raster)
    
    pixels = SpatialPixelsDataFrame(points = s[c("x", "y")], tolerance = 0.000891266, data = s)
    r = raster(pixels[,'z'])
  
    plot(r)
    
    # plot points selected for each row from table
    if (length(ss)) 
      points(ss, col="red", lwd=4, pch = 3, cex = 2)
    
  })
  

  
#------------------------- 
# WTSS
#-------------------------

 observe({ 
   call = wtss.ts()
   obj
   objlist <<- listCoverages(obj)
   updateRadioButtons(session, "coverages", choices = objlist, inline=TRUE)
 })
 
  observe({
    call = wtss.ts()
    obj
    s <<- which(objlist == input$coverages)
    objdesc <<- describeCoverage(obj,objlist[s])[[input$coverages]]
    valuesSet <<- objdesc
    updateRadioButtons(session, "dataset", choices = valuesSet, inline=TRUE)
  })

  output$text2 <- renderPrint({
    #s = input$table1_rows_selected
    s1 = input$coverages
    s2 = input$dataset
    s3 = input$lat
    s4 = input$long
    # if (length(s)) {
    cat('Data and dataset selected:\n')
    cat(s1, sep = '\n')
    cat(s2, sep = '\n')
    cat(s3, sep = '\n')
    cat(s4, sep = '\n')
    # }
  }) 

  observeEvent(input$ok,{
    output$table1 <- renderDataTable({ 
      ts1 <- timeSeries(obj, input$coverages, attributes=input$dataset, latitude=input$lat, longitude=input$long, start=input$dateRange[1], end=input$dateRange[2]) #dateStart; dateEnd
     
      temp1 <<- data.frame(Date=time(ts1[[input$coverages]]$attributes), ts1[[input$coverages]]$attributes, check.names=FALSE, row.names=NULL)
  
    })#, rownames = TRUE, server = TRUE)
  })
  
  proxy1 = dataTableProxy('table1')
  
  observeEvent(input$clearSelection1, {
    selectRows(proxy1, NULL)
  })
  
  # rows seleted 
  selection2 <<- reactive ({
    input$table1_rows_selected
  })
  
  output$text3 <- renderPrint({
    s = selection2()
    if (length(s)) {
      cat('These rows were selected:\n\n')
      cat(s, sep = ', ')
    }
  })
  
  # lines selected in table
  x <- reactive({
    s = selection2()
    length(s)
  })
  
  # adding vertical line over time series plot
  output$plot2 <- renderPlot({
    ss = selection2()
    
    ts1 <- timeSeries(obj, input$coverages, attributes=input$dataset, latitude=input$lat, longitude=input$long, start= input$dateRange[1], end=input$dateRange[2]) #dateStart; dateEnd
    
    temp1 <<- data.frame(Date=time(ts1[[input$coverages]]$attributes), ts1[[input$coverages]]$attributes, check.names=FALSE, row.names=NULL)
    
    s = temp1[,2]
    
    plot.ts(s, main = "Time Series plot", ylab=input$dataset, xaxt="n")
    axis(1, at = 1:length(s), labels=temp1[,1])
    
    if (length(ss)) 
      abline(v=ss, lty=2,lwd= 2,col="red") # 920,
  }) 
  
  # This code will be run after the client has disconnected
  session$onSessionEnded(function() {
    users_data$END <- Sys.time()
    # Write a file in your working directory
    #write.table(x = users_data, file = file.path(getwd(), "users_data.txt"),append = TRUE, row.names = FALSE, col.names = FALSE, sep = "\t")
  })    

})



