# Instalación de librerías
# install.packages("dplyr")
# install.packages("rvest")
# install.packages("RSelenium")

# Carga de librerías ----
library(dplyr)      # Manejo de datos
library(rvest)      # Raspado Web 
library(RSelenium)  # Raspado Web

# Abrir navegador con RSelenium ----

# Extraccion de organizaciones
url <- "https://www.google.com/"

# Podemos chequear versiones disponibles
binman::list_versions("chromedriver")

# Iniciamos servidor
driver <-  rsDriver(port = 4567L, 
         browser = "chrome",
         chromever = "94.0.4606.41") 

# Separamos el cliente/servidor
navegador <- driver$client
servidor <- driver$server

# Ingresamos a la pagina de interes
navegador$navigate(url = url)

# AQUI PODEMOS HACER MUCHAS COSAS

# Cerramos navegador y eliminamos el proceso que hay por detrás de la conexión
navegador$close()
system(paste0("Taskkill /F /T" ," /PID ", driver$server$process$get_pid()))
# Si cerramos el navegador y el servidor, tenemos que volver a crear una instancia

# Iniciamos servidor
driver <-  rsDriver(port = 4567L, 
                    browser = "chrome",
                    chromever = "94.0.4606.41") 

# Separamos el cliente/servidor
navegador <- driver$client
servidor <- driver$server

# Ingresamos a la pagina de interes
navegador$navigate(url = url)

# Explorando algunas funciones ----

# Podemos obtener la página en la cual actualmente estamos
navegador$getCurrentUrl()

# Podemos obtener el título de la página
navegador$getTitle()

# Podemos obtener el código fuente (para ocuparlo directamente con read_html)
navegador$getPageSource()[[1]] %>% read_html()

# Podemos identificar elementos con CSS selector
buscador <- navegador$findElement(using = "css",value = "body > div.L3eUgb > div.o3j99.ikrT4e.om7nvf > form > div:nth-child(1) > div.A8SBwf > div.RNNXgb > div > div.a4bIc > input")

# Podemos aplicar varias funciones sobre el elemento creado

# Podemos destacarlo
buscador$highlightElement()

# Tambien podemos utilizar lo que nos arroja SelectorGadget
buscador <- navegador$findElement(using = "css",value =".gLFyf.gsfi")

# Podemos destacarlo
buscador$highlightElement()

# Podemos extraer información de sus atributos
buscador$getElementAttribute(attrName = "name")
buscador$getElementAttribute(attrName = "title")  

# Podemos ingresar datos
buscador$sendKeysToElement(list("RStudio",key = "enter"))

# Podemos movernos a la página anterior
navegador$goBack()

# Podemos volver a la siguientes
navegador$goForward()

# Ahora podemos obtener el titulo de esta página
navegador$getTitle()

# Podemos ir a uno de los resultados
resultados <- navegador$findElement(using = "css",value = ".yuRUbf , .NsiYH")

# Podemos obtener el texto de un elemento con getElementText
resultados$getElementText()

# Con getElementText podemos acceder a todos los elementos
resultados <- navegador$findElements(using = "css",value = ".yuRUbf , .NsiYH")

# Podemos ver el texto de cada resultado de la lista
resultados[[1]]$getElementText()
resultados[[6]]$getElementText()
resultados[[7]]$getElementText()
resultados[[8]]$getElementText()

# Podemos hacer click a uno de los elementos
resultados[[1]]$clickElement()

# Volvamos a la página anterior
navegador$goBack()

# Vamos a ingresar otra busqueda. Primero limpiamos

# Identificamos elemento de buscador
buscador2 <- navegador$findElement(using = "name",value = "q")
                                                         
# Borramos el texto ingresado anteriormente
buscador2$clearElement()

# Ingresamos nueva busqueda
buscador2$sendKeysToElement(list("Ministerio Medio Ambiente",key = "enter"))

# Vamos al primer resultado
pag_mma <- navegador$findElement(using = "css",value = "#rso > div:nth-child(1) > div > div > div > div > div > div > div.yuRUbf > a > h3")

# Ingresamos a la pagina
pag_mma$clickElement()

# Vamos a la imagen que dice "Educacion en casa"
educacion <- navegador$findElement(using = "css",value = "#panel-14-0-1-1 > div > div > div > p > a > img")

# Hagamos click en el elemento seleccionado
educacion$clickElement()

# Se abrió otra ventana. ¿Cómo podemos enviar instrucciones a ella?
navegador$getTitle()

# Podemos obtener un identificador de nuestra actual ventana
navegador$getCurrentWindowHandle()

# Podemos ver también todas las ventanas disponibles
navegador$getWindowHandles()

# Un problema en las ultimas versiones de Chrome dificulta el cambio de ventanas
# pero se puede utilizar la siguiente funcion
cambio_ventana <- function (navegador, ventanaId) {
  qpath <- sprintf("%s/session/%s/window", navegador$serverURL, 
           navegador$sessionInfo[["id"]])
  navegador$queryRD(qpath, "POST", qdata = list(handle = ventanaId))}

# Utilizamos la funcion para cambiar a la segunda ventana
cambio_ventana(navegador, navegador$getWindowHandles()[[2]])

# Consultamos de nuevo el titulo de la página para chequear
navegador$getTitle()

# Seleccionamos la tabla
Tabla <- navegador$findElement(using = "css",value = "#panel-7705-0-1-0 > div > div > div > table")

# Extraemos la información de la tabla
Tabla$getElementText()

# Podriamos utilizar rvest para obtener la tabla más facilmente
Tabla_talleres <- navegador$getPageSource()[[1]] %>% 
  read_html() %>% 
  html_element(css = "#panel-7705-0-1-0 > div > div > div > table") %>% 
  html_table()

# Cerramos navegador y servidor
navegador$close()
system(paste0("Taskkill /F /T" ," /PID ", driver$server$process$get_pid()))
