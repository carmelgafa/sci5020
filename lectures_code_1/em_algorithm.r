#fully observed lifetime
tobs<-c(1764, 2772, 3444, 3542, 3780, 4860, 5196, 408, 408, 1344, 1344, 1440, 408, 408, 504, 504, 504)
#censored lifetime observations
tcens<-c(8064, 8064, 8064, 8064, 8064, 8064, 8064, 8064, 8064, 8064, 5448, 5448, 5448, 1680, 1680, 1680, 1680, 1680, 528, 528, 528, 528, 528)
#full vector of lifetime observations
t<-c(tobs,tcens)
#temperatures pertaining to observed lifetimes
tempobs<-c(170, 170, 170, 170, 170, 170, 170, 190, 190, 190, 190, 190, 220, 220, 220, 220, 220)
#temperatures pertaining to censored lifetimes
tempcens<-c(150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 170, 170, 170, 190, 190, 190, 190, 190, 220, 220, 220, 220, 220)
#full vector of temperature observations
temp<-c(tempobs,tempcens)
#applying the necessary transformations for the regression model
logtobs<-log(tobs)
logtcens<-log(tcens)
logt<-c(logtobs, logtcens)
vobs<-1000/(273.2+tempobs)
vcens<-1000/(273.2+tempcens)
v<-c(vobs,vcens)
#
lmobject<-lm(logt~v)
lmobject$coefficients[1]
#initial theta
beta0star<-lmobject$coefficients[1]
beta1star<-lmobject$coefficients[2]
sigmastar<-2
thetastar<-c(beta0star,beta1star,sigmastar)
print(thetastar)
#defining sample size
n<-40
for (i in 1:100){
  #evaluating mu_i's and H_i's 
  mu<-thetastar[1]+thetastar[2]*vcens
  x<-(logtcens-mu)/thetastar[3]
  H<-dnorm(x)/(1-pnorm(x))
  #evaluation E[Z] and E[Z^2] (expectation step)
  m1<-mu+sigmastar*H
  m2<-(mu^2)+(sigmastar^2)+sigmastar*(logtcens+mu)*H
  #defining the function -E[log(theta|Y,Z)]
  #expected negative loglikelihood
  lmin<-function(theta) n*log(theta[3])+sum(logtobs^2)*(0.5*(theta[3]^-2))+17*(0.5*(theta[1]^2)*(theta[3]^-2))+sum(vobs^2)*(0.5*(theta[2]^2)*(theta[3]^-2))-sum(logtobs)*(theta[1]*(theta[3]^-2))-sum(logtobs*vobs)*(theta[2]*(theta[3]^-2))+sum(vobs)*(theta[1]*theta[2]*(theta[3]^-2))+(23/2)*((theta[1]/theta[3])^2)+sum(vcens^2)*(0.5*((theta[2]/theta[3])^2))+sum(vcens)*(theta[1]*theta[2]*(theta[3]^-2))+sum(m2)*(0.5*(theta[3]^-2))-sum(m1)*(theta[1]*(theta[3]^-2))-sum(m1*vcens)*(theta[2]*(theta[3]^-2))
  #minimizing the expected negative loglikelihood
  thetastar<-optim(thetastar,lmin, method='Nelder-Mead')$par
  print(thetastar)
}
finaltheta<-thetastar
finaltheta

plot(temp,exp(finaltheta[1]+finaltheta[2]*(1000/(273.2+temp))),col='red',ylab='t')
points(temp,t)
