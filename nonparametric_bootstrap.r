#inputting the sample into x
x<-c(8.26, 6.33, 10.4, 5.27, 5.35, 5.61, 6.12, 6.19, 5.2, 7.01, 8.74, 7.78, 7.02, 6, 6.5, 5.8,5.12, 7.41, 6.52, 6.21, 12.28, 5.6, 5.38, 6.6, 8.74)
#defining the function cv (coefficient of variation)
cv<-function(x) sqrt(var(x))/mean(x)
#creating a vector for 1000 bootstrap estimates
boot<-numeric(1000)
#sampling x with replacement and calculating the
#coefficient of variation 
for (i in 1:1000) boot[i]<-cv(sample(x,replace=T))
#bootstrap estimator is the mean of boot
cvbootstrap<-mean(boot)
#variance of the bootstrap estimator
varcvbootstrap<-var(boot)
#CI for Bootstrap using normal distribution
LCInormal95<-cvbootstrap+qnorm(0.025)*sqrt(varcvbootstrap)
UCInormal95<-cvbootstrap+qnorm(0.975)*sqrt(varcvbootstrap)
#CI for Bootstrap using t distribution
LCIt95<-cvbootstrap+qt(0.025,24)*sqrt(varcvbootstrap)
UCIt95<-cvbootstrap+qt(0.975,24)*sqrt(varcvbootstrap)
#empirical confidence intervals
LCIempirical95<-quantile(boot,probs=0.025)
UCIempirical95<-quantile(boot,probs=0.975)
#sortedboot<-sort(boot)
#LCIempirical95<-sortedboot[25]
#UCIempirical95<-sortedboot[975]

print(cvbootstrap)
print(varcvbootstrap)
print(LCInormal95)
print(UCInormal95)
print(LCIt95)
print(UCIt95)
print(LCIempirical95)
print(UCIempirical95)