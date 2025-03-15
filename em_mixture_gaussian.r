#full vector
x<-c(7.33,9.66,9,5,8.82,10.36,1.78,8.42,10.2,7.69,1.57,10.85,8.66,8.18,-1.28,3.06,10.18,2.86,10.9,10.8,10,1.46,10.16,1.91,1.92,8.47,4.17,3.75,-0.02,10.53)
#plotting empirical PDF
install.packages("EnvStats")
library(EnvStats)
epdfPlot(x)
#plotting histogram
hist(x)
#estimate for initial values for mu1,mu2,sigma1,sigma2,pi1,pi2
mem<-kmeans(x,2)$cluster
mu1 <- mean(x[mem==1])
mu2 <- mean(x[mem==2])
sigma1 <- sd(x[mem==1])
sigma2 <- sd(x[mem==2])
pi1 <- sum(mem==1)/length(mem)
pi2 <- sum(mem==2)/length(mem)
print(mu1)
print(mu2)
print(sigma1)
print(sigma2)
print(pi1)
print(pi2)
#modified sum only considers finite values
sum.finite <- function(x) {
  sum(x[is.finite(x)])
}
# starting value of expected value of the log likelihood
Qprev <- -Inf
Q<- sum.finite(log(pi1)+log(dnorm(x, mu1, sigma1))) + sum.finite(log(pi2)+log(dnorm(x, mu2, sigma2)))
print(Qprev)
print(Q)
k<-2
while (abs(Q-Qprev)>=1e-6) {
  #E-step
  #calculating the posterior probabilities that each component has to eachdata point
  comp1 <- pi1 * dnorm(x, mu1, sigma1)
  comp2 <- pi2 * dnorm(x, mu2, sigma2)
  comp.sum <- comp1 + comp2
  p1 <- comp1/comp.sum
  p2 <- comp2/comp.sum
  #M-step
  #calculating component parameters
  pi1 <- sum.finite(p1) / length(x)
  pi2 <- sum.finite(p2) / length(x)
  mu1 <- sum.finite(p1 * x) / sum.finite(p1)
  mu2 <- sum.finite(p2 * x) / sum.finite(p2)
  sigma1 <- sqrt(sum.finite(p1 * (x-mu1)^2) / sum.finite(p1))
  sigma2 <- sqrt(sum.finite(p2 * (x-mu2)^2) / sum.finite(p2))
  print(c(mu1,mu2,sigma1,sigma2,pi1,pi2))
  #k <- k + 1
  Qprev<-Q
  Q<- sum.finite(log(pi1)+log(dnorm(x, mu1, sigma1))) + sum.finite(log(pi2)+log(dnorm(x, mu2, sigma2)))
}
# mu1 = 9.459767
# mu2 = 2.198961
# sigma1 = 1.111081
# sigma2 = 1.699045
# p = 0.5987451
