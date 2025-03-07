# Set seed for reproducibility
set.seed(2023)

# Load necessary libraries
library(ggplot2)

# Generate data
n <- 100  # Sample size
X <- seq(0, 10, length.out = n)  # Independent variable
beta_0 <- 2  # True intercept
beta_1 <- 3  # True slope
epsilon <- rnorm(n, mean = 0, sd = 2)  # Random noise

# Compute Y values
Y <- beta_0 + beta_1 * X + epsilon

# Fit OLS model
model <- lm(Y ~ X)

# Extract estimated coefficients
beta_hat <- coef(model)
beta_0_hat <- beta_hat[1]
beta_1_hat <- beta_hat[2]


prd <- data.frame(X = seq(min(X), max(X), length.out = 100))
err <- predict(model, newdata = prd, se.fit = TRUE)


# Compute residuals
residuals <- residuals(model)

# Check the moment condition: Sum of residuals * X should be close to 0
moment_condition <- sum(residuals * X) / n
cat("Moment condition (1/n * Σ ε_i * X_i) ≈", moment_condition, "\n")

# Plot Residuals vs. X
p <- ggplot(data.frame(X, residuals), aes(x = X, y = residuals)) +
  geom_point(color = "blue", alpha = 0.6) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Residuals vs X (Checking E[ε|X] = 0)",
       x = "X",
       y = "Residuals") +
  theme_minimal()

print(p)