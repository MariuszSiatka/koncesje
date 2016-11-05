
# This is the user-interface definition of a Shiny web application.
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


vars <- c(
    "wszystkie koncesje" = "-",
    "A - zawartosc alkoholu do 4,5%" = "A - ",
    "B - zawartosc alkoholu od 4,5% do 18%" = "B - ",
    "C - zawartosc alkoholu powyzej 18%" = "C - "

)

shinyUI(

    
    navbarPage("Koncesje na sprzedaż alkoholu", id="nav",
        tabPanel("Mapa interaktywna",
                div(class="outer",
                    tags$head(
                        # Include our custom CSS
                        includeCSS("styles.css"),
                        includeScript("gomap.js")
                    ),

                leafletOutput("map", width="100%", height="100%"),
                
                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                              width = 300, height = "auto",

                              h2("Eksplorer danych"),

                              selectInput("color", "Pokaż koncesje", vars),
                              selectInput("group", "Grupowanie punktów", c("wyłączone" = "off", "włączone" = "on"))

    
                ),
                
                
                tags$div(id="cite",
                         'Dane pochodzą ze strony ', tags$em('http://www.wroclaw.pl/open-data/')
                         )
                    )
               )
            )
)


