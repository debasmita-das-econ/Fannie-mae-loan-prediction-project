#--------------------------------------------------------------------------------
# Project: DS Project using Fannie Mae's Single-Family Historical Loan Performance Dataset
#
# R Script Name: prep_data.R
# Author: Debasmita Das (debasmita.das@gatech.edu)
# Script Written: 10/10/2023
# Last Updated: 12/05/2023
#
# This script prepares data for the analysis.
#
# We need to convert the data into a training data set that can be 
# used in a machine learning algorithm. This involves a few things:
# - count up how many rows exist for each loan and assign the count to each unique loan id
# - Removing any rows that don't have a lot of performance history (drop if don't have data for at least 4 quarters).
# - Converting string columns to numeric
# - Assigning a foreclosure and delinquency status to each loan
# - Filling in any missing values
#--------------------------------------------------------------------------------

glimpse(lppub_files)

lppub_files <- lppub_files %>% arrange("LOAN_ID", "ACT_PERIOD")

# number of unique loans
length(unique(lppub_files$LOAN_ID)) # 2500530

# In order to avoid including loans with little performance history in our sample,
# we'll also want to count up how many rows exist in the performance file for each loan.
# This will let us filter loans without much performance history from our training data. 

# Total number of times each loan appear in the merged dataset
n_loan_data <- lppub_files  %>%
  group_by(LOAN_ID) %>%
  summarize(n_loan_appear = n())

lppub_files <- left_join(lppub_files, n_loan_data, by = "LOAN_ID")

# Keep a loan if it has at least history (or performance data) of 4 quarters (that is, if n_loan_appear >= 4)!
lppub_files %>% filter(n_loan_appear < 4) # 562098 obsn
lppub_files <- lppub_files %>% filter(n_loan_appear >= 4) 
length(unique(lppub_files$LOAN_ID)) # 2212616

rm(n_loan_data)

# Converts first_payment_date and origination_date to 2 columns each:
# first_payment_month, first_payment_year, origination_month, and origination_year.
lppub_files <- lppub_files %>%
  mutate(
    ORIG_MO = substr(ORIG_DATE,1,2),
    ORIG_YR = substr(ORIG_DATE,3,6),
    FRST_PAY_MO = substr(FIRST_PAY,1,2),
    FRST_PAY_YR = substr(FIRST_PAY,3,6),
    ORIG_MO = as.numeric(ORIG_MO),
    ORIG_YR = as.numeric(ORIG_YR),
    FRST_PAY_MO = as.numeric(FRST_PAY_MO),
    FRST_PAY_YR = as.numeric(FRST_PAY_YR))

# Convert string columns to numeric/integer column:

# Number of Borrower:
lppub_files <- lppub_files %>%
  mutate(NUM_BO = as.numeric(NUM_BO))

# First Time Home Buyer Indicator:
unique(lppub_files$FIRST_FLAG ) # "N" "Y"
lppub_files <- lppub_files %>%
  mutate(frst_flag = ifelse(FIRST_FLAG == "Y", 1, 0))

lppub_files %>% summary()

#--------------------------------------------------------------------------------
# Performance Variables: Ever Delinquent & Ever Foreclosed
#--------------------------------------------------------------------------------

# In the Performance data, FORECLOSURE_DATE will appear in the quarter when the 
# foreclosure happened, so it should be blank prior to that. Some loans are never 
# foreclosed on, so all the rows related to them in the Performance data have 
# FORECLOSURE_DATE blank.

# loans with "Foreclosure date"
lppub_files %>% filter(FORECLOSURE_DATE != "") # 63 cases

# Target Variable: Foreclosure Status
lppub_files <- lppub_files %>%
  mutate(foreclosure_flag = ifelse(FORECLOSURE_DATE != "", 1, 0))

# Target Variable: Delinquency Status
unique(lppub_files$DLQ_STATUS) # "00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17"

# 00 = Current
# 01 = 30-59 days
# 02 = 60-89 days
# 03 = 90-119 days
# 04 = 120 - 149 days 05 = 150 - 179 days 06 = 180 - 209 days, etc

lppub_files <- lppub_files %>%
  mutate(DLQ_STATUS = as.numeric(DLQ_STATUS))

summary(lppub_files$DLQ_STATUS) # Min: 0, Max: 17

lppub_files %>%  filter(DLQ_STATUS > 0) # 252890
lppub_files <- lppub_files %>%  mutate(DLQ = ifelse(DLQ_STATUS > 0, 1, 0)) # Assign Delinquency status = 1 if DLQ_STATUS > 0

#--------------------------------------------------------------------------------
# Performance DF: Save Target Variables by Loan
#--------------------------------------------------------------------------------
perf_columns <- c("archive", "LOAN_ID",  "DLQ", "foreclosure_flag")
df_perf <- lppub_files[, .SD, .SDcols = perf_columns] 

df_perf <- df_perf %>% group_by(LOAN_ID) %>% mutate(max_DLQ = max(DLQ),
                                                    max_frcl = max(foreclosure_flag))
df_perf <- df_perf %>% ungroup()
df_perf <- df_perf %>% mutate(ever_DLQ = ifelse(max_DLQ > 0, 1, 0),
                              ever_Foreclosed = ifelse(max_frcl > 0, 1, 0))

df_dlq <- df_perf %>% dplyr::select("archive", "LOAN_ID", "ever_DLQ", "ever_Foreclosed")

df_perf_collapsed <- df_dlq %>% distinct()  # 2212616

length(unique(df_perf$LOAN_ID)) # 2212616
length(unique(df_perf_collapsed$LOAN_ID)) # 2212616

rm(df_dlq)
rm(df_perf)

#--------------------------------------------------------------------------------
# Origination DF: Save Origination/Acquisition Variables by Loan
#--------------------------------------------------------------------------------
orig_columns <- c("archive", "LOAN_ID", "n_loan_appear", 
                  "ORIG_RATE", "ORIG_UPB",  "ORIG_TERM", "ORIG_DATE", "FIRST_PAY", "OLTV", "OCLTV",
                  "NUM_BO", "DTI", "CSCORE_B", "CSCORE_C", 
                  "PROP", "NO_UNITS",  "STATE",  "frst_flag",
                  "ORIG_MO", "ORIG_YR", "FRST_PAY_MO", "FRST_PAY_YR")

# "SELLER", "SERVICER", "CHANNEL", "MI_PCT", "ZIP", "OCC_STAT", 
df_orig <- lppub_files[, .SD, .SDcols = orig_columns] 
df_orig_collapsed <- df_orig %>% distinct()

length(unique(lppub_files$LOAN_ID)) # 2212616
length(unique(df_orig$LOAN_ID)) # 2212616
length(unique(df_orig_collapsed$LOAN_ID)) # 2212616

df_orig_collapsed <- df_orig_collapsed %>% 
  group_by(LOAN_ID) %>% 
  mutate(m_ORIG_RATE = mean(ORIG_RATE, na.rm = TRUE), # exclude the NA values from the mean calculation
         m_ORIG_UPB = mean(ORIG_UPB, na.rm = TRUE),
         m_ORIG_TERM = mean(ORIG_TERM, na.rm = TRUE),
         m_OLTV = mean(OLTV, na.rm = TRUE),
         m_OCLTV = mean(OCLTV, na.rm = TRUE),
         m_NUM_BO = mean(NUM_BO, na.rm = TRUE),
         m_DTI = mean(DTI, na.rm = TRUE),
         m_CSCORE_B = mean(CSCORE_B, na.rm = TRUE),
         m_CSCORE_C = mean(CSCORE_C, na.rm = TRUE),
         m_NO_UNITS = mean(NO_UNITS, na.rm = TRUE)
        )

df_orig_collapsed <- df_orig_collapsed  %>% ungroup()

df_orig_collapsed <- df_orig_collapsed  %>% 
  dplyr::select("archive", "LOAN_ID", "n_loan_appear", 
                 "m_ORIG_RATE",  "m_ORIG_UPB",  "m_ORIG_TERM", 
                  "m_OLTV",  "m_OCLTV",  "m_NUM_BO",  "m_DTI",   "m_CSCORE_B",  "m_CSCORE_C", 
                   "PROP",  "m_NO_UNITS",  "STATE",  "frst_flag",
                    "ORIG_MO", "ORIG_YR", "FRST_PAY_MO", "FRST_PAY_YR")

df_orig_collapsed <- df_orig_collapsed  %>% distinct()

n_loan_cnt <- df_orig_collapsed  %>%
  group_by(LOAN_ID) %>%
  summarize(n_loan_cnt = n())

n_loan_cnt %>% filter(n_loan_cnt > 1) # 113


df_orig_collapsed <- left_join(df_orig_collapsed, n_loan_cnt, by = "LOAN_ID")

# for now drop those are appearing more than once
df_orig_collapsed %>% filter(n_loan_cnt > 1) 
df_orig_collapsed <- df_orig_collapsed %>% filter(n_loan_cnt < 2) # 2212503 loans

setDT(df_orig_collapsed)

rm(n_loan_cnt)
rm(df_orig)

#--------------------------------------------------------------------------------
# Merge
#--------------------------------------------------------------------------------

df_orig_perf <- left_join( df_orig_collapsed, df_perf_collapsed, by = "LOAN_ID")

fm_loan_df <- df_orig_perf 
#....... this is the working data

rm(df_orig_perf)
rm(df_orig_collapsed)
rm(df_perf_collapsed)
rm(lppub_files)
