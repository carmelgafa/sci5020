library(ggplot2)

set.seed(2023)  # Ensure reproducibility

N <-100

data_poisson <- rpois(n = N, lambda = 5)

LL_poisson <- function(lambda, y){
#   LL <- sum(y * log(lambda) - lambda - log(factorial(y)))

  LL <- sum(dpois(y, lambda, log = TRUE))
  return(LL)
}

lambda_values <- seq(1, 20, by = 0.01)

LL <- sapply(lambda_values, function(lambda){LL_poisson(lambda, data_poisson)})

df <- data.frame(LL, lambda_values)

p = ggplot(df, aes(x = lambda_values, y = LL)) +
  geom_point(color="blue", alpha=0.6) +
  labs(title = "Log-Likelihood for Poisson Distribution",
       x = "Lambda",
       y = "Log-Likelihood") +
  theme_bw()

print(p)