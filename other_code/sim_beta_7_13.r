set.seed(456)

theta_samples <- rbeta(5000, shape1 = 7, shape2 = 13)


hist(theta_samples, breaks = 50, probability = TRUE, main = "Histogram of Beta(7, 7) Samples", xlab = "theta")


lines(density(theta_samples), col = "red", lwd = 2)

print(mean(theta_samples))

print(sd(theta_samples))

print(quantile(theta_samples, probs = c(0.025, 0.975)))
