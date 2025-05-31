rm(list=ls())
library(ggplot2)
library(ggpubr)
library(VGAM)
library(xlsx)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))


###################
## Load the data ##
###################
Database <- read.xlsx("Data_EQ5DSTMF.xlsx", sheetIndex=1)
str(Database)


######################################
## Ordinary least squares estimator ##
######################################
OLS.M1 <- lm(EQ.INDEX ~ STMartin.INDEX + AGE + SEX + CPT, data=Database)
OLS.M2 <- lm(EQ.INDEX ~ STMartin.SD + STMartin.PW + STMartin.MW + STMartin.RI + STMartin.PD + AGE + SEX + CPT, data=Database)


#######################################################
## Generalized linear model: gaussian (link="logit") ##
#######################################################
Database$EQ.INDEX.trunc <- Database$EQ.INDEX
Database$EQ.INDEX.trunc[Database$EQ.INDEX.trunc<=0] <- 0.001

GLM.M1 <- glm(EQ.INDEX.trunc ~ STMartin.INDEX + AGE + SEX + CPT, family=gaussian(link="logit"), data=Database)
GLM.M2 <- glm(EQ.INDEX.trunc ~ STMartin.SD + STMartin.PW + STMartin.MW + STMartin.RI + STMartin.PD + AGE + SEX + CPT, family=gaussian(link="logit"), data=Database)


###########################################
## Tobit estimator (Lower=-Inf, Upper=1) ##
###########################################
Tobit.M1 <- vglm(EQ.INDEX ~ STMartin.INDEX + AGE + SEX + CPT, tobit(Lower=-Inf, Upper=1), model=TRUE, data=Database)
Tobit.M2 <- vglm(EQ.INDEX ~ STMartin.SD + STMartin.PW + STMartin.MW + STMartin.RI + STMartin.PD + AGE + SEX + CPT, tobit(Lower=-Inf, Upper=1), model=TRUE, data=Database)


##########################################################
## Table 2: Goodness-of-fit results of model candidates ##
##########################################################
Models <- list(OLS.M1=OLS.M1, OLS.M2=OLS.M2, 
               GLM.M1=GLM.M1, GLM.M2=GLM.M2,
               Tobit.M1=Tobit.M1, Tobit.M2=Tobit.M2)

Table2 <- lapply(Models, function(x){
  data.frame(diff=mean(fitted(x)-Database$EQ.INDEX),
             predict.mean=mean(fitted(x)),
             predict.min=min(fitted(x)),
             predict.max=max(fitted(x)),
             MAE=mean(abs(as.matrix(residuals(x))[,1])),
             RMSE=sqrt(mean(as.matrix(residuals(x))[,1]^2)))
})
round(do.call(rbind,Table2),4)


#####################################################################
## Table S3: Estimated regression coefficients of model candidates ##
#####################################################################
St.MQoLS.domains <- paste(c("Self-determination","Physical wellbeing","Material wellbeing",
                            "Rights","Personal development"), "domain")

TableS3.M1 <- data.frame(OLS.mean=coef(OLS.M1), OLS.sd=sqrt(diag(vcov(OLS.M1))),
                         GLM.mean=coef(GLM.M1), GLM.sd=sqrt(diag(vcov(GLM.M1))),
                         Tobit.mean=coef(Tobit.M1)[-2], Tobit.sd=sqrt(diag(vcov(Tobit.M1)))[-2])
rownames(TableS3.M1) <- c("Intercept","St.MQoL-S total scores","Age","I(Sex=male)","I(CPT=Dyskinetic)","I(CPT=Ataxic)","I(CPT=Unclassified)")
round(TableS3.M1,3)

TableS3.M2 <- data.frame(OLS.mean=coef(OLS.M2), OLS.sd=sqrt(diag(vcov(OLS.M2))),
                         GLM.mean=coef(GLM.M2), GLM.sd=sqrt(diag(vcov(GLM.M2))),
                         Tobit.mean=coef(Tobit.M2)[-2], Tobit.sd=sqrt(diag(vcov(Tobit.M2)))[-2])
rownames(TableS3.M2) <- c("Intercept",St.MQoLS.domains,"Age","I(Sex=male)","I(CPT=Dyskinetic)","I(CPT=Ataxic)","I(CPT=Unclassified)")
round(TableS3.M2,3)


#############################################################
## Table S4: Predicted values and 95% confidence intervals ##
#############################################################
data.predict <- Database[,c("STMartin.INDEX","AGE","SEX","CPT","EQ.INDEX")]

## Predictions for OLS model ##
OLS.pred <- predict(OLS.M1, Database, interval="confidence")
cbind(data.predict,round(OLS.pred,3))

## Predictions for GLM model ##
aux <- as.data.frame(predict(GLM.M1, Database, se.fit=TRUE))
aux$lwr <- aux$fit-qnorm(0.975)*aux$se.fit
aux$upr <- aux$fit+qnorm(0.975)*aux$se.fit

GLM.pred <- apply(aux[,c("fit","lwr","upr")],2,plogis)
cbind(data.predict,round(GLM.pred,3))

## Predictions for Tobit model ##
aux <- as.data.frame(predict(Tobit.M1, Database, se.fit=TRUE))
aux$lwr <- aux$fitted.values.mu-qnorm(0.975)*aux$se.fit.mu
aux$upr <- aux$fitted.values.mu+qnorm(0.975)*aux$se.fit.mu

Tobit.pred <- aux[,c("fitted.values.mu","lwr","upr")]
cbind(data.predict,round(Tobit.pred,3))


##########################################################################################
## Figure S2: Scatterplot between observed and predicted EQ-5D utility scores (MODEL 1) ##
##########################################################################################
Model1.pred <- data.frame(Observed=Database$EQ.INDEX,
                          Predicted.OLS=fitted(OLS.M1),
                          Predicted.GLM=fitted(GLM.M1),
                          Predicted.Tobit=fitted(Tobit.M1))

g1 <- ggplot(Model1.pred, aes(x=Observed, y=Predicted.OLS)) + 
  geom_point() +
  geom_abline(intercept=0, slope=1, color="red") + 
  scale_x_continuous(breaks=seq(-0.2,1,0.2), limits=c(-0.21,1)) + 
  scale_y_continuous(breaks=seq(-0.2,1,0.2), limits=c(-0.21,1)) + 
  labs(x="Observed EQ-5D utility scores", y="Predicted EQ-5D utility scores",
       title="Ordinary Least Squares Estimator") +
  theme(axis.title.x=element_text(margin=margin(t=10)),
        axis.title.y=element_text(margin=margin(r=10)),
        plot.title = element_text(hjust=0.5))

g2 <- ggplot(Model1.pred, aes(x=Observed, y=Predicted.GLM)) + 
  geom_point() +
  geom_abline(intercept=0, slope=1, color="red") + 
  scale_x_continuous(breaks=seq(-0.2,1,0.2), limits=c(-0.21,1)) + 
  scale_y_continuous(breaks=seq(-0.2,1,0.2), limits=c(-0.21,1)) + 
  labs(x="Observed EQ-5D utility scores", y="Predicted EQ-5D utility scores",
       title="Generalized linear model") +
  theme(axis.title.x=element_text(margin=margin(t=10)),
        axis.title.y=element_text(margin=margin(r=10)),
        plot.title = element_text(hjust=0.5))

g3 <- ggplot(Model1.pred, aes(x=Observed, y=Predicted.Tobit)) + 
  geom_point() +
  geom_abline(intercept=0, slope=1, color="red") + 
  scale_x_continuous(breaks=seq(-0.2,1,0.2), limits=c(-0.21,1)) + 
  scale_y_continuous(breaks=seq(-0.2,1,0.2), limits=c(-0.21,1)) + 
  labs(x="Observed EQ-5D utility scores", y="Predicted EQ-5D utility scores",
       title="Tobit Model") +
  theme(axis.title.x=element_text(margin=margin(t=10)),
        axis.title.y=element_text(margin=margin(r=10)),
        plot.title = element_text(hjust=0.5))

graphics.off()
pdf("FigureS2.pdf", width=12, height=4)
ggarrange(g1, g2, g3, nrow=1, ncol=3)
dev.off()


##########################################################################################
## Figure S3: Scatterplot between observed and predicted EQ-5D utility scores (MODEL 2) ##
##########################################################################################
Model2.pred <- data.frame(Observed=Database$EQ.INDEX,
                          Predicted.OLS=fitted(OLS.M2),
                          Predicted.GLM=fitted(GLM.M2),
                          Predicted.Tobit=fitted(Tobit.M2))

g1 <- ggplot(Model2.pred, aes(x=Observed, y=Predicted.OLS)) + 
  geom_point() +
  geom_abline(intercept=0, slope=1, color="red") + 
  scale_x_continuous(breaks=seq(-0.2,1,0.2), limits=c(-0.21,1)) + 
  scale_y_continuous(breaks=seq(-0.2,1,0.2), limits=c(-0.21,1)) + 
  labs(x="Observed EQ-5D utility scores", y="Predicted EQ-5D utility scores",
       title="Ordinary Least Squares Estimator") +
  theme(axis.title.x=element_text(margin=margin(t=10)),
        axis.title.y=element_text(margin=margin(r=10)),
        plot.title = element_text(hjust=0.5))

g2 <- ggplot(Model2.pred, aes(x=Observed, y=Predicted.GLM)) + 
  geom_point() +
  geom_abline(intercept=0, slope=1, color="red") + 
  scale_x_continuous(breaks=seq(-0.2,1,0.2), limits=c(-0.21,1)) + 
  scale_y_continuous(breaks=seq(-0.2,1,0.2), limits=c(-0.21,1)) + 
  labs(x="Observed EQ-5D utility scores", y="Predicted EQ-5D utility scores",
       title="Generalized linear model") +
  theme(axis.title.x=element_text(margin=margin(t=10)),
        axis.title.y=element_text(margin=margin(r=10)),
        plot.title = element_text(hjust=0.5))

g3 <- ggplot(Model2.pred, aes(x=Observed, y=Predicted.Tobit)) + 
  geom_point() +
  geom_abline(intercept=0, slope=1, color="red") + 
  scale_x_continuous(breaks=seq(-0.2,1,0.2), limits=c(-0.21,1)) + 
  scale_y_continuous(breaks=seq(-0.2,1,0.2), limits=c(-0.21,1)) + 
  labs(x="Observed EQ-5D utility scores", y="Predicted EQ-5D utility scores",
       title="Tobit Model") +
  theme(axis.title.x=element_text(margin=margin(t=10)),
        axis.title.y=element_text(margin=margin(r=10)),
        plot.title = element_text(hjust=0.5))

graphics.off()
pdf("FigureS3.pdf", width=12, height=4)
ggarrange(g1, g2, g3, nrow=1, ncol=3)
dev.off()


#####################################################################################################
## Figure 5: Empirical cumulative density functions of observed and predicted EQ-5D utility scores ##
#####################################################################################################
x <- seq(-0.21, 1, 0.001)

data.ECDF <- data.frame(x=x,
                        Obs.ECDF=ecdf(Database$EQ.INDEX)(x),
                        OLS.ECDF=ecdf(fitted(OLS.M1))(x),
                        GLM.ECDF=ecdf(fitted(GLM.M1))(x),
                        Tobit.ECDF=ecdf(fitted(Tobit.M1))(x))

g1 <- ggplot(data.ECDF, aes(x=x)) +
  geom_step(aes(y=Obs.ECDF, color="Observed"), linewidth=1) +
  geom_line(aes(y=OLS.ECDF, color="Predicted"), linewidth=1) +
  labs(x="EQ-5D utility scores", y="Empirical CDF",
       title="Ordinary Least Squares Estimator") +
  scale_color_manual(values=c("Observed"="blue", "Predicted"="red")) +
  theme_minimal() +
  theme(legend.position=c(0.95,0.05),
        legend.title=element_blank(),
        legend.justification=c("right","bottom")) +
  guides(color=guide_legend(override.aes=list(size=1)))

g2 <- ggplot(data.ECDF, aes(x=x)) +
  geom_step(aes(y=Obs.ECDF, color="Observed"), linewidth=1) +
  geom_line(aes(y=GLM.ECDF, color="Predicted"), linewidth=1) +
  labs(x="EQ-5D utility scores", y="Empirical CDF",
       title="Generalized linear model") +
  scale_color_manual(values=c("Observed"="blue", "Predicted"="red")) +
  theme_minimal() +
  theme(legend.position=c(0.95,0.05),
        legend.title=element_blank(),
        legend.justification=c("right","bottom")) +
  guides(color=guide_legend(override.aes=list(size=1)))

g3 <- ggplot(data.ECDF, aes(x=x)) +
  geom_step(aes(y=Obs.ECDF, color="Observed"), linewidth=1) +
  geom_line(aes(y=Tobit.ECDF, color="Predicted"), linewidth=1) +
  labs(x="EQ-5D utility scores", y="Empirical CDF",
       title="Tobit Model") +
  scale_color_manual(values=c("Observed"="blue", "Predicted"="red")) +
  theme_minimal() +
  theme(legend.position=c(0.95,0.05),
        legend.title=element_blank(),
        legend.justification=c("right","bottom")) +
  guides(color=guide_legend(override.aes=list(size=1)))

graphics.off()
pdf("Figure5.pdf", width=12, height=4)
ggarrange(g1, g2, g3, nrow=1, ncol=3)
dev.off()
