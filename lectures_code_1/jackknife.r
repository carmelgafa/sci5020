#entering the sample into x
x <- c(8.26, 6.33, 10.4, 5.27, 5.35, 5.61, 6.12, 6.19,
    5.2, 7.01, 8.74, 7.78, 7.02, 6, 6.5, 5.8,
     5.12, 7.41, 6.52, 6.21, 12.28, 5.6, 5.38, 6.6, 8.74)
#defining the function cv
cv <- function(x) sqrt(var(x)) / mean(x)


#reordering x and placing it in y
y <- mat.or.vec(25, 1)
set.seed(123)
y <- sample(x, length(x), replace = FALSE)

#ya's are y without partition a for a=1,...,5
y1 <- mat.or.vec(20, 1)
y2 <- mat.or.vec(20, 1)
y3 <- mat.or.vec(20, 1)
y4 <- mat.or.vec(20, 1)
y5 <- mat.or.vec(20, 1)
for (i in 1:20) y1[i] <- y[i +  5]
for (i in 1:5) y2[i] <- y[i]
for (i in 6:20) y2[i] <- y[i + 5]
for (i in 1:10) y3[i] <- y[i]
for (i in 11:20) y3[i] <- y[i + 5]
for (i in 1:15) y4[i] <- y[i]
for (i in 16:20) y4[i] <- y[i + 5]
for (i in 1:20) y5[i] <- y[i]
#evaluating thetahat_m,a for a=1,...5
cvjk<-mat.or.vec(5,1)
cvjk[1] <- 5 * cv(x) - 4 * cv(y1)
cvjk[2] <- 5 * cv(x) - 4 * cv(y2)
cvjk[3] <- 5 * cv(x) - 4 * cv(y3)
cvjk[4] <- 5 * cv(x) - 4 * cv(y4)
cvjk[5] <- 5 * cv(x) - 4 * cv(y5)


#evaluating the jackknife estimator of the CV
#by averaging the cvjk's
cvjackknife<-mean(cvjk)
#evaluating the variance of the jackknife estimator
#of the CV
varcvjackknife<-(1/5)*var(cvjk)
#evaluating the confidence intervals for the Jackknife
#estimator using the normal distribution
LCInormal95<-cvjackknife+qnorm(0.025)*sqrt(varcvjackknife)
UCInormal95<-cvjackknife+qnorm(0.975)*sqrt(varcvjackknife)
#evaluating the confidence intervals for the Jackknife
#estimator using the t distribution
LCIt95<-cvjackknife+qt(0.025, 24) * sqrt(varcvjackknife)
UCIt95<-cvjackknife+qt(0.975, 24) * sqrt(varcvjackknife)

print(cvjackknife)
print(varcvjackknife)
print(LCInormal95)
print(UCInormal95)
print(LCIt95)
print(UCIt95)