
## Question i

mu <- 5
sigma_2 <- 4
sigma <- sqrt(sigma_2)
n <- 1000

set.seed(1001)
x <- rnorm(n, mean = mu, sd = sigma)

# Save histogram object (does not plot automatically)
plt <- hist(x, breaks = 50, col = "skyblue", main = "Histogram of Simulated Data",
            xlab = "x values", border = "white", freq = FALSE)
plot(plt)

curve(dnorm(x, mean = mu, sd = sigma), col = "blue", lwd = 2, add = TRUE)


## Question ii

m0 <- 0
v0_sq <- 1e6
a <- 0.01
b <- 0.01

## Question iii

#sampler setting
n_iter <- 10000
burn_in <- 2000

#storeage for mu and tao 
mu_samples <- numeric(n_iter)
tau_samples <- numeric(n_iter)

#init tao
tau_current <- 1 / var(x)  # start with reasonable value

x_bar <- mean(x)

for (t in 1:n_iter) {
  var_mu <- 1 / (tau_current * n + 1 / v0_sq)
  mean_mu <- var_mu * (tau_current * n * x_bar + m0 / v0_sq)
  mu_current <- rnorm(1, mean = mean_mu, sd = sqrt(var_mu))

  #sample tao given mu
  shape_tau <- a + n / 2
  rate_tau <- b + sum((x - mu_current)^2) / 2
  tau_current <- rgamma(1, shape = shape_tau, rate = rate_tau)

  #store
  mu_samples[t] <- mu_current
  tau_samples[t] <- tau_current
}

#burn-in
mu_post <- mu_samples[(burn_in + 1):n_iter]
tau_post <- tau_samples[(burn_in + 1):n_iter]
sigma2_post <- 1 / tau_post  # for inference on variance


print(mean(mu_post))
print(quantile(mu_post, c(0.025, 0.5, 0.975)))
print(mean(sigma2_post))
print(quantile(sigma2_post, c(0.025, 0.5, 0.975)))

#question iv

mu_chain <- mcmc(mu_post)
tau_chain <- mcmc(tau_post)
sigma2_chain <- mcmc(sigma2_post)

#traceplota
par(mfrow = c(2, 1))
plot(mu_chain, main = "Traceplot of mu", col = "steelblue")
plot(sigma2_chain, main = "Traceplot of sigma^2", col = "darkgreen")

#autocorrelation plt
par(mfrow = c(2, 1))
# autocorr.plot(mu_chain, main = "Autocorrelation Plot of mu")
autocorr.plot(sigma2_chain, main = "Autocorrelation Plot of sigma^2")


# ess_mu <- effectiveSize(mu_chain)
# ess_sigma2 <- effectiveSize(sigma2_chain)

cat("Effective Sample Size (mu):", ess_mu, "\n")
cat("Effective Sample Size (sigma^2):", ess_sigma2, "\n")