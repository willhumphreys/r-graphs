require(data.table)
library(ggplot2)
library(scales)
library(Matrix)

args <- commandArgs(trailingOnly = TRUE)

input <- args[1]
output <- args[2]

generateForSymbol <- function(input, symbol, outputDir) {

    data <- fread(input)
    data$dayofweek <- factor(data$dayofweek, levels = c(1, 2, 3, 4, 5, 6, 7))
    data$hourofday <- factor(data$hourofday)

    dayHours <- unique(data[, c('dayofweek', 'hourofday')])

    generateGraphs <- function(data, profitName, outputDir) {

        output <- file.path(outputDir, paste(symbol, '_', 'BestTrades', sep = ""), profitName)
        csvOut <- file.path(output, paste(symbol, '_bestTrades.csv', sep = ""))

        if (file.exists(csvOut)) {
            print(sprintf('Skipping %s %s. Already is processed', symbol, profitName))
        } else {
            print(sprintf("Processing %s", profitName))

            output <- file.path(outputDir, paste(symbol, '_', 'BestTrades', sep = ""), profitName)
            dir.create(output, recursive = TRUE)

            concatBest <- function(data, day, hour) {

                print(sprintf('Processing %s %s', day, hour))
                selectedDayData <- data[which(data$dayofweek == day & data$hourofday == hour),]
                #selectedDayData <- selectedDayData[which(winningyears > 9), ]
                selectedDayData <- selectedDayData[with(selectedDayData, order(-winningyears, -profitColumn)),]
                return(head(selectedDayData, n = 1))
            }

            bestTrades <- apply(dayHours, 1, function(x) concatBest(data, x[1], x[2]))
            bestTrades <- do.call(rbind, bestTrades)
            bestTrades <- bestTrades[with(bestTrades, order(dayofweek, - profitColumn)),]

            gg <- ggplot(bestTrades, aes(x = hourofday, y = profitColumn)) + geom_bar(stat = "identity", aes(fill = dayofweek), colour = "black")
            gg <- gg + ggtitle(paste('Best Trades Per Day and Hour ', profitName, ' Stacked\n', symbol))
            gg <- gg + scale_y_continuous(breaks = pretty_breaks(n = 20))
            gg <- gg + theme(plot.title = element_text(size = 10))
            gg <- gg + theme(axis.ticks = element_blank())
            gg <- gg + theme(axis.text = element_text(size = 7))
            gg <- gg + theme(axis.title.x = element_text(colour = "grey20", size = 10, angle = 0, hjust = .5, vjust = 0, face = "plain"))
            gg <- gg + theme(axis.title.y = element_text(colour = "grey20", size = 10, angle = 90, hjust = .5, vjust = .5, face = "plain"))
            gg <- gg + theme(legend.title = element_text(size = 6))
            gg <- gg + theme(legend.text = element_text(size = 6))
            gg <- gg + labs(x = "hour of day", y = profitName)
            filePath <- file.path(output, paste(symbol, '_', profitName, '_bestTrades_stacked.png', sep = ""))
            ggsave(file = filePath)
            print(sprintf("Saved %s", filePath))

            mean <- mean(bestTrades$profitColumn)
            sd1 <- sd(bestTrades$profitColumn)

            summ <- data.frame(x = c(mean, mean + sd1, mean - sd1),
            colour = c("mean", "sd1", "-sd1"))

            gg <- ggplot(bestTrades, aes(x = hourofday, y = profitColumn)) + geom_bar(stat = "identity", aes(fill = dayofweek), colour = "black")
            gg <- gg + ggtitle(paste('Best Trades Per Day and Hour ', profitName, ' Facet\n', symbol, sep = ""))
            gg <- gg + facet_grid(dayofweek ~ .)
            gg <- gg + geom_hline(data = summ, aes(yintercept = x, colour = colour))
            gg <- gg + scale_color_manual(name = "values", values = c(mean = "#008B00", sd1 = "#CD4F39", '-sd1' = "#CD4F39"))
            gg <- gg + scale_y_continuous(breaks = pretty_breaks(n = 5))
            gg <- gg + theme(plot.title = element_text(size = 10))
            gg <- gg + theme(axis.ticks = element_blank())
            gg <- gg + theme(axis.text = element_text(size = 7))
            gg <- gg + theme(axis.title.x = element_text(colour = "grey20", size = 10, angle = 0, hjust = .5, vjust = 0, face = "plain"))
            gg <- gg + theme(axis.title.y = element_text(colour = "grey20", size = 10, angle = 90, hjust = .5, vjust = .5, face = "plain"))
            gg <- gg + theme(legend.title = element_text(size = 6))
            gg <- gg + theme(legend.text = element_text(size = 6))
            gg <- gg + labs(x = 'hour of day', y = profitName)
            filePath <- file.path(output, paste(symbol, '_', profitName, '_bestTrades_facet.png', sep = ""))
            ggsave(file = filePath)
            print(sprintf("Saved %s", filePath))

            bestTrades$hourDay <- paste(bestTrades$dayofweek, bestTrades$hourofday, sep = '-')
            bestTrades <- bestTrades[with(bestTrades, order(- profitColumn)),]

            gg <- ggplot(bestTrades, aes(x = reorder(hourDay, - profitColumn), y = profitColumn)) + geom_bar(stat = "identity", aes(fill = dayofweek), colour = "black")
            gg <- gg + ggtitle(paste('Best Trades Per Day and Hour ', profitName, ' Ranked\n', symbol, sep = ""))
            gg <- gg + theme(axis.text.x = element_text(angle = 90, hjust = 1))
            gg <- gg + scale_y_continuous(breaks = pretty_breaks(n = 20))
            gg <- gg + theme(plot.title = element_text(size = 10))
            gg <- gg + theme(axis.ticks = element_blank())
            gg <- gg + theme(axis.text = element_text(size = 7))
            gg <- gg + theme(axis.title.x = element_text(colour = "grey20", size = 10, angle = 0, hjust = .5, vjust = 0, face = "plain"))
            gg <- gg + theme(axis.title.y = element_text(colour = "grey20", size = 10, angle = 90, hjust = .5, vjust = .5, face = "plain"))
            gg <- gg + theme(legend.title = element_text(size = 6))
            gg <- gg + theme(legend.text = element_text(size = 6))
            gg <- gg + labs(x = "day hour", y = profitName)
            filePath <- file.path(output, paste(symbol, '_', profitName, '_bestTrades_ranked.png', sep = ""))
            ggsave(file = filePath, width = 15, height = 15)
            print(sprintf("Saved %s", filePath))

            #bestTwoPerDay <- function(data, day) {
            #  return(head(bestTrades[ bestTrades$dayofweek == day, ], n = 24))
            #}
            #
            #topTwo <- do.call(rbind, lapply(unique(bestTrades$dayofweek), function(x) bestTwoPerDay(data, x)))
            write.csv(file = csvOut , x = bestTrades)
        }
    }

    data$profitColumn <- data$profitperrisk
    generateGraphs(data, "profitperrisk", outputDir)
    data$profitColumn <- data$totalprofit
    generateGraphs(data, "totalprofit", outputDir)
    data$profitColumn <- data$appt
    generateGraphs(data, "appt", outputDir)
    data$profitColumn <- data$averagenetprofit
    generateGraphs(data, "averagenetprofit", outputDir)
    # data$profitColumn <- data$winningPercentage
    # generateGraphs(data, "winningPercentage", outputDir)
}

outputDir <- file.path('allBestTrades')

# symbolDir <- file.path('/mongo2', 'results', 'Small')
#
# getInputFromSymbol <- function(symbol) {
#     actualSymbols <- strsplit(symbol, split = "-", fixed = TRUE)[[1]]
#     actualSymbol <- actualSymbols[length(actualSymbols)]
#     return(file.path(symbolDir, symbol, 'data', paste(actualSymbol, '.csv', sep = "")))
# }



#symbols <- list.files(symbolDir)

#symbols <- c(
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4!short=-1-EURUSD_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4!short=-1-AUDUSD_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4!short=-1-GBPUSD_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4!short=-1-EURGBP_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4!short=-1-EURCHF_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4!short=-1-USDCHF_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4!short=-1-EURUSD_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4!short=-1-USDCAD_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4!short=-1-EURJPY_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4!short=-1-USDJPY_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4!short=-1-NZDUSD_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4-EURUSD_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4-AUDUSD_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4-GBPUSD_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4-EURGBP_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4-EURCHF_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4-USDCHF_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4-EURUSD_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4-USDCAD_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4-EURJPY_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4-USDJPY_happy',
#'s:-300>-10>10,l:10>750>10,o:-80>-10>5,d:14>14>7,out:8>8>4-NZDUSD_happy'
#)

#lapply(symbols, function(x) generateForSymbol(getInputFromSymbol(x), x, outputDir))

symbol <- substring(strsplit(input, split="-")[[1]][2],0,6)
generateForSymbol(input, symbol, output)