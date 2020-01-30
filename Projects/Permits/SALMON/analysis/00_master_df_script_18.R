# Script to recreate the 2017 Salmon Harvest estimates


#=====================================================================
# Read in and examine the data
#=====================================================================


library(tidyverse)



# Data Source: S:\RTS\common\Pat\Permits\Shrimp\2017\SHRIMP PERMITS 2017.XLS
# I saved individual copies of the two following sheets to my project folder
harvest <- read.csv("../data/harvest_records_18.csv", header = T, nrow = 26989, stringsAsFactors = FALSE, skip = 1)
permits <- read.csv("../data/permit_records_18.csv", header = T, nrow = 23734)
regions_key <- read.csv("../data/city_region_key.csv")


# change all variable names to lower (personal preference)
names(harvest) <- tolower(names(harvest))
names(permits) <- tolower(names(permits))



#==== KASILOF DIPNET OR GILLNET ====#
# make own function - do one thing well

# convert harvdate to date format
harvest$harvdate <- as.Date(harvest$harvdate, format = "%m/%d/%Y")
harvest <- harvest %>% filter(!is.na(harvdate))

is_gillnet_date <- (harvest$harvdate >= as.Date("6/15/2018", format = "%m/%d/%Y")) & (harvest$harvdate <= as.Date("6/24/2018", format = "%m/%d/%Y"))

# convert everything to dipnet, then switch to gillnet by date
harvest$fishery[harvest$fishery == "KASILOF"] <- "KASILOF DIPNET"
harvest$fishery[harvest$fishery == "KASILOF DIPNET" & is_gillnet_date] <- "KASILOF GILLNET"

# each row is one day of effort
harvest$effort_days <- 1



#==== joins ====#


master_df <- left_join(harvest, permits, by = c("permit"))
master_df <- left_join(master_df, regions_key, by = c("city"))

# permit-harvdate is the key, other variables are values
# this dataframe is strictly the reported values
master_df_clean <- master_df %>% select(1:9,
                                        effort_days,
                                        city,
                                        familysi,
                                        allowed,
                                        mailing,
                                        status,
                                        region_number,
                                        region_code,
                                        area_name,
                                        response_method)
master_df_clean$year <- 2018

write.csv(master_df_clean, "master_df_18.csv", row.names = FALSE)


# 2017

# Data Source: S:\RTS\common\Pat\Permits\Shrimp\2017\SHRIMP PERMITS 2017.XLS
# I saved individual copies of the two following sheets to my project folder
harvest <- read.csv("../data/harvest_records_17.csv", header = T, nrow = 32187, stringsAsFactors = FALSE)
permits <- read.csv("../data/permit_records_17.csv", header = T, nrow = 29594)
regions_key <- read.csv("../data/city_region_key.csv")


# change all variable names to lower (personal preference)
names(harvest) <- tolower(names(harvest))
names(permits) <- tolower(names(permits))



#==== KASILOF DIPNET OR GILLNET ====#
# make own function - do one thing well

# convert harvdate to date format
harvest$harvdate <- as.Date(harvest$harvdate, format = "%m/%d/%Y")
harvest <- harvest %>% filter(!is.na(harvdate))

is_gillnet_date <- (harvest$harvdate >= as.Date("6/15/2017", format = "%m/%d/%Y")) & (harvest$harvdate <= as.Date("6/24/2017", format = "%m/%d/%Y"))

# convert everything to dipnet, then switch to gillnet by date
harvest$fishery[harvest$fishery == "KASILOF"] <- "KASILOF DIPNET"
harvest$fishery[harvest$fishery == "KASILOF DIPNET" & is_gillnet_date] <- "KASILOF GILLNET"

# each row is one day of effort
harvest$effort_days <- 1



#==== joins ====#


master_df <- left_join(harvest, permits, by = c("permit"))
master_df <- left_join(master_df, regions_key, by = c("city"))

# permit-harvdate is the key, other variables are values
# this dataframe is strictly the reported values
master_df_clean <- master_df %>% select(1:9,
                                        effort_days,
                                        city,
                                        familysi,
                                        allowed,
                                        mailing,
                                        status,
                                        region_number,
                                        region_code,
                                        area_name,
                                        response_method)
master_df_clean$year <- 2017

write.csv(master_df_clean, "master_df_17.csv", row.names = FALSE)



# 2016


# Data Source: S:\RTS\common\Pat\Permits\Shrimp\2017\SHRIMP PERMITS 2017.XLS
# I saved individual copies of the two following sheets to my project folder
harvest <- read.csv("../data/harvest_records_16.csv", header = T, nrow = 34084, stringsAsFactors = FALSE)
permits <- read.csv("../data/permit_records_16.csv", header = T, nrow = 30490)
regions_key <- read.csv("../data/city_region_key.csv")


# change all variable names to lower (personal preference)
names(harvest) <- tolower(names(harvest))
names(permits) <- tolower(names(permits))



#==== KASILOF DIPNET OR GILLNET ====#
# make own function - do one thing well

# convert harvdate to date format
harvest$harvdate <- as.Date(harvest$harvdate, format = "%m/%d/%Y")
harvest <- harvest %>% filter(!is.na(harvdate))

is_gillnet_date <- (harvest$harvdate >= as.Date("6/15/2016", format = "%m/%d/%Y")) & (harvest$harvdate <= as.Date("6/24/2016", format = "%m/%d/%Y"))

# convert everything to dipnet, then switch to gillnet by date
harvest$fishery[harvest$fishery == "KASILOF"] <- "KASILOF DIPNET"
harvest$fishery[harvest$fishery == "KASILOF DIPNET" & is_gillnet_date] <- "KASILOF GILLNET"

# each row is one day of effort
harvest$effort_days <- 1



#==== joins ====#


master_df <- left_join(harvest, permits, by = c("permit"))
master_df <- left_join(master_df, regions_key, by = c("city"))

# permit-harvdate is the key, other variables are values
# this dataframe is strictly the reported values
master_df_clean <- master_df %>% select(1:9,
                                        effort_days,
                                        city,
                                        familysi,
                                        allowed,
                                        mailing,
                                        status,
                                        region_number,
                                        region_code,
                                        area_name,
                                        response_method)
master_df_clean$year <- 2016

write.csv(master_df_clean, "master_df_16.csv", row.names = FALSE)
                                        
