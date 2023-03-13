library(shiny)
library(shinydashboard)
library(rAmCharts)
library(leaflet)
library(ggplot2)
library(tidyverse)
library(shinyjs)
#bases de donnée utilisées
data <- read.csv("WHO-COVID-19-global-data.csv")
geo <- read.csv("capitales-du-monde.csv")
# Création du Dashboard nommé Covid-19
ui <- dashboardPage(title = "Covid-19",skin = "black", dashboardHeader(title = "Covid-19"),
                    dashboardSidebar(sidebarMenu(id="tabs",
                                                 sidebarMenuOutput("menu"))),
                    # 1ère partie du sommaire
                    dashboardBody(tabItems(tabItem(tabName = "m1", h1("Données sources", style = "text-align:center"),
                                                     tabsetPanel(id = "data_source",
                                                       tabPanel("data", dataTableOutput("table")),
                                                       tabPanel("summary", verbatimTextOutput("summary"))
                                                     )
                                                   ),
                    # 2ème partie du sommaire 
                                           tabItem(tabName = "m2", h1("Tableau de bord", style = "text-align:center"),
                                                     column(width = 3,
                                                       # wellPanel pour griser
                                                       wellPanel(
                                                         selectInput("country", "Pays:",
                                                                     unique(data$Country)
                                                                     ),
                                                         actionButton("go", "Actualiser")
                                                       )
                                                     ),
                                                     column(width = 9,
                                                      tabsetPanel(id = "viz",
                                                        tabPanel("Courbe",
                                                          fluidRow(
                                                            #Cas confirmés ayant le Covid
                                                            amChartsOutput("curve_Confirmed_cases")
                                                          ),br(),
                                                          fluidRow(
                                                            #Cas confirmés mort avec le Covid
                                                            amChartsOutput("curve_Confirmed_deaths")
                                                          )
                                                        ),
                                                        tabPanel("Carte",
                                                           leafletOutput("carte")
                                                        )
                                                      )
                                                     )
                                                                
                                           )
                                                   ),
                    
                                              tabItem(tabName = "Détail Analyse", h5("COVID-19 est une maladie infectieuse causée par le coronavirus SARS-CoV-2. Elle a été identifiée pour la première fois en décembre 2019 en Chine et s'est rapidement propagée dans le monde entier, entraînant une pandémie. Les symptômes les plus courants sont la fièvre, la toux et la difficulté à respirer, mais peuvent varier d'une personne à l'autre. La maladie est principalement transmise par des gouttelettes respiratoires lorsque les personnes infectées toussent ou éternuent. Des mesures de prévention telles que le lavage régulier des mains, le port de masques et la distanciation sociale sont recommandées pour réduire la transmission. Des vaccins contre le COVID-19 ont été développés et sont actuellement utilisés pour protéger les personnes à haut risque.", style = "text-align:center")
                            
                            
                                           )
                                  )
                    )