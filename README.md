PAS - DINARA
===

Esta aplicación web de R con Shiny le permite al usuario visualizar y descargar la información almacenada en los archivos exportados en bruto del sonar de barrido lateral StarFish 990F de Tritech. 

Está aplicación está siendo desarrollada en el marco del convenio entre la Dirección Nacional de Recursos Acuáticos (DINARA) y el Programa de Arqueología Subacuática (PAS).

El objetivo es generar una herramienta que permita a los usuarios acceder fácil y rapidamente a los datos del sonar de barrido lateral luego de cada campaña.

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
runGitHub('PAS-DINARA', 'guzmanlopez')
```

Capturas de pantalla
===

Bitácora:
![Image](https://raw.githubusercontent.com/guzmanlopez/PAS-DINARA/master/Iconos y figuras/captura-de-pantalla-01.png)

Seguimiento de actividades:
![Image](https://raw.githubusercontent.com/guzmanlopez/PAS-DINARA/master/Iconos y figuras/captura-de-pantalla-02.png)

SIG:
![Image](https://raw.githubusercontent.com/guzmanlopez/PAS-DINARA/master/Iconos y figuras/captura-de-pantalla-03.png)

Cargar datos:
![Image](https://raw.githubusercontent.com/guzmanlopez/PAS-DINARA/master/Iconos y figuras/captura-de-pantalla-04.png)

Acerca de la app:
![Image](https://raw.githubusercontent.com/guzmanlopez/PAS-DINARA/master/Iconos y figuras/captura-de-pantalla-05.png)
