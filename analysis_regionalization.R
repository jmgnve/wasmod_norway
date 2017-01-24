
####################################################################################################

# Libraries

library(ggplot2)
library(tidyr)
library(readxl)

####################################################################################################

# Plot results

# Folders with results

folders <- dir(path = ".", pattern = "results_")

# Loop over folders

for (folder in folders) {
  
  pdf(paste(folder, "plots.pdf", sep = "/"))
  
  # Plot NSE
  
  filename <- paste(folder, "ns_table.txt", sep = "/")
  
  data <- read.csv(filename, header = TRUE)
  
  colnames(data) <- 1:ncol(data)
  
  nr_neg <- data.frame(nr_neg = colSums(data<0), ndoner = colnames(data))
  
  boxplot(data, ylim=c(0, 1), 
          xlab = "Number of doners", ylab = "NSE (-)",
          main = "Red numbers: nr catchments with NSE < 0")
  text(x = nr_neg$ndoner, y = 1, labels = nr_neg$nr_neg, col = "red")
  
  # Plot KGE
  
  filename <- paste(folder, "kge_table.txt", sep = "/")
  
  data <- read.csv(filename, header = TRUE)
  
  colnames(data) <- 1:ncol(data)
  
  nr_neg <- data.frame(nr_neg = colSums(data<0), ndoner = colnames(data))
  
  boxplot(data, ylim=c(0, 1), 
          xlab = "Number of doners", ylab = "KGE (-)",
          main = "Red numbers: nr catchments with KGE < 0")
  text(x = nr_neg$ndoner, y = 1, labels = nr_neg$nr_neg, col = "red")
  
  # Plot PBIAS
  
  filename <- paste(folder, "pbias_table.txt", sep = "/")
  
  data <- read.csv(filename, header = TRUE)
  
  colnames(data) <- 1:ncol(data)
  
  nr_outside <- data.frame(nr_outside = colSums(abs(data) > 50), ndoner = colnames(data))
  
  boxplot(data, ylim=c(-51, 51), 
          xlab = "Number of doners", ylab = "PBIAS (%)",
          main = "Red numbers: nr catchments with pbias > abs(50)")
  text(x = nr_neg$ndoner, y = 10, labels = nr_neg$nr_neg, col = "red")
  
  dev.off()
  
}


####################################################################################################

# Function for computing statistics

summary_stat <- function(data, func) {
  
  if (func=="median") {
    center_col <- apply(data, 2, median)
  }
  
  if (func=="mean") {
    center_col <- apply(data, 2, mean)
  }
  
  best_center <- max(center_col)
  
  best_ndoner <- which(center_col == best_center)
  
  best_std <- sd(data[, best_ndoner])
  
  list(best_center = best_center, 
       best_std = best_std, 
       best_ndoner = best_ndoner)
  
}

# Load table with experiment settings

tbl_settings <- read_excel("regionalization_experiments.xlsx")

# Folders with results

folders <- paste("results", 1:nrow(tbl_settings), sep = "_")

# Loop over folders

nse <- c()
nse_std <- c()
nse_ndoner <- c()

pbias <- c()
pbias_std <- c()
pbias_ndoner <- c()

for (folder in folders) {
  
  # Analyze NSE
  
  filename <- paste(folder, "ns_table.txt", sep = "/")
  
  data <- read.csv(filename, header = TRUE)
  
  res <- summary_stat(data, "median")
  
  nse <- c(nse, res$best_center)
  nse_std <- c(nse_std, res$best_std)
  nse_ndoner <- c(nse_ndoner, res$best_ndoner)
  
  # Analyze PBIAS
  
  filename <- paste(folder, "pbias_table.txt", sep = "/")
  
  data <- read.csv(filename, header = TRUE)
  
  res <- summary_stat(data, "mean")
  
  pbias <- c(pbias, res$best_center)
  pbias_std <- c(pbias_std, res$best_std)
  pbias_ndoner <- c(pbias_ndoner, res$best_ndoner)
  
}

# Create data frame with results

tbl_results <- data.frame(nse = round(nse, digits = 2),
                          nse_std = round(nse_std, digits = 2),
                          nse_ndoner = nse_ndoner,
                          pbias = round(pbias, digits = 2),
                          pbias_std = round(pbias_std, digits = 2),
                          pbias_ndoner = pbias_ndoner)

tbl_all <- cbind(tbl_settings, tbl_results)

# Save results to text file

write.table(tbl_all, file = "results_summary.csv", quote = TRUE, sep = ";", row.names = FALSE, dec = ",")












