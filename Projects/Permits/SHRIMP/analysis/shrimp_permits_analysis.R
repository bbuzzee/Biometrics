
# Script to recreate the 2017 Prince William Sound Harvest and Effort Estimates


#=====================================================================
# Read in and examine the data
#=====================================================================


library(tidyverse)

# Data Source: S:\RTS\common\Pat\Permits\Shrimp\2017\SHRIMP PERMITS 2017.XLS
# I saved individual copies of the two following sheets to my project folder

harvest <- read.csv("harvest_records_17.csv", header = T)
permits <- read.csv("permit_records_17.csv", header = T)


# change all variable names to lower (personal preference)
names(harvest) <- tolower(names(harvest))
names(permits) <- tolower(names(permits))



# NA's - there appears to be an error while reading in from the excel sheet - R reads in the whole sheet, even the rows with nothing in them

sum(is.na(harvest$shrimp))
which(is.na(harvest$shrimp))
harvest <- harvest[!is.na(harvest$shrimp), ]



# calculate counts for each mailing type as well as each mailing-status combination
# and verify that they match the counts in the excel document

mail_cnts <- permits %>% group_by(mailing) %>% summarise(count = n())
status_cnts <- permits %>% group_by(mailing, status) %>% summarise(count = n())


print(mail_cnts)
print(status_cnts)


# look at a boxplot of gallons of shrimp harvested to see if anyone reported shrimp counts instead of gallons

boxplot(harvest$shrimp, ylab = "Gallons of Shrimp")



#=====================================================================
# Pull out all the variables described in the data analysis section
# of the op plan
#=====================================================================


# number of noncompliant (mailing == 2) households responding to the second reminder that reported fishing

ndf <- status_cnts %>% filter(mailing == 2, status == "HARVEST REPORTED") %>% ungroup() %>% select(count) %>% as.integer()

# NOTE: a grouped dataframe requires we ungroup it before selecting out one column
# We also switch the object from a dataframe to an integer for easier arithmetic


# total number of noncompliant households responding to the second reminder (mailing == 2)
nd <- status_cnts %>% filter(mailing == 2) %>% ungroup() %>% select(count) %>% sum() %>% as.integer()


# estimated proportion of non-respondents that fished
w_hat <- ndf/nd


N <- sum(mail_cnts$count)

# counts of those that did and did not fish out of compliant households
Ncf <- status_cnts %>% filter((mailing == 0 | mailing == 1) & status == "HARVEST REPORTED") %>% ungroup() %>% select(count) %>% sum()

Ncz <- status_cnts %>% filter((mailing == 0 | mailing == 1) & status == "DID NOT FISH") %>% ungroup() %>% select(count) %>% sum()

Ndf <- (N - (Ncf + Ncz))*w_hat

Ndz <- N - Ncf - Ncz - Ndf


#=====================================================================
# Combine data and calculate values of interest using the above quantities
#=====================================================================

# calculate total of harvest and effort for each permit
permit_dat <- left_join(harvest, permits, by = "permit") %>% group_by(permit) %>%
  summarize(pot_days = sum(pot_days), shrimp = sum(shrimp), mailing = unique(mailing), status = unique(status))


# calculate harvest and effort for compliant households,
Hcf_gals <- permit_dat %>% filter(mailing == 0 | mailing == 1) %>% select(shrimp) %>% sum()
Hcf_days <- permit_dat %>% filter((mailing == 0 | mailing == 1) & !is.na(pot_days)) %>% select(pot_days) %>% sum()


# calculate mean harvest and effort from those that responded to the second request
hdf_gals<- permit_dat %>% filter(mailing == 2 & !is.na(shrimp)) %>% select(shrimp) %>% summarize(mean = mean(shrimp)) %>% as.numeric()
hdf_days <- permit_dat %>% filter(mailing == 2 & !is.na(pot_days)) %>% select(pot_days) %>% summarize(mean = mean(pot_days)) %>% as.numeric()


# Should the variance formulas in equations 12 and 13 in the op plan have hats on them?

Sdf_gals <- permit_dat %>% filter(mailing == 2 & !is.na(shrimp) & status == "HARVEST REPORTED") %>% select(shrimp) %>% summarize(sd = var(shrimp)) %>% as.numeric()
Sdf_days <-  permit_dat %>% filter(mailing == 2 & !is.na(pot_days)) %>% select(pot_days) %>% summarize(sd = var(pot_days)) %>% as.numeric()

# multiply the means of respondents of the second request by the number that failed to respond AND fished
# to get an estimate of the total harvest and effort by non-respondents
Hdf_gals <- Ndf*hdf_gals
Hdf_days <- Ndf*hdf_days


#=====================================================================
# Results
#=====================================================================

#

Hcf_gals + Hdf_gals
Hcf_days + Hdf_days



var_hdf <- (1-ndf/Ndf)*(Sdf_gals/ndf)
var_Ndf <- N^2*(w_hat*(1-w_hat)/(nd-1))


total_var <- Ndf^2*var_hdf + hdf_gals^2*var_Ndf - var_hdf*var_Ndf
sqrt(total_var)
