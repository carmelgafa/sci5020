set.seed(2023)  # Ensu re reproducibility

library(ggplot2)

# Generate data

number_of_samples <- 1000

limits_x1 <- c(-10, 10)
limits_x2 <- c(-7, 5)
limits_x3 <- c(-3, 8)

x1 <- seq(limits_x1[1], limits_x1[2], length.out = number_of_samples) + rnorm(number_of_samples, mean = 0, sd = 2)  # Add slight randomness
x2 <- seq(limits_x2[1], limits_x2[2], length.out = number_of_samples) + rnorm(number_of_samples, mean = 0, sd = 2)  # Add slight randomness
x3 <- seq(limits_x3[1], limits_x3[2], length.out = number_of_samples) + rnorm(number_of_samples, mean = 0, sd = 2)  # Add slight randomness

beta_0  <- 5
beta_1  <- 2.5
beta_2  <- -1.2
beta_3  <- 0.8

y <- beta_0 + (beta_1 * x1) + (beta_2 * x2) + (beta_3 * x3^3)
error <- rnorm(length(y), mean = 0.1, sd = 10)  # Random noise
y_real <- y + error


model <- lm(y_real ~ x1 + x2 + I(x3^3))
print(summary(model))



# Predicted 
y_pred <- predict(model)

# Actual vs. Predicted
y_pred_plot <- ggplot(data.frame(Actual = y_real, Predicted = y_pred), aes(x = Actual, y = Predicted)) +
  geom_point(alpha = 0.5, color = "blue") +
  labs(title = "Actual vs. Predicted Values",
       x = "Actual Values",
       y = "Predicted Values") +
  theme_minimal()


print(y_pred_plot)


# # Extract fitted values and residuals
# fitted_values <- fitted(model)
# residuals <- residuals(model)

# # Plot Residuals vs. Fitted Values
# residuals_plot <- ggplot(data.frame(Fitted = fitted_values, Residuals = residuals), aes(x = Fitted, y = Residuals)) +
#   geom_point(alpha = 0.5, color = "blue") +
#   geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
#   labs(title = "Residuals vs. Fitted Values",
#        x = "Fitted Values",
#        y = "Residuals") +
#   theme_minimal()


# print(residuals_plot)


# # -----------------------------------

# #residuals
# residuals <- residuals(model)

# # residual statistics from summary results
# min = -31.031
# q1 = -6.926
# median_res = -0.218
# q3 = 6.738
# max_res = 33.252

# # create stats_df
# stats_df <- data.frame(
#   value = c(min_res, q1, median_res, q3, max_res),
#   label = c("Min", "1Q", "Median", "3Q", "Max")
# )

# # Extract model summary statistics
# summary_model <- summary(model)
# residual_std_error <- summary_model$sigma  # Residual Standard Error
# r_squared <- summary_model$r.squared  # R-squared
# adjusted_r_squared <- summary_model$adj.r.squared  # Adjusted R-squared
# f_statistic <- summary_model$fstatistic[1]  # F-statistic
# p_value <- pf(f_statistic, summary_model$fstatistic[2], summary_model$fstatistic[3], lower.tail = FALSE)

# # normal curve
# mu <- mean(residuals)
# sigma <- sd(residuals)

# # Plot
# res_plot <- ggplot(data.frame(residuals), aes(x = residuals)) +
#   geom_histogram(aes(y = ..density..), bins = 30, fill = "blue", alpha = 0.6) +  # Residual histogram
#   stat_function(fun = dnorm, args = list(mean = mu, sd = sigma), 
#                 color = "red", size = 1.2) +  # Normal distribution curve
#   geom_vline(data = stats_df, aes(xintercept = value), color = "black", linetype = "dashed") +
#   geom_text(data = stats_df, aes(x = value, y = 0.02, label = label),  # Labels
#             angle = 90, vjust = -0.5, hjust = 0, size = 4) +
#   labs(
#     title = "Residuals vs. Normal Distribution with Summary Statistics",
#     subtitle = paste(
#       "Residual Std. Error:", round(residual_std_error, 3), "|",
#       "R²:", round(r_squared, 4), "|",
#       "Adj. R²:", round(adjusted_r_squared, 4), "|",
#       "F-statistic:", round(f_statistic, 2), "|",
#       "p-value:", format(p_value, scientific = TRUE)
#     ),
#     x = "Residual Value", y = "Density"
#   ) +
#   theme_minimal()


# print(res_plot)


# # -----------------------------------


# y_hat <- fitted(model)

# residual_variance <-  sum((y_real - y_hat)^2) / (length(y_real) - model$rank)

# print(model$rank)
# print(residual_variance)

# x_1_mean <- mean(x1)

# standard_error_beta_1 <- sqrt( residual_variance / sum((x1 - x_1_mean)^2))

# print(standard_error_beta_1)
# print(summary(model)$coefficients[, "Std. Error"][2])

# # Extract design matrix X
# X <- model.matrix(model)

# # Compute (X'X)^-1
# XTX_inv <- solve(t(X) %*% X)

# # Compute standard errors using full variance-covariance matrix
# beta_cov_matrix <- residual_variance * XTX_inv
# standard_errors <- sqrt(diag(beta_cov_matrix))

# # Compare with summary(model)
# print(standard_errors)
# print(summary(model)$coefficients[, "Std. Error"])