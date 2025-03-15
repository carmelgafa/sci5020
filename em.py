import numpy as np

# Generate full population (true mean is 50)
# np.random.seed(42)
X_full = np.random.normal(loc=50, scale=10, size=10000)

# Randomly sample 100 observed values
observed_indices = np.random.choice(len(X_full), size=100, replace=False)
Y = X_full[observed_indices]  # Observed data

# Define EM Algorithm to estimate mean
def expectation_maximization(Y, n_missing, max_iters=50, tol=1e-5):
    """
    Estimate mean of a normal distribution with missing data using EM.
    """
    # Step 1: Initialize mean estimate
    # mu = np.mean(Y)  # Start with observed sample mean
    mu = np.random.normal(loc=50, scale=10)  # Random initialization
    
    steps = 0
    
    for _ in range(max_iters):
        # E-Step: Estimate missing data mean (assume missing values follow the same mean)
        Z_mean = mu
        
        # M-Step: Compute new estimate of mean
        mu_new = (np.sum(Y) + (n_missing * Z_mean)) / (len(Y) + n_missing)

        steps += 1

        # Convergence check
        if abs(mu_new - mu) < tol:
            break
        mu = mu_new

    return mu, steps

# Apply EM algorithm
n_missing = len(X_full) - len(Y)  # Number of missing values
estimated_mu, number_of_steps = expectation_maximization(Y, n_missing)

# Compare results
true_mu = np.mean(X_full)
observed_mu = np.mean(Y)

print(f"Results: converges in {number_of_steps} steps")

print(f"True mean: {true_mu}")
print(f"Observed mean  (using only Y): {observed_mu}")
print(f"Estimated mean (EM Algorithm): {estimated_mu}")
