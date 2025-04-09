#Metropolis Hastings

#generate dataset
set.seed(123)
x<-rnorm(100,mean=1,sd=0.5)

#defining the target as a function
#this is made of the normal loglikelihood given by prod(dnorm(x,mu,sigma)),
#the normal prior given by dnorm(mu,1,2) and the gamma prior given by 
#dgamma(sigma^2,shape=2,rate=1)
target<-function(mu,sigma){prod(dnorm(x,mu,sigma))*dnorm(mu,1,2)*dgamma(sigma^2,shape=1,rate=2)}

#as proposals we consider a normal distribution for mu, with the mean being the current
#chain value and the standard deviation being 0.2, and for sigma we consider a proposal
#which is a truncated normal distribution on [0,Inf] with mean being the current chain  
#value and standard deviation being 0.1
install.packages("truncnorm")
library(truncnorm)
#creating the Metropolis Hastings function
metropolis<-function(x1,x2,sigmastar1=0.2,sigmastar2=0.1){
  #generate y1 and y2 from aforementioned truncated normal distributions
  y1<-rnorm(1,x1,sigmastar1)
  y2<-rtruncnorm(1,a=0,b=Inf,mean=x2,sd=sigmastar2)
  #if U is greater than alpha(x,y) then keep the current x1 and x2 by putting into 
  #y1 and y2
  if (runif(1)>(target(y1,y2)/target(x1,x2))*(dnorm(x1,y1,sigmastar1)/dnorm(y1,x1,sigmastar1))*(dtruncnorm(x2,a=0,b=Inf,mean=y2,sd=sigmastar2)/dtruncnorm(y2,a=0,b=Inf,mean=x2,sd=sigmastar2))) {
      y1=x1
      y2=x2
  }
  #return y
  return(c(y1,y2))
}

#run the algorithm N times (irrelevant of acceptance/rejection of candidate point)
N<-10000
#create chain x
chain<-mat.or.vec(N,2)
#initialize x at 3.14
chain[1,]<-c(2,1)
#let count = 1
count<-1
for (n in 2:N){
  repeat{
    chain[n,]<-metropolis(chain[n-1,1],chain[n-1,2])
    count=count+1
    if ((chain[n,1]!=chain[n-1,1])|(chain[n,2]!=chain[n-1,2])){
      break
    } 
  }
}

#calculating the acceptance probability
acceptanceprob<-N/count
print(acceptanceprob)

#trace plots
plot(chain[,1],type='l',ylab="mu",main="Trace Plot of mu")
plot(chain[,2],type='l',ylab="mu",main="Trace Plot of sigma")

# #taking a burn-in of 10%
# burnin<-round(0.1*N,0)

# #trace plots without burn-in
# plot(chain[(burnin+1):N,1],type='l',ylab="mu",main="Trace Plot of mu without burn-in")
# plot(chain[(burnin+1):N,2],type='l',ylab="sigma",main="Trace Plot of sigma without burn-in")


# #plotting EPDF plot minus the burn-in period
# install.packages("EnvStats")
# library(EnvStats)
# epdfPlot(chain[(burnin+1):N,1],main="Empirical PDF of mu",xlab='mu')
# epdfPlot(chain[(burnin+1):N,2],main="Empirical PDF of sigma",xlab='sigma')

# #plotting histogram minus the burn-in period
# hist(chain[(burnin+1):N,1], main="Histogram of mu", xlab='mu')
# hist(chain[(burnin+1):N,2], main="Histogram of sigma", xlab='sigma')
