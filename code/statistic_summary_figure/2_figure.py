import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

## load data 
columns = ["D0" + str(i) if 0 <= i < 10 else "D" + str(i) if i >= 10 else "Dbefore" + str(abs(i)) for i in range(-10, 11)]
data_ec = pd.read_csv('data/output/statistic_summary/regression_ret.csv').loc[:, columns]
data_ec.dropna(axis=0, inplace=True)
Ave_NorRet = data_ec.mean(axis=0)

## plot scatters
x = [str(i) for i in range(-10, 11)]
plt.figure(figsize=(15,8), dpi=200)
plt.scatter(x, Ave_NorRet, color='blue', label='Implied Volatility for Earnings calls')
plt.xticks(['-10', '-5', '0', '5', '10'], [str(i) for i in range(-10, 11, 5)])
plt.xlabel('Days from events')
plt.ylabel('Average absolute normalized return')
# set dashed-line
ax = plt.gca()
x_value = 10 
ax.axvline(x=x_value, color='gray', linestyle='--')
y_value = np.sqrt(2 / np.pi)
ax.axhline(y=y_value, color='gray', linestyle='--')
plt.legend()
plt.savefig('data/output/statistic_summary/Figure1_statistic_summary.pdf', bbox_inches='tight')
plt.show()