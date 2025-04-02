set.seed(2023)  # Ensure reproducibility

library(ggplot2)

# Generate data
x <- seq(0, 30, by = 0.5)
y <- 2 - (0.6 * x) + (0.4 * x^2)
error <- rnorm(length(x), mean = 0.1, sd = 10)  # Random noise
y_real <- y + error

model_degree_2 <- lm(y_real ~ poly(x, 2))
print(summary(model_degree_2))


model_raw <- lm(y_real ~ x + I(x^2))
print(summary(model_raw))



df <- data.frame(
  fitted = fitted(model_raw),
  residuals = residuals(model_degree_2)
)

p <- ggplot(df, aes(x = x, y = y_real)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  theme_minimal() +
  labs(title = "x vs y real", x = "x", y = "noisy y")

print(p)


# Create prediction data
prd <- data.frame(x = seq(min(x), max(x), length.out = 100))

# se.fit TRUE returns both:
#   fit -- The predicted y values.
#   se.fit -- The standard error of each prediction.
err <- predict(model_degree_2, newdata = prd, se.fit = TRUE)


# Confidence intervals
prd$fit <- err$fit
prd$lci <- err$fit - 1.96 * err$se.fit
prd$uci <- err$fit + 1.96 * err$se.fit

# Plot
p <- ggplot(prd, aes(x = x, y = fit)) +
  theme_bw() +
  geom_line(color = "red") +
  geom_ribbon(aes(ymin = lci, ymax = uci), alpha = 0.2, fill = "blue") +
  geom_point(data = data.frame(x, y_real), aes(x = x, y = y_real), color = "black") +
  ggtitle("Polynomial Regression with 95% Confidence Interval")

print(p)
