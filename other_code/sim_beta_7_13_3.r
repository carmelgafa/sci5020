
library(rjags)
library(lattice)

# y has binomial distribution
# theta has beta distribution
# model composed of likelihood, link, and prior
model <- "model {
        y ~ dbin(theta, n)
        logit(theta) <- phi
        phi ~ dnorm(0, 1e-6)
}"

# data for model
dat <- data.frame(y = 5, n = 10)


initial <- list(.RNG.name = "base::Wichmann-Hill", .RNG.seed = 2023)


initials <- list(
  list(phi = -10, .RNG.name = "base::Wichmann-Hill", .RNG.seed = 1001),
  list(phi = 0, .RNG.name = "base::Wichmann-Hill", .RNG.seed = 1002),
  list(phi = 10, .RNG.name = "base::Wichmann-Hill", .RNG.seed = 1003)
)


# check model syntax
jagmod <- jags.model(textConnection(model), data = dat, inits = initials, n.chains = 3)
# update(jagmod, 0)


# extract 10000 draws from posterior distribution
# burn in of 2000

post <- coda.samples(jagmod, c('theta', 'phi'), 30000, thin = 10)
# more <- coda.samples(jagmod, c('theta', 'phi'), 6000)

# combo <- as.mcmc(rbind(as.mcmc(post), as.mcmc(more)))


# print(summary(combo))


# print(HPDinterval(post))


# plot(combo)

# plot(post)

print(lapply(post, summary))

# xyplot(post)
# print(xyplot(post[, 'theta'], outer=T, layout=c(1,3)))


print(gelman.diag(post))

gelman.plot(post)