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

