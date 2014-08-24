#ui###############
library(shiny)
library(ggplot2)
library(data.table)
library(reshape2)
library(markdown)

shinyUI(
        navbarPage("FATCA Foreign Financial Institution (FFI) List",
                   tabPanel("Dashboard",
                            sidebarPanel(
                                    sliderInput("range", 
                                                "Range:", 
                                                min = 1, 
                                                max = 5000, 
                                                value = c(1, 100),
                                                format="####"),
                                    uiOutput("evtypeControls")
                            ),
                            
                            mainPanel(
                                    tabsetPanel(
                                            # Data 
                                            tabPanel('Data',
                                                     dataTableOutput(outputId="table"),
                                                     downloadButton('downloadData', 'Download'),
                                                     includeMarkdown("www/Description.html")),
                                            #Graph#
                                            tabPanel("Stats", 
                                                     plotOutput('chart1')),
                                            
                                            #Credits#
                                            tabPanel("About",
                                                     mainPanel(
                                                             includeMarkdown("www/About.html")
                                            
                            )
                   )
        )
       
)),
#Credits#
tabPanel("Credits",
         mainPanel(
                 includeMarkdown("www/About.html")
))
))