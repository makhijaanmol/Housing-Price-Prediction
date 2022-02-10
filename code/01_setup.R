# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Setup: Used for installing/loading required packages and importing data
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Install Required Packages (Run only during the first time on your R setup)
install.packages("tidyverse") # A set of packages for visualization, cleaning, manipulation etc.
install.packages("leaps") # Model selection
install.packages("modelsummary") # Summarize statistical models
install.packages("corrplot") # Visualization of correlation matrix
install.packages("caret") # Classification and regression training package
install.packages("glmnet") # Used here for ridge regression modeling
install.packages("modelr") # Adding predicted values and residuals to data
install.packages("MASS") # Robust linear model to deal with outliers
install.packages("olsrr") # Used here for identifying outliers

# Load packages
library(tidyverse)
library(leaps)
library(modelsummary)
library(corrplot)
library(lubridate)
library(caret)
library(glmnet)
library(modelr)
library(MASS)
library(olsrr)

# Setting misc preferences
rstudioapi::writeRStudioPreference("data_viewer_max_columns", 100L) # View 100 columns at a time 
options(scipen = 999) # Prevent scientific notation

# Reading in raw data
training_data <- read_csv(str_interp("${input_dir}/TrainingData.csv"))
test_data <- read_csv(str_interp("${input_dir}/TestData.csv"))
