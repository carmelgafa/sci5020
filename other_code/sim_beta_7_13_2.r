
library(rjags)

# y has binomial distribution
# theta has beta distribution
# model composed of likelihood and prior

model <- "model {
        y ~ dbin(theta, n)
        theta ~ dbeta(2, 2)
}"

# data for model
dat <- data.frame(y = 5, n = 10)


initial <- list(.RNG.name = "base::Wichmann-Hill", .RNG.seed = 2023)

# check model syntax
jagmod <- jags.model(textConnection(model), data = dat, inits = initial)


# extract 10000 draws from posterior distribution
# burn in of 2000

post <- coda.samples(jagmod, 'theta', 10000)

print(summary(post))

HPDinterval(post)

plot(post)
