# QALYs in adults with cerebral palsy: mapping from the San Martin Scale onto the EQ-5D-5L instrument

**Author:**  
Nova-Díaz, D.M., Adin, A., and Sánchez-Iriso, E.  
**Published:**  
Oct/2024

This repository contains the original data and R code to reproduce the analyses presented in the paper entitled *"QALYs in adults with cerebral palsy: mapping from the San Martin Scale onto the EQ-5D-5L instrument"* (Nova-Díaz et al., 2024).

---

## Table of contents
- [Data](https://github.com/Diana-MND1996/QALYS-in-Adults-with-Cerebral-Palsy/blob/c898a0085bd49a6c8c11fcc93808cdd22c5aed8a/Data_EQ5DSTMF.Rdata)
- [1. Descriptive analysis](https://github.com/Diana-MND1996/QALYS-in-Adults-with-Cerebral-Palsy/blob/842cff6a10deef26277e7dd7961540bb45c62023/1_DescriptiveAnalysis.R)
- [2a. Variable Selection: OLS](https://github.com/Diana-MND1996/QALYS-in-Adults-with-Cerebral-Palsy/blob/842cff6a10deef26277e7dd7961540bb45c62023/2a_VariableSelection_OLS.R)
- [2b. Variable Selection: GLM](https://github.com/Diana-MND1996/QALYS-in-Adults-with-Cerebral-Palsy/blob/842cff6a10deef26277e7dd7961540bb45c62023/2b_VariableSelection_GLM.R)
- [2c. Variable Selection: Tobit](https://github.com/Diana-MND1996/QALYS-in-Adults-with-Cerebral-Palsy/blob/842cff6a10deef26277e7dd7961540bb45c62023/2c_VariableSelection_Tobit.R)
- [3. Mapping models](https://github.com/Diana-MND1996/QALYS-in-Adults-with-Cerebral-Palsy/blob/842cff6a10deef26277e7dd7961540bb45c62023/3_Mapping.R)
- [4. Cross-validation](https://github.com/Diana-MND1996/QALYS-in-Adults-with-Cerebral-Palsy/blob/842cff6a10deef26277e7dd7961540bb45c62023/4_CrossValidation.R)
- [5. Calculator_STMQOL_EQ-5D](https://github.com/Diana-MND1996/QALYS-in-Adults-with-Cerebral-Palsy/blob/61bcd1cc2aa1d92947ac8ae955857d70ad5d587c/Calculator_STMQOL_EQ-5D.xlsm)

---

## Data

Data were collected from 72 participants in the Study of Adults with Cerebral Palsy in Navarre, Spain (EPCANA), who completed both the St. MQoL-S and the EQ-5D-5L survey instruments simultaneously.

```r
# 📦 Carga de librería y base de datos
library(xlsx)

Database <- read.xlsx("Data_EQ5DSTMF.xlsx", sheetIndex = 1)
str(Database)

# ▶️ Estructura del objeto Database
# 'data.frame':   72 obs. of  22 variables:
#  $ ID                   : chr  "14" "62" "63" "44" ...
#  $ SEX                  : chr  "1" "1" "0" "0" ...
#  $ AGE                  : num  20 35 72 18 ...
#  $ CITY                 : chr  "0" "1" "0" "0" ...
#  $ CPT                  : chr  "1" "1" "1" "1" ...
#  $ RLD                  : chr  "3" "3" "3" "3" ...
#  $ TIME                 : num  14 33 27 6 ...
#  $ INST                 : num  0.7 0.943 0.375 ...
#  $ TOTAL.EQ             : num  23 21 20 21 ...
#  $ EVA                  : num  55 55 55 58 ...
#  $ EQ.INDEX             : num  -0.202 -0.04 0.046 ...
#  $ STMartin.SD          : num  7 10 13 11 ...
#  $ STMartin.EW          : num  8 9 9 11 ...
#  $ STMartin.PW          : num  7 6 8 10 ...
#  $ STMartin.MW          : num  7 7 5 11 ...
#  $ STMartin.RI          : num  6 9 6 11 ...
#  $ STMartin.PD          : num  6 4 8 9 ...
#  $ STMartin.IR          : num  8 4 5 10 ...
#  $ STMartin.SI          : num  8 7 7 6 ...
#  $ STMartin.SUM         : num  57 56 61 79 ...
#  $ STMartin.INDEX       : num  82 82 85 99 ...
#  $ STMartin.INDEX.scaled: num  0.375 0.375 0.412 ...

# 🧾 Descripción de las variables del objeto Database

# ID: Identificador del paciente (carácter)
# SEX: Sexo del paciente (0 = “Femenino”, 1 = “Masculino”)
# AGE: Edad del paciente (años)
# CITY: Lugar de residencia (0 = “fuera de la ciudad”, 1 = “dentro de la ciudad”)
# CPT: Tipo de parálisis cerebral
# RLD: Nivel reconocido de dependencia (1 = “Leve”, 2 = “Moderado”, 3 = “Severo”)
# TIME: Tiempo de afiliación a la institución (años)
# INST: Grado de institucionalización (INST = TIME / AGE)
# TOTAL.EQ: Puntaje total de las dimensiones del EQ-5D-5L
# EVA: Escala Visual Analógica (0 = peor estado, 100 = mejor estado)
# EQ.INDEX: Índice de salud calculado con EQ-5D-5L
# STMartin.SD: Dominio de autodeterminación (St. MQoL-S)
# STMartin.EW: Dominio de bienestar emocional (St. MQoL-S)
# STMartin.PW: Dominio de bienestar físico (St. MQoL-S)
# STMartin.MW: Dominio de bienestar material (St. MQoL-S)
# STMartin.RI: Dominio de derechos (St. MQoL-S)
# STMartin.PD: Dominio de desarrollo personal (St. MQoL-S)
# STMartin.IR: Dominio de relaciones interpersonales (St. MQoL-S)
# STMartin.SI: Dominio de inclusión social (St. MQoL-S)
# STMartin.SUM: Suma de todos los dominios del St. MQoL-S
# STMartin.INDEX: Puntaje total de calidad de vida según St. MQoL-S
# STMartin.INDEX.scaled: Puntaje total escalado al intervalo [0,1]




