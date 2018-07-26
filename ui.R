library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
library(maps)
library(knitr)
library(fiftystater)
library(testthat)
library(readr)
library(RColorBrewer)
library(dplyr)
library(plotly)
library(scales)
library(viridis)
library(shiny)
library(leaflet)
library(shinydashboard)
library(magrittr)
library(htmltools)
library(dygraphs)
library(xts)

library(assertive, warn.conflicts = FALSE)

load("msdata.RData")

dashboardPage(
  dashboardHeader(title = "US Gun Violence 2013-2018", titleWidth = 350),
  dashboardSidebar(
    menuItem("Map", tabName = 'map', icon= icon("map")),
    menuItem("Graph", tabName = 'graph', icon = icon("signal")),
    menuItem("Cities", tabName = 'cities', icon = icon("city")),
    menuItem("States", tabName = 'States', icon = icon("State")),
    menuItem("Norm.States", tabName = 'NormStates', icon = icon("State"))
    ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = 'map',
        tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),#use 80px for full screen
        fluidRow(tags$style("#death,#total_death {min-width:250px;}"),
             column(6,sliderInput("num_year", "Year Range (Press Play):",
                                   min = min(DATA$annual_d$year), max = max(DATA$annual_d$year),
                                   value =  min(DATA$annual_d$year),# as.Date("01/1/1967", "%m/%d/%Y"), 
                                   step = 1, sep = "",
                                   animate = animationOptions(interval=5000,loop=FALSE)
             ),align="center")),
        fluidRow(leafletOutput("map"))),
      tabItem (
        tabName = 'graph',
      
        selectInput ('state', label = "Select State", choices = statelist), 
        plotOutput('plot')
              ),
      tabItem(tabName = 'cities', plotOutput('cities')),
      tabItem(tabName = 'States', plotOutput('States', height=550)),
      tabItem(tabName = 'NormStates', plotOutput('States1', height=550) 
        
      )
  ))
)

