# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Training Data Preparation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
colSums(is.na(training_data)) # count number of NAs for each variable
# About 93% of pre_direction_code, 97% of unit_no, 92% of unit_type, 30% of roof_construction_type, 
# and 10% of sprinkler_coverage_sf are NA values

# Converting character transaction dates to formatted dates
modified_training_data <- training_data %>% 
  mutate(format_transaction_date = dmy(training_data$transaction_date)) %>% 
  mutate(transaction_year = year(format_transaction_date)) %>%
  mutate(transaction_month = month(format_transaction_date)) %>% 
  mutate(log_sale_price = log(sale_price)) %>% 
  filter(!is.na(sale_price)) %>% # Filtering out transactions from December 2012
  group_by(transaction_year) %>%
  mutate(
    avg_yearly_sale_price = mean(sale_price, na.rm = T, n = n())
  ) %>%
  # Deleting a few columns that would not contribute much to improve model building speed
  # Ideally I would not have deleted columns right off the bat, however, my computer crashed when I tried to 
  # calculate the optimal model with all 54 variables provided due to RAM constraints.
  # Removing observations that did not seem to logically explain sale price variation:
  dplyr::select(-c(transaction_date, grantor, grantee, city_name, section, township, range, quarter, predict,
            neighborhood_code, neighborhood_extension, format_transaction_date, built_as,
            # Removing observations that were largely NAs
            pre_direction_code, unit_no, unit_type, roof_construction_type_code, sprinkler_coverage_sf,
            # Removing observations with large number of factors to improve computational efficiency
            property_id, land_economic_area_code, street_name))

modified_training_data[sapply(modified_training_data, is.character)] <- 
  lapply(modified_training_data[sapply(modified_training_data, is.character)], 
                                       as.factor)

colSums(is.na(modified_training_data)) #Checking how many NA values there are per column
sapply(lapply(modified_training_data, unique), length)  # Checking number of unique values per column

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Test Data Preparation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
test_data <- test_data %>% mutate(format_transaction_date = dmy(test_data$transaction_date)) %>% 
  mutate(transaction_year = year(format_transaction_date)) %>% 
  mutate(log_sale_price = log(sale_price))