
library(tidyverse)
library(recapr)
setwd("~/Projects/Threemile/Chuit/Rscripts")


# ===================================== #
# ============ DATA PREP ============== #
# ===================================== #

# SKIP IF READING mr_df.csv in directly #

mark_angling <- read.csv("../data/angling mark chuit.csv", stringsAsFactors = FALSE, nrows = 27)
mark_gillnet <- read.csv("../data/gillnet mark chuit.csv", stringsAsFactors = FALSE)




 ### MARK EVENT ###

# I'm using the select function to rename the variables
mark_angling <- mark_angling %>% filter(Species == "NP" & !is.na(`Tag..`)) %>% select(section_mark = Section,
                                                                                      length_mark = Fork.length,
                                                                                      tag_no = `Tag..`)
# add an indicator to keep track of marks  vs recaptures after joining the dataframe
mark_angling <- mark_angling %>% mutate(mark = 1)


# Morts were not tagged so they can be added to the pop estimate afterwards
mark_gillnet <- mark_gillnet %>% filter(Species == "NP" & Tag.Number != "" & Tag.Number != "LOST")  %>% select(section_mark = Section,
                                                                                           length_mark = Fork.length.MM,
                                                                                           tag_no = Tag.Number)

mark_gillnet <- mark_gillnet %>% mutate(mark = 1, tag_no = as.integer(tag_no)) 


### RECAP EVENT ###

recap <- read.csv("../data/chuit recap.csv", stringsAsFactors = FALSE) %>% filter(Species == "NP")

recap <- recap %>% filter(Species == "NP" & !is.na(Tag..))  %>% select(tag_no = Tag.., section_recap = Section.., length_recap = Length)
recap <- recap %>% mutate(recap = 1)

recap$tag_no <- as.integer(recap$tag_no)


# join to create one dataframe
mr_df <- full_join(mark_angling, mark_gillnet)
mr_df <- full_join(mr_df, recap, by = c("tag_no"))

# create inidcator for whether a pike was caught during both events
mr_df <- mr_df %>% mutate(both_events = ifelse(mark == 1 & recap == 1, yes = 1, no = 0))

write.csv(mr_df, "../data/mr_df_clean.csv")

# ===================================== #
# ============ DATA ANALYSIS ========== #
# ===================================== #

mr_df <- read.csv("../data/mr_df_clean.csv")

mr_df <- mr_df %>% filter(length_mark >= 300 | is.na(length_mark), length_recap >= 310 | is.na(length_recap), !(is.na(length_mark) & is.na(length_recap)))

M <- sum(mr_df$mark, na.rm = T)
R <- sum(mr_df$both_events, na.rm = T)
C <- sum(mr_df$recap, na.rm = T)

est <- M*C/R

var <- ((M+1)*(C+1)*(M-R)*(C-R)/((R+1)^2*(R + 2)))

ci <- c(est - 2*sqrt(var), est + 2*sqrt(var))
ci



# GEOGRAPHICAL SELECTIVITY

sect5 <- c(1,NA)
section5 <- mr_df %>% filter(section_mark %in% sect5 & section_recap %in% sect5)


M5 <- sum(section5$mark, na.rm = T)
C5 <- sum(section5$recap, na.rm = T)
R5 <- sum(section5$both_events, na.rm = T)

N5 <- M5*C5/R5
var5 <- (C5 + 1)*(M5+1)*(C5-R5)*(M5-R5)/((R5+1)^2*(R5+2))



sect6 <- c(2,NA)
section6 <- mr_df %>% filter(section_mark %in% sect6 & section_recap %in% sect6)

M6 <- sum(section6$mark, na.rm = T)
C6 <- sum(section6$recap, na.rm = T)
R6 <- sum(section6$both_events, na.rm = T)

N6 <- M6*C6/R6

N5 + N6

# So the straitified estimate is 207, which is almost exactly equal to the unstratified estimate (210)
# so the bias introduced by geopgraphical selectivity is negligible




# SIZE SELECTIVITY


mark_len <- mr_df %>% filter(mark == 1, !is.na(length_mark)) %>% pull(length_mark)
recap_len <- mr_df %>% filter(both_events == 1, !is.na(length_recap)) %>% pull(length_recap)
cap_len <- mr_df %>% filter(recap == 1, !is.na(length_recap)) %>% pull(length_recap)




ks.test(mark_len, recap_len)
ks.test(cap_len, recap_len)


plot(ecdf(cap_len), col = "blue")
lines(ecdf(recap_len))
lines(ecdf(mark_len))

# since marked and recaptured tagged fish are roughly the same size, we can conclude all lengths had the same probability
# of capture during the SECOND event. No correction needed.

