import os
import pandas as pd

concrete_strength_path = os.path.join(
    os.path.dirname(__file__),
    'data',
    'concrete_data.xls')


df_concrete_strength = pd.read_excel(concrete_strength_path)

print(df_concrete_strength.head())

# correlation plot
import seaborn as sns
import matplotlib.pyplot as plt

# sns.heatmap(df_concrete_strength.corr(), annot=True)
# plt.show()

# now plot for each variable
sns.pairplot(df_concrete_strength)
# plt.show()

# save image
plt.savefig('con_str_pairplot.png')
