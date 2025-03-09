library(plyr)
library(RColorBrewer)
library(ggplot2)
library(ggthemes)
library(scales)
library(viridis)
require(data.table)

rm(list = ls())

options(warn = - 1, width = 150)
print("Starting monthYear.r")

args <- commandArgs(trailingOnly = TRUE)

input = args[1]
output = args[2]

data <- fread(input)

data$month = factor(data$month, levels = c("JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST",
"SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"))
data$year = factor(data$year)

data <- data[order(year, month),]

profitColumn <- 'totalprofit'

hm.palette <- colorRampPalette(rev(brewer.pal(11, 'Spectral')), space = 'Lab')

heatMapDir <- file.path(output)
dir.create(heatMapDir, recursive = TRUE)

generateHeatMaps <- function(profitColumn) {
    gg <- ggplot(data, aes_string(x = x, y = y, fill = profitColumn))
    gg <- gg + geom_tile(color = "white")
    gg <- gg + scale_fill_gradientn(colours = hm.palette(100))
    gg <- gg + coord_equal()
    gg <- gg + ggtitle(paste(profitColumn, "per", x, "and", y))
    gg <- gg + theme(plot.title = element_text(size = 10))
    gg <- gg + theme(axis.ticks = element_blank())
    gg <- gg + theme(axis.text = element_text(size = 7))
    gg <- gg + theme(axis.title.x = element_text(colour = "grey20", size = 10, angle = 0, hjust = .5, vjust = 0, face = "plain"))
    gg <- gg + theme(axis.title.y = element_text(colour = "grey20", size = 10, angle = 90, hjust = .5, vjust = .5, face = "plain"))
    gg <- gg + theme(legend.title = element_text(size = 6))
    gg <- gg + theme(legend.text = element_text(size = 6))
    graphOutput <- file.path(heatMapDir, paste(x, '_', y, '_', profitColumn, 'HM.png', sep = ""))
    print(sprintf("Saved %s", graphOutput))
    ggsave(file = graphOutput)
}

simpleBarPlot <- function(name, data, x, y) {
    gg <- ggplot(data, aes_string(x = x, y = y)) + geom_bar(stat = "identity", fill = "#b099ff", colour = "black")
    gg <- gg + geom_hline(yintercept = 0)
    gg <- gg + ggtitle(name)
    gg <- gg + theme(axis.text.x = element_text(angle = 90, hjust = 1))
    #  gg <- gg + scale_y_continuous(breaks=pretty_breaks(n=100))
    gg <- gg + facet_grid(year ~ .)
    filePath <- file.path(output, paste(name, '_', y , '.png', sep = ""))
    ggsave(file = filePath)
    print(sprintf("Saved %s", filePath))
}

profitColumns <- c('averagenetprofit', 'appt', 'profitperrisk', 'winnerLoserCount', 'totalprofit')
lapply(profitColumns, function(y) simpleBarPlot('monthYear', data, 'month', y))


data$traderName <- factor(data$traderName, levels = data$traderName[order(data$year, data$month)])
data <- data[order(data$year, data$month),]


simpleBarPlotNoFacet <- function(name, data, x, y) {
    gg <- ggplot(data, aes_string(x = x, y = y)) + geom_bar(stat = "identity", fill = "#b099ff", colour = "black")
    gg <- gg + geom_hline(yintercept = 0)
    gg <- gg + ggtitle(name)
    gg <- gg + scale_x_discrete(labels = data$traderName)
    gg <- gg + theme(axis.text.y = element_text(size = 6))
    gg <- gg + theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 4))
    gg <- gg + scale_y_continuous(breaks = pretty_breaks(n = 20))
    filePath <- file.path(output, paste(name, '_', y , '-Months.png', sep = ""))
    ggsave(file = filePath, width = 12, height = 4, dpi = 400)
    print(sprintf("Saved %s", filePath))
}

lapply(profitColumns, function(y) simpleBarPlotNoFacet('monthYearBar', data, 'traderName', y))

#Generate the heatmaps
x <- 'year'
y <- 'month'

lapply(profitColumns, function(x) generateHeatMaps(x))
