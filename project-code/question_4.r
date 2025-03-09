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
print(head(df))

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

number_partitions <- 5

#shuffle the dataframe
set.seed(123)
df_shuf <- df[sample(nrow(df)), ]

# Generate jackknife samples by removing each fold of 5 elements
jackknife_samples <- lapply(1:number_partitions,
    function(a) df_shuf[-((number_partitions * (a - 1) + 1):(number_partitions * a)), ])


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
nlsjk <- sapply(jackknife_samples, function(y_a) number_partitions * theta_hat_m - (number_partitions - 1) * theta_m_a(y_a))

#evaluating the jackknife estimator of the parametrs
jackknife_estimates <- rowMeans(nlsjk)

a_hat_jk <- jackknife_estimates["a"]
b_hat_jk <- jackknife_estimates["b"]


df$predicted_jk <- (a_hat_jk * df$x) / (b_hat_jk + df$x)


# Plot with Jackknife predictions and legend
p_jk <- ggplot(df, aes(x = x, y = y)) +
  geom_point(color = "blue", alpha = 0.5, size = 3) +
  geom_line(aes(y = Predicted, color = "Full Sample Prediction"),
            linewidth = 1, linetype = "dashed") +
  geom_line(aes(y = predicted_jk, color = "Jackknife Prediction"),
            linewidth = 1) +
  labs(title = "Nonlinear Regression: Full Sample vs. Jackknife",
       x = "X", y = "Y", color = "Legend") +
  theme_minimal() +
  scale_color_manual(values = c("Full Sample Prediction" = "red",
                                "Jackknife Prediction" = "green"))

# Print the plot
print(p_jk)


# -------------------------
# Bootstrap
# -------------------------

# Number of bootstrap samples
number_bootstrap_samples <- 1000
