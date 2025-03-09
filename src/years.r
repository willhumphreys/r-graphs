library(plyr)
library(RColorBrewer)
library(ggplot2)
library(ggthemes)
library(scales)
library(viridis)
require(data.table)
library(ggplot2)
options(warn = - 1, width = 150)
print("Starting years.r")

args <- commandArgs(trailingOnly = TRUE)

input = args[1]
output = args[2]

parseDataForAllYears <- function() {
    data <- fread(input)

    minTradesPerYear <- 6
    tradersToRemove <- data[data$tradecount < minTradesPerYear,]$traderid
    data <- data[! data$traderid %in% tradersToRemove,]
    gc()
    return (data)
}

generateHeatMaps <- function(data, output) {

    generateHeatMapGraph <- function(dataset, profitColumn, x, y) {

        gg <- ggplot(dataset, aes_string(x = x, y = y, fill = profitColumn))
        gg <- gg + geom_tile(color = "white", size = 0.1)
        gg <- gg + scale_fill_gradientn(colours = hm.palette(100))
        #gg <- gg + coord_equal()
        gg <- gg + ggtitle(paste(profitColumn, "per", x, "and", y))
        gg <- gg + theme(plot.title = element_text(size = 10))
        gg <- gg + theme(axis.ticks = element_blank())
        gg <- gg + theme(axis.text = element_text(size = 7))
        gg <- gg + theme(axis.title.x = element_text(colour = "grey20", size = 10, angle = 0, hjust = .5, vjust = 0, face = "plain"))
        gg <- gg + theme(axis.title.y = element_text(colour = "grey20", size = 10, angle = 90, hjust = .5, vjust = .5, face = "plain"))
        gg <- gg + theme(legend.title = element_text(size = 6))
        gg <- gg + theme(legend.text = element_text(size = 6))
        gg <- gg + scale_y_discrete(expand = c(0, 0), limits = 0 : 23)
        gg <- gg + scale_x_discrete(expand = c(0, 0), limits = c('1', '2', '3', '4', '5', '7'))


        heatMapDir <- file.path(output, 'graphs')
        dir.create(heatMapDir, recursive = TRUE)

        graphOutput <- file.path(heatMapDir, paste(x, '_', y, '_', profitColumn, '.png', sep = ""))
        print(sprintf("Saved %s", graphOutput))

        ggsave(file = graphOutput)
    }

    generateHourDayHeatMaps <- function(limit_bigger_data, output) {

        dataset <- setDF(limit_bigger_data[, lapply(.SD, sum), by = .(dayofweek, hourofday), .SDcols = c("totalprofit")])

        print(sprintf("hour dayofweek dataset %d", nrow(dataset)))

        generateHeatMapGraph(dataset, 'totalprofit', 'dayofweek', 'hourofday')

        dataset <- setDF(limit_bigger_data[, lapply(.SD, mean), by = .(dayofweek, hourofday), .SDcols = c("profitperrisk", "averagenetprofit")])

        generateHeatMapGraph(dataset, 'profitperrisk', 'dayofweek', 'hourofday')
        generateHeatMapGraph(dataset, 'averagenetprofit', 'dayofweek', 'hourofday')
    }
    parseDataForAllYears <- function() {
        data <- fread(input)

        minTradesPerYear <- 6
        tradersToRemove <- data[data$tradecount < minTradesPerYear,]$traderid
        data <- data[! data$traderid %in% tradersToRemove,]
        gc()
        return (data)
    }

    generateHeatMaps <- function(data, output) {

        generateHeatMapGraph <- function(dataset, profitColumn, x, y) {

            gg <- ggplot(dataset, aes_string(x = x, y = y, fill = profitColumn))
            gg <- gg + geom_tile(color = "white", size = 0.1)
            gg <- gg + scale_fill_gradientn(colours = hm.palette(100))
            #gg <- gg + coord_equal()
            gg <- gg + ggtitle(paste(profitColumn, "per", x, "and", y))
            gg <- gg + theme(plot.title = element_text(size = 10))
            gg <- gg + theme(axis.ticks = element_blank())
            gg <- gg + theme(axis.text = element_text(size = 7))
            gg <- gg + theme(axis.title.x = element_text(colour = "grey20", size = 10, angle = 0, hjust = .5, vjust = 0, face = "plain"))
            gg <- gg + theme(axis.title.y = element_text(colour = "grey20", size = 10, angle = 90, hjust = .5, vjust = .5, face = "plain"))
            gg <- gg + theme(legend.title = element_text(size = 6))
            gg <- gg + theme(legend.text = element_text(size = 6))
            gg <- gg + scale_y_discrete(expand = c(0, 0), limits = 0 : 23)
            gg <- gg + scale_x_discrete(expand = c(0, 0), limits = c(1 : 7))


            heatMapDir <- file.path(output, 'graphs')
            dir.create(heatMapDir, recursive = TRUE)

            graphOutput <- file.path(heatMapDir, paste(x, '_', y, '_', profitColumn, '.png', sep = ""))
            print(sprintf("Saved %s", graphOutput))

            ggsave(file = graphOutput)
        }

        generateHourDayHeatMaps <- function(limit_bigger_data, output) {

            dataset <- setDF(limit_bigger_data[, lapply(.SD, sum), by = .(dayofweek, hourofday), .SDcols = c("totalprofit")])

            print(sprintf("hour dayofweek dataset %d", nrow(dataset)))

            generateHeatMapGraph(dataset, 'totalprofit', 'dayofweek', 'hourofday')

            dataset <- setDF(limit_bigger_data[, lapply(.SD, mean), by = .(dayofweek, hourofday), .SDcols = c("profitperrisk", "averagenetprofit")])

            generateHeatMapGraph(dataset, 'profitperrisk', 'dayofweek', 'hourofday')
            generateHeatMapGraph(dataset, 'averagenetprofit', 'dayofweek', 'hourofday')
        }

        print("Generate the graphs")

        hm.palette <- colorRampPalette(rev(brewer.pal(11, 'Spectral')), space = 'Lab')

        print("Aggregate by dayofweek and hourofday")


        generateHourDayHeatMaps(data, output)

        print("Finished generating heatmaps")
    }

    data <- parseDataForAllYears()
    generateHeatMaps(data, output)

    print("Generate the graphs")

    hm.palette <- colorRampPalette(rev(brewer.pal(11, 'Spectral')), space = 'Lab')

    print("Aggregate by dayofweek and hourofday")


    generateHourDayHeatMaps(data, output)

    print("Finished generating heatmaps")
}

data <- parseDataForAllYears()
generateHeatMaps(data, output)
