library(ggplot2)
library(reshape)
library(plyr)
library(ggthemes)
library(scales)
library(viridis)
library(RColorBrewer)

options(warn = - 1, width = 150)

rm(list = ls())
args <- commandArgs(trailingOnly = TRUE)

input = args[1]
output = args[2]

dir.create(output)

data <- read.table(file.path(input), header = T, sep = ",")

data$year = factor(data$year)

simpleBarPlot <- function(name, data, x, y) {

    max <- round(max(data[y]), 2)
    min <- round(min(data[y]), 2)
    mean <- mean(data[, y])


    gg <- ggplot(data, aes_string(x = x, y = y)) + geom_bar(stat = "identity", fill = "#b099ff", colour = "black")
    gg <- gg + geom_hline(yintercept = 0)
    gg <- gg + geom_hline(yintercept = max, colour = "#990000", linetype = "dashed")
    gg <- gg + geom_hline(yintercept = min, colour = "#990000", linetype = "dashed")
    gg <- gg + ggtitle(paste(name, '  max:', format(round(max, 2), nsmall = 2), 'min:', format(round(min, 2), nsmall = 2), 'mean:', format(round(mean, 2), nsmall = 2)))
    gg <- gg + theme(axis.text.x = element_text(angle = 90, hjust = 1))
    gg <- gg + scale_y_continuous(breaks = pretty_breaks(n = 20))
    filePath <- file.path(output, paste(name, '_', y , '.png', sep = ""))
    ggsave(file = filePath)
    print(sprintf("Saved %s", filePath))
}

profitColumns <- c('averagenetprofit', 'appt', 'profitperrisk', 'winnerLoserCount', 'totalprofit')

lapply(profitColumns, function(x) simpleBarPlot('byYear', data, 'year', x))