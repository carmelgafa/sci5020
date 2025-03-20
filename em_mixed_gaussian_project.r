library(ggplot2)


generate_thousand <- function(mixing_coefficients, means, standard_deviations) {

  data <- c()
  choices_count <- rep(0, length(mixing_coefficients))

  number_of_samples <- 1000

  choices <- sample(
                   x = seq_along(mixing_coefficients),
                   size = number_of_samples,
                   prob = mixing_coefficients,
                   replace = TRUE)

  for(i in 1:number_of_samples){
    choices_count[choices[i]] <- choices_count[choices[i]] + 1
  }
  print(choices_count)

  data <- c(
            data,
            rnorm(
                  n = number_of_samples,
                  mean = means[choices],
                  sd = standard_deviations[choices]))

  # plot histogram and gaussian curves
  df <- data.frame(data)

  p <- ggplot(df, aes(x = data)) +
    geom_histogram(
                   aes(y = ..density..),
                   bins = 30,
                   fill = "blue",
                   alpha = 0.6) +
    stat_function(fun = function(x) {
      Reduce(`+`, lapply(1:length(means), function(i) {
        dnorm(
              x = x,
              mean = means[i],
              sd = standard_deviations[i]) * mixing_coefficients[i]
      }))
    }, color = "red") +
    labs(title = "Histogram of Mixture of Gaussians",
         x = "Value",
         y = "Density") +
    theme_bw()

  print(p)
}

mixing_coefficients <- c(0.2, 0.5, 0.3)
means <- c(6, 0, -7)
standard_deviations <- c(2, 1, 1.5)

generate_thousand(mixing_coefficients, means, standard_deviations)