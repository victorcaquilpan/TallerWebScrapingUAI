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

# Vamos a ingresar a la página de Inaturalist
url <- "https://www.inaturalist.org/observations"

# Iniciamos servidor
driver <-  rsDriver(port = 4571L, 
                    browser = "chrome",
                    chromever = "94.0.4606.41") 

# Separamos el cliente/servidor
navegador <- driver$client
servidor <- driver$server

# Ingresamos a la pagina de interes
navegador$navigate(url = url)

# Analizando caso individual ----

# Supongamos que queremos buscar tres especies de aves en Chile. Martin pescador de collar, Zorzal Patagónico y Pato jergon

# Primero ingresamos la información de búsqueda
ingreso_especie <- navegador$findElement(using = "name",value = "taxon_name")
ingreso_especie$highlightElement()
ingreso_especie$sendKeysToElement(list("Martin pescador de Collar"))
chequeo_especie <- navegador$findElement(using = "css",value = "#ui-id-2")
chequeo_especie$clickElement()

# Ahora ingresamos el país
ingreso_lugar <- navegador$findElement(using = "name",value = "primary_q2")
ingreso_lugar$sendKeysToElement(list("Chile",key = "enter"))

# Seleccionamos el cuerpo, podemos aplicar algunas opciones
cuerpo <- navegador$findElement("css", "body")

# Bajamos la página para visualizar las demás imagenes
cuerpo$sendKeysToElement(list(key = "page_down"))

# Vamos a la primera imagen
imagen1 <- navegador$findElement(using = "css",value = "#result-grid > div > div:nth-child(1) > div > a")

# Obtenemos el enlace de la imagen
imagen1$getElementAttribute(attrName = "style")

# Nos quedamos solo con la parte del enlace
enlace_martin <- imagen1$getElementAttribute(attrName = "style")[[1]]
enlace_martin <- str_extract(enlace_martin,pattern = 'https:.*')

# Descargamos imagen con download.file
download.file(url = enlace_martin,destfile = "martin1.jpg",mode = "wb")

# Podemos hacer lo mismo para las demás imagenes
inaturalist <- navegador$getPageSource()[[1]] %>% read_html()
enlaces_martines <- inaturalist %>% html_elements(css = ".has-photo") %>% html_attr(name = "style")
enlaces_martines <- str_extract(enlaces_martines,pattern = 'https:.*')

# Creamos un ciclo para descargar
for (archivo in 1:10) { # descargamos las primeras 10 imagenes
  
  download.file(enlaces_martines[archivo],destfile = str_c(archivo,"_martin.jpg"),mode = "wb")
  
}

# Analizando varios casos ----

# Podemos repetir este mismo proceso para las demás especies. El siguiente segmento de código realiza todo el proceso en conjunto
especies <- c("Martin pescador de Collar","Zorzal Patagónico","Pato jergon")

# Creamos un ciclo for
for (especie in 1:length(especies)) {

  # Ingresamos a la pagina de interes
  navegador$navigate(url = url)  
  
  # Esperamos unos segundos a que cargue página
  Sys.sleep(3)

  # Primero ingresamos la información de búsqueda
  ingreso_especie <- navegador$findElement(using = "name",value = "taxon_name")
  ingreso_especie$sendKeysToElement(list(especies[especie]))
  # Esperamos un par de segundos
  Sys.sleep(2)
  chequeo_especie <- navegador$findElement(using = "css",value = "#ui-id-2")
  chequeo_especie$clickElement()
  
  # Ahora ingresamos el país
  ingreso_lugar <- navegador$findElement(using = "name",value = "primary_q2")
  ingreso_lugar$sendKeysToElement(list("Chile",key = "enter"))
  
  # Esperemos unos segundos 
  Sys.sleep(3)
  
  # Creamos los objetos resultantes
  assign(str_c("enlaces",especies[especie]),
         value = navegador$getPageSource()[[1]] %>% 
           read_html() %>% 
           html_elements(css = ".has-photo") %>% 
           html_attr(name = "style") %>%
           str_extract(pattern = 'https:.*')) 
  
  # Generamos una pausa
  Sys.sleep(2)
  
}

# Podemos chequear los objetos creados con los respectivos enlaces

# Cerramos navegador y servidor
navegador$close()
system(paste0("Taskkill /F /T" ," /PID ", driver$server$process$get_pid()))
