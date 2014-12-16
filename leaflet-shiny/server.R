library(shiny)
library(leaflet)
# library(sp)
# library(maptools)
# library(geosphere)
library(stringr)
library(xts)

options(shiny.maxRequestSize=300*1024^2, digits=16)

# Extensión
#xmin <- -55.0853471962
#xmax <- -54.8169908485
#ymin <- -35.0635161252
#ymax <- -34.8499263791

# # Shapefiles de base
# costa <- readShapeLines(fn="/home/guzman/Shiny/SBL/shapes/linea_de_costa.shp", proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84"))
# 
# est_mejillon <- readShapePoints(fn="/home/guzman/Shiny/SBL/shapes/Estaciones-muestreo-mejillon.shp", proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84"))
# 
# isobatas <- readShapeLines(fn="/home/guzman/Shiny/SBL/shapes/isobatas-Maldonado.shp", proj4string=CRS("+proj=longlat +datum=WGS84 +ellps=WGS84"))
# 
# ##Polygon(coords=matrix(data=c(xmin,xmax,xmax,xmin,ymax,ymax,ymin,ymin),4,2, byrow = FALSE))
# ##SpatialPolygons(Srl = list())
# ##rgeos::gIntersection(isobatas, )
# 
# isobatas <- coordinates(isobatas)
# 
# n.obs <- sapply(isobatas, length)
# seq.max <- seq_len(max(n.obs))
# mat <- t(sapply(isobatas, "[", i = seq.max))
# isobatas <- as.data.frame(do.call('rbind',mat))
# colnames(isobatas) <- c("lon", "lat")
# 
# celdas_iso <- which(isobatas$lon < xmax & isobatas$lon > xmin & isobatas$lat < ymax & isobatas$lat > ymin)
# 
# isobatas <- isobatas[celdas_iso,]

densidad_ais <- rjson::fromJSON(file = "/home/guzman/Escritorio/isolineas-densidad-fondeos-BdeM.geojson")

# Establecer entorno de trabajo en carpeta temporal
setwd("/tmp/")

# Cargar entorno de trabajo
url_entorno <- "https://github.com/guzmanlopez/PAS-DINARA/blob/master/pas-dinara.RData?raw=true"
destfile <- paste(getwd(),"/pas-dinara.RData", sep="")
wd <- paste(getwd(),"/", sep="")
download.file(url = url_entorno, destfile=destfile, method = "wget")
load("pas-dinara.RData")

# Descargar javascripts y estilos 
url_binding <- "https://raw.githubusercontent.com/guzmanlopez/PAS-DINARA/master/binding.js"
download.file(url = url_binding, destfile=paste(wd,"binding.js", sep=""), method = "wget")

url_gomap <- "https://raw.githubusercontent.com/guzmanlopez/PAS-DINARA/master/gomap.js"
download.file(url = url_gomap, destfile=paste(wd,"gomap.js", sep=""), method = "wget")

url_styles <- "https://raw.githubusercontent.com/guzmanlopez/PAS-DINARA/master/styles.css"
download.file(url = url_styles, destfile=paste(wd,"styles.css", sep=""), method = "wget")

url_sig_md <- "https://raw.githubusercontent.com/guzmanlopez/PAS-DINARA/master/SIG/SIG-googlemap.Rmd"
download.file(url = url_sig_md, destfile=paste(wd,"SIG-googlemap.Rmd", sep=""), method = "wget")

shinyServer(function(input, output, session) {
  
  ### Entradas de datos ####
  datasetInput <- reactive({
    
    if (is.null(input$file1)) return(NULL) else sss <- unlist(strsplit(x=readLines(file(input$file1$datapath),n=4000,), split=","))
    return(sss)
  })
  
  ### Extraer Posiciones con resolución ###
  
  datasetInput_pos <- reactive ({
    
    if (is.null(input$file1)) return(NULL) else
    posiciones <- function(sss, exportar, nombre_archivo, res){
    
    # POSICIONES
    
    #sss = unlist(strsplit(x=sss, split=","))
    
    pos = which(sss=='POS')
    fin = length(pos)
    
    TS_P = NULL 
    for(i in 1:fin)
      TS_P[i] = sss[pos[i]+1]
    
    TS_P <- strptime(x=TS_P, format="%d/%m/%Y %H:%M:%S")
    
    LAT = NULL
    for(i in 1:fin)
      LAT[i] = sss[pos[i]+2]
    
    LON = NULL
    for(i in 1:fin)
      LON[i] = sss[pos[i]+3]
    
    NOR = NULL
    for(i in 1:fin)
      NOR[i] = sss[pos[i]+5]
    
    EST = NULL
    for(i in 1:fin)
      EST[i] = sss[pos[i]+6]
    
    # Data frame
    df_pos = data.frame(Tiempo=TS_P, LAT=as.numeric(LAT), LON=as.numeric(LON), UTM_N=as.numeric(NOR), UTM_E=as.numeric(EST))
    
    # Sacar datos repetidos (mismo tiempo)
    df_pos = df_pos[-which(duplicated(df_pos$Tiempo)),]
    
    # Convertir a xts
    df_pos = as.xts(df_pos, order.by=df_pos$Tiempo)
    
    # Agrupar por tiempo
    if(res != 0)  {
      
      df_pos = split.xts(df_pos, f='minutes', k=res)  
      
      df = matrix(ncol=5, nrow=length(df_pos))
      for(i in 1:length(df_pos))
        df[i,] = as.vector(df_pos[[i]][1,])
      
      df = as.data.frame(df)
      df_pos = data.frame("Tiempo"=as.character(df$V1), "LAT"=as.character(df$V2), "LON"=as.character(df$V3), "UTM_N"=as.character(df$V4), "UTM_E"=as.character(df$V5))    
      
      # Exportar
      if(exportar == 'si') write.table(df_pos, paste(wd,nombre_archivo,".csv", sep=""), sep=",", row.names=FALSE) & return(df_pos)
      
      if(exportar == 'no') return(df_pos)
      
    }
    if(res == 0)  {
      
      df_pos = as.data.frame(df_pos)
      
      # Exportar
      if(exportar == 'si') write.table(df_pos, paste(wd,nombre_archivo,".csv", sep=""), sep=",", row.names=FALSE) & return(df_pos)
      
      if(exportar == 'no') return(df_pos)
      
    }
    
  }
  
  if(is.null(input$exportar)) exp <- 'no' else exp <- 'si'
  
  sss_pos <- posiciones(sss=datasetInput(), exportar=exp, nombre_archivo=input$nombre_de_archivo, res=input$res)
  
  return(sss_pos)
  
  })
  
  ### Tabla ####
  output$table <- renderDataTable({
    datasetInput_pos()
  })
  
  ### SIG
  
  ### Interactive Map ####
  
  # Crear mapa
  map <- createLeafletMap(session, "map")
  
  # Capas:
  
  capas <- observe({
    
    # Estaciones mejillón:
    
    if(length(input$capas)==0) {
      
      map$clearShapes()
      return(NULL)
    }
    
    if(length(input$capas)!=0) {
      
      map$clearShapes()
      
      # Estaciones de mejillón
      if(length(which(input$capas=='est_mej'))!=0) {
                
        map$addCircle(
          lat=est_mejillon$dd.lat,
          lng=est_mejillon$dd.lon,
          radius=10000/max(12, input$map_zoom)^2,
          layerId=as.character(est_mejillon$est),
          list(weight = 1,                      # stroke weight
               fill = TRUE,                     # fill object
               color = '#808080',               # stroke color, grey
               opacity = 1,                     # stroke opacity
               fillColor = 'black',             # fill color
               fillOpacity = 1,                 # fill opacity
               clickable = T)
        )
      }
                  
      # Densidad AIS fondeos
      if(length(which(input$capas=='dens_ais'))!=0) {
              
#         map$addPolyline(
#           lat=isobatas$lat,
#           lng=isobatas$lon,
#           as.character(1),
#           list(color= '#808080',
#                weight=2,
#                opacity=1,
#                lineJoin='round', clickeable=T)
#         )
        
        
          map$addGeoJSON(densidad_ais)
                
      }
    }
})
  

  
  })