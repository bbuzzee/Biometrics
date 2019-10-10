setwd("~/Projects/Rob Massengill")
library(tidyverse)

ranks <- read.csv("Ranking table.csv")

# ranks$Minimum.Netting.Effort.When.Native.Fish.Are.Not.A.Concern <- ceiling(-log(.05)/(20*.02*(15/ranks$Surface.acres))/24)
# 
# ranks$Minimum.Netting.Effort.When.Native.Fish.Are.A.Concern <- ceiling(-log(.5)/(20*.02*(15/ranks$Surface.acres))/24)

ranks <- ranks %>% mutate(net_hours_4_fish_80_prob = round(-log(.2)/(4*.02*(1/ranks$Surface.acres)), 1))
ranks <- ranks %>% mutate(net_hours_4_fish_80_pro2 = round((-log(.2)*ranks$Surface.acres)/(4*.02), 1))
ranks <- ranks %>% mutate(net_hours_4_fish_50_prob = round(-log(.5)/(4*.02*(1/ranks$Surface.acres)), 1))
ranks <- ranks %>% mutate(net_hours_20_fish_80_prob = round(-log(.2)/(20*.02*(1/ranks$Surface.acres)), 1))
ranks <- ranks %>% mutate(net_hours_20_fish_50_prob = round(-log(.5)/(20*.02*(1/ranks$Surface.acres)), 1))



# exp(-.02*24*.5)^4
# set above equal to probability and solve for place of 24 hours

write.csv(ranks, "Ranking Table BB.csv")

DaystoNet <- function(p, K, D){
  
  # p = exp(-K*D*H)
  
  # D = density, set to 1net/2acre for convenience
  # K = median of posterior, = .02
  # H = hours, to be solved for and diveded by 24 to get the number of days of netting needed'
  # p = probability of failing to detect, from op plan
  
  hrs_at_D <- -log(p)/(4*K*D)
  
  return(days = ceiling(hrs_at_D/24))
  
  
}

DaystoNet(p = .05, K = .02, D = 15/ac)




# Question: not feasible to fix density at 1/2 for 400 acre lakes. Instead fix number of nets? Ask Krissy and Rob about typical crew size.