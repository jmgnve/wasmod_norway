# Libraries

library(ggplot2)
library(tidyr)
library(dplyr)

# Read data

restab <- read.csv("tables/wasmod_nseff.csv", header = TRUE, stringsAsFactors = FALSE, sep = ";")

# Prepare data

restab <- restab %>% select(mc_1111:mc_4222) %>% gather(mc, nseff, mc_1111:mc_4222)

# Plot data

ggplot(data = restab, aes(x = mc, y = nseff)) + geom_boxplot()

ggsave("figures/boxplots.pdf", width = 40, height = 20, units = "cm")

