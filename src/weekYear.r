library(plyr)
library(RColorBrewer)
library(ggplot2)
library(ggthemes)
library(scales)
library(viridis)
require(data.table)
options(warn = - 1, width = 150)
print("Starting years.r")

args <- commandArgs(trailingOnly = TRUE)

input = args[1]
output = args[2]

#input <- '/tmp/trades-EURUSD/data/EURUSD.csv'
#input <- '/tmp/trades-EURUSD-WOYYear/data/WOYYear.csv'
#output <- '/tmp/trades-EURUSD/graphs'

data <- fread(input)

data$year = factor(data$year)
# hourDayDataSet <- factor(hourDayDataSet[order(hourDayDataSet$dayofweek), ])

profitColumn <- 'totalprofit'

hm.palette <- colorRampPalette(rev(brewer.pal(11, 'Spectral')), space = 'Lab')

x <- 'year'
y <- 'weekOfYear'

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
    gg <- gg + theme(axis.text.x = element_text(angle = 90, hjust = 1))
    #gg <- gg + scale_y_continuous(expand=c(0,0), breaks=0,52,2)
    #gg <- gg + scale_y_discrete(breaks = data$weekOfYear, drop = FALSE)

    graphOutput <- file.path(heatMapDir, paste(x, '_', y, '_', profitColumn, '.png', sep = ""))
    print(sprintf("Saved %s", graphOutput))
    ggsave(file = graphOutput)
}

profitColumns <- c('averagenetprofit', 'appt', 'profit_per_risk_ratio', 'winnerLoserCount', 'totalprofit')

lapply(profitColumns, function(x) generateHeatMaps(x))

