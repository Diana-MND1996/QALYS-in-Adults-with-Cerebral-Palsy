rm(list=ls())
library(MASS)
library(DescTools)
library(xlsx)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))


###################
## Load the data ##
###################
Database <- read.xlsx("Data_EQ5DSTMF.xlsx", sheetIndex=1)
str(Database)


## Set negative values of EQ-5D utility scores to zero ##
Database$EQ.INDEX.trunc <- Database$EQ.INDEX
Database$EQ.INDEX.trunc[Database$EQ.INDEX.trunc<=0] <- 0.001
summary(Database$EQ.INDEX.trunc)


###################################################################
## 1) Mapping from St.MQoL-S total scores to EQ-5D utility score ##
###################################################################
M1 <- glm(EQ.INDEX.trunc ~ STMartin.INDEX, family=gaussian(link="logit"), data=Database)
summary(M1)


## Include AGE and SEX covariates ##
M2 <- update(M1, . ~ . + AGE*SEX)
anova(M2, test="F")

M2 <- stepAIC(M2)
summary(M2)


## Include cerebral palsy type ## 
M3 <- update(M2, . ~ . + CPT)
anova(M3, test="F")

M3 <- stepAIC(M3)
summary(M3)


## The rest of covariates are not statistically significant ##
M4 <- update(M3, . ~ . + CITY + RLD + INST)
anova(M4, test="F")


## We decided to include the SEX variable into the model ##
Model.final <- glm(EQ.INDEX.trunc ~ STMartin.INDEX + AGE + SEX + CPT, family=gaussian(link="logit"), data=Database)
summary(Model.final)


## Model comparison ##
Models <- list(M1=M1, M2=M2, M3=M3, Model.final=Model.final)

aux <- lapply(Models, function(x){
  data.frame(diff=mean(fitted(x)-Database$EQ.INDEX),
             predict.mean=mean(fitted(x)),
             predict.min=min(fitted(x)),
             predict.max=max(fitted(x)),
             R2=PseudoR2(x, which="Efron"),
             MAE=mean(abs(residuals(x))),
             RMSE=sqrt(mean(residuals(x)^2)))
})
round(do.call(rbind,aux),4)


##################################################################################
## 2) Mapping from domains of the St.MQoL-S total scores to EQ-5D utility score ##
##################################################################################
M1 <- glm(EQ.INDEX.trunc ~ STMartin.SD + STMartin.EW + STMartin.PW + STMartin.MW + STMartin.RI + STMartin.PD + STMartin.IR + STMartin.SI, family=gaussian(link="logit"), data=Database)
anova(M1, test="F")

M1 <- stepAIC(M1)
summary(M1)


## Include AGE and SEX covariates ##
M2 <- update(M1, . ~ . + AGE*SEX)
anova(M2, test="F")

M2 <- stepAIC(M2)
summary(M2)


## Include cerebral palsy type ## 
M3 <- update(M2, . ~ . + CPT)
anova(M3, test="F")

M3 <- stepAIC(M3)
summary(M3)


## We decided to include the AGE and SEX variables into the model ##
Model.final <- glm(EQ.INDEX.trunc ~ STMartin.SD + STMartin.PW + STMartin.MW + STMartin.RI + STMartin.PD + AGE + SEX + CPT, family=gaussian(link="logit"), data=Database)
summary(Model.final)


## Model comparison ##
Models <- list(M1=M1, M2=M2, M3=M3, Model.final=Model.final)

aux <- lapply(Models, function(x){
  data.frame(diff=mean(fitted(x)-Database$EQ.INDEX),
             predict.mean=mean(fitted(x)),
             predict.min=min(fitted(x)),
             predict.max=max(fitted(x)),
             R2=PseudoR2(x, which="Efron"),
             MAE=mean(abs(residuals(x))),
             RMSE=sqrt(mean(residuals(x)^2)))
})
round(do.call(rbind,aux),4)
