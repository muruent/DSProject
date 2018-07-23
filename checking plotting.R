

eoy_date = DATA$annual_d$eoy[DATA$annual_d$year==input$num_year]
dmap = DATA$d[DATA$d$date<=eoy_date,];
leaflet("map") %>%
  clearMarkers() %>%
  leaflet::addCircleMarkers(lat = dmap$latitude, lng = dmap$longitude,
                            radius = dmap$size,
                            color = 'red',
                            stroke = FALSE, fillOpacity = .5
                           #label = paste0(dmap$title," (",dmap$date,"), ", dmap$Total.victims," TV")
  )

