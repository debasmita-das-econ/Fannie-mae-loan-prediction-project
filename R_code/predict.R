#--------------------------------------------------------------------------------
# Project: DS Project using Fannie Mae's Single-Family Historical Loan Performance Dataset
#
# R Script Name: predict.R
# Author: Debasmita Das (debasmita.das@gatech.edu)
# Script Written: 11/20/2023
# Last Updated: 12/05/2023
#
# This script performs prediction analysis.
#
#--------------------------------------------------------------------------------

library(gmodels)

glimpse(fm_loan_df) 
summary(fm_loan_df)

#--------------------------------------------------------------------------------
# Create Training Set and Test Set
#--------------------------------------------------------------------------------

# Set seed of 567
set.seed(667)

# Store row numbers for training set: index_train
index_train <- sample(1:nrow(fm_loan_df), 2 / 3 * nrow(fm_loan_df))

# Create training set: training_set
training_set <- fm_loan_df[index_train, ]

# Create test set: test_set
test_set <- fm_loan_df[-index_train, ]

#--------------------------------------------------------------------------------
# Perform Logistic Regression
#--------------------------------------------------------------------------------

# Perform logistic regression 
logit_simple <- glm(formula = ever_DLQ ~ m_ORIG_RATE, family = "binomial",
                     data = training_set)

# parameter estimates 
summary(logit_simple)

# Perform logistic regression 
logit_multi <- glm(ever_DLQ ~ m_ORIG_RATE + m_ORIG_UPB + m_ORIG_TERM + m_OLTV
                       + m_NUM_BO + frst_flag, 
                       family = "binomial", data = training_set)

# coefficient estimates
summary(logit_multi)
summary(logit_multi)$coef

# Make prediction based on the estimates obtained from the logistic regression model
pred_multi <- predict(logit_multi, newdata = test_set, type = "response")

summary(pred_multi)

# range of the predicted probabilities 
range(pred_multi)

# Convert the predicted values to probabilities:
prob <- 1/(1 + exp(-pred_multi))
summary(prob)

#--------------------------------------------------------------------------------
# Assessing the Model
#--------------------------------------------------------------------------------
pred_y <- as.numeric(pred_multi > 0)
true_y <- as.numeric(training_set$ever_DLQ)
true_pos <- (true_y==1) & (pred_y==1)
true_neg <- (true_y==0) & (pred_y==0)
false_pos <- (true_y==0) & (pred_y==1)
false_neg <- (true_y==1) & (pred_y==0)
conf_mat <- matrix(c(sum(true_pos), sum(false_pos),
                     sum(false_neg), sum(true_neg)), 2, 2)
colnames(conf_mat) <- c('Yhat = 1', 'Yhat = 0')
rownames(conf_mat) <- c('Y = 1', 'Y = 0')
conf_mat

# precision
conf_mat[1, 1] / sum(conf_mat[,1]) 
# recall
conf_mat[1, 1] / sum(conf_mat[1,]) 
# specificity
conf_mat[2, 2] / sum(conf_mat[2,])



