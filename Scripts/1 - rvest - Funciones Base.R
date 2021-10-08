# Instalación de librerías
# install.packages("dplyr")
# install.packages("stringr")
# install.packages("robotstxt")
# install.packages("rvest")

# Carga de librerías ----
library(dplyr)     # Manejo de datos
library(stringr)   # Manejo de texto
library(robotstxt) # Consulta a protocolo robots.txt
library(rvest)     # Raspado Web 

# Introducción a rvest ----

# Seleccionamos una URL
url <- "https://www.bcn.cl/siit/reportescomunales/comunas_v.html?anno=2021&idcom=11201"

# Leemos con rvest todos los elementos de etiqueta a
read_html(url) %>% 
  html_elements(css = "p") %>% 
  html_text()

# Leemos con rvest, pero ahora obtenemos solo el valor de superficie de la comuna
read_html(url) %>% 
  html_element(css = "tr:nth-child(1) .font-weight-bold+ td") %>% 
  html_text()

# hora vamos a obtener el gentilicio
read_html(url) %>% 
  html_element(css = "tr:nth-child(2) .font-weight-bold+ td") %>% 
  html_text()

# Utilicemos html_element cuando tenemos una selección de varios elementos
read_html(url) %>% 
  html_element(css = ".font-weight-bold+ td") %>%
  html_text()

# Ahora provemos con html_elements
read_html(url) %>% 
  html_elements(css = ".font-weight-bold+ td") %>%
  html_text()

# Podemos pasar una tabla directamente a un dataframe con html_table
tabla <- read_html(url) %>% 
  html_element(css = "#contenido > section.tabla > div > div > div.col-md-8 > table") %>% 
  html_table()

# Vemos la tabla resultante
tabla

# Podemos extraer atributos con html_attr
read_html(url) %>% 
  html_element(css = "#contenido > section.tabla > div > div > div.col-md-8 > table") %>% 
  html_attr("class")

# Utilizando html_name podemos extraer el nombre de un elemento
read_html(url) %>% 
  html_element(css = "#contenido > section.tabla > div > div > div.col-md-8 > table") %>% 
  html_name()

# También podemos extraer enlaces disponibles en las páginas Web

# Vamos a revisar una nueva url
url_coberturas <- "https://www.bcn.cl/siit/mapas_vectoriales/index_html"

# Vamos a extraer un enlace de descarga
read_html(url_coberturas) %>% 
  html_element(css = "div.flex-grid-item:nth-child(1) > a:nth-child(1)") %>% 
  html_attr("href")

# En ocasiones tendremos que ingresar a los elementos anidados para conseguir la información necesaria.

url_coberturas <- "https://www.bcn.cl/siit/mapas_vectoriales/index_html"

# Vamos a extraer los enlaces de descarga de las coberturas disponibles 
objetos <- read_html(url_coberturas) %>% 
  html_element(css = ".flex-grid") %>% 
  html_children() %>% 
  html_children() %>% 
  html_attr("href")

# Vemos la lista de enlaces
objetos

# Podemos utilizar una función de descarga
for (descarga in 1:2) { # Aquí puedo setear length(objetos) para descargar todos los objetos
  
  # Realizamos la descarga
  download.file(url = objetos[descarga],
                destfile = str_c(descarga,".zip"))
  
}

# Raspado ético ----

# Revisamos si se nos permite ingresar
paths_allowed(domain = "https://www.bcn.cl/portal/")

# Luego, podemos leer la página sin problemas
read_html("https://www.bcn.cl/portal/")
