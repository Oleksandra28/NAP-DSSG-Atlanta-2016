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
                    checkboxInput(inputId='dekalb', label='Dekalb', value = TRUE, width = '400px'),
                    checkboxInput(inputId='fulton', label='Fulton', value = TRUE, width = '400px'),
                    checkboxInput(inputId='transit_stops', label='Public Transit', value = TRUE, width = '400px'),
                    checkboxInput(inputId='schools', label='Schools', value = TRUE, width = '400px'),
                    checkboxInput(inputId='supermarkets', label='Supermarkets', value = TRUE, width = '400px')
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
         setView(-84.3959808,33.7769859, zoom = 10) 
     })#output$main_map
     
     ###--------------------------Dekalb and Fulton Counties-------------------------------###
     observe({
       proxy <- leafletProxy("main_map", data = transit_stops)
       
       # clear all shapes if none of the counties selected
       if (!(input$dekalb & input$fulton))
       {
         proxy %>% 
           clearShapes() 
       }
     })#Dekalb and Fulton Counties
 
     ###--------------------------Public Transit--------------------------------------------###
     observe({
       proxy <- leafletProxy("main_map", data = transit_stops)
       
       if (input$transit_stops) {
         proxy %>% 
           addCircles(data=transit_stops, lat = ~Lat, lng = ~Lon, 
                    weight = 5, radius = 80, fillOpacity = .05, popup = transit_stops$name, group='group_transit_stops')
       }
 
     })#Public transit
     
     ###--------------------------Schools Dekalb and Fulton----------------------------------###
     observe({
       proxy <- leafletProxy("main_map")
       
       if (input$dekalb & input$schools) 
       {
         proxy %>% 
           addCircles(data=dekalb_schools, lat = ~latitude, lng = ~longitude, 
                      weight = 3, radius = 40, fillOpacity = .02, popup = dekalb_schools$school_name, group='group_dekalb_schools')
       }
       else
       {

       }
       
       if (input$fulton & input$schools)
       {
         proxy %>% 
         addCircles(data=fulton_schools, lat = ~latitude, lng = ~longitude, 
                    weight = 3, radius = 40, fillOpacity = .01, popup = fulton_schools$school_name, group='group_fulton_schools')
       }
       else
       {
    
       }

     })#Schools

#      proxy <- leafletProxy("main_map")
#      proxy %>% 
#      addLayersControl(
#        overlayGroups = c("Public Transit", "Schools"),
#        options = layersControlOptions(collapsed = FALSE)
#      )
     
   }#server
   
   shinyApp(ui = ui, server = server)
   
