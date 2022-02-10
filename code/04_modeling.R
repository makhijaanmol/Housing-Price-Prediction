# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Feature selection
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set.seed(1)

#splitting training data into 80% modeling set and 20% validation set
index <- createDataPartition(modified_training_data$log_sale_price, p=0.8, list=FALSE)

model_building <- modified_training_data[index, ] 

# model_building <- modified_training_data %>% filter(transaction_year>=2011, transaction_month>=11)
# Defining the model building set by including only transactions closer to Dec 2012 did improve the accuracy of the model
# However, the sample size was too small to justify a generalized model. The adjusted r-sq increased from 27% to 84% 
# under this specification

model_validation <- modified_training_data[-index, ]

train.control <- trainControl(method = "cv", number = 10) # cross-validating with 10 sub-samples

leapBack_model <- train(log_sale_price ~ ., data = model_building,
                        # Since number of samples > number of variables backward selection is an appropriate algorithm
                        method = "leapBackward", 
                        tuneGrid = data.frame(nvmax = 1:10),
                        trControl = train.control,
                        na.action = na.exclude,
                        metric = "RMSE") #Using root mean square error and optimzation parameter
summ <- summary(leapBack_model)
summ

selected_vars <- summ$which  # Checking which variables are included in optimal model
selected_vars

bic = summ$bic 
n.par <- apply(summ$which,1, sum)
cbind(bic, summ$which)[(bic < (min(bic) +2)), ]


# Based on the leapBackward model the best subset of variables is: total_net_acres, tax_district_no, style,
# improvement_sf, total_garage_sf, total_finished_basement_sf, total_unfinished_basement_sf, built_year, 
# and transaction_year. 

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Estimation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prediction_model <- lm(log_sale_price ~ location_zip_code + total_net_acres + tax_district_no + style + 
                         improvement_sf + total_garage_sf + total_finished_basement_sf + 
                         total_unfinished_basement_sf + built_year + transaction_year, data = model_building)
summary(prediction_model)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Outliers
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pdf(str_interp("${output_dir}/deleted_studentized_residuals.pdf"))
del.stu.res <- ols_plot_resid_stud(prediction_model)
while (!is.null(dev.list()))  dev.off()


# Check if data is influential using DFFITS, Cook's, and DFBETA (Graphically)
pdf(str_interp("${output_dir}/DFFITS.pdf"))
DFFITS <- ols_plot_dffits(prediction_model)
while (!is.null(dev.list()))  dev.off()

pdf(str_interp("${output_dir}/cooks_distance.pdf"))
cooks <- ols_plot_cooksd_chart(prediction_model)
while (!is.null(dev.list()))  dev.off()

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Remedial Measures
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
reg_validation <- rlm(log_sale_price ~ location_zip_code + total_net_acres + tax_district_no + style + 
                        improvement_sf + total_garage_sf + total_finished_basement_sf + 
                        total_unfinished_basement_sf + built_year + transaction_year, data = model_validation)
summary(reg_validation)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Prediction
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
test_data <- test_data %>% add_residuals(model = reg_validation) %>% 
  add_predictions(model = reg_validation, var = "pred_log_sale_price") %>% 
  mutate(predicted_price = exp(pred_log_sale_price)) %>% 
  mutate(price_diff = abs(predicted_price-sale_price))

write.csv(test_data, str_interp("${output_dir}/pred_test_data.csv"), row.names = F)

price_diff_hist <- ggplot(data = test_data, mapping = aes(x = price_diff)) +
  geom_histogram() +
  labs(x = "Price Difference", y = "Number of Observations")

ggsave("Price Diff Histogram.pdf", price_diff_hist, path = (str_interp("${output_dir}")), width = 7, height = 5)
while (!is.null(dev.list()))  dev.off()

obs_pred_price <- ggplot(data = test_data, mapping = aes(x = predicted_price, y = sale_price)) +
  geom_point(na.rm = T) +
  geom_smooth(na.rm = T) +
  labs(x = "Predicted Price", y = "Sale Price")

ggsave("Price Sactterplot.pdf", obs_pred_price, path = (str_interp("${output_dir}")), width = 7, height = 5)
while (!is.null(dev.list()))  dev.off()
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# OTHER MODELS ATTEMPTED
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# full.model <- lm(log_sale_price ~., data = model_building, nvmax=10)
# full.model <- regsubsets(log_sale_price ~., data = na.omit(model_building), really.big = T) #run-time too high

# grid_ri_reg = expand.grid(alpha = 0, lambda = seq(0.001, 0.1,
#                                                  by = 0.0002))
# # Training Ridge Regression model
# Ridge_model <-  train(log_sale_price ~ .,data = model_building,
#                     method = "glmnet",
#                     trControl = train.control,
#                     tuneGrid = grid_ri_reg,
#                     na.action = na.exclude
# )
# summ <- summary(Ridge_model)
# 
# selected_vars <- summ$which # Better subset of variables included under the backward stepwsie method
# selected_vars
# 
# stepAIC_model <- train(log_sale_price ~ ., data = model_building,
#                        method = "lmStepAIC",
#                        trControl = train.control,
#                        na.action = na.exclude)
# stepAIC_model
# summ <- summary(stepAIC_model)
# 
# selected_vars <- summ$which # Better subset of variables included under the backward stepwsie method
# selected_vars
