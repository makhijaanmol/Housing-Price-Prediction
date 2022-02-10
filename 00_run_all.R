# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Overview: This master script runs the setup, data preparation, visualization, and modeling scripts.
# Author: Anmol Makhija
# Date created: 01/18/2022
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Setting up dynamic working directory to source file location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Defining globals
input_dir = "input"
code_dir = "code"
output_dir = "output"

source("code/01_setup.R")
source("code/02_data_prep.R")
source("code/03_exploratory_analysis.R")
source("code/04_modeling.R")