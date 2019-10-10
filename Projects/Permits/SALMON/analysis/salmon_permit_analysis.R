# Script to recreate the 2017 Salmon Harvest estimates


#=====================================================================
# Read in and examine the data
#=====================================================================


library(tidyverse)

# Data Source: S:\RTS\common\Pat\Permits\Shrimp\2017\SHRIMP PERMITS 2017.XLS
# I saved individual copies of the two following sheets to my project folder

harvest <- read.csv("./data/harvest_records_17.csv", header = T, nrow = 32187)
permits <- read.csv("./data/permit_records_17.csv", header = T, nrow = 29584)



# change all variable names to lower (personal preference)
names(harvest) <- tolower(names(harvest))
names(permits) <- tolower(names(permits))



# calculate counts for each mailing type as well as each mailing-status combination
# and verify that they match the counts in the excel document

mail_cnts <- permits %>% group_by(mailing) %>% summarise(count = n())
status_cnts <- permits %>% group_by(mailing, status) %>% summarise(count = n())

#sum across all dates to get total fishing effort per permit and fishery

print(mail_cnts)
rbind(mail_cnts, c("total", sum(mail_cnts$count)))



### GET NUMBER OF NONCOMLIANTS THAT REPORTED FISHING ###======================================
# w_hat is estimated from mailing == 2 TOTALS
# NOT per fishery

# number of noncompliant (mailing == 2) households responding to the second reminder that reported fishing
ndf <- status_cnts %>% filter(mailing == 2, status == "HARVEST REPORTED") %>% ungroup() %>% select(count) %>% as.integer()


# NOTE: a grouped dataframe requires we ungroup it before selecting out one column
# We also switch the object from a dataframe to an integer for easier arithmetic


# total number of noncompliant households responding to the second reminder (mailing == 2)
nd <- status_cnts %>% filter(mailing == 2) %>% ungroup() %>% select(count) %>% sum() %>% as.integer()


# estimated proportion of non-respondents that fished
w_hat <- ndf/nd


# NOTE: a grouped dataframe requires we ungroup it before selecting out one column
# We also switch the object from a dataframe to an integer for easier arithmetic

#==============================================================================================





master_df <- left_join(harvest, permits, by = "permit")  %>% select(permit, red, king,coho, pink, chum, mailing, status, fishery)


# FIND AVG HARVEST FOR NONCOMPLIANTS THAT REPORTED FISHING ====================================

noncompl <- master_df %>% filter(mailing == 2)


noncompl_sum <- noncompl %>% group_by(permit, fishery) %>% summarise(red = sum(red), king = sum(king), coho = sum(coho), pink = sum(pink), chum = sum(chum))


noncompl_avg <- noncompl_sum %>% group_by(fishery) %>% summarise(red = mean(red), king = mean(king), coho = mean(coho), pink = mean(pink), chum = mean(chum))


#===============================================================================================



## TOTALS FOR COMPLIANT HOUSEHOLDS

sum_harvest <- master_df %>% filter(mailing == 0 | mailing == 1) %>% group_by(permit, fishery) %>% summarise(red = sum(red), king = sum(king), coho = sum(coho), pink = sum(pink), chum = sum(chum))


sum_harvest %>% group_by(fishery) %>% summarise(red = sum(red), king = sum(king), coho = sum(coho), pink = sum(pink), chum = sum(chum))









N <- sum(mail_cnts$count)

# counts of those that did and did not fish out of compliant households
Ncf <- status_cnts %>% filter((mailing == 0 | mailing == 1) & status == "HARVEST REPORTED") %>% ungroup() %>% select(count) %>% sum()

Ncz <- status_cnts %>% filter((mailing == 0 | mailing == 1) & status == "DID NOT FISH") %>% ungroup() %>% select(count) %>% sum()

Ndf <- (N - (Ncf + Ncz))*w_hat

Ndz <- N - Ncf - Ncz - Ndf


noncompl_avg

(Ndf)*noncompl_avg[3,3]

# need to get the avg harvest for mailing == 2 households per region
# multiply that by Ndf

# need to remove unknowns and it'll be closer to correct value