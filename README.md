PAS - DINARA
===

Esta aplicación web de R con Shiny se encuentra en desarrollo.

Está siendo desarrollada en el marco del convenio entre la Dirección Nacional de Recursos Acuáticos (DINARA) y el Programa de Arqueología Subacuática (PAS). Esta aplicación web le permite al usuario seguir las actividades realizadas entre el PAS y la DINARA. Además brinda la posibilidad de visualizar y descargar la información almacenada en los archivos exportados en bruto del sonar de barrido lateral StarFish 990F de Tritech. También brinda la posibilidad de visualizar la información en un mapa interactivo. El objetivo de esta aplicación es generar una herramienta que permita reunir toda la información generada a través del convenio y facilitar su acceso mediante una interfaz amigable e interactiva; además de proporcionar herramientas que resulten de utilidad a los técnicos a la hora de procesar datos de sonar luego de cada campaña.

Requisitos
===

```R
library('shiny')
library('devtools')
devtools::install_github('leaflet-shiny', 'jcheng5')
library('leaflet')
library('sp')
library('maptools')
library('geosphere')
library('stringr')
library('xts')
```
Para ejecutar la aplicación desde R:
===

```R
shiny::runGitHub('PAS-DINARA', 'guzmanlopez')
```

Capturas de pantalla
===

Bitácora:
![Image](https://raw.githubusercontent.com/guzmanlopez/PAS-DINARA/master/Data/img/Screenshots/Captura-de-pantalla-01.png)

Seguimiento de actividades:
![Image](https://raw.githubusercontent.com/guzmanlopez/PAS-DINARA/master/Data/img/Screenshots/Captura-de-pantalla-02.png)

SIG:
![Image](https://raw.githubusercontent.com/guzmanlopez/PAS-DINARA/master/Data/img/Screenshots/Captura-de-pantalla-03.png)

Cargar datos:
![Image](https://raw.githubusercontent.com/guzmanlopez/PAS-DINARA/master/Data/img/Screenshots/Captura-de-pantalla-04.png)

Acerca de la app:
![Image](https://raw.githubusercontent.com/guzmanlopez/PAS-DINARA/master/Data/img/Screenshots/Captura-de-pantalla-05.png)
