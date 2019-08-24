#=====================================================================
# Read in and examine the data
#=====================================================================


library(tidyverse)

# Data Source: S:\RTS\common\Pat\Permits\tanner\2017\tanner PERMITS 2017.XLS
# I saved individual copies of the two following sheets to my project folder

harvest <- read.csv("harvest_records_17.csv", header = T, nrow = 3201)
permits <- read.csv("permit_records_17.csv", header = T, nrow = 1930)


# change all variable names to lower (personal preference)
names(harvest) <- tolower(names(harvest))
names(permits) <- tolower(names(permits))


sum(is.na(harvest$tanner))


# calculate counts for each mailing type as well as each mailing-status combination
# and verify that they match the counts in the excel document

mail_cnts <- permits %>% group_by(mailing) %>% summarise(count = n())
status_cnts <- permits %>% group_by(mailing, status) %>% summarise(count = n())


# Number of Permits
print(mail_cnts)
print(status_cnts)



# Number of REPORTED crabs

harvest %>% group_by(location, use) %>% summarize(count = n())

# look at a boxplot of gallons of shrimp harvested to see if anyone reported shrimp counts instead of gallons

boxplot(harvest$tanner, ylab = "Gallons of Shrimp")


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
  summarize(tanner = sum(tanner), mailing = unique(mailing), status = unique(status))


# calculate harvest and effort for compliant households,
Hcf_gals <- permit_dat %>% filter(mailing == 0 | mailing == 1) %>% select(tanner) %>% sum()



# calculate mean harvest and effort from those that responded to the second request
hdf_gals<- permit_dat %>% filter(mailing == 2) %>% select(tanner) %>% summarize(mean = mean(tanner)) %>% as.numeric()



# Should the variance formulas in equations 12 and 13 in the op plan have hats on them?

Sdf_gals <- permit_dat %>% filter(mailing == 2, status == "HARVEST REPORTED") %>% select(tanner) %>% summarize(sd = var(tanner)) %>% as.numeric()


# multiply the means of respondents of the second request by the number that failed to respond
# to get an estimate of the total harvest and effort by non-respondents
Hdf_gals <- Ndf*hdf_gals



#=====================================================================
# Results
#=====================================================================

#

Hcf_gals + Hdf_gals




var_hdf <- (1-ndf/Ndf)*(Sdf_gals/ndf)
var_Ndf <- N^2*(w_hat*(1-w_hat)/(nd-1))


total_var <- Ndf^2*var_hdf + hdf_gals^2*var_Ndf - var_hdf*var_Ndf
sqrt(total_var)

