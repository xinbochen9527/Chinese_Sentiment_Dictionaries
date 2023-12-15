import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import scipy.sparse as sp

##############################
#    Figure groupby freq
##############################
data = pd.read_csv(r'data/output/group5_figure/regression_ret.csv')

labels = ['G0' + str(i) for i in range(1, 6)]
ret_pos_groups = pd.DataFrame(pd.qcut(data['ret_pos_word_counts'].rank(method='first'), 5, 
                              labels=labels).astype(str)).rename(columns={'ret_pos_word_counts': 'ret_pos_Group'})
ret_neg_groups = pd.DataFrame(pd.qcut(data['ret_neg_word_counts'].rank(method='first'), 5, 
                              labels=labels).astype(str)).rename(columns={'ret_neg_word_counts': 'ret_neg_Group'})
data = pd.merge(data, ret_pos_groups['ret_pos_Group'], left_index=True, right_index=True)
data = pd.merge(data, ret_neg_groups['ret_neg_Group'], left_index=True, right_index=True)
ret_pos_groups = data.groupby(['ret_pos_Group'])['ret_D0'].median().to_frame().reset_index().rename(columns={'ret_D0': 'ret_median'})
ret_neg_groups = data.groupby(['ret_neg_Group'])['ret_D0'].median().to_frame().reset_index().rename(columns={'ret_D0': 'ret_median'})

dict_name = ['积极情绪词典', '消极情绪词典']

ret_dict = {
    'return postive dictionary': ret_pos_groups,
    'return negative dictionary':ret_neg_groups
}

ret_df = pd.DataFrame()
for k, v in ret_dict.items():
    print(k)
    print(v)
    ret_df[k] = v['ret_median']

ret_df = ret_df.T
ret_df.columns = ['low', '2', '3', '4', 'high']
print(ret_df)
x = np.arange(len(ret_df))
print(x)

plt.rcParams['font.sans-serif'] = ['SimSun']
fontsize = 15
plt.rcParams['font.size'] = fontsize
plt.rcParams['font.weight'] = 'light'
plt.rcParams['font.style'] = 'normal'

fig, ax = plt.subplots(figsize=(8, 6))
colors = ['#bdd7e7', '#c6dbef', '#9ecae1', '#6baed6', '#3182bd']

width = 0.15
for i, column in enumerate(ret_df.columns):
    print(column)
    ax.bar(x + i * width, ret_df[column], width=width, label=column, color=colors[i])

ax.set_ylabel('超额收益率')
ax.set_xticks(x + width * (len(ret_df.columns) - 1) / 2)
ax.set_xticklabels(dict_name)
ax.legend()

plt.tight_layout()
plt.savefig(r'data/output/group5_figure/Figure_ret_groups.pdf', dpi=200, bbox_inches='tight')
plt.show()
