set.seed(2023)  # Ensure reproducibility

library(ggplot2)

# Generate data
x <- seq(0, 30, by = 0.5)
y <- 2 - 0.6*x + 0.4*x^2
error <- rnorm(length(y), mean = 0.1, sd = 10)  # Random noise
y.real <- y + error

# Fit quadratic model
model <- lm(y.real ~ x + I(x^2))

# Create prediction data
prd <- data.frame(x = seq(min(x), max(x), length.out = 100))
err <- predict(model, newdata = prd, se.fit = TRUE)

# Confidence intervals
prd$fit <- err$fit
prd$lci <- err$fit - 1.96 * err$se.fit
prd$uci <- err$fit + 1.96 * err$se.fit

# Plot
p <- ggplot(prd, aes(x = x, y = fit)) +
  theme_bw() +
  geom_line(color = "red") +
  geom_ribbon(aes(ymin = lci, ymax = uci), alpha = 0.2, fill = "blue") +
  geom_point(data = data.frame(x, y.real), aes(x = x, y = y.real), color = "black") +
  ggtitle("Polynomial Regression with 95% Confidence Interval")

print(p)