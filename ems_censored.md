# Part a - Setup

## 1. Statement
- We have a **random sample** \( X = (X_1, \dots, X_n) \) from a distribution \( f(x | \theta) \).
- There is **right-censoring** at \( a \), meaning:
  - If \( X_i \leq a \), we observe \( Y_i = X_i \).
  - If \( X_i > a \), we observe \( Y_i = a \) (censored observation).

Thus, we define:
- **Fully observed values:** \( Y = (Y_1, \dots, Y_m) \).
- **Censored values:** \( Y^* = (Y^*_{m+1}, \dots, Y^*_n) \) where \( Y^*_j > a \).
- **Latent censoring indicators:** \( Z = (Z_{m+1}, \dots, Z_n) \).

---

### Note: survival function


The **survival function** (also called the reliability function) of a random variable \( X \) is defined as:

\[
S(x) = P(X > x)
\]

where:
- \( X \) is a **continuous random variable** representing the time until an event occurs (e.g., failure time, survival time).
- \( P(X > x) \) is the probability that the event **has not yet occurred** by time \( x \), meaning \( X \) is greater than \( x \).

The survival function is related to the **cumulative distribution function (CDF)** \( F(x) \) by:

\[
S(x) = 1 - F(x)
\]

where:
- \( F(x) = P(X \leq x) \) is the cumulative probability of observing a value **less than or equal to** \( x \).



## 2. Observed-Data Likelihood
The likelihood of the observed data consists of:
1. The contribution from the fully observed values:
   \[
   L_{\text{obs}}(\theta) = \prod_{i=1}^{m} f(Y_i | \theta)
   \]
2. The contribution from the censored values, which use the **survival function**
   \[
   P(X > a | \theta) = 1 - F(a | \theta)
   \]
   leading to:
   \[
   L_{\text{cens}}(\theta) = \prod_{j=m+1}^{n} [1 - F(a | \theta)]
   \]
Thus, the **observed-data likelihood** is:

\[
L_{\text{obs}}(\theta) = \prod_{i=1}^{m} f(Y_i | \theta) \times \prod_{j=m+1}^{n} [1 - F(a | \theta)]
\]

---

## 3. Complete-Data Likelihood
If we assume that the censored values \( Y^*_j \) are known, the likelihood function includes their actual values using the full **probability density function**:

\[
L_{\text{complete}}(\theta) = \prod_{i=1}^{m} f(Y_i | \theta) \times \prod_{j=m+1}^{n} f(Y_j^* | \theta)
\]

which can be rewritten as:

\[
f(y, z | \theta) = \left[ \prod_{i=1}^{m} f(y_i | \theta) \right] \times \left[ \prod_{j=m+1}^{n} f(y_j^* | \theta) \right]
\]

---

## 4. Key Differences Between Observed and Complete Likelihoods
| **Likelihood Type** | **Expression** | **Handling of Censored Data** |
|--------------------|-----------------------------|--------------------------------------|
| **Observed Data**  | \( \prod f(Y_i \| \theta) \cdot \prod [1 - F(a \| \theta)] \) | Uses survival function \( 1 - F(a) \) to marginalize out censored values. |
| **Complete Data**  | \( \prod f(Y_i \| \theta) \cdot \prod f(Y_j^* \| \theta) \) | Assumes we know true values of censored data and uses full PDF. |

---

## 5. Key Insights
- The **observed-data likelihood** accounts for censored values via the **survival function** \( 1 - F(a | \theta) \).
- The **complete-data likelihood** assumes censored values are known and uses the full **PDF** \( f(x | \theta) \).
- **Expectation-Maximization (EM) Algorithm** is commonly used to estimate parameters by:
  1. Computing the **expected val

---
---

# Likelihood of Censored Data vs. Likelihood of Parameters Given Data

## 1. Likelihood of the Censored Data
In a **right-censored dataset**, the likelihood contribution from censored observations is given by:

\[
L_{\text{cens}}(\theta) = \prod_{j=m+1}^{n} [1 - F(a | \theta)]
\]

where:
- \( F(a | \theta) \) is the **cumulative distribution function (CDF)**.
- \( 1 - F(a | \theta) \) is the **survival function**, representing the probability that a censored observation is greater than \( a \).
- This term tells us **how likely it is that the censored values exceed \( a \)** given a specific parameter \( \theta \).

---

## 2. Likelihood of Parameters Given the Data
The **full likelihood function**, which includes both **observed and censored** data, is:

\[
L(\theta | Y) = \left[ 1 - F_{\theta}(a) \right]^{n - m} \prod_{i=1}^{m} f(y_i | \theta)
\]

where:
- \( \prod f(y_i | \theta) \) accounts for the **fully observed values**.
- \( [1 - F(a | \theta)]^{n-m} \) accounts for the **censored values** by using the survival function.

This function represents the **likelihood of a parameter set \( \theta \) given the observed sample**. In **Maximum Likelihood Estimation (MLE)**, we seek to **maximize this function** to find the best parameter estimates.

---

## 3. Key Differences
| **Expression** | **Interpretation** | **Focus** |
|--------------|------------------|-----------|
| \( L_{\text{cens}}(\theta) = \prod [1 - F(a \| \theta)] \) | Probability that censored values exceed \( a \). | Describes likelihood of censoring under a given \( \theta \). |
| \( L(\theta \| Y) = [1 - F(a \| \theta)]^{n - m} \prod f(y_i \| \theta) \) | Likelihood of observing the entire dataset (both observed and censored). | Used in MLE to estimate \( \theta \). |


---
---

# Comments on the dataset

The table represents failure times in hours for electronic components tested at four different temperature levels (150°C, 170°C, 190°C, and 220°C). Some values have an asterisk (∗), which indicates right-censoring—meaning that the failure time for that item is at least the given value but could be longer.

The columns (150, 170, 190, 220) correspond to different temperature levels in degrees Celsius.
The rows contain observed failure times at these temperatures.
If a value has an asterisk (∗), it means that the component was still functioning at the given time, but the test ended before failure was observed.

---
---

# Regression Model for Lifetime Data with Censoring

## 1. Model Specification
We model the relationship between **log-lifetime** and **temperature** using a **linear regression model** with normal errors:

\[
T_i = \beta_0 + \beta_1 V_i + \epsilon_i, \quad \epsilon_i \sim N(0, \sigma^2)
\]

where:
- \( T_i \) is the **logarithm of the lifetime** of the \( i \)-th component.
- \( V_i \) is a **temperature transformation**:

  \[
  V_i = \frac{1000}{273.2 + \text{temperature}_i}
  \]

  This ensures the temperature is properly scaled in **Kelvin**.
- \( \beta_0, \beta_1 \) are the **regression coefficients** to be estimated.
- \( \epsilon_i \) follows a **normal distribution** with variance \( \sigma^2 \).

---

## 2. Handling Censored Data
- There are **40 total observations**, where:
  - The first **17 values** (\( t_1, ..., t_{17} \)) correspond to **uncensored (fully observed) lifetimes**.
  - The last **23 values** (\( t_{18}, ..., t_{40} \)) are **right-censored** (we only know they exceed a certain value).
- We introduce:
  - \( T = (t_1, ..., t_{40}) \) as the full dataset.
  - \( Z = (Z_{18}, ..., Z_{40}) \) as the **unobserved true values** of the censored lifetimes.

Since some values are censored, we cannot apply standard regression techniques directly. Instead, we use the **Expectation-Maximization (EM) algorithm** to estimate them iteratively.

---

## 3. Derivation of the Complete Log-Likelihood Function

Since \( T_i \) follows a normal distribution:

\[
T_i \sim N(\beta_0 + \beta_1 V_i, \sigma^2)
\]

the **probability density function (PDF)** is:

\[
f(T_i | \theta) = \frac{1}{\sqrt{2\pi \sigma^2}} \exp \left( -\frac{(T_i - \beta_0 - \beta_1 V_i)^2}{2\sigma^2} \right).
\]

### **Likelihood Function for Complete Data**
The **complete likelihood function** (observed + censored data) is:

\[
L(\theta | T, Z) = \prod_{i=1}^{17} f(t_i | \theta) \prod_{i=18}^{40} f(Z_i | \theta).
\]

Substituting the normal PDF:

\[
L(\theta | T, Z) = \prod_{i=1}^{17} \frac{1}{\sqrt{2\pi \sigma^2}} \exp \left( -\frac{(t_i - \beta_0 - \beta_1 v_i)^2}{2\sigma^2} \right)
\]

\[
\times \prod_{i=18}^{40} \frac{1}{\sqrt{2\pi \sigma^2}} \exp \left( -\frac{(Z_i - \beta_0 - \beta_1 v_i)^2}{2\sigma^2} \right).
\]

Taking the **log-likelihood function**:

\[
\log L(\theta | T, Z) = \sum_{i=1}^{17} \left( -\frac{1}{2} \log (2\pi \sigma^2) - \frac{(t_i - \beta_0 - \beta_1 v_i)^2}{2\sigma^2} \right)
+\sum_{i=18}^{40} \left( -\frac{1}{2} \log (2\pi \sigma^2) - \frac{(Z_i - \beta_0 - \beta_1 v_i)^2}{2\sigma^2} \right)
\]

Since the first term \( -\frac{n}{2} \log (2\pi \sigma^2) \) is constant, we simplify:
\[
log L(\theta | T, Z) = -n \log \sigma - \sum_{i=1}^{17} \frac{(t_i - \beta_0 - \beta_1 v_i)^2}{2\sigma^2}  - \sum_{i=18}^{40} \frac{(Z_i - \beta_0 - \beta_1 v_i)^2}{2\sigma^2}
\]


This is the **log-likelihood function** for the complete data.

---
---


# Expectation Step (E-Step) in the EM Algorithm for Censored Data

## 1. Role of the E-Step
The **Expectation-Maximization (EM) algorithm** is used to handle **censored data**, where some values are unobserved. The **E-step** involves computing the expectation of these missing values given the observed data.

---

## 2. Expectation Computation for Censored Values
The **censored observations** \( Z_i \) follow a **normal distribution**:

\[
Z_i \sim N(\beta_0 + \beta_1 v_i, \sigma^2).
\]

Since the values are **right-censored**, we only know:

\[
Z_i > t_i^*.
\]

Thus, we need to compute the conditional expectation:

\[
E[Z_i | Z_i > t_i^*, \theta']
\]

where \( \theta' = (\beta_0', \beta_1', \sigma') \) are the **current estimates** of the parameters from the previous iteration.

This expectation is computed using properties of the **truncated normal distribution**.

---

## 3. Contribution to the Log-Likelihood Function

From the **complete log-likelihood function**:

\[
\log L(\theta | T, Z) = -n \log \sigma - \sum_{i=1}^{17} \frac{(t_i - \beta_0 - \beta_1 v_i)^2}{2\sigma^2} - \sum_{i=18}^{40} \frac{(Z_i - \beta_0 - \beta_1 v_i)^2}{2\sigma^2}
\]


Since the **only unknown values** are the censored \( Z_i \)'s, we take expectations:

\[
E \left[ \sum_{i=18}^{40} \frac{(Z_i - \beta_0 - \beta_1 v_i)^2}{2\sigma^2} \right]
\]

which simplifies to:

\[
\frac{1}{2\sigma^2} \sum_{i=18}^{40} E \left[ (Z_i - \beta_0 - \beta_1 v_i)^2 \right].
\]

This expectation accounts for:
1. The **variance of the censored normal distribution**.
2. The **mean shift due to censoring**.

---

## 4. Importance of This Step
- The **E-step** computes the expected values of the censored observations, treating them as **missing data**.
- This updates the **sufficient statistics** needed for parameter estimation in the **M-step**.
- The result is used to iteratively improve the estimates of \( \beta_0 \), \( \beta_1 \), and \( \sigma \).

---
---

# Expectation of the Censored Values in the E-Step

## 1. Computing \( E[Z_i | Z_i > t_i^*, \theta'] \)
In the **E-step** of the **Expectation-Maximization (EM) algorithm**, we compute the expectation of the censored values given the observed data.

Since the censored values \( Z_i \) follow a **normal distribution**:

\[
Z_i \sim N(\mu_i', \sigma'^2),
\]

where:

\[
\mu_i' = \beta_0' + \beta_1' v_i,
\]

the conditional expectation is:

\[
E[Z_i | Z_i > t_i^*, \theta'] = \mu_i' + \sigma' H \left( \frac{t_i^* - \mu_i'}{\sigma'} \right).
\]

Here, \( H(x) \) is the **truncated normal mean adjustment factor**:

\[
H(x) = \frac{\phi(x)}{1 - \Phi(x)},
\]

where:
- \( \phi(x) \) is the **standard normal probability density function (PDF)**.
- \( \Phi(x) \) is the **standard normal cumulative distribution function (CDF)**.

This formula accounts for the **shift in the mean** caused by censoring.

---

## 2. Computing \( E[Z_i^2 | Z_i > t_i^*, \theta'] \)
Similarly, the **expected squared value** of the censored observations is:

\[
E[Z_i^2 | Z_i > t_i^*, \theta'] = (\mu_i')^2 + (\sigma')^2 + \sigma' (t_i^* + \mu_i') H \left( \frac{t_i^* - \mu_i'}{\sigma'} \right).
\]

This formula incorporates:
- The squared mean shift due to truncation.
- The variance contribution from the normal distribution.

---

## 3. Why This Matters in the EM Algorithm
- These expectations **fill in the missing censored values** in the **E-step**.
- They allow the algorithm to estimate the missing data without bias.
- The expected values are then used in the **M-step** to update the regression parameters \( \beta_0, \beta_1, \sigma \).


---
---


# Maximization Step (M-Step) in the EM Algorithm

## 1. Expected Log-Likelihood Function
From the **E-step**, we derived the **Q-function**:

\[
Q(\theta, \theta') = -n \log \sigma - \frac{1}{2\sigma^2} \sum_{i=1}^{17} (t_i - \beta_0 - \beta_1 v_i)^2 - \frac{1}{2\sigma^2} \sum_{i=18}^{40} E[Z_i^2 | Z_i > t_i^*, \theta'] + \frac{1}{\sigma^2} \sum_{i=18}^{40} E[Z_i | Z_i > t_i^*, \theta'] (\beta_0 + \beta_1 v_i).
\]

This function depends on the parameters \( \beta_0, \beta_1, \sigma \), which we now estimate by maximizing \( Q(\theta, \theta') \).

---

## 2. Maximization with Respect to \( \beta_0 \) and \( \beta_1 \)

To estimate \( (\beta_0, \beta_1) \), we maximize the function:

\[
\sum_{i=1}^{17} (t_i - \beta_0 - \beta_1 v_i)^2 + \sum_{i=18}^{40} E[Z_i^2 | Z_i > t_i^*, \theta'] - 2 \sum_{i=18}^{40} E[Z_i | Z_i > t_i^*, \theta'] (\beta_0 + \beta_1 v_i).
\]

Taking derivatives with respect to \( \beta_0 \) and \( \beta_1 \), we obtain **normal equations**:

\[
\sum_{i=1}^{40} y_i = \beta_0 \sum_{i=1}^{40} 1 + \beta_1 \sum_{i=1}^{40} v_i,
\]

\[
\sum_{i=1}^{40} v_i y_i = \beta_0 \sum_{i=1}^{40} v_i + \beta_1 \sum_{i=1}^{40} v_i^2.
\]

where:
- For **uncensored** observations, \( y_i = t_i \).
- For **censored** observations, \( y_i = E[Z_i | Z_i > t_i^*, \theta'] \).

Thus, \( \beta_0 \) and \( \beta_1 \) are estimated by solving


\[
\begin{bmatrix}
\sum 1 & \sum v_i \\
\sum v_i & \sum v_i^2   
\end{bmatrix}
\begin{bmatrix}
\beta_0 \\
\beta_1
\end{bmatrix}=
\begin{bmatrix}
\sum y_i \\
\sum v_i y_i
\end{bmatrix}.
\]





This is a **linear regression problem**, which can be solved using least squares.

---

## 3. Maximization with Respect to \( \sigma \)

To estimate \( \sigma^2 \), we differentiate \( Q(\theta, \theta') \) with respect to \( \sigma \) and solve:

\[
\sigma^2 = \frac{1}{n} \left[ \sum_{i=1}^{17} (t_i - \beta_0 - \beta_1 v_i)^2 + \sum_{i=18}^{40} E[Z_i^2 | Z_i > t_i^*, \theta'] - 2 \sum_{i=18}^{40} E[Z_i | Z_i > t_i^*, \theta'] (\beta_0 + \beta_1 v_i) \right].
\]

This provides an updated estimate for the variance \( \sigma^2 \).

---

## 4. Summary of the M-Step
1. **Estimate \( \beta_0, \beta_1 \)** by solving the normal equations for a weighted least squares regression.
2. **Estimate \( \sigma^2 \)** using the variance formula.
3. **Repeat the E-step and M-step iteratively until convergence**.

---
---
