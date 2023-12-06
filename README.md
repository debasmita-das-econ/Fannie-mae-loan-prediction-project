# DS Project using Fannie Mae Single-Family Historical Loan Performance Dataset

**Goal:**
In this project, we want to predict whether or not loans acquired by Fannie Mae will become more than 30 days delinquent.

<!---
go into foreclosure. 

Foreclosure happens when a lender seizes and sells a property because the homeowner has not been making the required mortgage payments.
-->

Fannie Mae acquires loans from other lenders as a way of inducing them to lend more. Fannie Mae releases data on the loans it has acquired and their performance afterwards. 

## Accessing the Data
- For this project, I used Fannie Mae's **Single-Family Historical Loan Performance Dataset**. 
- Fannie Mae provides loan performance data on a portion of its single-family mortgage loans to promote better understanding of the credit performance of Fannie Mae mortgage loans.
- Data can be downloaded from [Fannie Mae's website](https://capitalmarkets.fanniemae.com/credit-risk-transfer/single-family-credit-risk-transfer/fannie-mae-single-family-loan-performance-data).
- Fannie Mae requires the user to register and create a unique username and password in order to access the performance data.
- After creating the account, we can log in to [Data Dynamics](https://capitalmarkets.fanniemae.com/tools-applications/data-dynamics), and download the data we need for this project.
- We will be downloading "Single-Family Loan Acquisition and Performance data". The data are available by quarter starting from 2000 Q1 till the latest available date (2023 Q2 as of now). For this project, we will use the data from 2020 Q1 till 2023 Q2.

## Code

* [`col_names.R`](https://github.com/debasmita-das-econ/Fannie-mae-loan-prediction-project/blob/main/R_code/col_names.R): set column names and variable types
 
* [`read_data.R`](https://github.com/debasmita-das-econ/Fannie-mae-loan-prediction-project/blob/main/R_code/read_data.R): read downloaded raw data sets into R dataframe

* [`prep_data.R`](https://github.com/debasmita-das-econ/Fannie-mae-loan-prediction-project/blob/main/R_code/prep_data.R): Prepares working data by selecting relevant acquisition and performance variablesof interest, renames variables, created derived variables required in the analysis, cleans data and saves working data.
    
* [`predict.R`](https://github.com/debasmita-das-econ/Fannie-mae-loan-prediction-project/blob/main/R_code/predict.R): creates training and test datasets, perform predictive analysis using logistic regression

Please note that this is an ongoing analysis, and will be updated.

<!---
## Required Packages
`dplyr`, `tidyverse`, `data.table`, `gmodels`,


## Predictive Analysis
Perform Logistic Regression

## Project Pipeline

This project is inspired from [DataQuest's Loan Prediction Project](https://github.com/dataquestio/loan-prediction).
-->
