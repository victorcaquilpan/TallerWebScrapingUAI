# Instalación de librerías
# install.packages("dplyr")
# install.packages("stringr")
# install.packages("rvest")

#Carga de librerías
library(dplyr)
library(stringr)
library(rvest)

# Extracción de información de una página -----

# Consultamos página del centro sismológico nacional
url_ultimos_sismos <- "http://www.sismologia.cl/ultimos_sismos.html"

# Extraemos la tabla
tabla_sismos <- read_html(url_ultimos_sismos) %>% 
  html_element(css = "#main > table:nth-child(3)") %>% 
  html_table()

# Podemos consultar sismos de distintas fechas
url_sismosdia <- "http://www.sismologia.cl/catalogo/2021/10/20211027.html"

# Extraigamos la tabla del día
tabla_dia <- read_html(url_sismosdia) %>% 
  html_element(css = "#main > table:nth-child(5)") %>% 
  html_table()

# Identificamos un patrón en la url

# Intentemos descargar los sismos del mes de enero 2021 ----

# Creamos una url base
url_base_sismos <- "http://www.sismologia.cl/catalogo/2021/01/"

# Modificamos los primeros valores para que tengan un cero al principio
dias_enero <- as.character(seq(1,31))
dias_enero[1:9] <- str_c("0",dias_enero[1:9])
# Modificacion final
dias_enero <- str_c("202101",dias_enero)

# Creamos dataframe vacío para guardar los valores
sismos <- data.frame()


# Realizamos consulta
for (dias in seq_along(dias_enero)) {
  
  # Imprimamos el día en el que vamos
  print(str_c("Consultando dia: ",dias))
  
  # Consulta diaria
  tabla_dia <- read_html(str_c(url_base_sismos,dias_enero[dias],".html")) %>% 
    html_element(css = "#main > table:nth-child(5)") %>% 
    html_table()
  
  # Vamos agregando la información en el dataframe  resultante
  sismos <- rbind(sismos,tabla_dia)
  
}

# Vemos el dataframe resultante