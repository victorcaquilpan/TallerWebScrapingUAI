# Instalación de librerías
# install.packages("dplyr")
# install.packages("stringr")
# install.packages("rvest")

# Carga de librerías ----
library(dplyr)   # Manejo de datos
library(stringr) # Manejo de texto
library(rvest)   # Raspado Web 


# Extraccion de organizaciones
url <- "https://datos.gob.cl/organization"

# Ingresamos
lectura_pagina <- read_html(url)


# Extraemos la informacionl nombre de organizaciones y su descripción
consulta <-lectura_pagina %>% html_elements(css = ".text-lines-7-3 , .text-lines-5-2") %>% html_text2()
consulta

# Ordenamos la informacion en vectores
nombres <- consulta[which(1:length(consulta) %% 2 == 1)] # con %% realizamos una division y nos quedamos con la parte entera sobrante (residuo)
descripcion <- consulta[which(1:length(consulta) %% 2 == 0)]

# Generamos dataframe
datos <- data.frame(nombres,descripcion)


# Podemos ver que hay muchas hojas de organizaciones. ¿Cómo podríamos obtener
# el nombre delas organizaciones disponibles en todas las hojas?

# Si exploramos un poco las páginas, podemos ver que mantenemos una misma ruta, pero
# va cambiando el numéro de página.

# Podemos ir modificando la ruta base
consulta <- read_html(str_c(url,"?page=2")) %>% html_elements(css = ".text-lines-7-3 , .text-lines-5-2") %>% 
  html_text2()

# Vemos lo que extraemos
consulta

# Extraemos la informacion de todas las páginas
pagina = 1
nombres <- c()
descripcion <- c()
consulta <- "iniciamos"

# Iniciamos el while
while (length(consulta) > 0) {
  
  # Imprimimos un mensaje en pantalla
  print(str_c("Consultando página: ",pagina))
  
  # Realizamos la consulta, en donde la página se vaya modificando
  consulta <-consulta <- read_html(str_c(url,"?page=",pagina)) %>% 
    html_elements(css = ".text-lines-7-3 , .text-lines-5-2") %>% html_text2()
    
   # Asignamos los nombres y descripcion a los vectores
   nombres  <-  append(nombres,consulta[which(1:length(consulta) %% 2 == 1)])
   descripcion <- append(descripcion,consulta[which(1:length(consulta) %% 2 == 0)])
  
  # Seguimos a la siguiente pagina
  pagina = pagina + 1
  
  # Esperamos un segundo
  Sys.sleep(1)

}

# Generamos dataframe final
datos <- data.frame(nombres,descripcion)
