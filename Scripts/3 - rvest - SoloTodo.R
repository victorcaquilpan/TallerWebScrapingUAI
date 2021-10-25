# Instalación de librerías
# install.packages("dplyr")
# install.packages("stringr")
# install.packages("rvest")

# Carga de librerías ----
library(dplyr)   # Manejo de datos
library(stringr) # Manejo de texto
library(rvest)   # Raspado Web 

# Pagina para extracción de información - PCFactory
url <- "https://www.solotodo.cl/notebooks?score_games_start=450&ordering=offer_price_usd&"

# Leemos la página 
lectura_pagina <- read_html(url)

# Extracción de información de una página ----

# Vemos que podemos extraer el nombre de los notebooks disponibles
lectura_pagina %>% 
  html_elements(css = "#category-browse-results-card h3") %>% html_text2()

# Hagamos algo más complejo y útil. Extraigamos el nombre y el precio
lectura_pagina %>% 
  html_elements(css = "#category-browse-results-card .flex-grow a , #category-browse-results-card h3") %>% 
  html_text2()

# Ahora que sabemos cómo extraer la inforamación, tenemos que ver cómo dejarla en un dataframe
datos_solotodo <- lectura_pagina %>% 
                  html_elements(css = "#category-browse-results-card .flex-grow a , #category-browse-results-card h3") %>% 
                  html_text2()

# Podemos idear alguna forma para extraer los valores impares: nombres, y pares: precios
which(1:length(datos_solotodo) %% 2 == 1)

# Creamos tabla
Notebook <- datos_solotodo[which(1:length(datos_solotodo) %% 2 == 1)]
Precio <- datos_solotodo[which(1:length(datos_solotodo) %% 2 == 0)]
Tabla <- data.frame(Notebook,Precio)

# Extracción de información de múltiples páginas ----

# Ya logramos extraer la información de una página ¿Podemos extraer la información de las demás páginas?

# Creamos un dataframe vacio
Tabla_resultado <- data.frame(Notebook = as.character(),
                              Precio = as.character())

for (pagina in 1:22) {
  
  # Seteamos la página que va a ir variando en el ciclo
  url <- str_c("https://www.solotodo.cl/notebooks?score_games_start=450&ordering=offer_price_usd&page=",pagina)
  
  # Colocamos una mensaje en pantalla
  print(str_c("Leyendo página: ",pagina))
  
  # Extraemos la información
  datos_solotodo <- read_html(url) %>% # vamos a ocupar read_html para que sea más rápido este proceso 
    html_elements(css = "#category-browse-results-card .flex-grow a , #category-browse-results-card h3") %>% 
    html_text2()
  
  # Creamos tabla
  Notebook <- datos_solotodo[which(1:length(datos_solotodo) %% 2 == 1)]
  Precio <- datos_solotodo[which(1:length(datos_solotodo) %% 2 == 0)]
  Tabla <- data.frame(Notebook,Precio)
  
  # Apendizamos nuestros datos a la tabla final
  Tabla_resultado <- rbind(Tabla_resultado,Tabla)
  
}


