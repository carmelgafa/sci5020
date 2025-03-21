import numpy as np
import random
import scipy.stats
from scipy.stats import norm
import matplotlib.pyplot as plt

def log_likelihood(data, means, standard_deviations, mixing_coefficients):

    number_of_gaussians = len(mixing_coefficients)

    likelihood = np.zeros((len(data), number_of_gaussians), dtype=float)

    for k in range(number_of_gaussians):
        likelihood[:, k] =  mixing_coefficients[k] * norm(means[k], standard_deviations[k]).pdf(data)

    log_likelihood = np.sum(np.log(np.sum(likelihood, axis=1)))
    
    return log_likelihood


def expectation_step(data, means, standard_deviations, mixing_coefficients):
    
    number_of_gaussians = len(mixing_coefficients)
    
    gamma = np.zeros((len(data), number_of_gaussians), dtype=float)
    
    
    # calculate denominator
    den_total = 0
    for k in range(number_of_gaussians):
        den_total += mixing_coefficients[k] * norm(means[k], standard_deviations[k]).pdf(data)
    
    # calculate the numerator
    for k in range(number_of_gaussians):
        gamma[:, k] = mixing_coefficients[k] * norm(means[k], standard_deviations[k]).pdf(data) / den_total
        
    return gamma



def maximization_step(data, gamma, means, standard_deviations, mixing_coefficients):

    no_gaussians = len(mixing_coefficients)
    m = len(data)
    new_means = np.zeros(shape=(means.shape))
    new_standard_deviations = np.zeros(shape=(standard_deviations.shape))

    m_c = np.sum(gamma, axis=0)

    new_mixing_coefficients = m_c / m

    for k in range(no_gaussians):
        new_means[k] = np.sum(gamma[:, k] * data) / m_c[k]
        new_standard_deviations[k] = np.sqrt(np.sum(gamma[:, k] * (data - means[k]) ** 2) / m_c[k])

    return new_means, new_standard_deviations, new_mixing_coefficients


def simulate_points(means, standard_deviations, mixing_coefficients, number_of_points=1000):
    '''
    Simulate 1000 data points from a mixture of Gaussians
    '''

    data = []

    counts = np.zeros(len(mixing_coefficients))
    choices = np.arange(len(mixing_coefficients))

    for _ in range(number_of_points):
        choice = random.choices(choices, mixing_coefficients)[0]
        counts[choice] += 1
        data.append(float(random.gauss(means[choice], standard_deviations[choice])))

    print("Counts: ", counts)

    plt.hist(data, bins=30, density=True, alpha=0.6, color='g')
    x_values = np.linspace(min(data), max(data), number_of_points)
    for idx, mix_coeff in enumerate(mixing_coefficients):
        plt.plot(
            x_values,
            mix_coeff * norm(means[idx], standard_deviations[idx]).pdf(x_values),
            label=f'Gaussian {idx+1}')
    plt.xlabel("Value")
    plt.ylabel("Probability Density")
    plt.title(f"Simulated Data (coeff = {mixing_coefficients}, means = {means}, std = {standard_deviations})")
    plt.legend()
    plt.show()

    print(data)

    return data

def main():
    data = [7.33, 9.66, 9.00, 5.00, 8.82, 10.36, 1.78, 8.42, 10.20, 7.69, 1.57, 10.85,8.66, 8.18,
            -1.28, 3.06, 10.18, 2.86, 10.90, 10.80, 10.00, 1.46, 10.16, 1.91, 1.92, 8.47, 4.17,
            3.75, -0.02, 10.53 ]

    number_of_gaussians = 2
    max_iterations = 50
    convergence_value = 0.0001


    random.seed(80)

    means = np.array([random.random(), random.random()])
    standard_deviations = np.array([random.random(), random.random()])

    # can work with single variable and do 1- for the other, but i want to reuse
    mixing_coefficients = np.zeros(number_of_gaussians)
    mixing_coefficients[0] = 1 / number_of_gaussians
    mixing_coefficients[1] = 1 / number_of_gaussians

    print("Initial Values: ")
    print("means = ", means)
    print("standard_deviations = ", standard_deviations)
    print("mixing_coefficients: ", mixing_coefficients)
    
    
    log_likelihoods = []
    
    for i in range(max_iterations):
        gamma = expectation_step(data, means, standard_deviations, mixing_coefficients)
        means, standard_deviations, mixing_coefficients = maximization_step(data, gamma, means, standard_deviations, mixing_coefficients)
        log_likelihoods.append(log_likelihood(data, means, standard_deviations, mixing_coefficients))
        
        if i>1 and log_likelihoods[-1] - log_likelihoods[-2] < convergence_value:
            break
        

    print("Updated Values: ")
    print("means = ", means)
    print("standard_deviations = ", standard_deviations)
    print("mixing_coefficients: ", mixing_coefficients)
    print("Log likelihood: ", log_likelihoods[-1])
    
    
    # plt.plot(log_likelihoods[1:], label="Log likelihood")
    # plt.xlabel('Iteration')
    # plt.ylabel('Log likelihood')
    # plt.show()
    
    
    # plot histogram scale gaussians with mixing coefficients
    plt.hist(data, bins=6, density=True, alpha=0.6, color='g')
    x_values = np.linspace(min(data), max(data), 1000)
    for k in range(number_of_gaussians):
        plt.plot(x_values, norm(means[k], standard_deviations[k]).pdf(x_values), label=f'Gaussian {k+1}')
        
    plt.xlabel("Value")
    plt.ylabel("Probability Density")
    plt.title(f"EM Algorithm - Gaussian Mixture Model (GMM) - {number_of_gaussians} Gaussians")
    plt.legend()
    plt.show()
    
    
def initial_values_knn(data, k=3):

    centroids = np.random.choice(data, k, replace=False)

    clusters = [[] for _ in range(k)]
    print("Clusters: ", clusters)

    for _ in range(100):
        for item in data:
            closest_centroid = np.argmin([abs(item - c) for c in centroids])
            clusters[closest_centroid].append(item)
            
        new_centroids = np.array([np.mean(cluster) if cluster else centroids[i] for i, cluster in enumerate(clusters)])
        
        if np.max(np.abs(new_centroids - centroids)) < 0.0001:
            break
            
        centroids = new_centroids
    
    standard_devs = []
    for i in range(k):
        mean = centroids[i]
        cluster_data = clusters[i]
        standard_devs.append(float(np.sqrt(np.sum((cluster_data - mean) ** 2) / len(cluster_data))))
    
    scaling_factors = [float(1/(np.sqrt(2*np.pi)*sd)) for sd in standard_devs]
    
    return centroids, np.array(standard_devs), scaling_factors


if __name__ == "__main__":

    means = np.array([2,11,-5])
    standard_deviations = np.array([1,2,0.5])
    mixing_coefficients = np.array([0.3,0.3,0.4])

    data = simulate_points(means, standard_deviations, mixing_coefficients)
    
    
    means, standard_deviations, mixing_coefficients = initial_values_knn(data, k=3)
    
    print(means)
    print(standard_deviations)
    print(mixing_coefficients)
    
    print("Initial Values: ")
    print("means = ", means)
    print("standard_deviations = ", standard_deviations)
    print("mixing_coefficients: ", mixing_coefficients)
    
    
    log_likelihoods = []
    
    for i in range(1000):
        gamma = expectation_step(data, means, standard_deviations, mixing_coefficients)
        means, standard_deviations, mixing_coefficients = maximization_step(data, gamma, means, standard_deviations, mixing_coefficients)
        log_likelihoods.append(log_likelihood(data, means, standard_deviations, mixing_coefficients))
        
        if i>1 and log_likelihoods[-1] - log_likelihoods[-2] < 0.00001:
            break
        

    print("Updated Values: ")
    print("means = ", means)
    print("standard_deviations = ", standard_deviations)
    print("mixing_coefficients: ", mixing_coefficients)
    print("Log likelihood: ", log_likelihoods[-1])