# QALYs in adults with cerebral palsy: mapping from the San Martin Scale onto the EQ-5D-5L instrument

**D.M. Nova-Díaz, A. Adin, and E. Sánchez-Iriso**  
*Jun/2025*

This repository contains the original data and R code to reproduce the analyses presented in the paper *“QALYs in adults with cerebral palsy: mapping from the San Martin Scale onto the EQ-5D-5L instrument”* (Nova-Díaz et al., 2025).

---

## Table of contents

- [Data](#data)
- [R code](#r-code)
  - [Descriptive Analysis](#descriptive-analysis)
  - [Variable selection](#variable-selection)
  - [Mapping model performance](#mapping-model-performance)
  - [Cross Validation](#cross-validation)
  - [Examples of the mapping algorithm](#examples-of-the-mapping-algorithm)

---

## Data

Data were collected from 72 participants in the Study of Adults Cerebral Palsy in Navarre, Spain (EPCANA), who completed both the St. MQoL-S and the EQ-5D-5L survey instruments simultaneously. It can be loaded in R using:

```r
library(xlsx)
Database <- read.xlsx("Data_EQ5DSTMF.xlsx", sheetIndex=1)
str(Database)

