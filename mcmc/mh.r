#Metropolis Hastings

#plotting the target density function
h<-seq(-10,10,0.001)
f<-(sin(h)^2)*(sin(2*h)^2)*dnorm(h)
plot(h,f,type='l')


#defining the target as a function
target<-function(x){(sin(x)^2)*(sin(2*x)^2)*dnorm(x)}

#creating the Metropolis Hastings function
metropolis<-function(x,alpha=0.3){
  #generate y from uniform distribution around (x-alpha, x+alpha)
  y=runif(1,x-alpha,x+alpha)
  #if U is greater than alpha(x,y) then keep the current x by putting into y
  if (runif(1)>target(y)/target(x)) y=x
  #return y
  return(y)
}

#run the algorithm N times (irrelevant of acceptance/rejection of candidate point)
N<-10000
#define x
x<-mat.or.vec(N,1)
#initialize x at 3.14
x[1]<-3.14
#let count = 1
count<-1

for (n in 2:N){
  repeat{
    x[n]<-metropolis(x[n-1])
    count=count+1
    if (x[n]!=x[n-1]){
      break
    } 
  }
}

acceptanceprob<-N/count
print(acceptanceprob)

#trace plot
plot(x,type='l')

# #taking a burn-in of 10%
# burnin<-round(0.1*N,0)

# #plotting EPDF plot minus the burn-in period
# install.packages("EnvStats")
# library(EnvStats)
# epdfPlot(x[(burnin+1):length(N)],main="Empirical PDF",xlab='x')

# #plotting histogram minus the burn-in period
# hist(x[(burnin+1):length(N)], main="Histogram", xlab='x')

