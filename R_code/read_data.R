#--------------------------------------------------------------------------------
# Project: DS Project using Fannie Mae's Single-Family Historical Loan Performance Dataset
#
# R Script Name: read_data.R
# Author: Debasmita Das (debasmita.das@gatech.edu)
# Script Written: 10/10/2023
# Last Updated: 12/05/2023
#--------------------------------------------------------------------------------
# Required packages
library(data.table)
library(tidyverse)
library(dplyr)

# remove any pre-loaded data 
rm(list = ls())

# Set current code directory
setwd("~/Dropbox (GaTech)/DD_Research/DS_projects/FannieMae/R_files")

# directory where raw data are stored
input_directory <- "~/Dropbox (GaTech)/DD_Research/DS_projects/FannieMae/data_R_files/raw_data"

# Run the file that contains all column names and selected column names (make sure to keep this file in the same directory)
source('col_names.R')

# Set up a function to read in the Loan Performance files
load_lppub_file <- function(file_path, col_names, col_classes, selected_columns, year, quarter){
  if (file.exists(file_path)) {
    cat("Reading the data for:", year, "quarter", quarter, "\n")
    
  # Read File
   df <- fread(file_path, sep = "|", col.names = col_names, colClasses = col_classes)
  
  # create YYYYQQ variable that marks the year and quarter of the file
  df <- df  %>% mutate(archive = paste0(year,quarter)) # YYYYQQ
  
  # keep selected columns
  df <- df[, .SD, .SDcols = selected_columns] 
  
  return(df)
  
  } else {
    # Print a message if the file does not exist
    cat("File does not exist for", year, "quarter", quarter, "\n")
  }
}

# List of years and quarters
years <- c(2022, 2023)
quarters <- c("Q1", "Q2", "Q3", "Q4")

for (year in years) {
  for (quarter in quarters) {
    
  # Create file name based on year and quarter
  file_name <- paste0(year, quarter, ".csv")
  
  # combine data directory with data file name
  file_path <- file.path(input_directory,file_name)
  
  #Load files
  if(year == 2022 & quarter == "Q1"){ # IMPORTANT: change according to starting year of the analysis
      lppub_files <- load_lppub_file(file_path, lppub_column_names, lppub_column_classes,
                                     selected_columns, year, quarter)
    } else {
      lppub_files <- rbind(lppub_files, 
                           load_lppub_file(file_path, lppub_column_names, lppub_column_classes, 
                                           selected_columns, year, quarter))
    }
  }
}

   
  
  
  
  
  