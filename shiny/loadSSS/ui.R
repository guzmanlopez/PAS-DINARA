library(shiny)
library(stringr)
library(xts)

# Ampliar a 16 el número de dígitos 
options(shiny.maxRequestSize = 800*1024^2, digits = 16, shiny.deprecation.messages = FALSE)

# Sonar Barrido Lateral

shinyUI(ui = fluidPage(
  titlePanel("Cargar datos SBL"),
  sidebarLayout(
    sidebarPanel(strong('Archivo de Sonar de Barrido Lateral'),
                 p('Tritech StarFish 990F'),
                 fileInput('file1', '', accept='text/csv', multiple=FALSE),
                 tags$hr(),
                 strong('Ver datos'),
                 selectInput(inputId = 'extraer', label = '', choices = c('GPS (lat, lon)' = 'gps', 'ECO (intensidad acústica)'='eco'), selectize=TRUE),
                 conditionalPanel(condition = "input.extraer == 'gps'",
                                  strong('Resolución'),
                                  selectInput(inputId = 'resolution', '', choices = c('Max' = 0, '1 min' = 1, '2 min' = 2, '3 min' = 3, '4 min' = 4, '5 min' = 5), multiple = FALSE),
                                  tags$hr(),
                                  strong('Exportar datos'),
                                  selectInput(inputId = 'export', '', choices = c('Tabla' = 'table', 'Shapefile' = 'shapefile', 'kml' = 'kml'), multiple = FALSE, selectize = FALSE),
                                  
                                  conditionalPanel(condition = "input.export == 'table'",
                                                   strong('Nombre de tabla'),
                                                   textInput(inputId = 'filename', label = '', value = 'posiciones-gps-sbl'),
                                                   downloadButton(outputId = 'action_exp_table', label = "Descargar", class = 'btn-success'),
                                                   tags$hr(),
                                                   helpText("Nota: se sugiere utilizar un nombre que contenga","un identificador de la campaña y la fecha de la misma.")),
                                  
                                  conditionalPanel(condition = "input.export == 'shapefile'",
                                                   strong('Nombre de trayectos'),
                                                   textInput(inputId = 'trackname', label = '', value = 'trayecto01'),
                                                   strong('Nombre de Shapefile'),
                                                   textInput(inputId = 'filename_shp', label = '', value = 'trayecto-sbl-sig'),
                                                   downloadButton(outputId = 'action_exp_shp', label = "Descargar", class = 'btn-success'),
                                                   tags$hr(),
                                                   helpText("Nota: se sugiere utilizar un nombre que contenga","un identificador de la campaña y la fecha de la misma.")),
                                  
                                  conditionalPanel(condition = "input.export == 'kml'",
                                                   strong('Nombre de kml'),
                                                   textInput(inputId = 'filename_kml', label = '', value = 'trayecto-sbl-googleearth'),
                                                   downloadButton(outputId = 'action_exp_kml', label = "Descargar", class = 'btn-success'),
                                                   tags$hr(),
                                                   helpText("Nota: se sugiere utilizar un nombre que contenga","un identificador de la campaña y la fecha de la misma."))
                 )
    ),
    mainPanel(dataTableOutput("table"))
  )
)
)