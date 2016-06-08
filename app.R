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
   path_to_schools <- paste(data_folder, 'Schools.csv', sep='/')
   
   schools <- read.csv(path_to_schools)
   
   ###-----------------------------------supermarkets---------------------------------------###
   path_to_dekalb_supermarkets <- paste(data_folder, 'results_dekalb_supermarkets.csv', sep='/')
   path_to_fulton_supermarkets <- paste(data_folder, 'results_fulton_supermarkets.csv', sep='/')
   
   dekalb_supermarkets <- read.csv(path_to_dekalb_supermarkets)
   fulton_supermarkets <- read.csv(path_to_fulton_supermarkets)
   
   supermarkets <- rbind(dekalb_supermarkets, fulton_supermarkets)
   
   ###-----------------------------------faith communities---------------------------------------###
   path_to_dekalb_faith <- paste(data_folder, 'results_dekalb_places_to_worship.csv', sep='/')
   path_to_fulton_faith <- paste(data_folder, 'results_fulton_places_to_worship.csv', sep='/')
   
   dekalb_faith <- read.csv(path_to_dekalb_faith)
   fulton_faith <- read.csv(path_to_fulton_faith)
   
   faith_centers <- rbind(dekalb_faith, fulton_faith)
   
   ###-----------------------------------Affordability---------------------------------------###
   Aff <- readOGR(data_folder,"Afford")
   
   
   #Set Color Palettes
   pal1 <- colorQuantile( palette = "RdPu", domain = Aff$blkgrp_med)
   pal2 <- colorQuantile( palette = "RdPu", domain = Aff$local_job_)
   pal3 <- colorQuantile( palette = "RdPu", domain = Aff$retail_acc)
   pal4 <- colorFactor(rainbow(4), schools$Grades)
   
   ###########################################################################################
   ###-------------------------------------------UI----------------------------------------###
   ###########################################################################################
   ## User Interface - Title, headings, and sidebar 
   
   ui <- fluidPage(
     titlePanel("New American Pathways Housing Scout"), br(), h2("Selection Criteria"),
     mainPanel(
       leafletOutput("main_map", height = "580", width = "1320")
        )#mainPanel
     )#fluidPage
                   

   ###########################################################################################
   ###---------------------------------------SERVER----------------------------------------###
   ###########################################################################################
   ## Server with functionality components
   server <- function(input, output, session) {
     
     output$main_map <- renderLeaflet({
       leaflet() %>%
         ### Street Tiles 
         addTiles(group = "Streets")%>%
         addTiles(urlTemplate = "http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png") %>%
         setView(-84.3959808,33.7769859, zoom = 10) 
     })#output$main_map
     
 
     ###----------------------------------Adding data--------------------------------------###
     proxy <- leafletProxy("main_map")
     proxy %>% 
           addMarkers(data=apt_complexes, lat = ~latitude, lng = ~longitude, 
                  popup = paste("<a href=", apt_complexes$website_url,  
                                "<b>", apt_complexes$apartment_name, "</b>","</a>", "<br>",
                                apt_complexes$phone, "<br>",
                                apt_complexes$property_address), clusterOptions = markerClusterOptions(),
                  group='Apartment Complexes') %>% 
           addCircles(data=transit_stops, lat = ~Lat, lng = ~Lon, color = "#ffa500", 
                    weight = 5, radius = 60, fillOpacity = .04, 
                    popup = paste(transit_stops$name, "<br>",
                                  transit_stops$agency, "<br>"), 
                    group='Transit Stops') %>% 
           addCircles(data=schools, lat = ~latitude, lng = ~longitude, stroke = TRUE, 
                      weight = 5, radius = 40, fillOpacity = .02, color = ~pal4(Grades),
                      popup = paste("<a href=", schools$website,
                                    "<b>", schools$school_name, "</b>","</a>", "<br>",
                                    schools$school_type, "<br>",
                                    schools$address, "<br>",
                                    schools$phone, "<br>"),
                      group='Schools') %>% 
           addCircles(data=supermarkets, lat = ~latitude, lng = ~longitude, 
                  weight = 5, radius = 20, fillOpacity = .01, 
                  popup = paste(supermarkets$market_name, "<br>",
                                supermarkets$supermarket_type, "<br>",
                                 supermarkets$property_address), 
                  group='Supermarkets')%>%
           addCircles(data=faith_centers, lat = ~latitude, lng = ~longitude, 
                weight = 5, radius = 20, fillOpacity = .01, 
                popup = paste(faith_centers$place_name, "<br>",
                              faith_centers$place_type, "<br>",
                              faith_centers$property_address), 
                group='Faith_centers')%>%
           ### Jobs Layer
           addPolygons(data = Aff, stroke = FALSE, fillOpacity = 0.5, smoothFactor = 0.5, group = "Jobs", color = ~pal2(local_job_))%>%
           ### Retail Layer
           addPolygons(data = Aff, stroke = FALSE, fillOpacity = 0.5, smoothFactor = 0.5, group = "Retail", color = ~pal3(retail_acc))
     ###---------------------------------Adding control------------------------------------###
     proxy <- leafletProxy("main_map")
     proxy %>% 
     addLayersControl(
       overlayGroups = c('Apartment Complexes', 'Transit Stops', 'Schools', 'Supermarkets', 'Faith_centers'),
       baseGroups = c( "Default", "Streets", "Affordability", "Jobs", "Retail" ),
       options = layersControlOptions(collapsed = FALSE)
     )%>% 
     
     ### Add Legend 
     addLegend("bottomright", pal = pal1, values = Aff$blkgrp_med , title = "Neighborhood Percentile", labFormat = labelFormat(prefix = "$"), opacity = 1)%>%
     addLegend("bottomleft", pal = pal4, value = schools$Grades, title= "Schools", opacity = 1)
     
   }#server
   
   shinyApp(ui = ui, server = server)
   
