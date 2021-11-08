# Instalación de librerías
# install.packages("dplyr")
# install.packages("stringr")
# install.packages("rvest")
# install.packages("RSelenium")

# Carga de librerías ----
library(dplyr)     # Manejo de datos
library(stringr)   # Manejo de texto
library(rvest)     # Raspado Web
library(RSelenium) # Raspado Web

# Extraccion de organizaciones
url <- "https://www.bcn.cl/historiapolitica/partidos_politicos/index.html"

# Iniciamos servidor
driver <-  rsDriver(port = 4571L, 
         browser = "chrome",
         chromever = "94.0.4606.41") 

# Separamos el cliente/servidor
navegador <- driver$client
servidor <- driver$server

# Ingresamos a la pagina de interes
navegador$navigate(url = url)

# Extraer informacion de un caso ----

# Vamos al selector de partidos
selector_partidos <- navegador$findElement(using = "css",value = "#lista_partidos")

# Hacemos click
selector_partidos$clickElement()

# Ahora elegimos partido
partidos <- navegador$findElement(using = "css",value = "#lista_partidos > option:nth-child(2)")
partidos$clickElement()

# Extraemos la fecha de fundacion
fecha_fundacion <- navegador$findElement(using = "css",value = "#ficha_partido > tbody > tr:nth-child(2) > td:nth-child(2) > span")

# Nos devuelve la fecha
fecha_fundacion$getElementText() %>% as.character()

# Además tenemos que saber a que partido corresponde dicha fecha
partido <- navegador$findElement(using = "css",value = "#ficha_partido > tbody > tr:nth-child(2) > td > b")

# Vemos el partido
partido$getElementText() %>% as.character()

# Nos devolvemos a la página anterior
navegador$goBack()

# Sabiendo esto, podemos hacer un ciclo para ir obteniendo la información del año en que  inicio cada partido

# Extraer informacion de varios casos (error) ----

# Ingresamos a la pagina de interes
navegador$navigate(url = url)

# Creamos vectores para ingresar la informacion
nombre_partido <- c()
fecha_partido <- c()
partido_n <- 1

# Sabiendo que si una opcion no existe, esto me genera  un error, puedo crear un bucle
while(partido_n < 31) {
  
  # Enviamos mensaje
  message("Consultando partido n: ",partido_n)
  
  # Vamos al selector de partidos
  selector_partidos <- navegador$findElement(using = "css",value = "#lista_partidos")
  
  # Podemos hacer clikc
  selector_partidos$clickElement()
  
  # Seleccionamos el partido actual
  selector_css_partido <- str_c("#lista_partidos > option:nth-child(",1+partido_n,")")
  
  # Ahora elegimos partido
  partidos <- navegador$findElement(using = "css",value = selector_css_partido)
  partidos$clickElement()
  
  # Además tenemos que saber a que partido corresponde dicha fecha
  partido <- navegador$findElement(using = "css",value = "#ficha_partido > tbody > tr:nth-child(1) > td > b")
  
  # Vemos el partido
  nombre_partido <- append(nombre_partido, partido$getElementText() %>% as.character())
  
  # Extraemos la fecha de fundacion
  fecha_fundacion <- navegador$findElement(using = "css",value = "#ficha_partido > tbody > tr:nth-child(2) > td:nth-child(2) > span")
  
  # Nos devuelve la fecha
  fecha_partido <- append(fecha_partido,fecha_fundacion$getElementText() %>% as.character())

  
  # Nos devolvemos a la página anterior
  navegador$goBack()
  
  # Esperamos un momento
  Sys.sleep(1)
  
  # Consultamos el siguiente partido
  partido_n <- partido_n + 1
  
}

# Bajo este enfoque hay un problema, ya que la fecha no siempre se ubica donde mismo

#Extraer informacion de varios casos (Ok) ----

# Ingresamos nuevamente a la pagina de interes 
navegador$navigate(url = url)

# Creamos vectores para ingresar la informacion
nombre_partido <- c()
fecha_partido <- c()
partido_n <- 1

# Sabiendo que si una opcion no existe, esto me genera  un error, puedo crear un ciclo en donde se lea un texto que cumpla una condición
while(partido_n < 31) {
  
  # Enviamos mensaje
  message("Consultando partido n: ",partido_n)
  
  # Vamos al selector de partidos
  selector_partidos <- navegador$findElement(using = "css",value = "#lista_partidos")
  
  # Podemos hacer clikc
  selector_partidos$clickElement()
  
  selector_css_partido <- str_c("#lista_partidos > option:nth-child(",1+partido_n,")")
  
  # Ahora elegimos partido
  partidos <- navegador$findElement(using = "css",value = selector_css_partido)
  partidos$clickElement()
  
  # Extraemos la tabla
  table <- navegador$getPageSource()[[1]] %>% 
    read_html() %>% 
    html_element(css = "#ficha_partido > tbody") %>% html_table()

  # En el caso de que una pagina no traiga fecha de fundacion, que me entregue un NA
  fecha_fundacion <- table$X2[table$X1 == "Fecha de fundación"]
  if (length(fecha_fundacion) == 0) {fecha_fundacion <- NA_character_}
  
  # Ingresamos esto a los vectores
  nombre_partido <- append(nombre_partido,table$X1[1]) 
  fecha_partido <- append(fecha_partido,fecha_fundacion)
  
  # Nos devolvemos a la página anterior
  navegador$goBack()
  
  # Esperamos un momento
  Sys.sleep(1)
  
  # Consultamos el siguiente partido
  partido_n <- partido_n+ 1
  
}

# Creamos dataframe
datos <- data.frame(nombre_partido,fecha_partido)

# Cerramos navegador y servidor
navegador$close()
system(paste0("Taskkill /F /T" ," /PID ", driver$server$process$get_pid()))
