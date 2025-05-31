rm(list=ls())
library(corrplot)
library(ggplot2)
library(ggpubr)
library(GGally)
library(Matrix)
library(psych)
library(reshape2)
library(xlsx)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))


###################
## Load the data ##
###################
Database <- read.xlsx("Data_EQ5DSTMF.xlsx", sheetIndex=1)
str(Database)


###################################################
## Table 1: Characteristics of the sample (n=72) ##
###################################################
n <- nrow(Database)

St.MQoLS.domains <- paste(c("Self-determination","Emotional wellbeing","Physical wellbeing","Material wellbeing",
                            "Rights","Personal development","Interpersonal relations","Social inclusion"), "domain")

## Quantitative variables ##
aux <- Database[,c("STMartin.INDEX","STMartin.SD","STMartin.EW","STMartin.PW","STMartin.MW",
                   "STMartin.RI","STMartin.PD","STMartin.IR","STMartin.SI","EQ.INDEX","AGE")]
Table1a <- data.frame(Mean=apply(aux,2,mean),SD=apply(aux,2,sd))
rownames(Table1a) <- c("St.MQoL-S total score", paste0("St.MQoL-S",St.MQoLS.domains), "EQ-Index","Age in years")
round(Table1a,2)

## Qualitative variables ##
aux <- Database[,c("SEX","CITY","CPT","RLD")]
Table1b <- data.frame(melt(apply(aux,2,table))$value,
                      100*melt(apply(aux,2,table))$value/n)
colnames(Table1b) <- c("N","%")
rownames(Table1b) <- c("Gender (Female)","Gender (Male)",
                       "City (Outside)", "City (Inside)",
                       "Spastic CP","Dyskinetic CP","Ataxic CP","Unclassified CP",
                       "Level of dependency (Mild)","Level of dependency (Moderate)","Level of dependency (Severe)")
round(Table1b,2)


##############################################################################
## Figure 2: Distribution of EQ-5D utility score and St.MQoL-S total score ##
##############################################################################
aux1 <- hist(Database$EQ.INDEX, prob=TRUE)
aux2 <- hist(Database$STMartin.INDEX, prob=TRUE)

p1 <- ggplot(Database, aes(x=EQ.INDEX)) +
  geom_histogram(aes(y=after_stat(density)), breaks=aux1$breaks, fill="lightblue", color="black") +
  geom_density() +
  labs(title="Histogram of EQ-Index", x=NULL, y="Density") +
  theme_minimal() + 
  theme(plot.title=element_text(hjust= 0.5))

p2 <- ggplot(Database, aes(x=STMartin.INDEX)) +
  geom_histogram(aes(y=after_stat(density)), breaks=aux2$breaks, fill="lightblue", color="black") +
  geom_density() +
  labs(title="Histogram of St.MQoL-S Index", x=NULL, y="Density") +
  theme_minimal() + 
  theme(plot.title=element_text(hjust= 0.5))

graphics.off()
pdf("Figure2.pdf", width=12, height=8)
ggarrange(p1, p2, nrow=1, ncol=2)
dev.off()


########################################################################################
## Figure 3: Scatterplot between the EQ-5D utility scores and St.MQoL-S total scores ##
########################################################################################
Model <- lm(EQ.INDEX ~ STMartin.INDEX, data=Database)

aux <- Database[,c("EQ.INDEX","STMartin.INDEX")]
aux <- aux[order(aux$STMartin.INDEX),]
aux <- rbind(data.frame(EQ.INDEX=NA, STMartin.INDEX=min(aux$STMartin.INDEX)-2),
             aux,
             data.frame(EQ.INDEX=NA, STMartin.INDEX=max(aux$STMartin.INDEX)+2))
aux$EQ.INDEX.predict <- predict(Model, newdata=aux)


graphics.off()
pdf("Figure3.pdf", width=10)
ggplot(aux, aes(x=STMartin.INDEX, y=EQ.INDEX, color="Data")) +
  geom_point() +
  geom_line(aes(y=EQ.INDEX.predict, color="Predicted")) +
  scale_y_continuous(breaks=seq(-0.2,1,0.2), limits=c(-0.2,0.9)) + 
  labs(x="St.MQoL-S total scores", y="EQ-5D utility scores") +
  scale_color_manual(values=c("Data"="black", "Predicted"="red"),
                     labels=c("Observed data", "Predicted values")) +  # Specify labels
  theme(axis.title.x=element_text(margin=margin(t=10)),
        axis.title.y=element_text(margin=margin(r=10)),
        legend.position=c(0.9,0.1),
        legend.text=element_text(size=12)) + 
  guides(color=guide_legend(title=NULL, override.aes=list(shape=c(19,NA), linetype=c("blank","solid"))))
dev.off()


####################################################################################################################
## Table S2: Spearman correlation coefficients between EQ-5D utility score and domains of St.MQoL-S total scores ##
####################################################################################################################
aux <- Database[,c("EQ.INDEX",paste0("STMartin.",c("SD","EW","PW","MW","RI","PD","IR","SI")))]

## Compute correlation matrix ##
M <- cor(aux, method="spearman")
colnames(M) <- rownames(M) <- c("EQ-Index","SD","EW","PW","MW","RI","PD","IR","SI")
round(tril(M),2)

## Hypothesis test (H0: rho=0 vs H1: rho!=0) ##
rho <- corr.test(aux, method="spearman", adjust="none")
colnames(rho$p) <- rownames(rho$p) <- c("EQ-Index","SD","EW","PW","MW","RI","PD","IR","SI")
round(tril(rho$p),2)

## Plot of the correlation matrix ##
graphics.off()
pdf("Figure_CorrelationMatrix.pdf")
corrplot(M, method="color", p.mat=rho$p, sig.level=0.05, addCoef.col=1)
dev.off()


######################################################################################################
## Figure S1: Scatterplot matrix between EQ-5D utility scores and domains of St.MQoL-S total scores ##
######################################################################################################
aux <- Database[,c("EQ.INDEX",paste0("STMartin.",c("SD","EW","PW","MW","RI","PD","IR","SI")))]
colnames(aux) <- c("EQ-Index","SD","EW","PW","MW","RI","PD","IR","SI")

graphics.off()
pdf("FigureS1.pdf", width=12, height=10)
ggpairs(aux, upper=list(continuous=wrap("cor", method="spearman", digits=2)))
dev.off()
