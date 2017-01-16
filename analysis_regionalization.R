
####################################################################################################

# Libraries

library(ggplot2)
library(tidyr)

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
  
  data <- gather(data, ndoner, ns)
  
  p <- ggplot(data = data, aes(x = ndoner, y = ns)) + 
    geom_boxplot() +
    ylim(c(0,1)) + 
    geom_text(data = nr_neg, aes(label = nr_neg, y = 1.0), colour = "red", size = 7) +
    ggtitle("Numbers indicate number of catchments with NSE < 0") +
    xlab("Number of doners") + 
    ylab("NSE (-)")
  
  print(p)
  
  # Plot KGE
  
  filename <- paste(folder, "kge_table.txt", sep = "/")
  
  data <- read.csv(filename, header = TRUE)
  
  colnames(data) <- 1:ncol(data)
  
  nr_neg <- data.frame(nr_neg = colSums(data<0), ndoner = colnames(data))
  
  data <- gather(data, ndoner, kge)
  
  p <- ggplot(data = data, aes(x = ndoner, y = kge)) + 
    geom_boxplot() +
    ylim(c(0,1)) + 
    geom_text(data = nr_neg, aes(label = nr_neg, y = 1.0), colour = "red", size = 7) +
    ggtitle("Numbers indicate number of catchments with KGE < 0") +
    xlab("Number of doners") + 
    ylab("KGE (-)")
  
  print(p)
  
  # Plot PBIAS
  
  filename <- paste(folder, "pbias_table.txt", sep = "/")
  
  data <- read.csv(filename, header = TRUE)
  
  colnames(data) <- 1:ncol(data)
  
  nr_outside <- data.frame(nr_outside = colSums(abs(data) > 50), ndoner = colnames(data))
  
  data <- gather(data, ndoner, pbias)
  
  p <- ggplot(data = data, aes(x = ndoner, y = pbias)) + 
    geom_boxplot() +
    ylim(c(-50,50)) + 
    geom_text(data = nr_outside, aes(label = nr_outside, y = 50), colour = "red", size = 7) +
    ggtitle("Numbers indicate number of catchments with pbias > abs(50)") +
    xlab("Number of doners") + 
    ylab("PBIAS (%)")
  
  print(p)
  
  dev.off()
  
}


####################################################################################################

# Function for computing statistics

summary_stat <- function(data, func) {
  
  if (func=="median") {
    center_col <- apply(data, 2, median)
    print("hej")
  }
  
  if (func=="mean") {
    center_col <- apply(data, 2, mean)
  }
  
  best_center <- max(center_col)
  
  best_ndoner <- which(center_col == best_center)
  
  best_std <- sd( data[, best_ndoner])
  
  list(best_center = best_center, 
       best_std = best_std, 
       best_ndoner = best_ndoner)
  
}

# Folders with results

folders <- dir(path = ".", pattern = "results_")

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



















