## Step1: Data processing and estimate robust MNIR and structure output in file Robust_MNIR
## data processing
python ./code/Robust_MNIR/1_words_split.py > ./data/output/Robust_MNIR/1_words_split.log.txt
python ./code/Robust_MNIR/2_vector_transformation.py > ./data/output/Robust_MNIR/2_vector_transformationlog.txt
## estimate robust MNIR
Rstript ./code/Robust_MNIR/3_Robust_MNIR.R > ./data/output/Robust_MNIR/3_Robust_MNIR.log.txt
## construct dictionaries
Rstript ./code/Robust_MNIR/4_dict_construction.R > ./data/output/Robust_MNIR/4_dict_construction.log.txt

## Step2: calculate volatility signals
Rstript ./code/cal_signals/cal_signals.R > ./data/output/signals.log.txt

## Step3: get all figures and tables
## 1. statistic summary figure
## data processing
python ./code/statistic_summary_figure/1_data_processing.py > ./data/output/statistic_summary_figure/1_data_processing.log.txt
## plot figure
python ./code/statistic_summary_figure/2_figure.py > ./data/output/statistic_summary_figure/2_figure.log.txt

## 2. dict breadth
Rstript ./code/dict_breadth/dic_breadth.R > ./data/output/breadth.log.txt

## 3. group5_figure
## cal word counts
Rstript ./code/group5_figure/1_cal_word_counts.R > ./data/output/group5_figure/1_cal_word_counts.R
## plot figure
python ./code/group5_figure/2_figure.py > ./data/output/group5_figure/2_figure.log.txt

## 4. panel regression
Rstript ./code/panel_regression/panel_regression.R > ./data/output/panel_regression.log.txt
