# Load necessary library
library(ggplot2)

# Prior for mu: Normal(170, 100)
mu_values <- seq(140, 200, length.out = 1000)  # Range of possible mu values
mu_prior <- dnorm(mu_values, mean = 170, sd = 10)  # Normal density



# Plot the prior for mu
mu_plot <- ggplot(data = data.frame(mu = mu_values, density = mu_prior), aes(x = mu, y = density)) +
  geom_line(color = "blue", size = 1) +
  labs(title = "Prior Distribution for μ", x = "μ (Mean)", y = "Density") +
  theme_minimal()

# Prior for tau: Gamma(1, 1)
tau_values <- seq(0, 5, length.out = 1000)  # Range of possible tau values
tau_prior <- dgamma(tau_values, shape = 1, rate = 1)  # Gamma density

# Plot the prior for tau
tau_plot <- ggplot(data = data.frame(tau = tau_values, density = tau_prior), aes(x = tau, y = density)) +
  geom_line(color = "red", size = 1) +
  labs(title = "Prior Distribution for τ", x = "τ (Precision)", y = "Density") +
  theme_minimal()

# Display the plots
print(mu_plot)
print(tau_plot)
