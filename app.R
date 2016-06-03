   library(shiny)
   library(leaflet)
   library(magrittr)
   library(rgdal)

   library(readxl) #IF NOT INSTALLED, NEED TO: install.packages("readxl")

   ###########################################################################################
   ###------------------------------------------DATA---------------------------------------###
   ###########################################################################################
   data_folder <- paste(getwd(), 'data', sep='/')
   
   ###-----------------------------------apt_complexes-------------------------------------###
   path_to_dekalb_apt_complexes <- paste(data_folder, 'results_dekalb_apt_complexes.csv', sep='/')
   path_to_fulton_apt_complexes <- paste(data_folder, 'results_fulton_apt_complexes.csv', sep='/')

   dekalb_apt_complexes <- read.csv(path_to_dekalb_apt_complexes)
   fulton_apt_complexes <- read.csv(path_to_fulton_apt_complexes)
   
   ###-----------------------------------schools-------------------------------------------###
   path_to_dekalb_schools <- paste(data_folder, 'results_dekalb_schools.csv', sep='/')
   path_to_fulton_schools <- paste(data_folder, 'results_fulton_schools.csv', sep='/')
   
   dekalb_schools <- read.csv(path_to_dekalb_schools)
   fulton_schools <- read.csv(path_to_fulton_schools)
   
   ###-----------------------------------supermarkets---------------------------------------###
   path_to_dekalb_supermarkets <- paste(data_folder, 'results_dekalb_supermarkets.csv', sep='/')
   path_to_fulton_supermarkets <- paste(data_folder, 'results_fulton_supermarkets.csv', sep='/')
   
   dekalb_supermarkets <- read.csv(path_to_dekalb_supermarkets)
   fulton_supermarkets <- read.csv(path_to_fulton_supermarkets)
   
   ###-----------------------------------transit-stops---------------------------------------###
   path_to_transit_stops <- paste(data_folder, 'transit_stops.csv', sep='/')
   
   transit_stops <- read.csv(path_to_transit_stops)
   
   ###########################################################################################
   ###-------------------------------------------UI----------------------------------------###
   ###########################################################################################
   ## User Interface - Title, headings, and sidebar 
   
   ui <- fluidPage(
     titlePanel("New American Pathways Housing Scout"), br(), h2("Selection Criteria"),
     sidebarLayout(
       sidebarPanel(width = 3, position = "left",
                    checkboxGroupInput(inputId='counties', label=h3('Counties'), 
                                       choices=list("Dekalb" = 1, "Fulton" = 2), 
                                       selected = list(1,2), inline = FALSE, width = NULL),
                    
                    checkboxInput(inputId='public_transit', label='Public Transit', value = TRUE, width = NULL),
                    checkboxInput(inputId='schools', label='Schools', value = TRUE, width = NULL)
       ),
                   mainPanel(
                     leafletOutput("main_map", height = "500", width = "800")
                     )#mainPanel
                   )#sidebarLayout
     )#fluidPage
                   

   ###########################################################################################
   ###---------------------------------------SERVER----------------------------------------###
   ###########################################################################################
   ## Server with functionality components
   server <- function(input, output, session) {
     
     output$main_map <- renderLeaflet({
       leaflet() %>%
         addTiles(urlTemplate = "http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png") %>%
         setView(-84.3959808,33.7769859, zoom = 10) #%>%
#          addCircles(data=dekalb_schools, lat = ~latitude, lng = ~longitude, 
#                    weight = 5, radius = 80, fillOpacity = .05, popup = dekalb_schools$school_name, group='Schools'),
#          addCircles(data=dekalb_schools, lat = ~latitude, lng = ~longitude, 
#                   weight = 5, radius = 80, fillOpacity = .05, popup = dekalb_schools$school_name, group='Schools'),
     })#output$main_map
 
     
#      addLayersControl(
#        overlayGroups = c('Schools'),
#        options = layersControlOptions(collapsed = FALSE)
#      )

   }#server
   
   shinyApp(ui = ui, server = server)
   
