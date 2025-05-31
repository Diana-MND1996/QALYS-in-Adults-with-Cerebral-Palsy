rm(list=ls())
library(MASS)
library(xlsx)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))


###################
## Load the data ##
###################
Database <- read.xlsx("Data_EQ5DSTMF.xlsx", sheetIndex=1)
str(Database)


###################################################################
## 1) Mapping from St.MQoL-S total scores to EQ-5D utility score ##
###################################################################
M1 <- lm(EQ.INDEX ~ STMartin.INDEX, data=Database)
summary(M1)


## Include AGE and SEX covariates ##
M2 <- update(M1, . ~ . + AGE*SEX)
anova(M2)

M2 <- stepAIC(M2)
summary(M2)


## Include cerebral palsy type ## 
M3 <- update(M2, . ~ . + CPT)
anova(M3)

M3 <- stepAIC(M3)
summary(M3)


## The rest of covariates are not statistically significant ##
M4 <- update(M3, . ~ . + CITY + RLD + INST)
anova(M4)


## We decided to include the SEX variable into the model ##
Model.final <- lm(EQ.INDEX ~ STMartin.INDEX + AGE + SEX + CPT, data=Database)
summary(Model.final)


## Model comparison ##
Models <- list(M1=M1, M2=M2, M3=M3, Model.final=Model.final)

aux <- lapply(Models, function(x){
  data.frame(diff=mean(fitted(x)-Database$EQ.INDEX),
             predict.mean=mean(fitted(x)),
             predict.min=min(fitted(x)),
             predict.max=max(fitted(x)),
             R2=summary(x)$adj.r.squared,
             MAE=mean(abs(residuals(x))),
             RMSE=sqrt(mean(residuals(x)^2)))
})
round(do.call(rbind,aux),4)


##################################################################################
## 2) Mapping from domains of the St.MQoL-S total scores to EQ-5D utility score ##
##################################################################################
M1 <- lm(EQ.INDEX ~ STMartin.SD + STMartin.EW + STMartin.PW + STMartin.MW + STMartin.RI + STMartin.PD + STMartin.IR + STMartin.SI, data=Database)
anova(M1)

M1 <- stepAIC(M1)
summary(M1)


## Include AGE and SEX covariates ##
M2 <- update(M1, . ~ . + AGE*SEX)
anova(M2)

M2 <- stepAIC(M2)
summary(M2)


## Include cerebral palsy type ## 
M3 <- update(M2, . ~ . + CPT)
anova(M3)

M3 <- stepAIC(M3)
summary(M3)


## We decided to include the AGE and SEX variables into the model ##
Model.final <- lm(EQ.INDEX ~ STMartin.SD + STMartin.PW + STMartin.MW + STMartin.RI + STMartin.PD + AGE + SEX + CPT, data=Database)
summary(Model.final)


## Model comparison ##
Models <- list(M1=M1, M2=M2, M3=M3, Model.final=Model.final)

aux <- lapply(Models, function(x){
  data.frame(diff=mean(fitted(x)-Database$EQ.INDEX),
             predict.mean=mean(fitted(x)),
             predict.min=min(fitted(x)),
             predict.max=max(fitted(x)),
             R2=summary(x)$adj.r.squared,
             MAE=mean(abs(residuals(x))),
             RMSE=sqrt(mean(residuals(x)^2)))
})
round(do.call(rbind,aux),4)
