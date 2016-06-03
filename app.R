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
   
   apt_complexes <- rbind(dekalb_apt_complexes, fulton_apt_complexes)
   
   ###-----------------------------------transit-stops---------------------------------------###
   path_to_transit_stops <- paste(data_folder, 'transit_stops.csv', sep='/')
   
   transit_stops <- read.csv(path_to_transit_stops)
   
   ###-----------------------------------schools-------------------------------------------###
   path_to_dekalb_schools <- paste(data_folder, 'results_dekalb_schools.csv', sep='/')
   path_to_fulton_schools <- paste(data_folder, 'results_fulton_schools.csv', sep='/')
   
   dekalb_schools <- read.csv(path_to_dekalb_schools)
   fulton_schools <- read.csv(path_to_fulton_schools)
   
   schools <- rbind(dekalb_schools, fulton_schools)
   
   ###-----------------------------------supermarkets---------------------------------------###
   path_to_dekalb_supermarkets <- paste(data_folder, 'results_dekalb_supermarkets.csv', sep='/')
   path_to_fulton_supermarkets <- paste(data_folder, 'results_fulton_supermarkets.csv', sep='/')
   
   dekalb_supermarkets <- read.csv(path_to_dekalb_supermarkets)
   fulton_supermarkets <- read.csv(path_to_fulton_supermarkets)
   
   supermarkets <- rbind(dekalb_supermarkets, fulton_supermarkets)
   
   
   ###########################################################################################
   ###-------------------------------------------UI----------------------------------------###
   ###########################################################################################
   ## User Interface - Title, headings, and sidebar 
   
   ui <- fluidPage(
     titlePanel("New American Pathways Housing Scout"), br(), h2("Selection Criteria"),
     mainPanel(
       leafletOutput("main_map", height = "500", width = "1200")
        )#mainPanel
     )#fluidPage
                   

   ###########################################################################################
   ###---------------------------------------SERVER----------------------------------------###
   ###########################################################################################
   ## Server with functionality components
   server <- function(input, output, session) {
     
     output$main_map <- renderLeaflet({
       leaflet() %>%
         addTiles(urlTemplate = "http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png") %>%
         setView(-84.3959808,33.7769859, zoom = 10) 
     })#output$main_map
     
 
     ###----------------------------------Adding data--------------------------------------###
     proxy <- leafletProxy("main_map", data = transit_stops)
     proxy %>% 
           addCircles(data=apt_complexes, lat = ~latitude, lng = ~longitude, color = 'red', 
                  weight = 5, radius = 80, fillOpacity = .05, popup = apt_complexes$name, group='Apartment Complexes') %>% 
           addCircles(data=transit_stops, lat = ~Lat, lng = ~Lon, color = 'green', 
                    weight = 5, radius = 60, fillOpacity = .04, popup = transit_stops$name, group='Transit Stops') %>% 
           addCircles(data=schools, lat = ~latitude, lng = ~longitude, 
                      weight = 5, radius = 40, fillOpacity = .02, popup = schools$school_name, group='Schools') %>% 
           addCircles(data=supermarkets, lat = ~latitude, lng = ~longitude, 
                  weight = 5, radius = 20, fillOpacity = .01, popup = supermarkets$school_name, group='Supermarkets')

     ###---------------------------------Adding control------------------------------------###
     proxy <- leafletProxy("main_map")
     proxy %>% 
     addLayersControl(
       overlayGroups = c('Apartment Complexes', 'Transit Stops', 'Schools', 'Supermarkets'),
       options = layersControlOptions(collapsed = FALSE)
     )
     
   }#server
   
   shinyApp(ui = ui, server = server)
   
