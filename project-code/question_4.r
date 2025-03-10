library(openxlsx)
library(ggplot2)

# load file
script_dir <- getwd()
file_path <- file.path(script_dir, "resampling.xlsx")
df <- read.xlsx(file_path, colNames = TRUE)

print(c("number of rows: ", nrow(df)))

# estimate the parameters of the model
init_a <- 1
init_b <- 1

nls_model <- nls(y ~ (a * x) / (b + x),
                 data = df,
                 start = list(a = init_a, b = init_b))


estimated_params <- coef(nls_model)
a_hat <- estimated_params["a"]
b_hat <- estimated_params["b"]
cat("Estimated a:", a_hat, "\n")
cat("Estimated b:", b_hat, "\n")

# predict the values of y
df$Predicted <- predict(nls_model)

# plot the data
p <- ggplot(df, aes(x = x, y = y)) +
  geom_point(color = "blue", alpha = 0.5) +
  geom_line(aes(y = Predicted), color = "red", linewidth = 1) +
  labs(title = "Nonlinear Regression: Y = (aX) / (b+X)",
       x = "X", y = "Y") +
  theme_minimal()

print(p)

# -------------------------
# Jackknife
# -------------------------

partition_size <- 5

#shuffle the dataframe
set.seed(123)
df_shuf <- df[sample(nrow(df)), ]

# Generate jackknife samples by removing each fold of 5 elements
# lapply applied a function to each element of a list
# my list is from 1:5
# the function will
# for a = 1 remove element 1 to 5 (5*(1-1)+1):(5*1)
# for a = 2 remove element 6 to 10 (5*(2-1)+1):(5*2)
# and so on
# note the - sign -- I am removing the elements
# so the return for each a is y without the elements 1 to 5, 6 to 10, etc.
jackknife_samples <- lapply(1:partition_size,
    function(a) df_shuf[-((partition_size * (a - 1) + 1):(partition_size * a)), ])


# we have calculated theta_hat_m before
theta_hat_m <- estimated_params

theta_m_a <- function(data) {
  model <- nls(y ~ (a * x) / (b + x),
               data = data,
               start = list(a = theta_hat_m["a"],
                            b = theta_hat_m["b"]))
  return(coef(model))
}

# jackknife estimator for each partition
nlsjk <- sapply(jackknife_samples, function(y_a) partition_size * theta_hat_m - (partition_size - 1) * theta_m_a(y_a))

#evaluating the jackknife estimator of the parametrs
jackknife_estimates <- rowMeans(nlsjk)

# Compute mean estimates for a and b
a_hat_jk <- mean(jackknife_estimates["a"], na.rm = TRUE)
b_hat_jk <- mean(jackknife_estimates["b"], na.rm = TRUE)

# Print results
cat("Jackknife Estimated a:", a_hat_jk, "\n")
cat("Jackknife Estimated b:", b_hat_jk, "\n")

df$predicted_jk <- (a_hat_jk * df$x) / (b_hat_jk + df$x)

# Plot with Jackknife predictions and legend
p_jk <- ggplot(df, aes(x = x, y = y)) +
  geom_point(color = "blue", alpha = 0.5, size = 3) +
  geom_line(aes(y = Predicted, color = "Full Sample Prediction"),
            linewidth = 1, linetype = "dashed") +
  geom_line(aes(y = predicted_jk, color = "Jackknife Prediction"),
            linewidth = 1) +
  labs(title = "Nonlinear Regression: Full Sample vs. Jackknife.",
       x = "X", y = "Y", color = "Legend") +
  theme_minimal() +
  scale_color_manual(values = c("Full Sample Prediction" = "red",
                                "Jackknife Prediction" = "green"))

# Print the plot
print(p_jk)

# --------
# part b - confidence intervals
# --------

# # standard errors
# se_a_jk <- sqrt(var(nlsjk["a", ], na.rm = TRUE) / partition_size)
# se_b_jk <- sqrt(var(nlsjk["b", ], na.rm = TRUE) / partition_size)

se_a_jk <- sqrt((partition_size - 1) * var(nlsjk["a", ], na.rm = TRUE) / partition_size)
se_b_jk <- sqrt((partition_size - 1) * var(nlsjk["b", ], na.rm = TRUE) / partition_size)

# 95% confidence using normal distribution
z_score <- qnorm(0.975)  # 1.96 for 95% CI
CI_a_normal <- c(a_hat_jk - z_score * se_a_jk, a_hat_jk + z_score * se_a_jk)
CI_b_normal <- c(b_hat_jk - z_score * se_b_jk, b_hat_jk + z_score * se_b_jk)

# 95% confidence  using t
df_jk <- partition_size - 1
t_score <- qt(0.975, df_jk)
CI_a_t <- c(a_hat_jk - t_score * se_a_jk, a_hat_jk + t_score * se_a_jk)
CI_b_t <- c(b_hat_jk - t_score * se_b_jk, b_hat_jk + t_score * se_b_jk)

cat("95% CI for a (Normal): [", CI_a_normal[1], ",", CI_a_normal[2], "]\n")
cat("95% CI for b (Normal): [", CI_b_normal[1], ",", CI_b_normal[2], "]\n")

cat("95% CI for a (t-distribution): [", CI_a_t[1], ",", CI_a_t[2], "]\n")
cat("95% CI for b (t-distribution): [", CI_b_t[1], ",", CI_b_t[2], "]\n")




# -------------------------
# Bootstrap
# -------------------------

num_samples <- 1000
sample_size <- 100

# 1000 bootstrap samples of size 100 with replacement
bootstrap_samples <- lapply(1:num_samples, function(i) df[sample(nrow(df), sample_size, replace = TRUE), ])

fit_bootstrap_nls <- function(data) {
    model <- nls(y ~ (a * x) / (b + x),
                   data = data,
                   start = list(a = 1, b = 1))  # Initial guesses
    return(coef(model))
}

# Apply NLS to each bootstrap sample
nlsbs <- lapply(bootstrap_samples, fit_bootstrap_nls)

# Convert list of bootstrap estimates to a matrix
bootstrap_estimates <- do.call(rbind, nlsbs)
colnames(bootstrap_estimates) <- c("a", "b")

# Compute mean estimates for a and b
a_hat_bs <- mean(bootstrap_estimates[, "a"], na.rm = TRUE)
b_hat_bs <- mean(bootstrap_estimates[, "b"], na.rm = TRUE)

# Print results
cat("Bootstrap Estimated a:", a_hat_bs, "\n")
cat("Bootstrap Estimated b:", b_hat_bs, "\n")


df$predicted_bs <- (a_hat_bs * df$x) / (b_hat_bs + df$x)


# Plot with Jackknife predictions and legend
p_bs <- ggplot(df, aes(x = x, y = y)) +
  geom_point(color = "blue", alpha = 0.5, size = 3) +
  geom_line(aes(y = Predicted, color = "Full Sample Prediction"),
            linewidth = 1, linetype = "dashed") +
  geom_line(aes(y = predicted_jk, color = "Jackknife Prediction"),
            linewidth = 1) +
  geom_line(aes(y = predicted_bs, color = "Bootstrap Prediction"),
            linewidth = 1) +
  labs(title = "Nonlinear Regression: Full Sample vs. Jackknife vs. Bootstrap",
       x = "X", y = "Y", color = "Legend") +
  theme_minimal() +
  scale_color_manual(values = c("Full Sample Prediction" = "red",
                                "Jackknife Prediction" = "green",
                                "Bootstrap Prediction" = "blue"))

# Print the plot
# print(p_bs)


# --------
# part b - confidence intervals
# --------


# standard error
se_a_bs <- sd(bootstrap_estimates[, "a"], na.rm = TRUE)
se_b_bs <- sd(bootstrap_estimates[, "b"], na.rm = TRUE)

# dof for t
df_bs <- num_samples - 1 

# 95% normal
z_score <- qnorm(0.975)  # 1.96 for 95% CI
CI_a_normal <- c(a_hat_bs - z_score * se_a_bs, a_hat_bs + z_score * se_a_bs)
CI_b_normal <- c(b_hat_bs - z_score * se_b_bs, b_hat_bs + z_score * se_b_bs)

# 95% t
t_score <- qt(0.975, df_bs)
CI_a_t <- c(a_hat_bs - t_score * se_a_bs, a_hat_bs + t_score * se_a_bs)
CI_b_t <- c(b_hat_bs - t_score * se_b_bs, b_hat_bs + t_score * se_b_bs)

# 95% empirical
CI_a_empirical <- quantile(bootstrap_estimates[, "a"], probs = c(0.025, 0.975), na.rm = TRUE)
CI_b_empirical <- quantile(bootstrap_estimates[, "b"], probs = c(0.025, 0.975), na.rm = TRUE)

cat("Normal CI for a: [", CI_a_normal[1], ",", CI_a_normal[2], "]\n")
cat("Normal CI for b: [", CI_b_normal[1], ",", CI_b_normal[2], "]\n")

cat("t-Distribution CI for a: [", CI_a_t[1], ",", CI_a_t[2], "]\n")
cat("t-Distribution CI for b: [", CI_b_t[1], ",", CI_b_t[2], "]\n")

cat("Empirical CI for a: [", CI_a_empirical[1], ",", CI_a_empirical[2], "]\n")
cat("Empirical CI for b: [", CI_b_empirical[1], ",", CI_b_empirical[2], "]\n")