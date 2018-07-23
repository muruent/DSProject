library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
library(maps)
library(fiftystater)
library(testthat)
library(readr)
library(RColorBrewer)
library(dplyr)
library(plotly)
library(scales)
library(viridis)
library(assertive, warn.conflicts = FALSE)
library(shiny)
#library(shinydashboard)
library(leaflet)
library(magrittr)
library(htmltools)
library(dygraphs)
library(xts)

load("msdata.RData")

shinyServer(function(input, output) {
 
  output$plot = renderPlot({
    d1  () %>% group_by(Year = format(date, "%Y")) %>% 
      summarize(killed =sum(n_killed),injured = sum(n_injured)) %>% 
      melt(id.vars="Year")%>%
      ggplot(aes(x = Year, y = value, fill = variable )) + geom_bar(stat = 'identity', position = 'dodge')
    
    
  } )
  
  d1 = reactive({ d %>% filter(state == input$state)
    
    
  })
  
  output$cities = renderPlot({
    top10cities <- d %>% group_by(city_or_county) %>% 
      summarize(Incidents = n()) %>% 
      arrange(Incidents) %>% 
      tail(10)
    
    top10cities$city_or_county = factor(top10cities$city_or_county, levels = top10cities$city_or_county)
    ggplot(top10cities, aes(x = city_or_county, y = Incidents, fill =Incidents)) + 
      geom_bar(stat = "identity") +  
      theme_bw() 
    
  })
  
  output$map <- leaflet::renderLeaflet({
    leaflet::leaflet(DATA$d
                     #, options = leafletOptions(minZoom=4)
    ) %>%
      leaflet::addTiles() %>% 
      #setView(lng = -98.5, lat = 39.5, zoom = 5)
      setView(lng = -96.5, lat = 38.0, zoom = 4)
  })
  
  observeEvent(input$num_year, {
    ## plot the subsetted data
    eoy_date = DATA$annual_d$eoy[DATA$annual_d$year==input$num_year]
    dmap = DATA$d[DATA$d$date<=eoy_date,];
    leafletProxy("map") %>%
      clearMarkers() %>%
      leaflet::addCircleMarkers(lat = dmap$latitude, lng = dmap$longitude,
                                radius = dmap$Total.victims,
                                color = 'red',
                                stroke = FALSE, fillOpacity = .5
                               # label = paste0(dmap$title," (",dmap$date,"), ", dmap$Total.victims," TV")
                              )

  })
})  