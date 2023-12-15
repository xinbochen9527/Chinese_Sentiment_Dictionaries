import pandas as pd
import numpy as np
import warnings
warnings.filterwarnings("ignore")

def data_split(meta, days_before, days_after):
    # Extract 'Stkcd' from 'meta'
    Stkcd = meta['Stkcd']
    print(Stkcd)

    # Transpose 'meta' DataFrame for easier manipulation
    meta = pd.DataFrame(meta).T

    # Read daily stock data for the specified stock code
    TRD_Dalyr = pd.read_csv(r'data/input/Stock_d/Stock_d_{}.csv'.format(Stkcd))
    TRD_Dalyr['Stkcd'] = TRD_Dalyr['Stkcd'].apply(lambda x: str(x).zfill(6))

    # Add a 'sig' column to 'meta' and merge with 'TRD_Dalyr'
    meta['sig'] = 1
    TRD_Dalyr = pd.merge(TRD_Dalyr, meta[['Stkcd', 'Trddt', 'sig']], on=['Stkcd', 'Trddt'], how='left')
    sig_df = TRD_Dalyr[TRD_Dalyr['sig'] == 1]

    # Get data before and after the event
    if sig_df.empty:
        return sig_df
    else:
        index_eventday = sig_df.index[0]
        start_index = max(0, index_eventday - days_before)
        end_index = min(len(TRD_Dalyr) - 1, index_eventday + days_after)
        selected_data = TRD_Dalyr.iloc[start_index:end_index + 1]
        selected_data = selected_data.fillna(np.nan)
        selected_data = selected_data.reset_index(drop=True)

        return selected_data

def get_ret(meta, days_before, days_after):
    # Get split data
    selected_data = data_split(meta, days_before, days_after)

    if selected_data.empty:
        return None
    else:
        # Calculate adjusted returns
        selected_data['adjusted_ret'] = selected_data['Dretwd'] - selected_data['index_ret']
        center_index = selected_data[selected_data['sig'] == 1].index[0]
        num_rows_before = max(0, 60 - center_index)
        num_rows_after = max(0, 10 - (len(selected_data) - 1 - center_index))
        empty_rows = pd.DataFrame(columns=selected_data.columns, index=range(num_rows_before + num_rows_after))
        selected_data = pd.concat([empty_rows.iloc[:num_rows_before], selected_data, empty_rows.iloc[num_rows_before:]], ignore_index=True)
        selected_data.reset_index(drop=True, inplace=True)

        # Calculate normalized returns
        mean = selected_data.iloc[:59]['Dretwd'].mean()
        std = selected_data.iloc[:59]['Dretwd'].std()
        ret_data = selected_data.iloc[50:]
        ret_data['norm_ret'] = ret_data['Dretwd'].apply(lambda x: abs((x - mean) / std))
        ret_data = ret_data.reset_index(drop=True)
        ret_data = ret_data['norm_ret'].to_list()

        return ret_data

if __name__ == '__main__':
    # Load data
    meta = pd.read_csv(r'data/input/regression_ret.csv')
    meta['Stkcd'] = meta['Stkcd'].apply(lambda x: str(x).zfill(6))

    # Calculate normalized returns for each stock and each document
    columns = ["D0" + str(i) if 0 <= i < 10 else "D" + str(i) if i >= 10 else "Dbefore" + str(abs(i)) for i in range(-10, 11)]
    ret_data = pd.DataFrame(columns=columns)

    for index, meta_temp in meta.iterrows():
        ret_data_temp = get_ret(meta_temp, 60, 10)
        ret_data.loc[len(ret_data)] = ret_data_temp

    # Merge data
    regression_ret = pd.concat([meta, ret_data], axis=1)

    # Save data
    regression_ret.to_csv(r'data/output/statistic_summary/regression_ret.csv', index=False)
