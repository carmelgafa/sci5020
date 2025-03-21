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


mixing_coefficients <- c(0.2, 0.5, 0.3)
means <- c(6, 0, -7)
standard_deviations <- c(2, 1, 1.5)

# generate the data
data <- generate_samples(mixing_coefficients, means, standard_deviations)

# initial values
ret <- initial_values_kmeans(data)

print(ret$centroids)
print(ret$standard_devs)
print(ret$mixing_coefficients)