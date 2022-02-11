  library("SASxport")
  library("dplyr")
  library("ggpubr")
  library("ggplot2")
  library("foreign")
  
  ## Loading data from sources provided from NNAHES Website
  getwd()
  dbts<-read.xport("DIQ_J.XPT")
  dbts_sub <- dbts[,c("SEQN","DIQ010")]
  body_m<-read.xport("BMX_J.XPT")
  body_m_sub<- body_m[,c("SEQN","BMXWT","BMXHT","BMXWAIST","BMXHIP","BMXBMI")]
  bp<-read.xport("BPQ_J.XPT")
  bp_sub<-bp[,c("SEQN","BPQ020","BPQ080")]
  alcohol_use<-read.xport("ALQ_J.XPT")
  alcohol_use_sub<-alcohol_use[,c("SEQN","ALQ290","ALQ130")]
  
  ## Merging all data into one matrix
  joined_data<- inner_join(dbts_sub,body_m_sub,by='SEQN')%>%inner_join(.,bp_sub,by='SEQN')%>%inner_join(.,alcohol_use_sub,by='SEQN')
  data_final<-na.omit(joined_data)
  summary(data_final)
  
  ###Problem2
  ##In case of diabetes:: 1->1(Yes), 2->0(No) rest->N/A
  
  data_final<-within(data_final,DIQ010[DIQ010==2]<-0)
  data_final<-within(data_final,DIQ010[DIQ010!=1 & DIQ010!=0]<-NA)
  data_final<-within(data_final,ALQ290[ALQ290==99|ALQ290==77|ALQ290=='.']<-NA)
  data_final<-within(data_final,ALQ130[ALQ130==999|ALQ130==777|ALQ130=='.']<-NA)
  data_final<-within(data_final,BMXWT[BMXWT=='.']<-NA)
  data_final<-within(data_final,BMXWAIST[BMXWAIST=='.']<-NA)
  data_final<-within(data_final,BMXHT[BMXHT=='.']<-NA)
  data_final<-within(data_final,BMXBMI[BMXBMI=='.']<-NA)
  data_final<-within(data_final,BMXHIP[BMXHIP=='.']<-NA)
  data_final<-within(data_final,BPQ020[BPQ020=='.'|BPQ020==9|BPQ020==7]<-NA)
  data_final<-within(data_final,BPQ080[BPQ080=='.'|BPQ080==9|BPQ080==7]<-NA)
  data_final<-na.omit(data_final)
  summary(data_final)
  
  ##Add column Overweight : 1 if BMI>30, else 0
  data_final<-mutate(data_final, Overweight=0)
  data_final<-within(data_final, Overweight[BMXBMI>30]<-1)
  
  ##Correlation Test Between BMXBMI and BMXHT
  cor.test(data_final$BMXBMI, data_final$BMXHT, method="pearson")
  
  #cor = -0.03994298
  #p-value = 0.3806
  #BMI = weight(kg)/[height(in m)]^2
  
  ##Factor
  factor(data_final)
  
  ##Class
  class(data_final)
  
  #Checking new summary of data
  summary(data_final)

  ###Problem 3 
  ##Logistic Regression model

  logit_model_1<-glm(DIQ010~BMXHT+BMXWAIST+BPQ020,family=binomial(link = "logit"),data=data_final)
  summary(logit_model_1)
  
  logit_model_2<-glm(DIQ010~Overweight,family=binomial(link = "logit"),data=data_final)
  summary(logit_model_2)
  
  logit_model_3<-glm(DIQ010~BPQ080,family=binomial(link = "logit"),data=data_final)
  summary(logit_model_3)
  
  logit_model_4<-glm(DIQ010~ALQ130,family=binomial(link = "logit"),data=data_final)
  summary(logit_model_4)
  
  logit_model_5<-glm(DIQ010~ALQ290,family=binomial(link = "logit"),data=data_final)
  summary(logit_model_5)
  
  ## BMI V/S Diabetes Relation
  logit_model_6<-glm(DIQ010~BMXBMI,family=binomial(link = "logit"),data=data_final)
  summary(logit_model_6)
  BMI_range <- seq(from=0, to=150, by=0.1)
  Temp.df<- data.frame(BMXBMI= BMI_range)
  Temp.df$DIQ010 <- predict(logit_model_6, newdata=Temp.df, type="response")
  ggplot(Temp.df, aes(x=BMXBMI, y=DIQ010))+geom_line()+ggtitle("Diabetes v/s BMI")+ylab("Diabetes") + xlab("BMI")+ ylim(0,1) 
  
  ## Distribution of Body Weight
  wt<-ifelse(data_final$DIQ010==1,data_final$BMXWT,NA_integer_)
  wt<-na.omit(wt)
  boxplot(wt,main="Distribution of Body Weight",ylab = "Weights",ylim = c(40, 140), border = par("fg"), col = "turquoise")
  summary(wt)
  
  ## Distribution of Body Mass Index
  BodyMI<-ifelse(data_final$DIQ010==1,data_final$BMXBMI,NA_integer_)
  BodyMI<-na.omit(BodyMI)
  BodyMI_frame<-data.frame(BodyMI)
  BodyMI_hist<-ggplot(BodyMI_frame, aes(BodyMI))+ geom_histogram(fill = 'orange', color = 'brown', breaks=seq(10,70,2)) + labs(title = 'BMI HISTOGRAM', x = 'BMI', y = 'Number of Samples') + xlim(10,NA)
  summary((BodyMI))
  BodyMI_hist