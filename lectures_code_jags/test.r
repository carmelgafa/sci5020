#Introduction to JAGS presentation
rm(list = ls())
#Load the package that links R to JAGS
library(rjags)

#If the above line executes successfully you get the following message:
#Loading required package: coda
#Linked to JAGS 4.3.1
#Loaded modules: basemod,bugs
#identifying the values of the shape and rate parameterss
#of the gamma prior 
a<-seq(0,2,by=0.01)
b<-dgamma(a,shape=0.01,rate=0.01)
plot(a,b)
#Specifying the model for Example 1 in the slides
model<-"model{
  for(i in 1:n){
    y[i]~dnorm(mu[i],taue)# taue here is precision not variance!!!
    mu[i]<-beta0+beta1*x[i]
  } 
  taue~dgamma(0.01,0.01)
  beta0~dnorm(0,0.01)
  beta1~dnorm(0,0.01)
  #next we define the priors
  
}"

#Input the data
dat<-data.frame(y=c(6,7,8,4,9,11,12,14,15,19),x=c(1,2,3,4,5,6,7,8,9,10))
data_jags = list(y = dat$y, n = nrow(dat),x = dat$x)
#Initial Values
initial<-list(taue=1,beta0=0,beta1=1)
#Checking model was correctly specified prior to running the simulation
jagmod<-jags.model(textConnection(model),data_jags,inits=initial)

post<-coda.samples(jagmod,c('taue','beta0','beta1'),10000)
summary(post)
#adjust plot margins
par(mar = c(1, 1, 1, 1))
plot(post)


#Adding more chains
jagmod2<-jags.model(textConnection(model),data_jags,inits=initial,n.chains=3)

post2<-coda.samples(jagmod2,c('taue','beta0','beta1'),10000)
summary(post2)
library(lattice)
xyplot(post2)
# Trace for a selected parameter, chains in separate panels:
xyplot(post2[,'beta0'],outer=T,layout=c(1,3))
gelman.diag(post2)
gelman.plot(post2)
acfplot(post2,outer=T)
effectiveSize(post2)#summed across chains
lapply(post2,effectiveSize)



# #Issuing posterior with 10000 samples plus burn in of 2000
# rm(list = ls())
# #Load the package that links R to JAGS
# library(rjags)
# #Specifying the model for Example 1 in the slides
# model<-"model{
#   for(i in 1:n){
#     y[i]~dnorm(mu[i],taue)# taue here is precision not variance!!!
#     mu[i]<-beta0+beta1*x[i]
#   } 
#   taue~dgamma(0.01,0.01)
#   beta0~dnorm(0,0.01)
#   beta1~dnorm(0,0.01)
#   #next we define the priors
  
# }"

# #Input the data
# dat<-data.frame(y=c(6,7,8,4,9,11,12,14,15,19),x=c(1,2,3,4,5,6,7,8,9,10))
# data_jags = list(y = dat$y, n = nrow(dat),x = dat$x)
# #Initial Values
# initial<-list(taue=1,beta0=0,beta1=1)
# #Checking model was correctly specified prior to running the simulation
# jagmod2<-jags.model(textConnection(model),data_jags,inits=initial)
# post2<-coda.samples(jagmod2,c('taue','beta0','beta1'),12000)
# summary(window(post2,2001))#removing burn-in

# #Computing DIC
# #Load the package that links R to JAGS
# library(runjags)
# #Specifying the model for Example 1 in the slides
# m2<-"model{
#   for(i in 1:10){
#     y[i]~dnorm(mu[i],taue)# taue here is precision not variance!!!
#     mu[i]<-beta0+beta1*x[i]
#   } 
#   taue~dgamma(0.01,0.01)
#   beta0~dnorm(0,0.01)
#   beta1~dnorm(0,0.01)
#   #next we define the priors
  
# }"

# #Input the data
# dat<-data.frame(y=c(6,7,8,4,9,11,12,14,15,19),x=c(1,2,3,4,5,6,7,8,9,10))
# data_jags = list(y = dat$y,x = dat$x)
# #Initial Values
# #For 3 chains create initial values for the stochastic nodes. Note initialisation by a list of lists:
# ini1<-list(beta0=-1,beta1=0,taue=1,.RNG.name = "base::Wichmann-Hill",.RNG.seed = 1)
# ini2<-list(beta0= 0,beta1=1,taue=20000,.RNG.name = "base::Wichmann-Hill",.RNG.seed = 2)
# ini2<-list(beta0= 4,beta1=5,taue=20,.RNG.name = "base::Wichmann-Hill",.RNG.seed = 2)
# ini<-list(ini1,ini2,ini2)

# #List the nodes to monitor:
# nodes<-c('beta0','beta1','taue','dic')#dic is computed as a parameter 
# #here the command is run.jags instead of coda.samples and it takes burn-in length as input
# post2<-run.jags(model=m2,monitor=nodes,data=dat,inits=ini,n.chains=3,burnin = 2000)
# summary(post2)
# post2

# print(gelman.diag(post2))
