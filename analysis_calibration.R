# Libraries

library(ggplot2)
library(tidyr)
library(dplyr)

# Read data

restab <- read.csv("calibration_results/wasmod_calib_nse.csv", header = TRUE, stringsAsFactors = FALSE, sep = ";")

# Prepare data

restab <- restab %>% select(mc_3111:mc_3121) %>% gather(mc, nseff, mc_3111:mc_3121)

# Plot data

ggplot(data = restab, aes(x = mc, y = nseff)) + geom_boxplot()

ggsave("calibration_results/boxplots.pdf", width = 40, height = 20, units = "cm")

