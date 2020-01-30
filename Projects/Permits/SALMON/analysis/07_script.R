library(tidyverse)


create_07 <- function(master_df){
  
  region_fishery <- master_df %>% group_by(region_number, fishery) %>% summarize(days = sum(effort_days), salmon = sum(red + king + coho + pink + chum))
  region_2 <- master_df %>% filter(region_code %in% c("L", "P", "K")) %>% group_by(area_name, fishery) %>% summarize(days = sum(effort_days), salmon = sum(red + king + coho + pink + chum))
  
  return(list(knitr::kable(region_fishery), knitr::kable(region_2)))
}



master_df_18 <- read.csv("master_df_18.csv")
tab7_18 <- create_07(master_df_18)


master_df_17 <- read.csv("master_df_17.csv")
tab7_17 <- create_07(master_df_18)

master_df_16 <- read.csv("master_df_16.csv")
tab7_16 <- create_07(master_df_18)