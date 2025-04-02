import numpy as np
import pandas as pd
import scipy.stats as stats
from scipy.optimize import minimize

# === Define Data === #
observed_data = pd.DataFrame({
    "Temperature (°C)": [170] * 7 + [190] * 5 + [220] * 5,
    "Failure Time": [1764, 2772, 3444, 3542, 3780, 4860, 5196, 408, 408, 1344, 1344, 1440, 408, 408, 504, 504, 504]
})

hidden_data = pd.DataFrame({
    "Temperature (°C)": [150] * 10 + [170] * 3 + [190] * 5 + [220] * 5,
    "Failure Time": [8064] * 10 + [5448] * 3 + [1680] * 5 + [528] * 5
})

# Compute transformed temperature (V) and log failure time
for df in [observed_data, hidden_data]:
    df["V"] = 1000 / (273.2 + df["Temperature (°C)"])
    df["Log(Failure Time)"] = np.log(df["Failure Time"])

# === Step 1: Initial Estimates === #
def compute_initial_estimates():
    n_obs = len(observed_data)
    sum_V = np.sum(observed_data["V"])
    sum_T = np.sum(observed_data["Log(Failure Time)"])
    sum_VT = np.sum(observed_data["V"] * observed_data["Log(Failure Time)"])
    sum_V2 = np.sum(observed_data["V"] ** 2)

    # Solve for beta_0 and beta_1
    A = np.array([[n_obs, sum_V], [sum_V, sum_V2]])
    B = np.array([sum_T, sum_VT])
    beta_0, beta_1 = np.linalg.solve(A, B)

    # Compute initial sigma^2
    residuals = observed_data["Log(Failure Time)"] - (beta_0 + beta_1 * observed_data["V"])
    sigma_squared = np.sum(residuals ** 2) / n_obs

    return beta_0, beta_1, sigma_squared

# === Step 2: Expectation Step (E-Step) === #
def compute_expectations(beta_0, beta_1, sigma_squared):
    mu_dash = beta_0 + beta_1 * hidden_data["V"]
    x = (hidden_data["Log(Failure Time)"] - mu_dash) / np.sqrt(sigma_squared)

    # Compute H(x) safely
    eps = 1e-10  # Small epsilon to avoid division by zero
    H_x = stats.norm.pdf(x) / (1 - stats.norm.cdf(x) + eps)

    E_Z = mu_dash + np.sqrt(sigma_squared) * H_x
    E_Z2 = (mu_dash ** 2) + sigma_squared + np.sqrt(sigma_squared) * (hidden_data["Log(Failure Time)"] + mu_dash) * H_x

    return E_Z, E_Z2

# === Step 3: Maximization Step (M-Step) === #
def compute_maximization(E_Z, E_Z2):
    obs_sum_t = np.sum(observed_data["Log(Failure Time)"])
    obs_sum_vt = np.sum(observed_data["V"] * observed_data["Log(Failure Time)"])
    
    hid_sum_e_z = np.sum(E_Z)
    hid_sum_e_z2 = np.sum(E_Z2)
    hid_sum_v_e_z = np.sum(hidden_data["V"] * E_Z)

    all_sum_v = np.sum(observed_data["V"]) + np.sum(hidden_data["V"])
    all_sum_v2 = np.sum(observed_data["V"] ** 2) + np.sum(hidden_data["V"] ** 2)
    count_all_elements = len(observed_data) + len(hidden_data)

    # Solve for new beta_0 and beta_1
    A = np.array([[count_all_elements, all_sum_v], [all_sum_v, all_sum_v2]])
    B = np.array([obs_sum_t + hid_sum_e_z, obs_sum_vt + hid_sum_v_e_z])
    beta_0_new, beta_1_new = np.linalg.solve(A, B)

    # Compute sigma^2
    sum_residuals_squared = np.sum((observed_data["Log(Failure Time)"] - (beta_0_new + beta_1_new * observed_data["V"])) ** 2)
    sum_expected_squared = hid_sum_e_z2
    sum_expected_product = 2 * (beta_0_new * hid_sum_e_z + beta_1_new * hid_sum_v_e_z)

    # sigma_squared_new = max((sum_residuals_squared + sum_expected_squared - sum_expected_product) / count_all_elements, 1e-5)
    sigma_squared_new = (sum_residuals_squared + sum_expected_squared - sum_expected_product) / count_all_elements

    return beta_0_new, beta_1_new, sigma_squared_new

# === Step 4: Full EM Algorithm === #
def run_em_algorithm(max_iterations=1000):
    beta_0, beta_1, sigma_squared = compute_initial_estimates()

    print(f"Initial Estimates: β0 = {beta_0:.4f}, β1 = {beta_1:.4f}, σ² = {sigma_squared:.4f}")

    for i in range(max_iterations):
        # E-Step
        E_Z, E_Z2 = compute_expectations(beta_0, beta_1, sigma_squared)

        # M-Step
        beta_0_new, beta_1_new, sigma_squared_new = compute_maximization(E_Z, E_Z2)

        print(f"Iteration {i+1}: β0 = {beta_0_new:.4f}, β1 = {beta_1_new:.4f}, σ² = {sigma_squared_new:.4f}")

        # Convergence check
        if abs(beta_0_new - beta_0) < 1e-5 and abs(beta_1_new - beta_1) < 1e-5 and abs(sigma_squared_new - sigma_squared) < 1e-5:
            break

        beta_0, beta_1, sigma_squared = beta_0_new, beta_1_new, sigma_squared_new

    return beta_0, beta_1, sigma_squared

# === Run EM Algorithm === #
final_beta_0, final_beta_1, final_sigma_squared = run_em_algorithm()
print(f"Final Estimates: β0 = {final_beta_0:.4f}, β1 = {final_beta_1:.4f}, σ² = {final_sigma_squared:.4f}")
