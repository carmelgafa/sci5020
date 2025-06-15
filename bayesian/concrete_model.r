script_dir <- getwd()
concrete_cleansed_path <- file.path(script_dir, "bayesian/concrete_cleansed.csv")

concrete_cleansed <- read.csv(concrete_cleansed_path)


jags_data <- list(
    x_cement = concrete_cleansed$cement,
    x_superplasticizer = concrete_cleansed$superplasticizer,
    x_age = concrete_cleansed$age,
    y_strength = concrete_cleansed$strength,
    n = nrow(concrete_cleansed)
)

model_description <- "
model {
    for (i in 1:n) {
        y_strength[i] ~ dnorm(mu[i], tau)
        mu[i] <- beta0 + (beta1 * x_cement[i]) + (beta2 * x_superplasticizer[i]) + (beta3 * x_age[i])
    }
    beta0 ~ dnorm(0, 0.01)
    beta1 ~ dnorm(0, 0.01)
    beta2 ~ dnorm(0, 0.01)
    beta3 ~ dnorm(0, 0.01)
    tau ~ dgamma(0.01, 0.01)
} "

n_chains <- 3
n_burnin <- 1000
n_samples <- 10000
parameters_to_monitor <- c("beta0", "beta1", "beta2", "beta3", "tau")

initial_values <- list(
    list(beta0 = 0, beta1 = 0, beta2 = 0, beta3 = 0, tau = 1),
    list(beta0 = 0, beta1 = 0, beta2 = 0, beta3 = 0, tau = 1),
    list(beta0 = 0, beta1 = 0, beta2 = 0, beta3 = 0, tau = 1)
)


model <- jags.model(textConnection(model_description),
                    data = jags_data,
                    inits = initial_values,
                    n.chains = n_chains)

update(model, n_burnin)

samples <- coda.samples(model = model,
                        variable.names = parameters_to_monitor,
                        n.iter = n_samples,
                        thin = 20)

print(summary(samples))

plot(samples)