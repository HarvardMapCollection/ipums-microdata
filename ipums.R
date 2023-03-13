#Install tidyverse for general awesomeness/functionality
library(tidyverse)

#Navigate to project working directory
setwd("~/Documents/R/ipums")

#Import IPUMS data; don't need to bother unzipping first (go R!)
IPUMS_data <- read_csv(file = "raw data/usa_00004.csv.gz")

#We only need to keep columns PLACENHG, SEX, and RACE so let's do that and overwrite because it's huge. 
IPUMS_data <- IPUMS_data %>% select(PLACENHG, SEX, RACE) #down to 3 variables.

#R is reading in these coded numbers as numbers, but they're not really. We need to convert to factors.
#Found some documentation about how to "efficiently" do this: https://stackoverflow.com/questions/33180058/coerce-multiple-columns-to-factors-at-once 

#What we're doing is creating new columns based on old columns. New columns will overwrite existing columns of the same name,
#which in our case means we're replacing our columns with transformed versions of themselves. We're transforming them with the
#function as.factor(). across() will take columns denoted with select() syntax and apply the function after the comma to all
#selected columns. This could also be done with lapply and a list of column names, but this is pretty elegant. 
IPUMS_data <- IPUMS_data %>% mutate(across(everything(), as.factor))
#Could have gone column by column
IPUMS_data$PLACENHG <- as.factor(IPUMS_data$PLACENHG)
#Equivalent to the piped version above
IPUMS_data <- mutate(IPUMS_data, across(everything(), as.factor))

#Next we're going to summarize the data and add a new column called population. 
IPUMS_summarized <- IPUMS_data %>% group_by(PLACENHG, SEX, RACE) %>% 
  summarise(POP=n())

#Next we're going to replace our factors using the codebook. Working code:
IPUMS_summarized$SEX <- recode(IPUMS_summarized$SEX, "1"="Male", "2"="Female")

#This worked! Assignment operator %<>%, see https://www.r-bloggers.com/2021/09/the-four-pipes-of-magrittr/ 
library(magrittr)
IPUMS_summarized$SEX %<>% recode("1"="Male", "2"="Female")

#Do this for Race once I get the codebook
IPUMS_summarized$RACE <- recode(IPUMS_summarized$RACE, "1"="White", "2"="Black/African American",
                                "3"="American Indian or Alaska Native", "4"="Chinese", "5"="Japanese", 
                                "6"="Other Asian or Pacific Islander")

#Now we need to use pivot_wider() to have a column per race
IPUMS_wider <- IPUMS_summarized %>% pivot_wider(names_from = RACE, values_from = POP)
#Will get total population by added together all of the races, then reordering columns to get original table
IPUMS_table <- IPUMS_wider %>% mutate(POPGENDER=sum(`White`,`Black/African American`,`American Indian or Alaska Native`, 
                                                      `Chinese`, `Japanese`, `Other Asian or Pacific Islander`, na.rm = TRUE))

#Showing how much info we lose by changing the format
IPUMS_test <- IPUMS_table %>% pivot_wider(names_from = SEX, values_from = POPGENDER)

#To get it up to the one-town-per-row level we have to summarize and temporarily remove gender to pivot_wider() seperately.
IPUMS_gender <- IPUMS_table %>% select(PLACENHG, SEX, POPGENDER) %>% 
  pivot_wider(names_from = SEX, values_from = POPGENDER)

#Could have done this using summarize to recode each column rather than recording elsewhere:
IPUMS_final <- IPUMS_table %>% group_by(PLACENHG) %>% 
  summarise(TOTALPOP=sum(POPGENDER), White=sum(White, na.rm=TRUE), `Black/African American`=sum(`Black/African American`, na.rm=TRUE),
            `American Indian or Alaska Native`=sum(`American Indian or Alaska Native`, na.rm=TRUE), Chinese=sum(Chinese, na.rm = TRUE),
            Japanese=sum(Japanese, na.rm = TRUE), `Other Asian or Pacific Islander`=sum(`Other Asian or Pacific Islander`, na.rm = TRUE)) %>% 
  ungroup() %>% bind_cols(select(IPUMS_gender, Male, Female)) %>% 
  mutate(TOTALPOP=Male+Female)
