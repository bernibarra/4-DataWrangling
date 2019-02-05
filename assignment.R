# a4-data-wrangling

# Before you get started, set your working directory using the Session menu.
# While we (mostly) don't require specific variable names, we will be checking
# your code (structure + style) as well as your output. The .csv files you save
# must have the described format/column names, and the file name provided.
# For all .csv file, make sure to exclude rownames, and write them to the
# a folder called `output/` which you will create below.

################################### Set up ###################################

# Install (if not installed) + load dplyr package
library(dplyr)

# Read in `any_drinking.csv` data using a *relative path*
any_drinking <- read.csv("data/any_drinking.csv", stringsAsFactors = F)
# Read in `binge.drinking.csv` data using a *relative path*
binge_drinking <- read.csv("data/binge_drinking.csv", stringsAsFactors = F)

# Create a directory (using R) called "output" in your project directory
# Make sure to *suppress any warnings*, in case the directory already exists
# You must save all .csv files in this directory (last reminder!)
dir.create("output", showWarnings = F)
# ref: https://stackoverflow.com/questions/4216753/check-existence-of-directory-
# and-create-if-doesnt-exist

############################# Any drinking in 2012 #############################

# For this first section, you will work only with the *any drinking* dataset.
# In particular, we'll focus on data from 2012. All output should include only
# the relevant 2012 columns (as well as `state` + `location`), described below.


# Create a new data.frame that has the `state` and `location` columns,
# and all columns with data from 2012. you will use this dataframe throughout
# the rest of this section.
any_drinking_2012 <- any_drinking %>%
  select(state, location, both_sexes_2012, females_2012, males_2012)
# Using the (new) 2012 data, create a column `diff` that has
# the difference in male and female drinking rates
any_drinking_2012 <- any_drinking_2012 %>%
  mutate(diff = males_2012 - females_2012)

# Write your data to a file `diff_2012.csv` (in your `output/` directory)
# Make sure to exclude rownames (for all .csv files! -- last reminder).
write.csv(any_drinking_2012, "output/diff_2012.csv", row.names = F)

# To answer "Are there any locations where females drink more than males"?
# Create a new dataframe by filtering the 2012 dataframe to the rows that
# meet the criterion. Keep only the `state`, `location`, and column of interest.
# Write your answer to `more_f_than_m.csv`.
more_f_than_m <- any_drinking_2012 %>% 
  filter(females_2012 > males_2012) %>% 
  select(state,location, diff)

write.csv(more_f_than_m, "output/more_f_than_m.csv", row.names = F)

# To answer the question: "What is the location in which male and female
# drinking rates are most similar", create a new dataframe by filtering the 2012
# dataframe to the rows that meet the criterion. Keep only the `state`,
# `location`, and column of interest.Write your answer to `most_similar.csv`.
most_similar <- any_drinking_2012 %>% 
  filter(diff == min(diff)) %>% 
  select(state, location, diff)

write.csv(most_similar, "output/most_similar.csv", row.names = F)

# As you've (hopefully) noticed, the `location` column includes national,
# state, and county level estimates. However, many audiences may only be
# interested in the *state* level data. Given that, you should do the following:
# Create a new data frame that is only the *state level* observations in 2012.
# For the sake of this analysis, you should treat Washington D.C. as a *state*
# Write this data frame to `state_only.csv`.
state_only <- any_drinking_2012 %>% 
  select(state, both_sexes_2012, females_2012, males_2012, diff) %>% 
  filter(state != "National") %>% 
  group_by(state) %>% 
  summarise_all(sum)

write.csv(state_only, "output/state_only.csv", row.names = F)

# Which state had the **highest** drinking rate for both sexes combined?
# Your answer should be a *dataframe* of the state and value of interest
# Write this data frame to `highest_state.csv`.
highest_state <- state_only %>% 
  filter(both_sexes_2012 == max(both_sexes_2012)) %>% 
  select(state, both_sexes_2012)

write.csv(state_only, "output/highest_state.csv", row.names = F)

# Which state had the **lowest** drinking rate for both sexes combined?
# Your answer should be a *dataframe* of the state and value of interest
# Write this data frame to `lowest_state.csv`.
lowest_state <- state_only %>% 
  filter(both_sexes_2012 == min(both_sexes_2012)) %>% 
  select(state, both_sexes_2012)

write.csv(state_only, "output/lowest_state.csv", row.names = F)

# What was the difference in prevalence between the state with the highest level
# of consumption,and the state with the lowest level of consumption?
# Your answer should be a single value (a dataframe storing one value is fine)
# Store your answer in a variable called `biggest_state_diff`.
biggest_state_diff <- highest_state$both_sexes_2012 - lowest_state$both_sexes_2012


# Write a function called `get_state_data` that allows you to specify a state,
# then saves a .csv file (`STATE_data.csv`) with observations from that state
# This includes data about the state, as well as the counties in the state
# You should use the full any.drinking dataset in this function (not just 2012)
get_state_data <- function(state_spec){
  
  state_result <- any_drinking %>% 
    filter(state == state_spec)

  write.csv(state_result, "output/STATE_data.csv", row.names = F)
}

# Demonstrate that you function works by passing "Utah" to the function
get_state_data("Utah")

############################ Binge drinking Dataset ############################

# In this section, you will ask a variety of questions regarding the
# `binge_drinking.csv` dataset. More specifically, you will analyze a subset of
# the observations of *just the counties* (exclude state/national estimates!).
# You will store your answers in a *named list*, and at the end of the section,
# Convert that list to a data frame, and write the data frame to a .csv file.
# Pay close attention to the *names* to be used in the list.


# Create a dataframe with only the county level observations from the
# `binge_driking.csv` dataset. You should (again) think of Washington D.C. as
# a state, and therefore *exclude it here*.
# However, you should include "county-like" areas such as parishes and boroughs
county_binge_drinking <- binge_drinking %>% 
  filter(state != "National" & state != location)

# Create an empty list in which to store answers to the questions below.
binge_list <- list()

# What is the average county level of binge drinking in 2012 for both sexes?
# Store the number in your list as `avg_both_sexes`.
avg_both_sexes <- county_binge_drinking %>% 
  select(both_sexes_2012) %>% 
  summarise(mean_avg = mean(both_sexes_2012, na.rm = T))

binge_list <- list(avg_both_sexes = avg_both_sexes[[1]])

# What is the name of the county with the largest increase in male binge
# drinking between 2002 and 2012?
# Store the county name in your list as `largest_male_increase`.
male_increase_data <- binge_drinking %>% 
  select(location, males_2002, males_2012) %>%
  mutate(diff = males_2012 - males_2002)
  
largest_male_increase <- male_increase_data %>%
  filter(diff == max(diff)) %>% 
  select(location)

binge_list <- c(binge_list, largest_male_increase = largest_male_increase[[1]])

# How many counties experienced an increase in male binge drinking between
# 2002 and 2012?
# Store the number in your list as `num_male_increase`.
num_male_increase_df <- male_increase_data %>%
  filter(diff > 0) %>% 
  summarise(total_rows = length(location), na.rm = T) %>% 
  select(total_rows)

num_male_increase <- num_male_increase_df[["total_rows"]]

binge_list <- c(binge_list, num_male_increase = num_male_increase)

# What fraction of counties experienced an increase in male binge drinking
# between 2002 and 2012?
# Store the fraction (num/total) in your list as `frac_male_increase`.
tot_male_increase_df <- male_increase_data %>%
  summarise(tot_rows = length(location), na.rm = T) %>% 
  select(tot_rows)

tot_male_increase <- tot_male_increase_df[["tot_rows"]]

frac_male_increase <- num_male_increase / tot_male_increase

binge_list <- c(binge_list, frac_male_increase = frac_male_increase)
# How many counties experienced an increase in female binge drinking between
# 2002 and 2012?
# Store the number in your list as `num_female_increase`.
female_increase_data <- binge_drinking %>% 
  select(location, females_2002, females_2012) %>%
  mutate(diff = females_2012 - females_2002)

num_female_increase_df <- female_increase_data %>%
  filter(diff > 0) %>% 
  summarise(row_count = length(location), na.rm = T) %>% 
  select(row_count)

num_female_increase <- num_female_increase_df[["row_count"]]

binge_list <- c(binge_list, num_female_increase = num_female_increase)

# What fraction of counties experienced an increase in female binge drinking
# between 2002 and 2012?
# Store the fraction (num/total) in your list as `frac_female_increase`.
tot_female_increase_df <- female_increase_data %>%
  summarise(row_total = length(location), na.rm = T) %>% 
  select(row_total)

tot_female_increase <- tot_female_increase_df[["row_total"]]

frac_female_increase <- num_female_increase / tot_female_increase

binge_list <- c(binge_list, frac_female_increase = frac_female_increase)

# How many counties experienced a rise in female binge drinking *and*
# a decline in male binge drinking?
# Store the number in your list as `num_f_increase_m_decrease`.
f_m_change_data <- binge_drinking %>% 
  select(location,males_2002, males_2012, females_2002, females_2012) %>%
  mutate(diff_m = males_2012 - males_2002, diff_f = females_2012 - females_2002)

f_m_change_data_df <- f_m_change_data %>%
  filter(diff_m < 0 & diff_f > 0) %>% 
  summarise(row_count = length(location), na.rm = T) %>% 
  select(row_count)

num_f_increase_m_decrease <- f_m_change_data_df[["row_count"]]

binge_list <- c(binge_list, num_f_increase_m_decrease = num_f_increase_m_decrease)

# Convert your list to a data frame, and write the results
# to the file `binge_info.csv`

#View(binge_list)
#str(binge_list)
#View(binge_info)
#str(binge_info)

binge_info <- as.data.frame(binge_list)

write.csv(binge_info, "output/binge_info.csv", row.names = F)

# https://www.rdocumentation.org/packages/dimRed/versions/0.2.2/topics/as.data.frame

# The next questions return *data frames as results*:

# What is the *minimum* level of binge drinking in each state in 2012 for
# both sexes (across the counties)? Your answer should contain roughly 50 values
# (one for each state), unless there are two counties in a state with the
# same value. Your answer should be a *dataframe* with the location, state, and
# 2012 binge drinking rate. Write this to a file called `min_binge.csv`.

both_binge <- binge_drinking %>% 
  select(state, location, both_sexes_2012) %>% 
  filter(state != "National" & state != location) 

min_binge <- both_binge %>% 
  group_by(state) %>% 
  summarise_all(min)

write.csv(min_binge, "output/min_binge.csv", row.names = F)

# What is the *maximum* level of binge drinking in each state in 2012 for
# both sexes (across the counties)? Your answer should contain roughly 50 values
# (one for each state), unless there are two counties in a state with the
# same value. Your answer should be a *dataframe* with the location, state, and
# 2012 binge drinking rate. Write this to a file called `max_binge.csv`.
max_binge <- both_binge %>% 
  group_by(state) %>% 
  summarise_all(max)

write.csv(max_binge, "output/max_binge.csv", row.names = F)

################################# Joining Data #################################
# You'll often have to join different datasets together in order to ask more
# involved questions of your dataset. In order to join our datasets together,
# you'll have to rename their columns to differentiate them.


# First, rename all prevalence columns in the any_drinking dataset to the
# have prefix "any_" (i.e., `males_2002` should now be `any_males_2002`)
# Hint: you can get (and set!) column names using the colnames function.
# This may take multiple lines of code.

any_drinking_df <- any_drinking
names(any_drinking_df) <- paste("any_", colnames(any_drinking), sep = "")

# https://stackoverflow.com/questions/45535157/difference-between-dplyrrename-and-dplyrrename-all
# https://stackoverflow.com/questions/34092237/applying-dplyrs-rename-to-all-columns-while-using-pipe-operator

# Then, rename all prevalence columns in the binge_drinking dataset to the have
# the prefix "binge_" (i.e., `males_2002` should now be `binge_males_2002`)
# This may take multiple lines of code.

binge_drinking_df <- binge_drinking
names(binge_drinking_df) <- paste("binge_", colnames(binge_drinking), sep = "")

# Then, create a dataframe by joining together the both datasets.
# Think carefully about the *type* of join you want to do, and what the
# *identifying columns* are. You will use this (joined) data to answer the
# questions below.
any_binge_full_df <- full_join(any_drinking_df, binge_drinking_df[-1], by = c("any_location" = "binge_location"))

# Create a column `diff_2012` storing the difference between `any` and `binge`
# drinking for both sexes in 2012
any_binge_full_df <- mutate(any_binge_full_df, diff_2012 = any_both_sexes_2012 - binge_both_sexes_2012)

# Which location has the greatest *absolute* difference between `any` and
# `binge` drinking? Your answer should be a one row data frame with the state,
# location, and column of interest (diff_2012).
# Write this dataframe to `biggest_abs_diff_2012.csv`.
any_binge_full_clean <- any_binge_full_df %>% 
  select(any_state, any_location, diff_2012) %>% 
  filter(any_state != "National" & any_state != any_location)

biggest_abs_diff_2012 <- any_binge_full_clean %>% 
  filter(diff_2012 == max(abs(diff_2012))) 

write.csv(biggest_abs_diff_2012, "output/biggest_abs_diff_2012.csv", row.names = F)

# Which location has the smallest *absolute* difference between `any` and
# `binge` drinking? Your answer should be a one row data frame with the state,
# location, and column of interest (diff_2012).
# Write this dataframe to `smallest_abs_diff_2012.csv`.
smallest_abs_diff_2012 <- any_binge_full_clean %>% 
  filter(diff_2012 == min(abs(diff_2012)))

write.csv(smallest_abs_diff_2012, "output/smallest_abs_diff_2012.csv", row.names = F)

############## Write a function to ask your own question(s) ####################
# Even in an entry level data analyst role, people are expected to come up with
# their own questions of interest (not just answer the questions that other
# people have). For this section, you should *write a function* that allows you
# to ask the same question on different subsets of data. For example, you may
# want to ask about the highest/lowest drinking level given a state or year.
# The purpose of your function should be evident given the input parameters and
# function name. After writing your function, *demonstrate* that the function
# works by passing in different parameters to your function.

most_regional_drinkers <- function(region, year){
  mrd_results <- any_drinking %>% 
  select(state, paste0("both_sexes_", year), paste0("females_", year), paste0("males_", year)) %>%
  filter(state %in% region) %>%
  group_by(state) %>% 
  summarise_all(max)
}

PNW <- c("Washington", "Oregon", "Idaho", "Montana", "Wyoming")
PNW_max_state_drinkers <- most_regional_drinkers(PNW, 2012)

Pacific_West <- c("Alaska", "California", "Hawaii", "Oregon", "Washington")
PW_max_state_drinkers <- most_regional_drinkers(PNW, 2012)

################################### Challenge ##################################

# Using your function from part 1 that wrote a .csv file given a state name,
# write a separate file for each of the 51 states (including Washington D.C.)
# The challenge is to do this in a *single line of (very concise) code*

# get_state_data("Utah")

f_test <- function(para){
  print(para)
}
varone <- c("a", "b", "c")
f_test(varone[1:3])

# Write a function that allows you to pass in a *dataframe* (i.e., in the format
# of binge_drinking or any_drinking) *year*, and *state* of interest. The
# function should saves a .csv file with observations from that state's counties
# (and the state itself). It should only write the columns `state`, `location`,
# and data from the specified year. Before writing the .csv file, you should
# *sort* the data.frame in descending order by the both_sexes drinking rate in
# the specified year. The file name should have the format:
# `DRINKING_STATE_YEAR.csv` (i.e. `any_Utah_2005.csv`).
# To write this function, you will either have to use a combination of dplyr
# and base R, or confront how dplyr uses *non-standard evaluation*
# Hint: https://github.com/tidyverse/dplyr/blob/34423af89703b0772d59edcd0f3485295b629ab0/vignettes/nse.Rmd
# Hint: https://www.r-bloggers.com/non-standard-evaluation-and-standard-evaluation-in-dplyr/


# Create the file `binge_Colorado_2007.csv` using your function.
binge_Colorado_2007 <- "empty"
write.csv(binge_Colorado_2007, "output/binge_Colorado_2007.csv", row.names = F)

