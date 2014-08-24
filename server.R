#server###############
library(shiny)
library(ggplot2)
library(data.table)
library(reshape2)
library(markdown)


dt <- fread('cdata/cleandata.csv')
dt1 <<- sort(unique(dt$CategoryCode))

shinyServer(function(input, output) {
        
        dt.agg <- reactive({
                tmp <- merge(
                        data.table(Country=sort(unique(dt$Country))),
                        dt[
                                dt$Frequence >= input$range[1] & dt$Frequence <= input$range[2] & dt$CategoryCode %in% input$dt1,
                                list(
                                        COUNT=Frequence,
                                        CATEGORY=CategoryCode),
                                by=list(Country)],
                        by=c('Country'), all=TRUE,
                        allow.cartesian=TRUE
                )
                tmp[is.na(tmp)] <- 0
                tmp
        })
        
        output$evtypeControls <- renderUI({
                if(1) {
                        checkboxGroupInput('dt1', 'Event types', dt1, selected=dt1)
                }
        })
        
        dataTable <- reactive({
                dt.agg() 
        })
        
        output$table <- renderDataTable(
{dataTable()}, options = list(bFilter = FALSE,aLengthMenu = c(10, 30, 50), iDisplayLength = 10))



output$downloadData <- downloadHandler(
        filename = 'data.csv',
        content = function(file) {
                write.csv(dataTable(), file, row.names=FALSE)
        }
)
############################
output$chart1 <- renderPlot({
                
        dt3 <- subset(dt, Frequence>=1000)
        dt4 <- dt3[order(dt3$Frequence), ]#order
        
        p1<-ggplot(dt4, aes(x = Country, y = Frequence ,fill=CategoryCode, label = Frequence)) + 
                geom_bar(stat = "identity",position = "dodge") + 
                geom_text(hjust = 0, size = 3) + 
                coord_flip() + 
                theme_minimal()
p1
        })

############################

})