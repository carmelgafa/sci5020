library(rjags)
library(lattice)
library(ggplot2)
library(coda)

#load dataset
script_dir <- getwd()
concrete_cleansed_path <- file.path(
  script_dir,
  "project_2_code/concrete_cleansed.csv"
)
concrete_cleansed <- read.csv(concrete_cleansed_path)

jags_data <- list(
  x_cement = concrete_cleansed$cement,
  x_superplasticizer = concrete_cleansed$superplasticizer,
  x_age = concrete_cleansed$age,
  y_strength = concrete_cleansed$strength,
  n = nrow(concrete_cleansed)
)

#define model
model_description <- "
model {
    for (i in 1:n) {
        y_strength[i] ~ dnorm(mu[i], tau)
        mu[i] <- beta0 +
        (beta1 * x_cement[i]) +
        (beta2 * x_superplasticizer[i]) +
        (beta3 * x_age[i])
    }
    beta0 ~ dnorm(0, 0.01)
    beta1 ~ dnorm(0, 0.01)
    beta2 ~ dnorm(0, 0.01)
    beta3 ~ dnorm(0, 0.01)
    tau ~ dgamma(0.01, 0.01)
} "

#params
n_chains <- 3
n_burnin <- 6000
n_samples <- 15000
parameters_to_monitor <- c("beta0", "beta1", "beta2", "beta3", "tau")
initial_values <- list(
  list(beta0 = -10, beta1 = 0.5, beta2 = 0.1, beta3 = 0.05, tau = 0.5),
  list(beta0 = 0,   beta1 = 1,   beta2 = 0.3, beta3 = 0.1,  tau = 1),
  list(beta0 = 10,  beta1 = 2,   beta2 = 0.5, beta3 = 0.2,  tau = 2)
)

#create the jags model
model <- jags.model(
  textConnection(model_description),
  data = jags_data,
  inits = initial_values,
  n.chains = n_chains
)

#posterior samples from jgs model
post <- coda.samples(model = model,
                        variable.names = parameters_to_monitor,
                        n.iter = n_samples,
                        thin = 20)


#throw away burnin samples
post_burned <- window(post, start = n_burnin)

#posterior summary
print(summary(post_burned))

#autocorr mcmc samples
autocorr.plot(post_burned[, "beta0"])   
autocorr.plot(post_burned[, "beta1"])
autocorr.plot(post_burned[, "beta2"])
autocorr.plot(post_burned[, "beta3"])
autocorr.plot(post_burned[, "tau"])

#density plts
plot(post_burned[, "beta0"], main="beta0 -- Intercept")
plot(post_burned[, "beta1"], main="beta1 -- Cement")
plot(post_burned[, "beta2"], main="beta2 -- Superplasticizer")
plot(post_burned[, "beta3"], main="beta3 -- Age")
plot(post_burned[, "tau"], main="tau -- Precision")


print(gelman.diag(post))
gelman.plot(post_burned[, "beta0"])
gelman.plot(post_burned)



print(effectiveSize(post_burned))

#extract post samples -- generate a bunch of samples for each posterior distribution
samples_matrix <- as.matrix(post_burned)

#new values --
x_new <- c(300, 8, 28)

#compute mu for each -- scale the samples with the example values
mu_pred <- samples_matrix[, "beta0"] +
  samples_matrix[, "beta1"] * x_new[1] +
  samples_matrix[, "beta2"] * x_new[2] +
  samples_matrix[, "beta3"] * x_new[3]

#distrib of pred mean --> distr of outcomes by adding resdl noise
tau_samples <- samples_matrix[, "tau"]
y_pred <- rnorm(length(mu_pred), mean = mu_pred, sd = 1 / sqrt(tau_samples))

print("Summary of prediction")
print(summary(y_pred))
print(quantile(y_pred, c(0.025, 0.5, 0.975)))


df <- data.frame(
  predictive = y_pred,
  expected = mu_pred
)


plt <- ggplot(df) +
  geom_density(aes(x = predictive, color = "Predictive")) +
  geom_density(aes(x = expected, color = "Expected Mean")) +
  labs(title = "Posterior Predictive vs Expected Mean",
       x = "Predicted Strength (MPa)",
       y = "Density",
       color = "Line Type") +
  theme_minimal() +
  scale_color_manual(values = c("Predictive" = "skyblue", "Expected Mean" = "orange")) +
  scale_x_continuous(limits = c(min(df), max(df)))
print(plt)


plt <- ggplot(df, aes(x = predictive)) +
  geom_density(fill = "skyblue", alpha = 0.5) +
  geom_vline(aes(xintercept = mean(predictive)), color = "blue", linetype = "dashed") +
  geom_vline(aes(xintercept = quantile(predictive, 0.025)), linetype = "dotted") +
  geom_vline(aes(xintercept = quantile(predictive, 0.975)), linetype = "dotted") +
  labs(title = "Posterior Predictive Distribution",
       x = "Predicted Strength (MPa)", y = "Density") +
  theme_minimal()
plot(plt)
