   library(shiny)
   library(leaflet)
   library(magrittr)
   library(rgdal)

   library(readxl) #IF NOT INSTALLED, NEED TO: install.packages("readxl")

   Properties <- read.csv('./data/Potential-Properties.csv')
   TStops <- read.csv('./data/TStops.csv')
   Schools <- read.csv('./data/Schools.csv')
  
   ## User Interface - Title, headings, and sidebar 
   ui <- fluidPage(
     titlePanel("New American Pathways Housing Scout"), br(), h2("Selection Criteria"),
     sidebarLayout(position = "right",
                   
       sidebarPanel(width = 3, position = "left",
        selectInput("n_bedrooms", "Bedrooms",
                  choices = c("Studio", "1", "2","3","4","5")
                   )
     ),
     mainPanel(
       h5(strong("Dekalb & Fulton Counties"),
       leafletOutput("mymap", height = "500", width = "800"))
     )
   )
   )                 
  
   
   ## Server with functionality components
   server <- function(input, output, session) {
     
     
     output$mymap <- renderLeaflet({
       input$price 
       leaflet() %>%
          addTiles(urlTemplate = "http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png") %>%  
          setView(-84.3959808,33.7769859, zoom = 10)%>%
          addCircles(lat = ~latitude, lng = ~longitude, data= Properties, weight = 5, radius = 80, fillOpacity = .05, popup = Properties$Name, group = "Units")%>%
          addCircles(lat = ~Lat, lng = ~Lon, data= TStops, color="#ffa500", weight = 1, radius = 10, fillOpacity = .03, group = "Transit")%>%
          addCircles(lat = ~ Y, lng = ~X, data = Schools, color="#e01d5d", weight = 4, radius = 100, popup = Schools$FACNAME, group ="Schools")%>%
          addLayersControl(overlayGroups = c("Units", "Transit", "Schools")) #%>%
          ##addLegend(position = topleft, )
       
     })
     
   }
   
   shinyApp(ui = ui, server = server)
   
