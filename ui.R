library(shiny)
library(leaflet)
library(sp)
library(maptools)
library(geosphere)
library(stringr)
library(xts)

# Ampliar a 16 el número de dígitos 
options(digits=16)

# Sonar Barrido Lateral

shinyUI(navbarPage(title="Convenio PAS-DINARA", 
             inverse=TRUE,
             collapsable=TRUE,
             fluid=TRUE,
             responsive=TRUE,
             
                         
             tabPanel("Bitácora",
                      icon=icon(name="location-arrow", "fa-2x"),
                      fluidRow(
                        column(2,
                               offset=0.5,
                               includeMarkdown("/home/guzman/GitHub/PAS-DINARA/Texto/indice.md")
                        ),
                        column(10,
                               offset=-0.5,
                               includeMarkdown("/home/guzman/GitHub/PAS-DINARA/Texto/contenido.md")
                               )
                        )
                      ),
             
             tabPanel("SIG",
                      icon=icon(name="map-marker", "fa-2x"),
                      div(class="outer",
                          tags$head(
                            # Include our custom CSS
                            includeCSS("styles.css"),
                            includeScript("gomap.js"),
                            includeScript("binding.js")
                            ),
                          leafletMap("map", width="100%", height="100%",
                                     initialTileLayer = "//{s}.tiles.mapbox.com/v3/guzman.j035h3hc/{z}/{x}/{y}.png",
                                     initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
                                     options=list(center= c(-34.9400, -54.9700),
                                                  zoom = 13,
                                                  maxBounds = list(list(-32.99966,-49.49774), list(-40.00023,-59.50186))
                                                  )
                                     ),
                          absolutePanel(id = "controls", class="modal", fixed=TRUE, draggable=TRUE, top=120, left=300, right="auto", bottom="auto", width=200, height="auto",
                                        h4("Capas espaciales"),
                                        tags$hr(),
                                        checkboxGroupInput('capas', label = "", choices = c('Isóbatas'='isobatas', 'Estaciones de mejillón'='est_mej','Pecios'='pecios','Densidad AIS (2012-2013)'='dens_ais','Navegación sonar'='nav_son')
                                                           )
                                        )
                          ),
                      
                      tags$div(id="cite",'Propuesta de estudio de la Bahía de Maldonado. Convenio PAS-DINARA.')
                      ),
             
             tabPanel("Cargar SBL", icon=icon(name="file", "fa-2x"),
                      sidebarPanel(
                        strong('Archivo de Sonar de Barrido Lateral'),
                        p('Tritech StarFish 990F'),
                        fileInput('file1', '', accept='text/csv', multiple=FALSE),
                        tags$hr(), 
                        strong('Ver datos'),
                        selectInput(inputId='extraer',label='',choices=c('GPS (lat, lon)'='gps','ECO (intensidad acústica)'='eco'), selectize=TRUE),                        
                        conditionalPanel(condition="input.extraer == 'gps'",
                                         strong('Resolución'),
                                         selectInput(inputId='res', '', choices=c('Max'=0,'1 min'=1,'2 min'=2,'3 min'=3,'4 min'=4,'5 min'=5), multiple=FALSE),
                                         tags$hr(), 
                                         strong('Exportar datos'),
                                         selectInput(inputId='exportar','', choices=c('Tabla'='tabla','Shapefile'='shapefile', 'KMZ'='kmz'), multiple=TRUE, selectize=TRUE),
                                         conditionalPanel(condition="input.exportar == 'tabla'",
                                                          strong('Nombre de tabla'),
                                                          textInput(inputId='nombre_de_archivo', label='', value='tabla-gps-sonar'),
                                                          downloadButton(outputId='action_exp_t', label="Descarga"),
                                                          tags$hr(),
                                                          helpText("Nota: se sugiere utilizar un nombre que contenga",
                                                                   "un identificador de la campaña y la fecha de la misma.")
                                         ),
                                         
                                         conditionalPanel(condition="input.exportar == 'shapefile'",
                                                          strong('Nombre de Shapefile'),
                                                          textInput(inputId='nombre_de_archivo_shp', label='', value='recorrido-sonar-sig'),
                                                          downloadButton(outputId='action_exp_s', label=""),
                                                          tags$hr(),
                                                          helpText("Nota: se sugiere utilizar un nombre que contenga",
                                                                   "un identificador de la campaña y la fecha de la misma.")
                                         ),
                                         
                                         conditionalPanel(condition="input.exportar == 'kmz'",
                                                          strong('Nombre de KMZ'),
                                                          textInput(inputId='nombre_de_archivo_kmz', label='', value='recorrido-sonar-googleearth'),
                                                          downloadButton(outputId='action_exp_k', label=""),
                                                          tags$hr(),
                                                          helpText("Nota: se sugiere utilizar un nombre que contenga",
                                                                   "un identificador de la campaña y la fecha de la misma.")
                                         ),
                                         conditionalPanel(condition="input.exportar == 'tabla' && input.exportar == 'shapefile'",
                                                          strong('Nombre de tabla'),
                                                          textInput(inputId='nombre_de_archivo', label='', value='tabla-gps-sonar'),
                                                          strong('Nombre de Shapefile'),
                                                          textInput(inputId='nombre_de_archivo_shp', label='', value='recorrido-sonar-sig'),
                                                          downloadButton(outputId='action_exp_ts', label=""),
                                                          tags$hr(),
                                                          helpText("Nota: se sugiere utilizar nombres que contengan",
                                                                   "un identificador de la campaña y la fecha de la misma.")
                                         )
                        )
                      ),
                      
                      mainPanel(
                        dataTableOutput("table")
                        )
                      ),
             
             tabPanel("Acerca de esta APP", icon=icon(name="comments", "fa-2x"),
                      sidebarPanel(
                        HTML('<div style="clear: left;"><img src="https://raw.githubusercontent.com/guzmanlopez/PAS-DINARA/master/Iconos%20y%20figuras/Logos-PAS-DINARA.png"/></div>')
                        ),
                      mainPanel(
                          tabPanel("Acerca de esta APP",
                                   h3(p(strong('Descripción'))),
                                   p(style="text-align:justify",'Esta aplicación web de R con Shiny se encuentra en desarrollo.'),
                                   p(style="text-align:justify",'Está siendo desarrollada en el marco del convenio entre la Dirección Nacional de Recursos Acuáticos (DINARA) y el Programa de Arqueología Subacuática (PAS). Esta aplicación web le permite al usuario seguir las actividades realizadas entre el PAS y la DINARA. Además brinda la posibilidad de visualizar y descargar la información almacenada en los archivos exportados en bruto del sonar de barrido lateral StarFish 990F de Tritech. También brinda la posibilidad de visualizar la información en un mapa interactivo. El objetivo de esta aplicación es generar una herramienta que permita reunir toda la información generada a través del convenio y facilitar su acceso mediante una interfaz amigable e interactiva; además de proporcionar herramientas que resulten de utilidad a los técnicos a la hora de procesar datos de sonar luego de cada campaña.'),
                                   tags$hr(),
                                   h3(p(strong('Características'))),
                                   p(style="text-align:justify",'La mayor parte del software empleado para desarrollar esta aplicación es libre, eso quiere decir que garantiza al usuario la libertad de poder usarlo, estudiarlo, compartirlo (copiarlo) y modificarlo. El software R es un proyecto de software libre que es colaborativo y tiene muchos contribuyentes.'),
                                   tags$hr(),
                                   h3(p(strong('Guía de usuario'))),
                                   HTML('<div style="clear: left;"><img src="https://raw.githubusercontent.com/guzmanlopez/Pampero/master/Figuras/PDF.png" alt="" style="width: 5%; height: 5%; float: left; margin-right:5px" /></div>'),
                                   br(),
                                   a('PAS-DINARA app', href="", target="_blank"),
                                   tags$hr(),
                                   h3(p(strong('Código fuente'))),
                                   HTML('<div style="clear: left;"><img src="https://raw.githubusercontent.com/guzmanlopez/Pampero/master/Figuras/github-10-512.png" alt="" style="width: 5%; height: 5%; float: left; margin-right:5px" /></div>'),
                                   br(),
                                   a('Repositorio GitHub', href="https://github.com/guzmanlopez/PAS-DINARA", target="_blank"),
                                   tags$hr(),
                                   h3(p(strong('Contacto'))),
                                   HTML('<div style="clear: left;"><img src="https://raw.githubusercontent.com/guzmanlopez/Pampero/master/Figuras/foto_perfil.jpg" alt="" style="float: left; margin-right:5px" /></div>'),
                                   strong('Autor'),
                                   p(a('Guzmán López', href="https://www.linkedin.com/pub/guzm%C3%A1n-l%C3%B3pez/59/230/812", target="_blank"),' - glopez@dinara.gub.uy',br(),'Biólogo | Asesor en Hidroacústica',br(),a('Laboratorio de Tecnología Pesquera - Hidroacústica (DINARA - MGAP)',href="http://www.dinara.gub.uy", target="_blank")),
                                   br()
                                   )
                          )
                      )
             )
        )                                