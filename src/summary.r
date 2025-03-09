library(R.utils)
options(warn = - 1)
print('Start summary.r')

args <- commandArgs(trailingOnly = TRUE)

options(width = 150)

input = args[1];
output = args[2]

data <- read.table(input, header = T, sep = ",")

summary <- function(data, input, output) {

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
    averageProfit <- mean(data$totalprofit)
    maxProfit <- max(data$totalprofit)
    minProfit <- min(data$totalprofit)
    maxYears <- max(data$winningYears)
    maxProfitPerRisk <- max(data$profitperrisk)
    maxAppt <- max(data$appt)
    maxAverageNetProfit <- max(data$averagenetprofit)
    maxWinningPercentage <- max(data$winningPercentage)

    fileConn <- file(file.path(output), "wt")
    writeLines(c(sprintf("Winners: %d\nLosers: %d\nAverage Profit: %#.2f\nMax Profit: %d\nMin Profit: %d\nMax Years: %d\nMaxProfitPerRisk: %#.2f\nMaxAppt: %#.4f\nMaxAverageNetProfit: %#.2f\nMaxWinningPercentage: %#.2f\n",
    winners, losers, averageProfit, maxProfit, minProfit, maxYears, maxProfitPerRisk, maxAppt, maxAverageNetProfit, maxWinningPercentage)),
    con = fileConn, sep = "\n")

    close(fileConn)
    print('Finished summary.r')
}

summary(data, input, output)


summary.txt
