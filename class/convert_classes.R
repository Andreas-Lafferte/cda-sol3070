## Descargar clases en html a pdf

library(pagedown)
library(here)

# Clase 1

pagedown::chrome_print('https://mebucca.github.io/cda_soc3070/slides/class_1/class_1#1', 
                       output = here("class", "class_1.pdf"))
