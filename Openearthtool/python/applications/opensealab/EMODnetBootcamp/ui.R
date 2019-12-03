library(shiny)
library(leaflet)

# Choices for drop-downs


shinyUI(navbarPage("EIA", id="nav",
                   
                   tabPanel("Interactive map",
                            div(class="outer",
                                
                                tags$head(
                                  # Include our custom CSS
                                  includeCSS("styles.css"),
                                  includeScript("gomap.js")
                                ),
                                
                                leafletOutput("map", width="100%", height="100%"),
                                
                                # Shiny versions prior to 0.11 should use class="modal" instead.
                                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                              draggable = TRUE, top = 60, left = 40, right = "auto", bottom = "auto",
                                              width = 330, height = "auto",
                                              
                                              h2("EIA Wizard"),
                                              
                                              selectInput("benthos", "Species or group: ", c("Buccinum undatum")),
                                              img(src = "dogwhelk.png", width = "155px"),
                                              img(src='variogram.png', width = "300px", height = '250px'),
                                              plotOutput("timeSeriesBenthos", height = 250)
                                )  #,
                                
                                # tags$div(id="cite",
                                #   'Data compiled for ', tags$em('Coming Apart: The State of White America, 1960–2010'), ' by Charles Murray (Crown Forum, 2012).'
                                # )
                            )
                   ),
                   
                   tabPanel("Data Wizard" ,
                            # fluidRow(
                            #   column(3,
                            #     selectInput("states", "States", c("All states"="", structure(state.abb, names=state.name), "Washington, DC"="DC"), multiple=TRUE)
                            #   ),
                            #   column(3,
                            #     conditionalPanel("input.states",
                            #       selectInput("cities", "Cities", c("All cities"=""), multiple=TRUE)
                            #     )
                            #   ),
                            #   column(3,
                            #     conditionalPanel("input.states",
                            #       selectInput("zipcodes", "Zipcodes", c("All zipcodes"=""), multiple=TRUE)
                            #     )
                            #   )
                            # ),
                            fluidRow(
                              column(8,
                                numericInput("startyear", "start year", min = 1980, max=2017, step = 1, value=2000)
                              ),
                              column(8,
                                numericInput("endyear", "end year",  min=1980, max=2017, step = 1, value=2017)
                              )
                            ),
                            hr(),
                            tableOutput("benthosTable")
                   ),
                   
                   conditionalPanel("false", icon("crosshair"))
)
)
