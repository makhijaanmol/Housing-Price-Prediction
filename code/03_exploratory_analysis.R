# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Motivating Log Sale Price Construction
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
sale_price_hist <- ggplot(data = modified_training_data) +
  geom_histogram(mapping = aes(x = sale_price), binwidth = 100000) +
  labs(x = "Sale Price", y = "Number of Observation") # Heavily right skewed 

ggsave("Sale Price Histogram.pdf", sale_price_hist, path = (str_interp("${output_dir}")), width = 7, height = 5)
while (!is.null(dev.list()))  dev.off()

log_sale_hist <- ggplot(data = modified_training_data) +
  geom_histogram(mapping = aes(x = log(sale_price)), binwidth = 0.2) +
  coord_cartesian(xlim = c(2, 20)) +
  labs(x = "Log Sale Price", y = "Number of Observations")

ggsave("Log Sale Price Histogram.pdf", log_sale_hist, path = (str_interp("${output_dir}")), width = 7, height = 5)
while (!is.null(dev.list()))  dev.off()

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Plotting trends in yearly average sale price
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
yearly_sale_price_trend <- ggplot(data = modified_training_data, 
                                  mapping = aes(x = transaction_year, y = avg_yearly_sale_price)) +
  geom_point() +
  geom_smooth() +
  labs(x = "Transaction Year", y = "Yearly Average Sales Price")

ggsave("Trends in Yearly Average Sale Price.pdf", yearly_sale_price_trend, 
       path = (str_interp("${output_dir}")), width = 7, height = 5)
while (!is.null(dev.list()))  dev.off()