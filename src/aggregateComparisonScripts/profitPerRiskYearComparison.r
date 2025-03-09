library(ggplot2)
library(reshape)
library(plyr)
library(ggthemes)
library(scales)
library(viridis)
library(RColorBrewer)

options(warn = - 1, width = 150)

rm(list = ls())

files <- list(
'results/aggregatedFilteredMonTueWed/byYear/data/EURUSD.csv',
'results/aggregatedFilteredTueWed/byYear/data/EURUSD.csv',
'results/aggregatedNormal/byYear/data/EURUSD.csv'
)

output <- 'results/aggregatedComparisons'

datalist <- lapply(files, read.csv)
data <- Reduce(function(x, y) {merge(x, y, by = "traderName")}, datalist)
data <- rename(data, c("profit_per_risk_ratio.x" = "profit_per_risk_ratioMonTueWed", "profit_per_risk_ratio.y" = "profit_per_risk_ratioTueWed", "profit_per_risk_ratio" = "profit_per_risk_ratioNormal"))

melted <- melt(data, id.vars = "traderName", measure.vars = c("profit_per_risk_ratioMonTueWed", "profit_per_risk_ratioTueWed", "profit_per_risk_ratioNormal"))

melted$traderName = factor(melted$traderName)

melted <- rename(melted, c("traderName" = "year", "variable" = "profitsPerRisk", "value" = "profit_per_risk_ratio"))

max <- round(max(melted$profit_per_risk_ratio), 2)
min <- round(min(melted$profit_per_risk_ratio), 2)
mean <- mean(melted$profit_per_risk_ratio)

gg <- ggplot(melted) + geom_bar(aes(x = year, y = profit_per_risk_ratio, fill = profitsPerRisk), stat = "identity", colour = "black", position = "dodge")
gg <- gg + geom_hline(yintercept = 0)
gg <- gg + geom_hline(yintercept = max, colour = "#990000", linetype = "dashed")
gg <- gg + geom_hline(yintercept = min, colour = "#990000", linetype = "dashed")
gg <- gg + ggtitle(paste('Profit Per Risk Comparison  max:', format(round(max, 2), nsmall = 2), 'min:', format(round(min, 2), nsmall = 2), 'mean:', format(round(mean, 2), nsmall = 2)))
gg <- gg + theme(axis.text.x = element_text(angle = 90, hjust = 1))
gg <- gg + scale_y_continuous(breaks = pretty_breaks(n = 10))
gg <- gg + theme(axis.text = element_text(size = 7))
filePath <- file.path(output, 'profit_per_risk_ratioComparison.png')
ggsave(file = filePath)
print(sprintf("Saved %s", filePath))


