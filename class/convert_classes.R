## Descargar clases en html a pdf

library(pagedown)
library(here)

# Clases

pagedown::chrome_print('https://mebucca.github.io/cda_soc3070/slides/class_1/class_1#1', 
                       output = here("class", "class_1.pdf"))

pagedown::chrome_print('https://mebucca.github.io/cda_soc3070/slides/class_2/class_2#1', 
                       output = here("class", "class_2.pdf"))

pagedown::chrome_print('https://mebucca.github.io/cda_soc3070/slides/class_3/class_3#1', 
                       output = here("class", "class_3.pdf"))

pagedown::chrome_print('https://mebucca.github.io/cda_soc3070/slides/class_4/class_4#1', 
                       output = here("class", "class_4.pdf"))
