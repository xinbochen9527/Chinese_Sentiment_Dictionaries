# -*- coding: utf-8 -*-
"""
Created on Thu Aug  3 08:53:47 2023

@author: 96525
"""

import pandas as pd
import  os
from tqdm import tqdm
from multiprocessing import Process
import multiprocessing as mp
import jieba

###################################################
# This part is to cut reports into words with jieba       
###################################################

def get_cut(file):
    # Read stop words from file
    stop_words = open(r'data/input/stopwords.txt', encoding='utf-8').read()

    # Read data from CSV file
    df = pd.read_csv(r'data/input/' + file, usecols=['Symbol', 'DeclareDate', 'FullDeclareDate', 'Title', 'Summary'])
    
    # Drop rows with NaN values in the 'Summary' column
    df.dropna(subset=['Summary'], inplace=True)

    # Rename columns for consistency
    df.rename(columns={'Symbol': 'Stkcd', 'DeclareDate': 'Trddt'}, inplace=True)

    # Combine 'Title' and 'Summary' columns into a new 'content' column
    df['content'] = df['Title'] + df['Summary']

    # Initialize an empty list to store cut strings
    list_cut_all = []

    # Iterate over rows in the DataFrame using tqdm for progress visualization
    for index, item in tqdm(df.iterrows(), desc=f'Processing {file}'):
        txt = item['content']

        # Remove newline characters from the text
        txt = txt.replace('\n', '')

        # Remove non-Chinese and non-numeric characters
        for char in txt:
            if (char < u'\u4e00' or char > u'\u9fa5') or (char >= u'\u0030' and char <= u'\u0039'):
                txt = txt.replace(char, '')

        # Tokenize the text using jieba
        txt_cut = jieba.cut(txt, cut_all=False)
        
        # Filter out stopwords and short words
        list_cut = [w for w in txt_cut if len(w) > 1 and w not in stop_words]

        # Join the filtered words into a string
        string = ' '.join(list_cut)

        # Append the string to the list
        list_cut_all.append(string)

    # Add the list of cut strings as a new 'cut' column in the DataFrame
    df['cut'] = list_cut_all

    # Select and reorder columns
    df = df[['Stkcd', 'Trddt', 'FullDeclareDate', 'cut']]

    # Format 'Stkcd' column values by zero-padding to 6 digits
    df['Stkcd'] = df['Stkcd'].apply(lambda x: str(x).zfill(6))

    # Save the processed DataFrame to a new CSV file
    df.to_csv(r'data/output/Robust_MNIR/' + file[:-4] + '_split.csv', index=False, header=True)

if __name__ == '__main__':
    # Set the number of processes
    process_num = 6
    
    # Create a list of processes, each targeting the get_cut function with a specific file
    processes = [mp.Process(target=get_cut, args=('REP_ReportInfo_Sec_2019_2022.csv',))]

    # Start and join the processes
    [p.start() for p in processes]
    [p.join() for p in processes]


        
        
    


