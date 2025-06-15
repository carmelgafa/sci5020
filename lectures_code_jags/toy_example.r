library(ggplot2)

heights <- c(160, 165, 170, 180, 185, 190, 160, 155, 165)

# prior for mean N(170,100)
# std dev is 10
# mean is 170

mu_values <- seq(140, 200, length.out = 1000)

mu_prior <- dnorm(mu_values, mean = 170, sd = 10)

mu_plot <- ggplot(data = data.frame(mu = mu_values, density = mu_prior),
aes(x = mu, y = density)) +
  geom_line(color = "blue", size = 1) +
  labs(title = "Prior Distribution for μ", x = "μ (Mean)", y = "Density") +
  theme_minimal()

print(mu_plot)


# prior for taou Gamma(1,1)
# shape is 1
# rate is 1

tau_values <- seq(0, 5, length.out = 1000)

tau_prior <- dgamma(tau_values, shape = 1, rate = 1)

tau_plot <- ggplot(data = data.frame(tau = tau_values, density = tau_prior),
aes(x = tau, y = density)) +
  geom_line(color = "red", size = 1) +
  labs(title = "Prior Distribution for τ", x = "τ (Precision)", y = "Density") +
  theme_minimal()

print(tau_plot)



library(rjags)


model_description <- "model {
  for (i in 1:N) {
    heights[i] ~ dnorm(mu, tau)
  }
  
  mu ~ dnorm(170, 0.01) # mean 170, precision 0.01
  tau ~ dgamma(1, 1)
}"

n_chains <- 3
n_burnin <- 3000
n_samples <- 15000
jags_data <- list(heights = heights, N = length(heights))

# create three initial values
initial_values <-function(){ list(
  list(mu = 165, tau = 0.95),
  list(mu = 170, tau = 1.00),
  list(mu = 175, tau = 1.05)
)}

parameters_to_monitor <- c("mu", "tau", "sigma")

model <- jags.model(textConnection(model_description),
                    data = jags_data,
                    inits = initial_values(),
                    n.chains = n_chains)


update(model, n_burnin)


samples <- coda.samples(model = model,
                        variable.names = parameters_to_monitor,
                        n.iter = n_samples,
                        thin = 20)


plot(samples)

# chain1 <- samples[[3]]
# plot(chain1[, "mu"], type = "l", main = "mu - Chain 1")

library(coda)

print(gelman.diag(samples))

gelman.plot(samples)

# plot(acfplot(samples[, "mu"]))
