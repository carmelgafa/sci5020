library(rjags)


script_dir <- getwd()
file_path <- file.path(script_dir, "other-material", "sydhob.txt")
data <- read.table(file_path, header = TRUE, sep = "\t")

x1 <- data$Year
y1 <- data$Time
n1 <- length(x1)

mod1 <- "model{
    for (i in 1:n) {
        y1[i] ~ dnorm(mu1[i], tau1)
        mu1[i] <- beta0 + beta1 * x1[i]
    }
    #prior distributions
    tau1 ~ dgamma(1, 1)
    beta0 ~ dnorm(0, 0.0001)
    beta1 ~ dnorm(0, 0.0001)
    #variance
    sigma1 <- 1 / tau1
    }"

data1 <- list("x1", "y1", "n1")

param1 <- c("beta0", "beta1", "sigma1")

inits1 <- function(){
    list("beta0" = 0, "beta1" = 0, "tau1" = 1)}

writeLines(mod1, "mod1.jags")

mod1.jags <- jags(data = data1,
    inits = inits1,
    parameters.to.save = param1,
    model.file = "mod1.jags",
    n.chains = 2,
    n.iter = 10000,
    n.thin = 1)

mod1.jags2 <- update(mod1.jags, n.iter = 5000)

traceplot(mod1.jags2)
plot(mod1.jags)