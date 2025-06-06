library(ggplot2)
library(reshape)
library(plyr)
library(ggthemes)
library(scales)
library(viridis)
library(RColorBrewer)
require(data.table)

options(warn = - 1, width = 150)

rm(list = ls())

output <- 'results/aggregatedComparisons'
dir.create(output)

files <- list(
'results/aggregatedFilteredMonTueWed/byYear/data/EURUSD.csv',
'results/aggregatedFilteredTueWed/byYear/data/EURUSD.csv',
'results/aggregatedNormal/byYear/data/EURUSD.csv'
)

datalist <- lapply(files, read.csv)
data <- Reduce(function(x, y) {merge(x, y, by = "traderName")}, datalist)

data <- rename(data, c("totalprofit.x" = "totalprofitMonTueWed", "totalprofit.y" = "totalprofitTueWed", "totalprofit" = "totalprofitNormal"))
melted <- melt(data, id.vars = "traderName", measure.vars = c("totalprofitMonTueWed", "totalprofitTueWed", "totalprofitNormal"))
melted$traderName = factor(melted$traderName)
melted <- rename(melted, c("traderName" = "year", "variable" = "totalprofits", "value" = "totalprofit"))

max <- round(max(melted$totalprofit), 2)
min <- round(min(melted$totalprofit), 2)
mean <- mean(melted$totalprofit)

gg <- ggplot(melted) + geom_bar(aes(x = year, y = totalprofit, fill = totalprofits), stat = "identity", colour = "black", position = "dodge")
gg <- gg + geom_hline(yintercept = 0)
gg <- gg + geom_hline(yintercept = max, colour = "#990000", linetype = "dashed")
gg <- gg + geom_hline(yintercept = min, colour = "#990000", linetype = "dashed")
gg <- gg + ggtitle(paste('Profit Per Risk Comparison  \nmax:', format(round(max, 2), nsmall = 2), 'min:', format(round(min, 2), nsmall = 2), 'mean:', format(round(mean, 2), nsmall = 2)))
gg <- gg + theme(axis.text.x = element_text(angle = 90, hjust = 1))
gg <- gg + scale_y_continuous(breaks = pretty_breaks(n = 10))
gg <- gg + theme(axis.text = element_text(size = 7))
filePath <- file.path(output, 'totalprofitComparison.png')
ggsave(file = filePath)
print(sprintf("Saved %s", filePath))


