library(tidyverse)
library(forecast)



CaseCounts <- c(676,740
                ,897,509,
                379,651,
                1212,927,
                739,667,
                617, 1317,
                1419, 1305,
                1270,1180,
                966, 1096, 
                1371, 1698,
                1902,2625,
                1972, 1756,
                1774,1783,
                2610, 3207)


#=================


inds <- seq(as.Date("2020-05-23"), as.Date("2020-06-18"), by = "day")

myts <- ts(CaseCounts,
                   start = c(2020, as.numeric(format(inds[1], "%j"))),
                   frequency = 365)
plot(myts)


myts %>% ets(model = "MMZ") %>% forecast(h=14) %>% autoplot()




CaseCounts <- c(676,740
                ,897,509,
                379,651,
                1212,927,
                739,667,
                617, 1317,
                1419, 1305,
                1270,1180,
                966, 1096, 
                1371, 1698,
                1902,2625,
                1972, 1756,
                1774,1783,
                2610, 3207,
                3822)



inds <- seq(as.Date("2020-05-23"), as.Date("2020-06-19"), by = "day")

myts <- ts(CaseCounts,
           start = c(2020, as.numeric(format(inds[1], "%j"))),
           frequency = 365)
plot(myts)


myts %>% ets(model = "ZMZ") %>% forecast(h=14) %>% autoplot() + ggtitle("Florida Case Count Forecast")

