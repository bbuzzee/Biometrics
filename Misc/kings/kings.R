
library(tidyverse)
library(gridExtra)


# ==== EASTSIDE VISUALIZATIONS ===== #
# https://knb.ecoinformatics.org/view/doi:10.5063/F18K77BT


kings <- read.csv("ASL_Eastside_Chinook.csv")


kings <- kings %>% separate(col = sampleDate, into = c("year", "month", "day"))
colnames(kings) <- tolower(colnames(kings))

kings <- kings[!is.na(kings$sex) & !is.na(kings$length),]


# everything is constant except the selected variables
kings_len <- kings %>% select(year, sex, fresh.water.age, salt.water.age, length) %>% group_by(year, sex) %>%
  summarize(med_len = median(length, na.rm = T),
            mean_salt_age = mean(salt.water.age, na.rm = T),
            mean_fresh_age = mean(fresh.water.age, na.rm = T),
            mean_age = mean(salt.water.age + fresh.water.age, na.rm = T),
            prop_fresh2 = sum(fresh.water.age==2, na.rm = T)/length(fresh.water.age)
  )






theme1 <- theme(axis.text.x = element_text(angle = 45, hjust = 1))

plot1 <- kings_len %>% ggplot(aes(x=year, y = med_len, group = sex, col = sex)) + geom_line() + labs(title= "Median Length", x = "Year", y = "Length") + theme1

plot2 <- kings_len %>% ggplot(aes(x=year, y = mean_age, group = sex, col = sex)) + geom_line() + labs(title= "Mean Total Age", x = "Year", y = "Age") + theme1

plot3 <- kings_len %>% ggplot(aes(x=year, y = mean_salt_age, group = sex, col = sex)) + geom_line() + labs(title= "Mean Saltwater Age", x = "Year", y = "Age") + theme1

plot4 <- kings_len %>% ggplot(aes(x=year, y = prop_fresh2, group = sex, col = sex)) + geom_line() + labs(title= "Proportion of Freshwater Age 2", x = "Year", y = "Proportion") + theme1


grid.arrange(plot1, plot2, plot3, plot4, ncol=2, nrow = 2)

# no sex variable


kings_len <- kings %>% select(year, sex, fresh.water.age, salt.water.age, length) %>% group_by(year) %>%
  summarize(med_len = median(length, na.rm = T),
            mean_salt_age = mean(salt.water.age, na.rm = T),
            mean_fresh_age = mean(fresh.water.age, na.rm = T),
            mean_age = mean(salt.water.age + fresh.water.age, na.rm = T),
            prop_fresh2 = sum(fresh.water.age==2, na.rm = T)/length(fresh.water.age)
  ) %>% ungroup()


plot1 <- kings_len %>% ggplot(aes(x=year, y = med_len, group = 1)) + geom_line() + labs(title= "Median Length", x = "Year", y = "Length") + theme1

plot2 <- kings_len %>% ggplot(aes(x=year, y = mean_age, group = 1)) + geom_line() + labs(title= "Mean Total Age", x = "Year", y = "Age") + theme1

plot3 <- kings_len %>% ggplot(aes(x=year, y = mean_salt_age, group = 1)) + geom_line() + labs(title= "Mean Saltwater Age", x = "Year", y = "Age") + theme1

plot4 <- kings_len %>% ggplot(aes(x=year, y = prop_fresh2, group = 1)) + geom_line() + labs(title= "Proportion of Freshwater Age 2", x = "Year", y = "Proportion") + theme1


grid.arrange(plot1, plot2, plot3, plot4, ncol=2, nrow = 2)