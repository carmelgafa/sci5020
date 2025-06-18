library(ggplot2)

#betas
x_beta <- seq(-30, 30, length.out = 1000)
beta_prior <- dnorm(x_beta, mean = 0, sd = sqrt(100))  # sd = sqrt(variance)

plt1 <- ggplot(data.frame(x = x_beta, y = beta_prior), aes(x = x, y = y)) +
  geom_line(color = "blue", size = 1) +
  labs(title = "Prior Distribution for beta (N(0, 100))",
       x = expression(beta),
       y = "Density") +
  theme_minimal()

#tao
x_tau <- seq(0, 10, length.out = 1000)
tau_prior <- dgamma(x_tau, shape = 0.01, rate = 0.01)

plt2 <- ggplot(data.frame(x = x_tau, y = tau_prior), aes(x = x, y = y)) +
  geom_line(color = "red", size = 1) +
  labs(title = "Prior Distribution for tao (Gamma(0.01, 0.01))",
       x = expression(tau),
       y = "Density") +
  theme_minimal()


plot(plt1)
# plot(plt2)