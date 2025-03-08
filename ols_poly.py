import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures

# Set seed for reproducibility
np.random.seed(1470)

# Generate data
x = np.arange(0, 30.5, 0.5).reshape(-1, 1)  # Column vector
y = 2 - 0.6*x + 0.4*x**2
error = np.random.normal(loc=0.1, scale=10, size=y.shape)  # Add noise
y_real = y + error

# Fit polynomial regression (degree 2)
poly = PolynomialFeatures(degree=2, include_bias=False)
X_poly = poly.fit_transform(x)

model = LinearRegression()
model.fit(X_poly, y_real)

# Generate predictions
x_pred = np.linspace(x.min(), x.max(), 100).reshape(-1, 1)
X_pred_poly = poly.transform(x_pred)
y_pred = model.predict(X_pred_poly)

# Compute confidence intervals
y_pred_std = np.std(y_real - model.predict(X_poly))  # Estimate standard deviation
y_lci = y_pred - 1.96 * y_pred_std  # Lower bound
y_uci = y_pred + 1.96 * y_pred_std  # Upper bound

# Convert to Pandas DataFrame
df_pred = pd.DataFrame({'x': x_pred.flatten(), 'fit': y_pred.flatten(), 'lci': y_lci.flatten(), 'uci': y_uci.flatten()})
df_data = pd.DataFrame({'x': x.flatten(), 'y_real': y_real.flatten()})

# Plot results
plt.figure(figsize=(8,6))
sns.scatterplot(data=df_data, x='x', y='y_real', color='black', label="Data")
sns.lineplot(data=df_pred, x='x', y='fit', color='red', label="Polynomial Fit")
plt.fill_between(df_pred['x'], df_pred['lci'], df_pred['uci'], color='blue', alpha=0.2, label="95% CI")
plt.xlabel("x")
plt.ylabel("fit")
plt.title("Polynomial Regression with 95% Confidence Interval")
plt.legend()
plt.show()
