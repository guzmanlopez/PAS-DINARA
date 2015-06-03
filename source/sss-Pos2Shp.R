### Export positions from Tritech StarFish SideScanSonar to line shapefile (.shp)
### Input: output from sssExtractGPS
### Output: line shapefile (.shp)

export.line.shp <- function(posiciones, nombre_transecta){
  
  # Crear lineas
  
  posiciones[,2] <- as.numeric(as.character(posiciones$LAT))
  posiciones[,3] <- as.numeric(as.character(posiciones$LON))
  posiciones[,4] <- as.numeric(as.character(posiciones$UTM_N))
  posiciones[,5] <- as.numeric(as.character(posiciones$UTM_E))
  
  # Matriz de posiciones
  lista_transecta = list()
  for(i in 1:(nrow(posiciones)-1))
    lista_transecta[[i]] = cbind(c(posiciones[i,3],posiciones[i+1,3]),c(posiciones[i,2],posiciones[i+1,2]))
  
  # Líneas entre puntos adyacentes
  lista_lineas_transecta = list()
  for(i in 1:(nrow(posiciones)-1))
    lista_lineas_transecta[[i]] = Line(coords=lista_transecta[[i]])
  
  # Distancias de líneas entre puntos
  lista_dist_transecta = list()
  for(i in 1:(nrow(posiciones)-1))
    lista_dist_transecta[[i]] = LineLength(cc=lista_lineas_transecta[[i]],longlat=TRUE)
  # Pasar de kilómetros a metros
  lista_dist_transecta = unlist(lista_dist_transecta)*1000
  
  # Cortar segmentos si: dist > 50 metros
  #if(length(which(lista_dist_transecta > 50))==0) lista_lineas_transecta <- lista_lineas_transecta else
    #lista_lineas_transecta <- lista_lineas_transecta[-which(lista_dist_transecta > 50)]
  
  lista_transecta = Lines(slinelist=lista_lineas_transecta, ID=paste(nombre_transecta))
  
  lineas_posiciones = SpatialLines(LinesList=list(lista_transecta), proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs"))
  
  lineas_posiciones = SpatialLinesDataFrame(sl=lineas_posiciones, data=data.frame(ID=paste(nombre_transecta,sep="")), match.ID=FALSE)
  
  return(writeLinesShape(x=lineas_posiciones, fn=paste("/home/guzman/Documentos/DINARA/SIG/Mejillon/Capas vectoriales/", nombre_transecta, sep="")
                         )
         )
}
