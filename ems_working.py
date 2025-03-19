import numpy as np
import pandas as pd
import scipy


#define data


observed_data = {
    "Temperature (°C)": [170, 170,  170,  170,  170,  170,  170,  190, 190, 190,  190,  190,  220, 220, 220, 220, 220],
    "Failure Time": [   1764, 2772, 3444, 3542, 3780, 4860, 5196, 408, 408, 1344, 1344, 1440, 408, 408, 504, 504, 504]
}

# Convert to DataFrame
observed_data = pd.DataFrame(observed_data)
observed_data["V"] = 1000 / (273.2 + observed_data["Temperature (°C)"])  # Compute transformed temperature
observed_data["Log(Failure Time)"] = np.log(observed_data["Failure Time"])  # Log-transform failure time


hidden_data = {
    "Temperature (°C)": [150,   150,   150,   150,   150,   150,   150,   150,  150,    150,  170,  170,  170,  190,  190,  190,  190,  190,  220,  220,  220,  220,  220],
    "Failure Time":     [8064,  8064,  8064,  8064,  8064,  8064,  8064,  8064,  8064,  8064, 5448, 5448, 5448, 1680, 1680, 1680, 1680, 1680,  528,  528,  528,  528,  528]
}

hidden_data = pd.DataFrame(hidden_data)
hidden_data["V"] = 1000 / (273.2 + hidden_data["Temperature (°C)"])  # Compute transformed temperature
hidden_data["Log(Failure Time)"] = np.log(hidden_data["Failure Time"])  # Log-transform failure time


def compute_initial_estimates():
    """
    Computes beta_0, beta_1, and sigma^2 given observed failure time data.
    
    Parameters:
        data (pd.DataFrame): A DataFrame containing observed failure times and temperatures.
        
    Returns:
        dict: A dictionary containing initial estimates for beta_0, beta_1, and sigma^2 
    """


    # Define variables for normal equations
    n_obs = len(observed_data)
    sum_V = np.sum(observed_data["V"])
    sum_T = np.sum(observed_data["Log(Failure Time)"])
    sum_VT = np.sum(observed_data["V"] * observed_data["Log(Failure Time)"])
    sum_V2 = np.sum(observed_data["V"] ** 2)

    # Construct normal equations
    A = np.array([[n_obs, sum_V], [sum_V, sum_V2]])
    B = np.array([sum_T, sum_VT])

    # Solve for beta_0 and beta_1
    beta_0, beta_1 = np.linalg.solve(A, B)

    #sigma^2
    residuals = observed_data["Log(Failure Time)"] - (beta_0 + beta_1 * observed_data["V"])
    sigma_squared = np.sum(residuals ** 2) / n_obs

    return {"beta 0": beta_0, "beta 1": beta_1, "sigma squared": sigma_squared, "n_obs": n_obs}


def compute_expectations(beta_0, beta_1, sigma_squared):
    """    Computes beta_0, beta_1, and sigma^2 given observed failure time data.
    
    Parameters:
        data (pd.DataFrame): A DataFrame containing observed failure times and temperatures.
        beta_0 (float): The intercept parameter.
        beta_1 (float): The slope parameter.
        sigma_squared (float): The variance parameter.
        
    Returns:
        pd.DataFrame: A DataFrame containing computed estimates.
    """

    expectations_results = pd.DataFrame()

    expectations_results["mu dash"] = beta_0 + beta_1 * hidden_data["V"]
    expectations_results["x"] = (hidden_data["Log(Failure Time)"] - expectations_results["mu dash"])/np.sqrt(sigma_squared)

    expectations_results["H(x)"] = scipy.stats.norm.pdf(expectations_results["x"])/(1-scipy.stats.norm.cdf(expectations_results["x"]))

    expectations_results["E[Z | Z > t*]"] = expectations_results["mu dash"] + (np.sqrt(sigma_squared) * expectations_results["H(x)"])
    expectations_results["E[Z^2 | Z > t*]"] = (expectations_results["mu dash"]**2) + sigma_squared + (np.sqrt(sigma_squared) * expectations_results["H(x)"] * (hidden_data["Log(Failure Time)"] + expectations_results["mu dash"]))

    
    return expectations_results

def compute_maximization(expectations_results):
    
    obs_sum_t = np.sum(observed_data["Log(Failure Time)"])
    obs_sum_vt = np.sum(observed_data["V"] * observed_data["Log(Failure Time)"])
    
    
    hid_sum_e_z = np.sum(expectations_results["E[Z | Z > t*]"])
    hid_sum_e_z2 = np.sum(expectations_results["E[Z^2 | Z > t*]"])
    hid_sum_v_e_z = np.sum(hidden_data["V"] * expectations_results["E[Z | Z > t*]"])

    
    
    all_sum_v = np.sum(observed_data["V"]) + np.sum(hidden_data["V"])
    all_sum_v2 = np.sum(observed_data["V"] ** 2) + np.sum(hidden_data["V"] ** 2)


    count_all_elements = len(observed_data) + len(hidden_data)

    A = np.array([[count_all_elements, all_sum_v], [all_sum_v, all_sum_v2]])
    B = np.array([obs_sum_t + hid_sum_e_z, obs_sum_vt + hid_sum_v_e_z])

    beta_0_new, beta_1_new = np.linalg.solve(A, B)


    sum_residuals_squared = np.sum((observed_data["Log(Failure Time)"] - (beta_0_new + beta_1_new * observed_data["V"])) ** 2)
    sum_expected_squared = hid_sum_e_z2
    sum_expected_product = 2 * (beta_0_new * hid_sum_e_z + beta_1_new * hid_sum_v_e_z)

    sigma_squared_new = (sum_residuals_squared + sum_expected_squared - sum_expected_product) / count_all_elements
    sigma_squared_new = max(sigma_squared_new, 0)



    return beta_0_new, beta_1_new, sigma_squared_new






initial_estimates = compute_initial_estimates()

for param, value in initial_estimates.items():
    print(f"{param} = {value:.4f}")

beta_0 = initial_estimates["beta 0"]
beta_1 = initial_estimates["beta 1"]
sigma_squared = initial_estimates["sigma squared"]


for i in range(20000):

    ex_results = compute_expectations(beta_0, beta_1, sigma_squared)

    beta_0_new, beta_1_new, sigma_squared_new = compute_maximization(ex_results)

    print(f"beta_0_new = {beta_0_new:.4f}, beta_1_new = {beta_1_new:.4f}, sigma_squared_new = {sigma_squared_new:.4f}")

    if abs(beta_0_new - beta_0) < 1e-5 and abs(beta_1_new - beta_1) < 1e-5 and abs(sigma_squared_new - sigma_squared) < 1e-5:
        break

    beta_0, beta_1, sigma_squared = beta_0_new, beta_1_new, sigma_squared_new