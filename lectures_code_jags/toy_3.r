# Load the required packages
library(rjags)

# Observed data
heights <- c(160, 165, 170, 175, 180, 185, 190, 160, 155, 165)
n <- length(heights)

# JAGS model
model_string <- "
  model {
    # Likelihood
    for (i in 1:N) {
      heights[i] ~ dnorm(mu, tau)
    }
    
    # Priors
    mu ~ dnorm(170, 0.01)  # Mean 170, precision 0.01 (variance = 100)
    tau ~ dgamma(1, 1)     # Gamma(1, 1) prior for precision

    # Convert precision to standard deviation
    sigma <- 1 / sqrt(tau)
  }
"

# Data for JAGS
data_jags <- list(heights = heights, N = n)

# Initial values
inits <- function() {
  list(mu = 170, tau = 1)
}

# Parameters to monitor
parameters <- c("mu", "tau", "sigma")

# Create the JAGS model
model <- jags.model(textConnection(model_string),
                    data = data_jags,
                    inits = inits,
                    n.chains = 3,
                    n.adapt = 1000)

# Update the model (burn-in)
update(model, 1000)

# Sample from the posterior
samples <- coda.samples(model, variable.names = parameters, n.iter = 5000)

# Summarize the results
summary(samples)

# Plot the results
plot(samples)
