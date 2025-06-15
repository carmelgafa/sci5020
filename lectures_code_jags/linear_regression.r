library(rjags)

samples <- data.frame(X <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10), y <- c(6, 7, 8, 4, 9, 11, 12, 14, 15, 19))

model_description <- "
model {
    for (i in 1:n) {
        y[i] ~ dnorm(mu[i], tau)
        mu[i] <- beta0 + (beta1 * X[i])
    }
    beta0 ~ dnorm(0, 0.01)
    beta1 ~ dnorm(0, 0.01)
    tau ~ dgamma(0.01, 0.01)
} "


jags_data <- list(y = samples$y, X = samples$X, n = nrow(samples))

initial_values <- list(beta0 = 0, beta1 = 1, tau = 1)

jagmod <- jags.model(textConnection(model_description), data = jags_data, inits = initial_values)

post <- coda.samples(jagmod, c("beta0", "beta1", "tau"), n.iter = 10000)

print(summary(post))

plot(post)


################################


initial_values_2 <- list(
    list(beta0 = -1, beta1 = 0, tau = 0.5),
    list(beta0 = 0, beta1 = 1, tau = 1),
    list(beta0 = 1, beta1 = 2, tau = 1.5)
)


jagmod_2 <- jags.model (textConnection(model_description), data = jags_data, inits = initial_values_2, n.chains = 3 )

post_2 <- coda.samples(jagmod_2, c("beta0", "beta1", "tau"), n.iter = 12000)

# update(jagmod_2, 2000)

print(summary(window(post_2, 2001)))


########################################


# library(lattice)

# print(gelman.diag(post_2))

# print(xyplot(post_2))
# # print(xyplot(post_2[, "beta0"], outer = TRUE, layout = c(1, 3)))
# # print(xyplot(post_2[, "beta1"], outer = TRUE, layout = c(1, 3)))
# # print(xyplot(post_2[, "tau"], outer = TRUE, layout = c(1, 3)))

# gelman.plot(post_2)
