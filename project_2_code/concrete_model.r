library(rjags)
library(lattice)


script_dir <- getwd()
concrete_cleansed_path <- file.path(script_dir, "project_2_code/concrete_cleansed.csv")

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
n_burnin <- 6000
n_samples <- 15000
parameters_to_monitor <- c("beta0", "beta1", "beta2", "beta3", "tau")

initial_values <- list(
  list(beta0 = -10, beta1 = 0.5, beta2 = 0.1, beta3 = 0.05, tau = 0.5),
  list(beta0 = 0,   beta1 = 1,   beta2 = 0.3, beta3 = 0.1,  tau = 1),
  list(beta0 = 10,  beta1 = 2,   beta2 = 0.5, beta3 = 0.2,  tau = 2)
)


model <- jags.model(textConnection(model_description),
                    data = jags_data,
                    inits = initial_values,
                    n.chains = n_chains)


post <- coda.samples(model = model,
                        variable.names = parameters_to_monitor,
                        n.iter = n_samples,
                        thin = 20)

post_burned <- window(post, start = n_burnin)

print("Summary of posterior samples")
print(summary(post_burned))

# plot(post_burned[, "beta0"], main="beta0 -- Intercept")
# plot(post_burned[, "beta1"], main="beta1 -- Cement")
# # plot(post_burned[, "beta2"], main="beta2 -- Superplasticizer")
# # plot(post_burned[, "beta3"], main="beta3 -- Age")
# # plot(post_burned[, "tau"], main="tau -- Precision")


# # print(gelman.diag(post))
# # gelman.plot(post_burned[, "beta0"])
# gelman.plot(post_burned)



# library(coda)
# print(effectiveSize(samples))



# # Extract posterior samples from coda object
# samples_matrix <- as.matrix(samples)

# # New values for prediction
# x_new <- c(300, 8, 28)

# # Compute mu for each sample
# mu_pred <- samples_matrix[, "beta0"] +
#            samples_matrix[, "beta1"] * x_new[1] +
#            samples_matrix[, "beta2"] * x_new[2] +
#            samples_matrix[, "beta3"] * x_new[3]

# # Draw y_pred ~ Normal(mu_pred, sd = 1/sqrt(tau))
# tau_samples <- samples_matrix[, "tau"]
# y_pred <- rnorm(length(mu_pred), mean = mu_pred, sd = 1 / sqrt(tau_samples))



# # Summary of prediction
# print("Summary of prediction")
# print(summary(y_pred))
# print(quantile(y_pred, c(0.025, 0.5, 0.975)))

# library(ggplot2)

# df <- data.frame(
#   predictive = y_pred,
#   expected = mu_pred
# )

# plt <- ggplot(df) +
#   geom_density(aes(x = predictive), fill = "skyblue", alpha = 0.5, color = NA) +
#   geom_density(aes(x = expected), fill = "orange", alpha = 0.5, color = NA) +
#   labs(title = "Posterior Predictive vs Expected Mean",
#        x = "Predicted Strength (MPa)",
#        y = "Density") +
#   theme_minimal() +
#   scale_x_continuous(limits = c(min(df), max(df))) +
#   annotate("text", x = mean(mu_pred), y = 0.02, label = "Expected mean", color = "orange") +
#   annotate("text", x = mean(y_pred), y = 0.015, label = "Predictive", color = "skyblue")

# plot(plt)