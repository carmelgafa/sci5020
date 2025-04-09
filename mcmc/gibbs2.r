install.packages("Envstats")
library(EnvStats)
install.packages("coda")
library(coda) #for trace plot

rm(list = ls()) #clearing variables

#defining valid iterations, burn-in period and total iterations
validIterations<-10000
burnInPeriod<-2000
totalIterations<-validIterations+burnInPeriod

#defining X and Y
X<-seq(0,5)
Y<-c(12,10,8,11,6,7)

#Declaring matrix of parameters and ensuring entries in the 1st column correspond to
#initial values
parameterNames<-c("a","b","tau")
parameterMatrix<-mat.or.vec(3,totalIterations)
parameterMatrix[,1]<-c(mean(Y),0,1)

#Running Gibbs Sampler
for (i in 2:totalIterations){ #updating paramaters
  parameterMatrix[1,i]<-rnorm(1,(parameterMatrix[3,i-1]/(6*parameterMatrix[3,i-1]+0.1))*sum(Y-parameterMatrix[2,i-1]*X),((6*parameterMatrix[3,i-1]+0.1)^(-1))) 
  parameterMatrix[2,i]<-rnorm(1,(parameterMatrix[3,i-1]*sum((Y-parameterMatrix[1,i])*X))/(0.1+parameterMatrix[3,i-1]*sum(X^2)),1/(0.1+parameterMatrix[3,i-1]*sum(X^2)))
  parameterMatrix[3,i]<-rgamma(1,3.001,0.001+0.5*sum((Y-parameterMatrix[1,i]-parameterMatrix[2,i]*X)^2))
}
#plotting trace plots
for (i in 1:2){ 
  #plots
  traceplot(as.mcmc(parameterMatrix[i,]),xlab ="Iteration No.",ylab="Parameter Value",main=c("Trace Plot for Parameter ",parameterNames[i]))
  hist(parameterMatrix[i,2001:12000],ylab = "Count",xlab ="Parameter Value",main=c("Histogram of parameter ",parameterNames[i]))
  epdfPlot(parameterMatrix[i,],main = c("Empirical PDF for parameter ",parameterNames[i]),xlab="Parameter Value")
}
traceplot(as.mcmc(parameterMatrix[3,]),main="Trace Plot for Parameter Tau",xlab ="Iteration No.")
hist(parameterMatrix[3,2001:12000] ,ylab = "Count",xlab ="Parameter Value",main=c("Histogram of parameter value ",parameterNames[3]))
epdfPlot(parameterMatrix[3,],main = c("Empirical PDF for parameter ",parameterNames[3]),xlab="Parameter Value")
