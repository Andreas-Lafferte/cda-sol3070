#*******************************************************************************************************************
#
# 0. Identification ---------------------------------------------------
# Title: Data preparation and analysis for CDA 
# Overview: Preparation and analysis of the CASEN data        
# Date: 26-11-2024            
#
#******************************************************************************************************************

# 1. Packages ---------------------------------------------------------
if (!require("pacman")) install.packages("pacman")

pacman::p_load(tidyverse,
               sjlabelled, 
               sjmisc, 
               sjPlot,
               here,
               naniar,
               haven,
               survey,
               srvyr,
               texreg,
               stargazer,
               modelr,
               ggdist)

options(scipen=999)
rm(list = ls())

# 2. Data --------------------------------------------------------------

base <- haven::read_sav(file = here("input/data/Base de datos Casen 2022 SPSS_18 marzo 2024.sav"))

names(base)
glimpse(base)

# 3. Processing -----------------------------------------------------------

base_proc <- base %>% 
  
  # 3.1 Select ----

  dplyr::select(1:3, nse, estrato, hogar, nucleo, expr, varstrat, varunit, sexo, genero,
         edad, os1, educ, s16, s17, disc_wg, depen_grado, dau, lugar_nac) %>% 
  
  # 3.2 Filtrar ----

  filter(edad >= 18) %>%  #Filtro edad

  # 3.3 Transformar ----

  mutate(
    asistencia = case_when(
      s17 == 1 ~ 1,               # "Sí" se recodifica como 1
      s17 == 2 ~ 0,               # "No" se recodifica como 0
    TRUE ~ NA_real_),             # Todo lo demás se convierte en NA
    lgbt = case_when(
      os1 %in% c(2,3,4) | genero %in% c(3,4,5,6) ~ "LGBT",  # Incluye trans
      os1 %in% c(1) & genero %in% c(1, 2) ~ "No LGBT",  # Hetero-cis
      TRUE ~ NA_character_),
    lgbt = factor(lgbt,
                  levels = c("No LGBT",
                             "LGBT")),
    n_educ = case_when(educ == 0 ~ "Sin Educ. Formal",
                       educ == 1 ~ "Básica Incompleta",
                       educ == 2 ~ "Básica Completa",
                       educ %in% c(3,4) ~ "Media Incompleta",
                       educ %in% c(5,6) ~ "Media Completa",
                       educ %in% c(7,9) ~ "Superior Incompleta",
                       educ %in% c(8,10,11,12) ~ "Superior Completa",
                       TRUE ~ NA_character_),
    n_educ = factor(n_educ,
                    levels = c("Sin Educ. Formal",
                               "Básica Incompleta",
                               "Básica Completa",
                               "Media Incompleta",
                               "Media Completa",
                               "Superior Incompleta",
                               "Superior Completa")),
    disc_wg = case_when(disc_wg == 0 ~ "Sin discapacidad", 
                        disc_wg == 1 ~ "Con discapacidad",
                        TRUE ~ NA_character_),
    disc_wg = factor(disc_wg,
                     levels = c("Sin discapacidad", 
                                "Con discapacidad")),
    depen_grado = case_when(
      depen_grado == 0 ~ "No dependiente",
      depen_grado == 1 ~ "Dependencia severa",
      depen_grado == 2 ~ "Dependencia moderada",
      depen_grado == 3 ~ "Dependencia leve",
      TRUE ~ NA_character_),
    depen_grado = factor(depen_grado,
                         levels = c("No dependiente",
                                    "Dependencia leve",
                                    "Dependencia moderada",
                                    "Dependencia severa")),
    nacionalidad = if_else(lugar_nac == 0, "Chileno", "No chileno"),
    nacionalidad = factor(nacionalidad,
                       levels = c("Chileno", "No chileno")),
    sexo = case_when(
      sexo == 1 ~ "Hombre",       
      sexo == 2 ~ "Mujer",        
      TRUE ~ NA_character_),      
    sexo = factor(sexo,
                  levels = c("Hombre", "Mujer"))    
    
)
  

base_proc <- base_proc %>% 
  dplyr::select(asistencia, 
         lgbt,
         disc_wg, 
         depen_grado,
         n_educ,
         edad,
         dau,
         nacionalidad,
         sexo,
         expr)


colSums(is.na(base_proc))

miss_var_summary(base_proc)

base_proc <- na.omit(base_proc)

save(base_proc, file = here("output/base_proc.RData"))


# 4. Analysis -------------------------------------------------------------


m1 <- glm(asistencia ~ 1 + lgbt, family = binomial(link = "logit"), 
          data = base_proc) 

m2 <- glm(asistencia ~ 1 + lgbt + n_educ, family = binomial(link = "logit"), 
          data = base_proc) 

m3 <- glm(asistencia ~ 1 + lgbt + n_educ + nacionalidad, family = binomial(link = "logit"), 
          data = base_proc) 

m4 <- glm(asistencia ~ 1 + lgbt + n_educ + nacionalidad*lgbt, family = binomial(link = "logit"), 
          data = base_proc) 

m5 <- glm(asistencia ~ 1 + lgbt + n_educ + nacionalidad*lgbt + 
            sexo + edad + dau + depen_grado + disc_wg, family = binomial(link = "logit"), 
          data = base_proc) 

screenreg(
  list(m1, m2, m3, m4, m5)
)


bs <- function(x) {
  df <- as.data.frame(x)
  
  df <- df %>%
    mutate(
      n_educ = as.numeric(n_educ),
      disc_wg = as.numeric(disc_wg),
      depen_grado = as.numeric(depen_grado),
      dau = as.numeric(dau),
      nacionalidad = as.numeric(nacionalidad),
      sexo = as.numeric(sexo),
      lgbt = as.numeric(lgbt)
    )
  
  # Crear grid de predicción
  grid <- df %>%
    data_grid(
      lgbt = unique(lgbt),
      n_educ = n_educ,
      nacionalidad = unique(nacionalidad),
      sexo = unique(sexo),
      edad = median(edad, na.rm = TRUE),
      dau = median(dau, na.rm = TRUE),
      depen_grado = unique(depen_grado),
      disc_wg = median(disc_wg, na.rm = TRUE)
    )
  
  # Modelos ajustados
  lpm <- lm(asistencia ~ 1 + lgbt + n_educ + nacionalidad * lgbt + sexo + edad + dau + depen_grado + disc_wg, data = df)
  
  logistic <- glm(asistencia ~ 1 + lgbt + n_educ + nacionalidad * lgbt + sexo + edad + dau + depen_grado + disc_wg, 
                  family = "binomial", data = df)
  
  # Agregar predicciones al grid
  grid <- grid %>%
    mutate(
      lpm = predict(lpm, newdata = grid),
      logistic = predict(logistic, newdata = grid, type = "response")
    )
  
  return(grid)
}

grid <- base_proc %>% 
  bootstrap(500) %>% 
  mutate(pred = map(strap, ~ bs(.x))) %>% 
  dplyr::select(.id, pred) %>% 
  unnest()


grid2 <- grid %>% 
  pivot_longer(cols = -c(.id, lgbt, n_educ, nacionalidad, sexo, 
                         edad, dau, depen_grado, disc_wg), 
               names_to="model",
               values_to="asistencia_hat") %>%
  mutate(lgbt = if_else(lgbt == 1, "No LGBT", "LGBT"),
         lgbt = factor(lgbt, levels = c("No LGBT", "LGBT")),
         nacionalidad = if_else(nacionalidad == 1, "Chileno", "No chileno"),
  ) 


p1 <- grid2 %>% 
  ggplot(aes(x=lgbt,y=asistencia_hat, group=interaction(.id), colour=model)) +
  geom_line(alpha=.05) +
  scale_color_manual(values = c("#aba8fa", "#c71558")) +
  facet_wrap(~model) +
  labs(x = NULL,
       y = "P(Asistir a centros de salud)",
       caption = "Fuente: elaboración propia en base a CASEN 2022 (n=17.226)") +
  theme_ggdist() +
  theme(legend.position = "none")


p2 <- grid2 %>% 
  ggplot(aes(x=nacionalidad,y=asistencia_hat, group=interaction(.id), colour=model)) +
  geom_line(alpha=.05) +
  scale_color_manual(values = c("#aba8fa", "#c71558")) +
  facet_wrap(~model) +
  labs(x = NULL,
       y = "P(Asistir a centros de salud)",
       caption = "Fuente: elaboración propia en base a CASEN 2022 (n=17.226)") +
  theme_ggdist() +
  theme(legend.position = "none")
  

marginaleffects::plot_slopes(m4, 
                             variables = "lgbt", 
                             condition = "nacionalidad", 
                             conf_level = 0.95, 
                             re.form = NA)


marginaleffects::avg_slopes(m4, 
                            variables = "lgbt", by = "nacionalidad",
                            conf_level = 0.95)
