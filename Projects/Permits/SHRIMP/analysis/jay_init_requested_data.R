setwd("~/Projects/Permits/SHRIMP")

library(tidyverse)


harvest <- read.csv("./data/2019/harvest_records_19.csv", stringsAsFactors = FALSE)


locs <- harvest %>% group_by(location, stat_area) %>% summarize(count = n())

write.csv(x = locs, file = "./data/2019/loc_area2019.csv")




hvrec <- harvest %>% select(hvrecid, pots, soaktime, shrimp, comments)

write.csv(x = hvrec, file = "./data/2019/hvrec2019.csv")

