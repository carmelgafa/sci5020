from scipy.stats import gamma
import numpy as np
import matplotlib.pyplot as plt

# Generate synthetic Gamma-distributed data
np.random.seed(42)


alpha = 6  # True shape parameter
beta = 2.0    # True scale parameter
sample_size = 1000

gamma_data = np.random.gamma(shape=alpha, scale=beta, size=sample_size)


# Plot histogram of sample
plt.hist(gamma_data, bins=50, alpha=0.6, color='b', edgecolor='black', density=True, label="Sampled Data")

# Compute theoretical Gamma PDF
x_values = np.linspace(0, max(gamma_data), 1000)
pdf_values = gamma.pdf(x_values, a=alpha, scale=beta)

# Overlay the theoretical Gamma PDF
plt.plot(x_values, pdf_values, 'r-', label="Gamma PDF (Theoretical)")
plt.xlabel("Value")
plt.ylabel("Probability Density")
plt.title(f"Gamma Distribution (alpha = {alpha}, beta = {beta})")
plt.legend()
plt.show()


X_1 = np.mean(gamma_data)
X_2 = np.mean(np.power(gamma_data, 2))


# Estimate alpha using method of moments formula
alpha_est = 1 / ((X_2 / X_1**2) - 1)
print(f"Estimated alpha (Method of Moments): {alpha_est}, True alpha: {alpha}")

# Estimate beta using method of moments formula
beta_est = (X_2 - X_1**2) / X_1
print(f"Estimated beta (Method of Moments): {beta_est}, True beta: {beta}")
