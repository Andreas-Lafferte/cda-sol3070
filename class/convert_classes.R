## Descargar clases en html a pdf

library(servr)
library(pagedown)
library(here)
install.packages("psycModel")
library(psycModel)
# Clases



# install.packages("remotes")
remotes::install_github("jhelvy/renderthis", force = T)

library(renderthis)

to_pdf(from = "https://jhelvy.github.io/renderthis/example/slides.html")

html_to_pdf(file_path = 'https://mebucca.github.io/cda_soc3070/slides/class_5/class_5#1',
            dir = here("class", "class_5.pdf"), scale = 1, render_exist = FALSE)

pagedown::chrome_print('https://mebucca.github.io/cda_soc3070/slides/class_1/class_1#1', 
                       output = here("class", "class_1.pdf"))

pagedown::chrome_print('https://mebucca.github.io/cda_soc3070/slides/class_2/class_2#1', 
                       output = here("class", "class_2.pdf"))

pagedown::chrome_print('https://mebucca.github.io/cda_soc3070/slides/class_3/class_3#1', 
                       output = here("class", "class_3.pdf"))

pagedown::chrome_print('https://mebucca.github.io/cda_soc3070/slides/class_4/class_4#1', 
                       output = here("class", "class_4.pdf"))

pagedown::chrome_print('https://mebucca.github.io/cda_soc3070/slides/class_5/class_5#1', 
                       output = here("class", "class_5.pdf"))

pagedown::chrome_print('https://mebucca.github.io/cda_soc3070/slides/class_6/class_6#1', 
                       output = here("class", "class_6.pdf"))

pagedown::chrome_print('https://mebucca.github.io/cda_soc3070/slides/class_7/class_7#1', 
                       output = here("class", "class_7.pdf"))

pagedown::chrome_print('https://mebucca.github.io/cda_soc3070/slides/class_8/class_8#1', 
                       output = here("class", "class_8.pdf"))

pagedown::chrome_print('https://mebucca.github.io/cda_soc3070/slides/class_9/class_9#1', 
                       output = here("class", "class_9.pdf"))

pagedown::chrome_print('https://mebucca.github.io/cda_soc3070/slides/class_10/class_10#1', 
                       output = here("class", "class_10.pdf"))