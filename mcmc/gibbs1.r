#length of chain required
nsim<-100000


#defining mean vector and variance covariance matrix
mu<-c(3,2)
Sigma<-matrix(c(1,0.5,0.5,4),ncol=2,nrow=2,byrow=TRUE)



#creating object where to store the chain
x<-mat.or.vec(nsim,2)




#starting the first chain at point 5
x[1,1]<-5
#simulating the first point in the second chain based on x[1,1]
x[1,2]<-rnorm(1,mean=mu[2]+Sigma[2,1]*(Sigma[1,1]^-1)*(x[1,1]-mu[1]),sd=sqrt(Sigma[2,2]-Sigma[2,1]*(Sigma[1,1]^-1)*Sigma[1,2]))
#running the Gibbs sampler for the rest of the chain
for (i in 2:nsim){
  x[i,1]<-rnorm(1,mean=mu[1]+Sigma[1,2]*(Sigma[2,2]^-1)*(x[i-1,2]-mu[2]),sd=sqrt(Sigma[1,1]-Sigma[1,2]*(Sigma[2,2]^-1)*Sigma[2,1]))
  x[i,2]<-rnorm(1,mean=mu[2]+Sigma[2,1]*(Sigma[1,1]^-1)*(x[i,1]-mu[1]),sd=sqrt(Sigma[2,2]-Sigma[2,1]*(Sigma[1,1]^-1)*Sigma[1,2]))
}
#histograms
hist(x[,1],main="Histogram of x1",xlab="x1")
hist(x[,2],main="Histogram of x2",xlab="x2")
#checking that mean and covariance are "close" to those
#we intend to simulate
print(mean(x[,1]))
print(mean(x[,2]))
print(cov(x))

plot(x)
