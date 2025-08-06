# QALYs in adults with cerebral palsy: mapping from the San Martin Scale onto the EQ-5D-5L instrument

**Author:**  
Nova-Díaz, D.M., Adin, A., and Sánchez-Iriso, E.  
**Published:**  
Oct/2024

This repository contains the original data and R code to reproduce the analyses presented in the paper entitled *"QALYs in adults with cerebral palsy: mapping from the San Martin Scale onto the EQ-5D-5L instrument"* (Nova-Díaz et al., 2024).

---

## Table of contents
- [Data](#data)
- [1. Descriptive analysis](https://github.com/Diana-MND1996/QALYS-in-Adults-with-Cerebral-Palsy/blob/842cff6a10deef26277e7dd7961540bb45c62023/1_DescriptiveAnalysis.R)
- [2a. Variable Selection: OLS](#2a-variable-selection-ols)
- [2b. Variable Selection: GLM](#2b-variable-selection-glm)
- [2c. Variable Selection: Tobit](#2c-variable-selection-tobit)
- [3. Mapping models](#3-mapping-models)
- [4. Cross-validation](#4-cross-validation)

---

## Data

Data were collected from 72 participants in the Study of Adults with Cerebral Palsy in Navarre, Spain (EPCANA), who completed both the St. MQoL-S and the EQ-5D-5L survey instruments simultaneously.

It can be loaded in R by using the command:

```r
library(xlsx)

Database <- read.xlsx("Data_EQ5DSTMF.xlsx", sheetIndex=1)
str(Database)

