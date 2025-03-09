# Question 1.6
# Generate 1000 points from an exponential distributed random variable
# with rate parameter λ = 1.5.
# Plot the histogram of the exponential random variable with lambda = 1.5
# also overlay the theoretical density function.




library(ggplot2)
library(glue)

set.seed(50)
lambda <- 1.5
x <- rexp(n = 1000, rate = lambda)

data <- data.frame(x = x)

p <- ggplot(data,
            aes(x = x)) +
  geom_histogram(
                 aes(y = after_stat(density)),
                 bins = 50, fill = "blue",
                 color = "black",
                 alpha = 0.6) +
  stat_function(
                fun = function(x) lambda * exp(-lambda * x),
                color = "red",
                size = 1) +
  labs(title = glue("Histogram of exponentially distributed 
  random variable with lambda = {lambda}"),
       x = "x", y = "Density") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

quartz()
print(p)


LL_exponential <- function(lambda, x) {
  n <- length(x)
  log_likelihood <- n * log(lambda) - lambda * sum(x)
  return(log_likelihood)
}

lambda_values <- seq(0.1, 5, by = 0.01)
log_likelihood_values <- sapply(lambda_values,
                                function(lambda) LL_exponential(lambda, x))

df <- data.frame(lambda_values, log_likelihood_values)

p <- ggplot(df, aes(x = lambda_values, y = log_likelihood_values)) +
  geom_point(
             color = "blue",
             alpha = 0.6) +
  labs(
       title = "Log-Likelihood for with varying lambda values",
       x = "Lambda",
       y = "Log-Likelihood") +
  theme_bw()

quartz()
print(p)

max_ll <- max(log_likelihood_values)
max_lambda <- lambda_values[log_likelihood_values == max_ll]
print(glue("Lambda value for maximum log-likelihood is {max_lambda}"))