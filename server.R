
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)



koncesje <- readRDS('koncesje.Rds')
 # pozwolenia <- pozwolenia[sample.int(nrow(pozwolenia), 2000),]

shinyServer(

    function(input, output, session) ({
        
            koncesje$Lat <- jitter(koncesje$Lat)
            koncesje$Lon <- jitter(koncesje$Lon)

            output$map <- renderLeaflet({
                leaflet() %>%
                    addTiles(
                        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
                        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
                    ) %>%
                    setView(lng = 17, lat = 51.1, zoom = 13)
            })
            
            # pointsInDate <- reactive({
            #     subset(pozwolenia, Data.wniosku >= input$dat[1] & Data.wniosku <= input$dat[2])
            # })
            
            # A reactive expression that returns the set of zips that are
            # in bounds right now
            pointsInBounds <- reactive({
                # if (is.null(input$map_bounds))
                #     return(koncesje[FALSE,])
                # bounds <- input$map_bounds
                # latRng <- range(bounds$north, bounds$south)
                # lngRng <- range(bounds$east, bounds$west)
                # 
                # subset(koncesje,
                #        Lat >= latRng[1] & Lat <= latRng[2] &
                #            Lon >= lngRng[1] & Lon <= lngRng[2])
                koncesje[grep(input$color, koncesje$Rodzaj.alkoholu),]
            })

            
            # dodawanie punktow
            observe({
                if(nrow(pointsInBounds())==0) { leafletProxy("map", data = pointsInBounds()) %>% clearMarkerClusters() %>% clearMarkers()}
                else{
                    
                    colorBy <- "Typ.koncesji" #input$color
                    colorData <- pointsInBounds()[[colorBy]]
                    pal <- colorFactor(c("#C0D5F2","#F99D4A"), koncesje[[colorBy]])
                    
                    if(input$group == "off")
                    {
                        leafletProxy("map", data = pointsInBounds()) %>%
                            clearMarkers() %>%
                            clearMarkerClusters() %>%
                            addCircleMarkers(~Lon, ~Lat, layerId=~Nr.zezwolenia, radius=5,
                                       stroke=TRUE, color ="black", weight = 1, fillOpacity=1, fillColor=pal(colorData)) %>%#, clusterOptions = markerClusterOptions()) %>%
                             addLegend("bottomright", pal=pal, values=colorData, title=colorBy,
                                         layerId="colorLegend")
                    }
                    else
                    {
                        leafletProxy("map", data = pointsInBounds()) %>%
                            clearMarkers() %>%
                            clearMarkerClusters() %>%
                            addCircleMarkers(~Lon, ~Lat, layerId=~Nr.zezwolenia, radius=13,
                                             stroke=FALSE, fillOpacity=1, fillColor=pal(colorData), clusterOptions = markerClusterOptions()) %>%
                            addLegend("bottomright", pal=pal, values=colorData, title=colorBy,
                                      layerId="colorLegend")
                    }
                    }
                    })
           
             # Show a popup at the given location
            showPlacePopup <- function(Nr.zezwolenia, Lat, Lon) {
                selectedPlace <- koncesje[koncesje$Nr.zezwolenia == Nr.zezwolenia,]
                content <- as.character(tagList(
                    tags$h4("Nazwa:", selectedPlace$Nazwa), tags$br(),
                    sprintf("Adres: %s", selectedPlace$Adres.punKtu), tags$br(),
                    sprintf("Rodzaj alkoholu: %s", selectedPlace$Rodzaj.alkoholu), tags$br(),
                    sprintf("Data upływu zezwolenia: %s", selectedPlace$Data), tags$br(),
                    sprintf("Numer zezwolenia: %s", selectedPlace$Nr.zezwolenia), tags$br(),
                    sprintf("Typ koncesji: %s", selectedPlace$Typ.koncesji)
                ))
                leafletProxy("map") %>% addPopups(Lon, Lat, content, layerId = Nr.zezwolenia)
            }
            
            # When map is clicked, show with info
            observe({
                leafletProxy("map") %>% clearPopups()
                event <- input$map_marker_click
                if (is.null(event))
                    return()

                isolate({
                    showPlacePopup(event$id, event$lat, event$lng)
                })
            })
            
    })
)

