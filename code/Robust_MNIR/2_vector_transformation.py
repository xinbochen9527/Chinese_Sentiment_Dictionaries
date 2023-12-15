import pandas as pd
from tqdm import tqdm
from sklearn.feature_extraction.text import CountVectorizer
import multiprocessing as mp
from scipy import sparse
import scipy.io

###################################################
# This part is to transform text data into dtm
###################################################

def get_train_test_split(df):
    # Initialize a dictionary to store word counts
    dictionary = {}
    
    # Iterate over rows in the DataFrame using tqdm for progress visualization
    for index, row in tqdm(df.iterrows(), desc='Counting Words'):
        words = row['cut'].split(" ")
        words = set(words)
        
        # Update word counts in the dictionary
        for word in words: 
            if word in dictionary:
                dictionary[word] += 1
            else:
                dictionary[word] = 1
                
    # Filter words with counts less than 200
    filtered_dict = {word: count for word, count in dictionary.items() if count >= 200}
    
    # Convert the filtered dictionary to a DataFrame
    df_dict = pd.DataFrame.from_dict(filtered_dict, orient='index', columns=['value'])
    df_dict.reset_index(inplace=True)
    
    # Save the filtered words to a CSV file
    df_dict.to_csv(r'data/output/Robust_MNIR/words_col.csv', index=False, header=True)

    # Get the 'cut' column from the DataFrame as a list of documents
    documents = df['cut'].tolist()
    
    # Initialize CountVectorizer with the filtered dictionary as vocabulary
    vectorizer = CountVectorizer(vocabulary=filtered_dict.keys())
    
    # Transform documents into a term-document matrix (tfidf_matrix)
    tfidf_matrix = vectorizer.fit_transform(documents)
    print(type(tfidf_matrix))

    # Save the tfidf_matrix in MAT format
    scipy.io.savemat(r'data/output/Robust_MNIR/tfidf_matrix_2019_2022.mat', {'tfidf_matrix': tfidf_matrix})
    
    # Save the tfidf_matrix in compressed sparse row (CSR) format
    sparse.save_npz(r'data/output/Robust_MNIR/REP_ReportInfo_Sec_2019_2022_vector.npz', tfidf_matrix)
    
    print('end')

    return None

if __name__=='__main__':
    # Read the CSV file into a DataFrame
    df = pd.read_csv(r'data/output/Robust_MNIR/REP_ReportInfo_Sec_2019_2022_split.csv', encoding='utf-8')
    print(df.shape)

    # drop non-Ashare
    Markettype = pd.read_csv(r'data/input/TRD_Dalyr.csv', usecols=['Stkcd', 'Trddt', 'Markettype'])
    df['Stkcd'] = df['Stkcd'].apply(lambda x: str(x).zfill(6))
    Markettype['Stkcd'] = Markettype['Stkcd'].apply(lambda x: str(x).zfill(6))
    df = pd.merge(df, Markettype, on=['Stkcd', 'Trddt'], how='left')
    df = df[df.Markettype.isin([1, 4, 16, 32])]
    print(df.shape)
    
    # Drop rows with NaN values
    df.dropna(inplace=True)
    
    # Add a new column 'len' representing the number of terms in 'cut'
    df['len'] = df['cut'].apply(lambda x: len(x.split(' ')))
    
    # Filter text with terms less than 200
    df = df[df['len'] >= 200]
    print(df.shape)
    
    # Save the filtered DataFrame to a new CSV file
    df.to_csv(r'data/output/Robust_MNIR/REP_ReportInfo_Sec_2019_2022_split_filter.csv', index=False, header=True)
    
    # Create a list of processes, each targeting the get_train_test_split function with the DataFrame
    process = [mp.Process(target=get_train_test_split, args=(df,))]
    
    # Start and join the processes
    [p.start() for p in process]  
    [p.join() for p in process] 
