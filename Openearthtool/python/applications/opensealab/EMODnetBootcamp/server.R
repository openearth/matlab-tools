

shinyServer(function(input, output, session) {
  
  
  ## Interactive Map ###########################################
  
  # get species observations
  # species <- reactive({
  #   pol = st_sfc(st_polygon(list(cbind(c(7.55,7.55,12.09,12.09,7.55),c(56.99,58.05,58.05,58.05,56.99)))))
  #   pol_ext = st_buffer(pol, dist = 1)
  #   obsData <- occurrence(scientificname = c("Buccinum undatum"), geometry = st_as_text(pol_ext))
  #   obsData
  #   
  # })
  
  # Create the map
  output$map <- renderLeaflet({
    factpal <- colorFactor(topo.colors(5), emodnet_habitat_cl_sp$HAB_TYPE)
    pal <- colorNumeric(c("green", "white", "red"), values(kriged_wulk),
                        na.color = "transparent")
    palb <- colorNumeric(c("blue", "white", "brown"), values(bathymetry),
                         na.color = "transparent")
      
    leaflet() %>%
      addTiles(group = "OSM (default)") %>%  #  Esri.WorldStreetMap, Esri.OceanBasemap
      addProviderTiles(providers$Esri.OceanBasemap) %>%
     addPolylines(data = cables,
                  weight = 1, fillOpacity = 1,
                  color = "black",
                  # label = ~htmlEscape(HAB_TYPE),
                  group = "cables") %>%
      addMarkers(data = windparks_df,
                 # lat = ~ coords.x2,
                 # lng = ~coords.x1,
                 group = "windparks") %>%
      addPolygons(data = emodnet_habitat_cl_sp, 
                  weight = 1, fillOpacity = 0.8, 
                  color = ~factpal(HAB_TYPE),
                  label = ~htmlEscape(HAB_TYPE),
                  group = "EMODnet habtype") %>%
      addCircleMarkers(data = obsData,
                       lng = ~decimalLongitude, 
                       lat = ~decimalLatitude,
                       group = "speciesObservations", 
                       weight = ~individualCount,
                       label = ~htmlEscape(paste(eventDate))) %>%
      addCircleMarkers(data = endangeredSp,
                       # lat = ~ coords.x2,
                       # lng = ~coords.x1,
                       color = "red",
                       group = "endangered_sp") %>%
      addRasterImage(x = kriged_wulk,
                     colors = pal, 
                     opacity = 0.8,
                     group = "kriged observations") %>%
      addRasterImage(x = primprod,
                     group = "primary production") %>%
      addRasterImage(x = bathymetry,
                     colors = palb, 
                     opacity = 0.8,
                     group = "bathymetry") %>%
      addLayersControl(
        baseGroups = c("OSM (default)", "Esri.OceanBasemap"),
        overlayGroups = c("EMODnet habtype", "speciesObservations", "kriged observations", "bathymetry", "cables","endangered_sp", "windparks", "primary production"),
        options = layersControlOptions(collapsed = FALSE)) %>%
      hideGroup(c("speciesObservations", "kriged observations", "bathymetry", "endangered_sp", "primary production")) %>%
      setView(lng =  10, lat = 57.5, zoom = 8)
  })
  
  # A reactive expression that returns the set of benthos data that are
  # in bounds right now
  
  # samplesInBounds <- reactive({
  #   if (is.null(input$map_bounds))
  #     return(benthos[FALSE,])
  #   bounds <- input$map_bounds
  #   latRng <- range(bounds$north, bounds$south)
  #   lngRng <- range(bounds$east, bounds$west)
  
  # benthos %>% 
  #   dplyr::filter(parameter.omschrijving %in% benthosselection &
  #                   grootheid.code == input$variable )%>%
  #   dplyr::filter(lat >= latRng[1] & 
  #                   lat <= latRng[2] & 
  #                   lon >= lngRng[1] & 
  #                   lon <= lngRng[2]) 
  # })
  
  output$benthosTable <- renderTable({
    obsData %>%
      dplyr::select(eventDate, institutionCode, sex, scientificName, depth, individualCount)
    
  })
  
  # Precalculate the breaks we'll need for the two histograms
  # benthosBreaks <- hist(plot = FALSE, mybenthos()$sum_of_benthos, breaks = 20)$breaks
  
  # output$histBenthos <- renderPlot({
  #   # If no points are in view, don't plot
  #   if (nrow(samplesInBounds()) == 0)
  #     return(NULL)
  # 
  #   hist(samplesInBounds()$sum_of_benthos,
  #        # breaks = benthosBreaks,
  #        main = "Benthos (visible samples)",
  #        xlab = "Percentile",
  #        # xlim = range(samplesInBounds()$sum_of_benthos),
  #        col = '#00DD00',
  #        border = 'white')
  # })
  
  # output$timeSeriesBenthos <- renderPlot({
  #   # If no points are in view, don't plot
  #   # if (nrow(samplesInBounds()) == 0)
  #   #   return(print("no data in view")) # should print in the UI, not in de console
  #   # timebox <- ggplot(samplesInBounds(), (aes(x = year, y = numeriekewaarde))) + 
  #   #   geom_boxplot(aes(group = year))
  #   # if(input$plotlog)  {timebox = timebox + scale_y_log10()}
  #   # if(!input$plotlog) {timebox = timebox}
  #   # timebox
  #   # # print(xyplot(monsternemingsdatum ~ numeriekewaarde, data = samplesInBounds(), xlim = range(samplesInBounds$monsternemingsdatum), ylim = range(samplesInBounds$numeriekewaarde)))
  # })
  # 
  # This observer is responsible for maintaining the circles and legend,
  # according to the variables the user has chosen to map to color and size.
  # observe({
  #   colorBy <- input$color
  #   sizeBy <- input$size
  #   
  #   if (colorBy == "superzip") {
  #     # Color and palette are treated specially in the "superzip" case, because
  #     # the values are categorical instead of continuous.
  #     colorData <- ifelse(zipdata$centile >= (100 - input$threshold), "yes", "no")
  #     pal <- colorFactor("Spectral", colorData)
  #   } else {
  #     colorData <- zipdata[[colorBy]]
  #     pal <- colorBin("Spectral", colorData, 7, pretty = FALSE)
  #   }
  #   
  #   if (sizeBy == "superzip") {
  #     # Radius is treated specially in the "superzip" case.
  #     radius <- ifelse(zipdata$centile >= (100 - input$threshold), 30000, 3000)
  #   } else {
  #     radius <- zipdata[[sizeBy]] / max(zipdata[[sizeBy]]) * 30000
  #   }
  #   
  #   leafletProxy("map", data = zipdata) %>%
  #     clearShapes() %>%
  #     addCircles(~longitude, ~latitude, radius=radius, layerId=~zipcode,
  #                stroke=FALSE, fillOpacity=0.4, fillColor=pal(colorData)) %>%
  #     addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
  #               layerId="colorLegend")
  # })
  
  # Show a popup at the given location
  # showZipcodePopup <- function(zipcode, lat, lng) {
  #   selectedZip <- allzips[allzips$zipcode == zipcode,]
  #   content <- as.character(tagList(
  #     tags$h4("Score:", as.integer(selectedZip$centile)),
  #     tags$strong(HTML(sprintf("%s, %s %s",
  #                              selectedZip$city.x, selectedZip$state.x, selectedZip$zipcode
  #     ))), tags$br(),
  #     sprintf("Median household income: %s", dollar(selectedZip$income * 1000)), tags$br(),
  #     sprintf("Percent of adults with BA: %s%%", as.integer(selectedZip$college)), tags$br(),
  #     sprintf("Adult population: %s", selectedZip$adultpop)
  #   ))
  #   leafletProxy("map") %>% addPopups(lng, lat, content, layerId = zipcode)
  # }
  
  # When map is clicked, show a popup with city info
  # observe({
  #   leafletProxy("map") %>% clearPopups()
  #   event <- input$map_shape_click
  #   if (is.null(event))
  #     return()
  #   
  #   isolate({
  #     showZipcodePopup(event$id, event$lat, event$lng)
  #   })
  # })
  
  
  ## Data Explorer ###########################################
  
  # observe({
  #   cities <- if (is.null(input$states)) character(0) else {
  #     filter(cleantable, State %in% input$states) %>%
  #       `$`('City') %>%
  #       unique() %>%
  #       sort()
  #   }
  #   stillSelected <- isolate(input$cities[input$cities %in% cities])
  #   updateSelectInput(session, "cities", choices = cities,
  #                     selected = stillSelected)
  # })
  # 
  # observe({
  #   zipcodes <- if (is.null(input$states)) character(0) else {
  #     cleantable %>%
  #       filter(State %in% input$states,
  #              is.null(input$cities) | City %in% input$cities) %>%
  #       `$`('Zipcode') %>%
  #       unique() %>%
  #       sort()
  #   }
  #   stillSelected <- isolate(input$zipcodes[input$zipcodes %in% zipcodes])
  #   updateSelectInput(session, "zipcodes", choices = zipcodes,
  #                     selected = stillSelected)
  # })
  # 
  # observe({
  #   if (is.null(input$goto))
  #     return()
  #   isolate({
  #     map <- leafletProxy("map")
  #     map %>% clearPopups()
  #     dist <- 0.5
  #     zip <- input$goto$zip
  #     lat <- input$goto$lat
  #     lng <- input$goto$lng
  #     showZipcodePopup(zip, lat, lng)
  #     map %>% fitBounds(lng - dist, lat - dist, lng + dist, lat + dist)
  #   })
  # })
  # 
  # output$ziptable <- DT::renderDataTable({
  #   df <- cleantable %>%
  #     filter(
  #       Score >= input$minScore,
  #       Score <= input$maxScore,
  #       is.null(input$states) | State %in% input$states,
  #       is.null(input$cities) | City %in% input$cities,
  #       is.null(input$zipcodes) | Zipcode %in% input$zipcodes
  #     ) %>%
  #     mutate(Action = paste('<a class="go-map" href="" data-lat="', Lat, '" data-long="', Long, '" data-zip="', Zipcode, '"><i class="fa fa-crosshairs"></i></a>', sep=""))
  #   action <- DT::dataTableAjax(session, df)
  #   
  #   DT::datatable(df, server = TRUE, options = list(ajax = list(url = action)),
  #                 escape = FALSE)
  # })
})
