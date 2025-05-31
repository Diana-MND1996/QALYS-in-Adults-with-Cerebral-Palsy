rm(list=ls())
library(VGAM)
library(DescTools)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))


###################
## Load the data ##
###################
Database <- read.xlsx("Data_EQ5DSTMF.xlsx", sheetIndex=1)
str(Database)


###################################################################
## 1) Mapping from St.MQoL-S total scores to EQ-5D utility score ##
###################################################################
M1 <- vglm(EQ.INDEX ~ STMartin.INDEX, tobit(Lower=-Inf, Upper=1), model=TRUE, data=Database)
summary(M1)


## Include AGE and SEX covariates ##
M2 <- vglm(EQ.INDEX ~ STMartin.INDEX + AGE*SEX, tobit(Lower=-Inf, Upper=1), model=TRUE, data=Database)
anova(M2)

M2 <- step4vglm(M2)
summary(M2)


## Include cerebral palsy type ##
M3 <- vglm(EQ.INDEX ~ STMartin.INDEX + AGE + CPT, tobit(Lower=-Inf, Upper=1), model=TRUE, data=Database)
anova(M3)

M3 <- step4vglm(M3)
summary(M3)


## We decided to include the SEX variable into the model ##
Model.final <- vglm(EQ.INDEX ~ STMartin.INDEX + AGE + SEX + CPT, tobit(Lower=-Inf, Upper=1), model=TRUE, data=Database)
summary(Model.final)


## Model comparison ##
Models <- list(M1=M1, M2=M2, M3=M3, Model.final=Model.final)

aux <- lapply(Models, function(x){
  data.frame(diff=mean(fitted(x)-Database$EQ.INDEX),
             predict.mean=mean(fitted(x)),
             predict.min=min(fitted(x)),
             predict.max=max(fitted(x)),
             R2=PseudoR2(x, which="Efron"),
             MAE=mean(abs(residuals(x)[,1])),
             RMSE=sqrt(mean(residuals(x)[,1]^2)))
})
round(do.call(rbind,aux),4)


##################################################################################
## 2) Mapping from domains of the St.MQoL-S total scores to EQ-5D utility score ##
##################################################################################
M1 <- vglm(EQ.INDEX ~ STMartin.SD + STMartin.EW + STMartin.PW + STMartin.MW + STMartin.RI + STMartin.PD + STMartin.IR + STMartin.SI, tobit(Lower=-Inf, Upper=1), model=TRUE, data=Database)
anova(M1)

M1 <- step4vglm(M1)
summary(M1)


## Include AGE and SEX covariates ##
M2 <- vglm(EQ.INDEX ~ STMartin.SD + STMartin.PW + STMartin.MW + STMartin.RI + STMartin.PD + AGE*SEX, tobit(Lower=-Inf, Upper=1), model=TRUE, data=Database)
anova(M2)

M2 <- step4vglm(M2)
summary(M2)


## Include cerebral palsy type ##
M3 <- vglm(EQ.INDEX ~ STMartin.SD + STMartin.PW + STMartin.MW + STMartin.RI + STMartin.PD + AGE + CPT, tobit(Lower=-Inf, Upper=1), model=TRUE, data=Database)
anova(M3)

M3 <- step4vglm(M3)
summary(M3)


## We decided to include the AGE and SEX variables into the model ##
Model.final <- vglm(EQ.INDEX ~ STMartin.SD + STMartin.PW + STMartin.MW + STMartin.RI + STMartin.PD + AGE + SEX + CPT, tobit(Lower=-Inf, Upper=1), model=TRUE, data=Database)
summary(Model.final)


## Model comparison ##
Models <- list(M1=M1, M2=M2, M3=M3, Model.final=Model.final)

aux <- lapply(Models, function(x){
  data.frame(diff=mean(fitted(x)-Database$EQ.INDEX),
             predict.mean=mean(fitted(x)),
             predict.min=min(fitted(x)),
             predict.max=max(fitted(x)),
             R2=PseudoR2(x, which="Efron"),
             MAE=mean(abs(residuals(x)[,1])),
             RMSE=sqrt(mean(residuals(x)[,1]^2)))
})
round(do.call(rbind,aux),4)
