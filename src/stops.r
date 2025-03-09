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


if (length(args) < 2) {
    stop("Need to supply input file and output directory arguments", call. = FALSE)
}

input = args[1]
output = args[2]
graph.output = file.path(output, 'graphs')
dir.create(graph.output, recursive = TRUE)

print("Starting stops.r")
print(sprintf("Input for stops.r %s", input))
print(sprintf("Output for stops.r %s", graph.output))

print(sprintf("Checking for file %s", input))
if (! file.exists(input)) {
    stop(sprintf("Unable to find the input file %s", input))
}


data <- read.table(file.path(input), header = T, sep = ",")
filtered.data <- data

summary <- function(data, input, output) {

    output <- file.path(output, 'data', 'summary.txt')

    print("Starting summary.r")
    print(sprintf("Input for summary.r %s", input))
    print(sprintf("Output for summary.r %s", output))

    (sprintf("Input is %s\n", input))
    cat(sprintf("Output is %s\n", output))
    cat(sprintf("Current working directory %s\n", getwd()))
    cat(sprintf("Rows %s", nrow(data)))

    winners <- sum(data$totalprofit > 0)
    losers <- sum(data$totalprofit < 0)
    flat <- sum(data$totalprofit == 0)

    fileConn <- file(file.path(output), "wt")
    writeLines(c(sprintf("Winners: %d\nLosers: %d\n", winners, losers)),
    con = fileConn, sep = "\n")

    close(fileConn)
    print('Finished summary')
}

summary(data, input, output)


breaks <- c(min, max)
aggregate.by.stop <- aggregate(filtered.data, by = list(filtered.data$stop), FUN = mean, na.rm = TRUE)
aggregate.by.limit <- aggregate(filtered.data, by = list(filtered.data$limit), FUN = mean, na.rm = TRUE)
aggregate.by.tickoffset <- aggregate(filtered.data, by = list(filtered.data$tickoffset), FUN = mean, na.rm = TRUE)
aggregate.by.tradeduration <- aggregate(filtered.data, by = list(filtered.data$tradeduration), FUN = mean, na.rm = TRUE)
aggregate.by.outoftime <- aggregate(filtered.data, by = list(filtered.data$outoftime), FUN = mean, na.rm = TRUE)
aggregate.by.dayofweek <- aggregate(filtered.data, by = list(filtered.data$dayofweek), FUN = mean, na.rm = TRUE)
aggregate.by.dayofweek$dayofweek <- NULL
aggregate.by.dayofweek <- rename(aggregate.by.dayofweek, c("Group.1" = "dayofweek"))
aggregate.by.hourofday <- aggregate(filtered.data, by = list(filtered.data$hourofday), FUN = mean, na.rm = TRUE)
aggregate.by.hourofday$hourofday <- NULL
aggregate.by.hourofday <- rename(aggregate.by.hourofday, c("Group.1" = "hourofday"))
aggregate.by.hourofday$hourofday <- factor(aggregate.by.hourofday$hourofday)

simpleBarPlot <- function(name, data, fillColor, x, y) {

    max <- round(max(data[y]), 2)
    min <- round(min(data[y]), 2)
    mean <- mean(data[, y])

    print(sprintf("Saved %s", y))
    gg <- ggplot(data, aes_string(x = x, y = y)) + geom_bar(stat = "identity", fill = fillColor, colour = "black")
    gg <- gg + geom_hline(yintercept = 0)
    gg <- gg + geom_hline(yintercept = max, colour = "#990000", linetype = "dashed")
    gg <- gg + geom_hline(yintercept = min, colour = "#990000", linetype = "dashed")
    gg <- gg + ggtitle(paste(name, '  max:', format(round(max, 2), nsmall = 2), 'min:', format(round(min, 2), nsmall = 2), 'mean:', format(round(mean, 2), nsmall = 2)))
    gg <- gg + theme(axis.text.x = element_text(angle = 90, hjust = 1))
    gg <- gg + scale_y_continuous(breaks = pretty_breaks(n = 20))
    ggsave(file = file.path(graph.output, paste(name, y , '.png', sep = "")))
}

profitFields <- c('averagenetprofit', 'profitperrisk', 'totalprofit')

lapply(profitFields, function(y) simpleBarPlot(name = 'dayofweek', data = aggregate.by.dayofweek, fill = '#FF9999', x = 'dayofweek', y))
lapply(profitFields, function(y) simpleBarPlot(name = 'hourofday', data = aggregate.by.hourofday, fill = '#b099ff', x = 'hourofday', y))
lapply(profitFields, function(y) simpleBarPlot(name = 'stop', data = aggregate.by.stop, fill = '#99ff9a', x = 'stop', y))
lapply(profitFields, function(y) simpleBarPlot(name = 'limit', data = aggregate.by.limit, fill = '#603021', x = 'limit', y))
lapply(profitFields, function(y) simpleBarPlot(name = 'tickoffset', data = aggregate.by.tickoffset, fill = '#8a8e75', x = 'tickoffset', y))
lapply(profitFields, function(y) simpleBarPlot(name = 'tradeduration', data = aggregate.by.tradeduration, fill = '#757b8e', x = 'tradeduration', y))
lapply(profitFields, function(y) simpleBarPlot(name = 'outoftime', data = aggregate.by.outoftime, fill = '#3e61c9', x = 'outoftime', y))



print('Finished stops.r')

