library(shiny)
library(shinydashboard)
library(RColorBrewer)


server <- function(input, output,session) {
  
  data <- read.csv("WHO-COVID-19-global-data.csv")
  geo <- read.csv("capitales-du-monde.csv")
  
  output$menu <- renderMenu({
    sidebarMenu(menuItem("Données sources",
                                                  tabName="m1",
                                                  icon = icon("database")),
                                         menuItem("Tableau de bord",
                                                  tabName="m2",
                                                  icon = icon("dashboard")),
                                         menuItem("Introduction au Covid", tabName = "m3", icon = icon("comment"),
                                                  menuSubItem("Description en bas de page ", tabName = "à titre informatif")
                                                  
                                         ),
                                        # notification en live
                                         dropdownMenu(type = "messages",
                                                      messageItem(
                                                        from = "Jonathan",
                                                        time = "09:45",
                                                        message = "Peux-tu me confirmé le taux de décés en France ?"
                                                      ),
                                                      messageItem(
                                                        from = "Client",
                                                        message = "Pourriez-vous le rendre plus automatisé?",
                                                        icon = icon("question"),
                                                        time = "10:06"
                                                      ),
                                                      messageItem(
                                                        from = "Support",
                                                        message = "Tu peux rajouter un tableau en barre sur la progression du covid dans le monde",
                                                        icon = icon("life-ring"),
                                                        time = "2023-01-32"
                                                      )
                                         )
                                         
                                         
                                         
                                         
                                         )
                            })
  isolate({updateTabItems(session, "tabs", "m2")})
  
  output$curve_Confirmed_cases <- renderAmCharts({
    input$go
    isolate({
      data_curve <- data[which(data$Country == input$country),] %>% group_by(Date) %>% summarise(Confirmed_cases = sum(Confirmed_cases))
      data_curve$Date <- as.POSIXct(data_curve$Date)
      amTimeSeries(data_curve, 'Date', c('Confirmed_cases'), main = paste("Cas confirmés en ", input$country), bullet = 'round',  export = TRUE)

    })
  })
  
  output$curve_Confirmed_deaths <- renderAmCharts({
    input$go
    isolate({
      data_curve <- data[which(data$Country == input$country),] %>% group_by(Date) %>% summarise(Confirmed_deaths = sum(Confirmed_deaths))
      data_curve$Date <- as.POSIXct(data_curve$Date)
      amTimeSeries(data_curve, 'Date', c('Confirmed_deaths'), main = paste("Décés confirmés en ", input$country), bullet = 'round',  export = TRUE)
      
    })
  })
  
  output$carte <- renderAmCharts({
    isolate({
      data_carte <- merge(x=data,y=geo,by.x = "Country_code", by.y = "CountryCode",all.x=TRUE)
      data_carte <- data_carte %>% group_by(Country, CapitalLatitude, CapitalLongitude) %>% summarise(Confirmed_cases = sum(Confirmed_cases),
                                                             Confirmed_deaths = sum(Confirmed_deaths))
      #define the color pallate
      pal <- colorNumeric(
        #Code couleur selon les zones dans le monde touchées par le Covid
        palette = c('gold', 'orange', 'dark orange', 'orange red', 'red', 'dark red'),
        #Ceux contaminés avec le Covid
        domain = data_carte$Confirmed_cases)
      
      
      output$carte <- renderLeaflet({
        leaflet() %>% addTiles() %>% addProviderTiles("Esri.WorldTopoMap") %>%
          #Vu par default
          setView(lng = 0, lat = -0.09, zoom = 2) %>%
          addTiles() %>% 
          addCircles(data = data_carte, lat = ~ CapitalLatitude, lng = ~ CapitalLongitude, weight = 1,
                     radius = ~sqrt(Confirmed_cases)*100, popup = ~as.character(Country),
                     label = ~as.character(paste("Pays: ", Country, "| Cas confirmés: ", sep = " ", Confirmed_cases)),
                     color = ~pal(Confirmed_cases), fillOpacity = 0.5)
      })
      
    })
  })
  
  
  # passage automatique a l'onglet Courbe
  observeEvent(input$go, {
    updateTabsetPanel(session, inputId = "viz", selected = "Courbe")
  })
  
  
  # summary / Résultats Calculs
  output$summary <- renderPrint({
    summary(data)
  })
  # table afin de visualiser les données
  output$table <- renderDataTable({
    data
  })
}




