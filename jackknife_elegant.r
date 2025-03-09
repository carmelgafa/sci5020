# Sample data
x <- c(8.26, 6.33, 10.4, 5.27, 5.35, 5.61, 6.12, 6.19,
       5.2, 7.01, 8.74, 7.78, 7.02, 6, 6.5, 5.8,
       5.12, 7.41, 6.52, 6.21, 12.28, 5.6, 5.38, 6.6, 8.74)


number_partitions <- 5

# Coefficient of Variation (CV) function
cv <- function(x) sd(x) / mean(x)

# Shuffle x to create y
set.seed(123)  # For reproducibility
x_shuf <- sample(x, length(x), replace = FALSE)


# Generate jackknife samples by removing each fold of 5 elements
# lapply applied a function to each element of a list
# my list is from 1:5
# the function will
# for a = 1 remove element 1 to 5 (5*(1-1)+1):(5*1)
# for a = 2 remove element 6 to 10 (5*(2-1)+1):(5*2)
# and so on
# note the - sign -- I am removing the elements
# so the return for each a is y without the elements 1 to 5, 6 to 10, etc.
jackknife_samples <- lapply(1:number_partitions,
       function(a) x_shuf[-((number_partitions * (a - 1) + 1):(number_partitions * a))])


# since jack_knife_samples is a list vectors we use sapply
# to apply the function cv to each element of the list

# i dont want to evaluate the cf of the original sample for
#each element of the list
# so i evaluate it once
# let us make it more generic using theta and theta_a
theta_hat_m <- cv(x)
theta_m_a <- function(y_a) cv(y_a)

# jackknife estimator for each partition
cvjk <- sapply(jackknife_samples, function(y_a) number_partitions * theta_hat_m - (number_partitions - 1) * theta_m_a(y_a))

#evaluating the jackknife estimator of the CV
#by averaging the cvjk's
cvjackknife <- mean(cvjk)
#evaluating the variance of the jackknife estimator
#of the CV
varcvjackknife <- var(cvjk) / number_partitions
#evaluating the standard error of the jackknife estimator
se_cvjackknife <- sqrt(varcvjackknife)

#evaluating the confidence intervals for the Jackknife
#estimator using the normal distribution
LCInormal95 <- cvjackknife + qnorm(0.025) * se_cvjackknife
UCInormal95 <- cvjackknife + qnorm(0.975) * se_cvjackknife

#evaluating the confidence intervals for the Jackknife
#estimator using the t distribution
LCIt95 <- cvjackknife + qt(0.025, df = length(x) - 1) * se_cvjackknife
UCIt95 <- cvjackknife + qt(0.975, df = length(x) - 1) * se_cvjackknife


cat("Jackknife CV Estimate:", cvjackknife, "\n")
cat("Variance of Jackknife CV:", varcvjackknife, "\n")
cat("95% CI (Normal): [", LCInormal95, ",", UCInormal95, "]\n")
cat("95% CI (t-distribution): [", LCIt95, ",", UCIt95, "]\n")
