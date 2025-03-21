library(ggplot2)

generate_samples <- function(
    mixing_coefficients,
    means,
    standard_deviations,
    number_of_samples = 1000) {


  # should check that lengths are equal

  data <- c()
  choices_count <- rep(0, length(mixing_coefficients))

  # select one of the gaussian distributions according
  # to the mixing coefficients
  choices <- sample(
                    x = seq_along(mixing_coefficients),
                    size = number_of_samples,
                    prob = mixing_coefficients,
                    replace = TRUE)

  # let us see that the number of selections make sense
  for (i in 1:number_of_samples){
    choices_count[choices[i]] <- choices_count[choices[i]] + 1
  }
  print(choices_count)

  # for each selection, sample from the gaussian
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

  return(data)
}


initial_values_kmeans <- function(data, k = 3) {
  set.seed(42)  # For reproducibility

  # Randomly select k initial centroids
  centroids <- sample(x = data, size = k, replace = FALSE)

  # Initialize empty clusters
  clusters <- vector(mode = "list", length = k)

  for (iteration in 1:100) {
    # Reset clusters
    clusters <- vector(mode = "list", length = k)

    # Assign each data point to the closest centroid
    for (item in data) {
      distances <- abs(item - centroids)
      closest_centroid <- which.min(distances)
      clusters[[closest_centroid]] <- c(clusters[[closest_centroid]], item)
    }

    # Compute new centroids
    new_centroids <- sapply(1:k, function(i) {
      if (length(clusters[[i]]) > 0) {
        mean(clusters[[i]])
      } else {
        centroids[i]  # Keep old centroid if no points are assigned
      }
    })

    # Check for convergence
    if (max(abs(new_centroids - centroids)) < 0.0001) {
      break
    }

    centroids <- new_centroids
  }

  # Compute standard deviations
  clusters_standard_devs <- sapply(1:k, function(cluster_idx) {
    if (length(clusters[[cluster_idx]]) > 0) {
      sqrt(sum((clusters[[cluster_idx]] - centroids[cluster_idx])^2) / length(clusters[[cluster_idx]]))
    } else {
      0
    }
  })

  # Compute mixing coefficients for each cluster
  mixing_coefficients <- sapply(1:k, function(cluster_idx) {
    length(clusters[[cluster_idx]]) / length(data)
  })

  return(list(
              centroids = centroids,
              standard_devs = clusters_standard_devs,
              mixing_coefficients = mixing_coefficients))
}


log_likelihood <- function(data, means, standard_deviations, mixing_coefficients) {

  number_of_gaussians <- length(mixing_coefficients)

  # Initialize likelihood matrix
  likelihood <- matrix(0, nrow = length(data), ncol = number_of_gaussians)

  # Compute likelihood for each Gaussian component
  for (k in 1:number_of_gaussians) {
    likelihood[, k] <- mixing_coefficients[k] * dnorm(data, mean = means[k], sd = standard_deviations[k])
  }

  # Compute the log-likelihood
  log_likelihood_value <- sum(log(rowSums(likelihood)))

  return(log_likelihood_value)
}


expectation_step <- function(data, means, standard_deviations, mixing_coefficients) {

  number_of_gaussians <- length(mixing_coefficients)

  # Initialize gamma matrix
  gamma <- matrix(0, nrow = length(data), ncol = number_of_gaussians)

  # Calculate denominator (total probability for each data point)
  den_total <- 0
  for (k in 1:number_of_gaussians) {
    den_total <- den_total + mixing_coefficients[k] * dnorm(data, mean = means[k], sd = standard_deviations[k])
  }

  # Calculate numerator and compute gamma
  for (k in 1:number_of_gaussians) {
    gamma[, k] <- (mixing_coefficients[k] * dnorm(data, mean = means[k], sd = standard_deviations[k])) / den_total
  }

  return(gamma)
}


maximization_step <- function(data, gamma, means, standard_deviations, mixing_coefficients) {

  no_gaussians <- length(mixing_coefficients)
  m <- length(data)

  # Compute cluster responsibilities
  m_c <- colSums(gamma)  # Sum of responsibilities for each Gaussian

  # Compute new mixing coefficients
  new_mixing_coefficients <- m_c / m

  # Initialize new means and standard deviations
  new_means <- numeric(no_gaussians)
  new_standard_deviations <- numeric(no_gaussians)

  # Compute new means and standard deviations for each Gaussian
  for (k in 1:no_gaussians) {
    new_means[k] <- sum(gamma[, k] * data) / m_c[k]
    new_standard_deviations[k] <- sqrt(sum(gamma[, k] * (data - means[k])^2) / m_c[k])
  }

  return(list(
    means = new_means,
    standard_devs = new_standard_deviations,
    mixing_coefficients = new_mixing_coefficients
  ))
}



mixing_coefficients <- c(0.2, 0.5, 0.3)
means <- c(6, 0, -7)
standard_deviations <- c(2, 1, 1.5)

# generate the data
data <- generate_samples(mixing_coefficients, means, standard_deviations)

# initial values
kmeans_ret <- initial_values_kmeans(data)


centroids <- kmeans_ret$centroids
standard_devs <- kmeans_ret$standard_devs
mixing_coefficients <- kmeans_ret$mixing_coefficients

print("initial values")
print(centroids)
print(standard_devs)
print(mixing_coefficients)


log_likelihoods <- c()
for (i in 1:100) {
  gamma <- expectation_step(data, centroids, standard_devs, mixing_coefficients)

  max_ret <- maximization_step(data, gamma, centroids, standard_devs, mixing_coefficients)

  centroids <- max_ret$means
  standard_devs <- max_ret$standard_devs
  mixing_coefficients <- max_ret$mixing_coefficients 

  ll <- log_likelihood(data, means, standard_devs, mixing_coefficients)

  log_likelihoods <- c(log_likelihoods, ll)

  if (i>2 &&  abs(ll - log_likelihoods[i-1]) < 1e-5) {
    print("converged")
    break
  }

  # form string
  iteration_result_str <- paste( "iteration: ", i)
  for (j in 1:length(centroids)) {
    iteration_result_str <- paste(iteration_result_str, " centroid: ", centroids[j])
  }
  for (j in 1:length(standard_devs)) {
    iteration_result_str <- paste(iteration_result_str, " standard_dev: ", standard_devs[j])
  }
  for (j in 1:length(mixing_coefficients)) {
    iteration_result_str <- paste(iteration_result_str, " mixing_coefficient: ", mixing_coefficients[j])
  }
  print(iteration_result_str)

}


