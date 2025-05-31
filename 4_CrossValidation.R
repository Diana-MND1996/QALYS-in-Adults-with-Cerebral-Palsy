rm(list=ls())
library(caret)
library(lattice)
library(ggplot2)
library(ggpubr)
library(VGAM)
library(stats4)
library(splines)
library(xlsx)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))


###################
## Load the data ##
###################
Database <- read.xlsx("Data_EQ5DSTMF.xlsx", sheetIndex=1)
str(Database)


####################################################################
## Control parameters to perform repeated 5-fold cross validation ##
####################################################################
set.seed(1234)

control <- trainControl(method="repeatedcv",
                        number=5,
                        repeats=5,
                        savePredictions=TRUE)


######################################
## Ordinary least squares estimator ##
######################################
OLS.M1 <- formula(EQ.INDEX ~ STMartin.INDEX + AGE + SEX + CPT)
OLS.M2 <- formula(EQ.INDEX ~ STMartin.SD + STMartin.PW + STMartin.MW + STMartin.RI + STMartin.PD + AGE + SEX + CPT)

OLS.M1.cv <- train(OLS.M1, method="lm", trControl=control, data=Database)
OLS.M2.cv <- train(OLS.M2, method="lm", trControl=control, data=Database)


##############################################################
## Generalized linear model: gaussian (link="logit")        ##
##                                                          ##
## NOTE: We need to compute the correct MAE and RMSE values ##
##############################################################
Database$EQ.INDEX.trunc <- Database$EQ.INDEX
Database$EQ.INDEX.trunc[Database$EQ.INDEX.trunc<=0] <- 0.001


## GLM - Model 1
#################
GLM.M1 <- formula(EQ.INDEX.trunc ~ STMartin.INDEX + AGE + SEX + CPT)

GLM.M1.cv <- train(GLM.M1, method="glm", trControl=control,
                   family=gaussian(link="logit"), data=Database)

GLM.M1.cv$pred$obs <- Database$EQ.INDEX[GLM.M1.cv$pred$rowIndex]

for(i in unique(GLM.M1.cv$resample$Resample)){
  aux <- GLM.M1.cv$pred[GLM.M1.cv$pred$Resample==i,]

  GLM.M1.cv$resample$Rsquared <- NULL
  GLM.M1.cv$resample[GLM.M1.cv$resample$Resample==i,"MAE"] <- mean(abs(aux$pred-aux$obs))
  GLM.M1.cv$resample[GLM.M1.cv$resample$Resample==i,"RMSE"] <- sqrt(mean((aux$pred-aux$obs)^2))
}

GLM.M1.cv$results <- data.frame(MAE=mean(GLM.M1.cv$resample$MAE),
                                RMSE=mean(GLM.M1.cv$resample$RMSE))


## GLM - Model 2
#################
GLM.M2 <- formula(EQ.INDEX.trunc ~ STMartin.SD + STMartin.PW + STMartin.MW + STMartin.RI + STMartin.PD + AGE + SEX + CPT)

GLM.M2.cv <- train(GLM.M2, method="glm", trControl=control,
                   family=gaussian(link="logit"), data=Database)

GLM.M2.cv$pred$obs <- Database$EQ.INDEX[GLM.M2.cv$pred$rowIndex]

for(i in unique(GLM.M2.cv$resample$Resample)){
  aux <- GLM.M2.cv$pred[GLM.M2.cv$pred$Resample==i,]

  GLM.M2.cv$resample$Rsquared <- NULL
  GLM.M2.cv$resample[GLM.M2.cv$resample$Resample==i,"MAE"] <- mean(abs(aux$pred-aux$obs))
  GLM.M2.cv$resample[GLM.M2.cv$resample$Resample==i,"RMSE"] <- sqrt(mean((aux$pred-aux$obs)^2))
}

GLM.M2.cv$results <- data.frame(MAE=mean(GLM.M2.cv$resample$MAE),
                                RMSE=mean(GLM.M2.cv$resample$RMSE))


#####################################################
## Tobit estimator (Lower=-Inf, Upper=1)           ##
##                                                 ##
## NOTE: We need to manually compute the CV scheme ##
#####################################################
samples.cv <- createMultiFolds(Database$ID, k=5, times=5)


## Tobit - Model 1 
###################
Tobit.M1 <- formula(EQ.INDEX ~ STMartin.INDEX + AGE + SEX + CPT)

aux.M1 <- lapply(samples.cv, function(x){
  
  data.train <- Database[x,]
  data.predict <- Database[-x,]
  
  model <- vglm(Tobit.M1, tobit(Lower=-Inf, Upper=1), model=TRUE, data=data.train)
  aux <- predict(model, newdata=data.predict, type="response")
  
  pred <- data.frame(pred=aux, obs=data.predict$EQ.INDEX, rowIndex=as.integer(rownames(aux)))
  
  resample <- data.frame(MAE=mean(abs(pred$pred-pred$obs)),
                         RMSE=sqrt(mean((pred$pred-pred$obs)^2)))
  
  return(list(pred=pred, resample=resample))
})

for(i in names(samples.cv)){
  aux.M1[[i]]$pred$Resample <- i
  aux.M1[[i]]$resample$Resample <- i
}

Tobit.M1.cv <- vector("list",3)
names(Tobit.M1.cv) <- c("pred","resample","results")

Tobit.M1.cv$pred <- do.call(rbind, lapply(aux.M1, function(x) x$pred))
rownames(Tobit.M1.cv$pred) <- NULL

Tobit.M1.cv$resample <- do.call(rbind, lapply(aux.M1, function(x) x$resample))
rownames(Tobit.M1.cv$resample) <- NULL

Tobit.M1.cv$results <- data.frame(MAE=mean(Tobit.M1.cv$resample$MAE),
                                  RMSE=mean(Tobit.M1.cv$resample$RMSE))


## Tobit - Model 2 
###################
Tobit.M2 <- formula(EQ.INDEX ~ STMartin.SD + STMartin.PW + STMartin.MW + STMartin.RI + STMartin.PD + AGE + SEX + CPT)

aux.M2 <- lapply(samples.cv, function(x){
  
  data.train <- Database[x,]
  data.predict <- Database[-x,]
  
  model <- vglm(Tobit.M2, tobit(Lower=-Inf, Upper=1), model=TRUE, data=data.train)
  aux <- predict(model, newdata=data.predict, type="response")
  
  pred <- data.frame(pred=aux, obs=data.predict$EQ.INDEX, rowIndex=as.integer(rownames(aux)))
  
  resample <- data.frame(MAE=mean(abs(pred$pred-pred$obs)),
                         RMSE=sqrt(mean((pred$pred-pred$obs)^2)))
  
  return(list(pred=pred, resample=resample))
})

for(i in names(samples.cv)){
  aux.M2[[i]]$pred$Resample <- i
  aux.M2[[i]]$resample$Resample <- i
}

Tobit.M2.cv <- vector("list",2)
names(Tobit.M2.cv) <- c("pred","resample")

Tobit.M2.cv$pred <- do.call(rbind, lapply(aux.M2, function(x) x$pred))
rownames(Tobit.M2.cv$pred) <- NULL

Tobit.M2.cv$resample <- do.call(rbind, lapply(aux.M2, function(x) x$resample))
rownames(Tobit.M2.cv$resample) <- NULL

Tobit.M2.cv$results <- data.frame(MAE=mean(Tobit.M2.cv$resample$MAE),
                                  RMSE=mean(Tobit.M2.cv$resample$RMSE))


#####################################################################
## Table 3: Goodness-of-fit using repeated 5-fold cross validation ##
#####################################################################
CV <- list(OLS.M1=OLS.M1.cv, OLS.M2=OLS.M2.cv,
           GLM.M1=GLM.M1.cv, GLM.M2=GLM.M2.cv,
           Tobit.M1=Tobit.M1.cv, Tobit.M2=Tobit.M2.cv)

Table3 <- lapply(CV, function(x){
  data.frame(diff=mean(x$pred$pred-x$pred$obs),
             predict.mean=mean(x$pred$pred),
             predict.min=min(x$pred$pred),
             predict.max=max(x$pred$pred),
             MAE=x$results$MAE,
             RMSE=x$results$RMSE)
})
round(do.call(rbind,Table3),4)


######################################################################
## Figure 4: Goodness-of-fit using repeated 5-fold cross validation ##
######################################################################
CV.MAE <- data.frame(group=factor(rep(names(CV),each=25), levels=names(CV)),
                     value=unlist(lapply(CV, function(x) x$resample$MAE)),
                     row.names=NULL)

CV.RMSE <- data.frame(group=factor(rep(names(CV),each=25), levels=names(CV)),
                      value=unlist(lapply(CV, function(x) x$resample$RMSE)),
                      row.names=NULL)

g1 <- ggplot(CV.MAE, aes(x=group, y=value)) +
  geom_boxplot(fill="lightblue") +
  scale_y_continuous(limits=c(0,0.3)) + 
  labs(x=NULL, y=NULL, title="Mean absolute error") + 
  theme(axis.text.x=element_text(size=12),
        plot.title=element_text(hjust=0.5))

g2 <- ggplot(CV.RMSE, aes(x=group, y=value)) +
  geom_boxplot(fill="lightblue") +
  scale_y_continuous(limits=c(0,0.3)) + 
  labs(x=NULL, y=NULL, title="Root mean square error") + 
  theme(axis.text.x=element_text(size=12),
        plot.title=element_text(hjust=0.5))

graphics.off()
pdf("Figure4.pdf", width=12)
ggarrange(g1, g2, nrow=1, ncol=2)
dev.off()
