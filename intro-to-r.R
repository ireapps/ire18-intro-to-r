# Intro to R (pre-registered class)
# IRE 2018
# Saturday, June 16, 9 a.m.

# Hannah Fresques, ProPublica (hannah.fresques@propublica.org)
# Charles Minshew, IRE-NICAR (charles@ire.org)
# Olga Pierce, ProPublica (olga.pierce@propublica.org)



# hour 1: intro and loading data ------------------------------------------



# Set up your environment -------------------------------------------------

# set working directory
setwd("C:/Users/user/Desktop/hands_on_classes/intro_to_r_1437")

# when you use a package on a computer for the first time, you need to install it
# install.packages("tidyverse")
# install.packages("lubridate")
# install.packages("stringr")
# install.packages("readxl")

# load packages
# you can either load the whole tidyverse:
library(tidyverse)
# or choose individual packages to load:
library(stringr) # included in tidyverse
library(readr) # included in tidyverse
library(tidyr) # included in tidyverse
library(lubridate)
library(readxl) 


# Load data: csv ----------------------------------------------------------

# http://blog.rstudio.com/2015/04/09/readr-0-1-0/

# We'll use read_csv() from readr
# there are other functions to read in CSVs, but this one is particularly nice.

orange_voters <- read_csv("data/Orange_voters.csv")

orange_history <- read_csv("data/Orange_history.csv")



# Load data: delimited ----------------------------------------------------


# we can specify column names and column types
# we can also choose to load only some of the columns by using cols_only

# HF: this section still needs work.

names <- c()

orange_voters_extra <- read_delim(
  "data/Orange_voters.csv", 
  delim = ',' , 
  col_names = names, 
  col_types = cols_only(
    ID             = col_integer(),
    `Case Number`  = col_character(),
    Date           = col_character(),
    Block          = col_character(),
    IUCR           = col_character(),
    `Primary Type` = col_character(),
    Description    = col_character()
    )
  )

rm(orange_voters_extra)



# Load data: from the internet --------------------------------------------

# install.packages("downloader")
library(downloader)

# get the file from the internet and save it on your computer
# Go to the landing page first: http://geodata.myfwc.com/datasets/black-bear-related-calls-in-florida
myURL <- "https://opendata.arcgis.com/datasets/a27014d0f6e84e3082da209995a1285f_2.csv"
download(myURL,"data/florida_bear_reports_raw.csv")

# now read in the csv using read_csv
bear_reports <- read_csv("data/florida_bear_reports_raw.csv")



# Load data: excel --------------------------------------------------------

# Now we want to load a tab from an excel spreadsheet
# But we don't remember how
# We can pull up the documentation for a function using a '?' before the name

?read_excel

# The help pane shows us what arguments are needed for the function
# We want just the tab from the our excel file

theme_parks <- read_excel("data/theme_park_incidents.xlsx", sheet = "fullData")

theme_parks %>% head() %>% View()

# We're done with theme_parks though, so let's remove it from our environment
rm(theme_parks)



# Load data: google sheet -------------------------------------------------

# https://github.com/jennybc/googlesheets
library(googlesheets)
# if you wanted to use a private google sheet, you would run gs_auth()
# gs_auth(new_user = TRUE)
# the sheet we're using is public, so we don't need to do that.
# Sheet needs to be published to the web via 'File -> Publishg to the web'.
# You get the link via the 'Share' button 
gsLink <- gs_url("https://docs.google.com/spreadsheets/d/1_zwLSsQIqzK3z2l8uId9DhvU-UH5HA4MYMKKTiPRl_Q/")
alligator_bites <- gs_read(gsLink, ws = "fullData")

rm(gsLink)






# hour 2: manipulating data -----------------------------------------------

# read in aligator bites, if you don't already have it. 
alligator_bites <- read_csv("data/Alligator_Bites.csv")



# SELECT ------------------------------------------------------------------

# Now let's start manipulating our data
# In the tidyverse, there are two ways to use a function

# The first is to type out the function, complete with arguments
# Try this:
?select

# Now let's use 'select' to grab just the date column
select(alligator_bites, Date)

# But there's another way to use many R functions, that can be more concise and
# easier to read

# It's called a pipe and looks like this %>% 
alligator_bites %>% select(Date)


# Piping is most helpful if we are doing more than one operation
# This code selects just the dates and then sorts them

alligator_bites %>% select(Date) %>% arrange(Date)

# you can also save the result to an object in your environment
dates <- alligator_bites %>% select(Date) %>% arrange(Date)

# we don't actually need a list of dates, so remove it.
rm(dates)



# FILTER ------------------------------------------------------------------

# we use 'filter' to choose only certain rows
# let's look at incidents where the victim was 80 or older
alligator_bites %>% filter(Age>=80) %>% View()



# MUTATE ------------------------------------------------------------------

# Another useful verb is mutate, it lets us either alter an existing column,
# or create one or more new ones
# Let's use a mutate function to properly format the 'Date' field in a new column

# Let's use the dmy() function from lubridate to create a new date column called `Date2`
alligator_bites <- alligator_bites %>% mutate(Date2 = dmy(Date))
# What does the new column look like?
# head() lets you see the top few rows of the data set
alligator_bites %>% select(Year,Date,Date2) %>% head(10)
# Uh oh! What do you notice about the first row?

# To fix this, we'll build up the date piece by piece 
# The month and day in the Date2 column are right. Let's put them in their own columns using month() and day()
alligator_bites <- alligator_bites %>% 
  mutate(
    Month = Date2 %>% month(),
    Day   = Date2 %>% day()
  )
# look again
alligator_bites %>% select(Date,Date2,Year,Month,Day) %>% head(10)

# Now we can put all the pieces together using make_date()
alligator_bites <- alligator_bites %>% mutate(Date3 = make_date(year=Year,month=Month,day=Day))
# How does it look now? 
alligator_bites %>% select(Year,Date,Date3) %>% head()


# We got no errors, but it's good practice to not just assume a transformation worked
# Let's also look at a random selection of rows.
alligator_bites %>% select(Year,Date,Date3) %>% sample_n(10)
# And let's also look any rows where the new date variable is missing
alligator_bites %>% filter(is.na(Date3)) %>% select(Year,Date,Date3) 
# It makes sense that those are missing. Everything looks good.


# Now that we're happy with our new date column, let's clean up the data set 
alligator_bites <- alligator_bites %>% 
  # remove the Date and Date2 columns
  select(-Date,-Date2) 



# Let's also create a variable called Length_Total that measures aligator's total length in inches
alligator_bites <- alligator_bites %>% rowwise() %>% mutate(Length_Total = sum(Length_Feet*12, Length_Inches, na.rm=TRUE)) 
# Some have length zero, which I d

# check your column
alligator_bites %>% select(Length_Feet,Length_Inches,Length_Total) %>% sample_n(10)





# COUNT -------------------------------------------------------------------

# What if we want to look at how many bites happen in each county?
# you can use count()
counties <- alligator_bites %>% count(County)
counties %>% View()



# Your turn (1) -----------------------------------------------------------

# How often is alcohol/drugs involved?





# Joining tables ----------------------------------------------------------

# Joining tables is useful when some of our data is in one table and some is in another
# We can use the join functions to bring two tables together

# We're going to switch data for a minute and use the voter data

# Now, the orange_history table
orange_history %>% head(100) %>% View()

# First let's view the orange_voters table
orange_voters %>% head(100) %>% View()


# When we're doing a join, we need to figure out what column the two tables have in common
# In this case the field is the 'voterid' field

# There are different types of join, which you can study up on later, but in this case
# we want all the rows from orange_history, but only those rows from orange_voters that match that table, so we want a left join

orange_joined <- left_join(orange_history, orange_voters, by="voterid")


# who vote in the 11/08/2016 election?
orange_joined %>% filter(election_date=="11/08/2016") %>% View()




# GROUP_BY and SUMMARIZE  -------------------------------------------------

# let's group by severity of injury and find the mean and maximum alligator size
alligator_bites %>% count(Injury_Severity_LowMedHigh)

alligator_bites %>% 
  group_by(Injury_Severity_LowMedHigh) %>% 
  summarize(
    mean_weight = mean(Weight_Lbs,na.rm=TRUE), 
    max_weight  = max(Weight_Lbs ,na.rm=TRUE),
    n           = n(),
    n_missing   = sum(is.na(Weight_Lbs))
  )





# hour 3: Data Visualization ----------------------------------------------


# load El Ridership data
elRidership <- read_csv("cta_ridership_12_17.csv")

# Inspect the data in a View and see what we're working with
View(elRidership)

# One of the most basic and common graphs we can do in R is the histogram.
# Before we make a histogram, let's get some stats on ridership numbers in the table.
summary(elRidership$rides)

# Since we're looking at daily ridership at each station, let's see what the most common numbers are.
hist(elRidership$rides)

# This histogram is very skewed to the left. We've got a few days where ridership is HIGH.
# Let's change the number of breaks.
hist(elRidership$rides, breaks = 5)

# OK. Now we see that most of our records show daily station ridership of less than 10,000 rides.
# Let's increase the breaks.
hist(elRidership$rides, breaks = 10)

# Let's specify the breaks this time. We're very interested in breaking rides below 10,000 down.
hist(elRidership$rides, breaks = c(0,5000,10000,15000,20000,25000,30000,35000,40000))

# It's pretty clear. Ridership in Chicago's metro system is shared across many stations. 

# Let's look at ridership over time now. 
# Our dates are not in a good format. Let's clean those using lubridate in a new column. 
elRidership <- elRidership %>%
  mutate(date_clean = mdy(date))

# This is a lot of data to work with, so let's filter for just one station near us.
# There are two stops with Grand in it's name. So we need to use grep to find them.
grandRidership <- filter(elRidership, grepl("Grand", stationname))

# Let's look at what we're left with now.
table(grandRidership$stationname) # We're going to be left with two stations here. 
# Grand/Milwaukee and Grand/State

# Base R provides us with some standard plots. Not going to be useful but can provide a cursory look.
plot(grandRidership$date_clean,grandRidership$rides)

# Let's try this same plot in ggplot2.
# NOTE: aes() is for 'aesthetic mapping' This helps us standardize names.
# We have to declare the data frame, the x and y values inside aes() as well as the graph type.
ggplot(grandRidership,aes(date_clean,rides)) + geom_point() # Points
ggplot(grandRidership,aes(date_clean,rides)) + geom_line() # Lines
ggplot(grandRidership,aes(date_clean,rides)) + geom_bar(stat='identity') # Bars

# Okay, a little cleaner, but what if we color by 'stationname'
ggplot(grandRidership,aes(date_clean,rides, color=stationname)) + geom_point()
ggplot(grandRidership,aes(date_clean,rides, color=stationname)) + geom_line()
ggplot(grandRidership,aes(date_clean,rides, color=stationname)) + geom_bar(stat='identity')

# Let's facet this graph by daytype
ggplot(grandRidership,aes(date_clean,rides, color=daytype)) + geom_point() + 
  facet_grid(.~stationname)

# This can be hard to see what's going on, but we easily see yearly trends.
# Let's filter further for just one year of data - 2017.
# There are other ways to filter, but this is easier for changing to different dates.
grandRidership17 <- filter(grandRidership, date_clean >= "2017-01-01" & date_clean <= "2017-12-31")

# What does our most recent plot look like when filtered to one year?
ggplot(grandRidership17,aes(date_clean,rides, color=daytype)) + geom_line() + 
  facet_grid(.~stationname)

# We're not going to facet anymore. That was facet-nating, right? 
# But let's take a look at how we can modify our charts.
# For this chart, we're looking at Grand/State only. Filtering one more time.

grandStateRidership17 <- filter(grandRidership17, stationname == "Grand/State")

# And we'll plot.
ggplot(grandStateRidership17,aes(date_clean,rides)) + geom_point() # Just the points.

# This is a little messy but you can see the weekdays, Saturdays and Sundays.
ggplot(grandStateRidership17, aes(date_clean, rides, fill=daytype)) +
  geom_bar(stat="identity")

# This time, we'll look at lines.
ggplot(grandStateRidership17, aes(date_clean,rides)) + geom_line()

# I can also see these together. It's kind of messy but it can be done.
ggplot(grandStateRidership17, aes(date_clean,rides)) + geom_line() + geom_point()

# I really like the line for a possible graphic showing ridership at
# Grand/State throughout 2017. Let's add a headline. We're also going to store this whole block of code.

myChart <- ggplot(grandStateRidership17, aes(date_clean,rides)) + 
  geom_line() +
  labs(title="Grand/State station daily ridership in 2017") +
  labs(subtitle = "Daily ridership at the Grand/State metro station as counted by the Chicago Transit Authority") +
  labs(x = "Date") +
  labs(y = "Number of rides") +
  labs(caption = "Charles Minshew/IRE and NICAR")

# Since we stored the chart as 'myChart', we need to run this in order to show it.
myChart

# Now let's output our graphic to a file!
# First JPEG
jpeg("myChart.jpeg")
myChart
dev.off() # This is very important to end the export!

# Next up, EPS (for using in Adobe Illustrator)
setEPS()
postscript('output/myChart.eps')
myChart
dev.off()

# And you can export your data from R, too
write_csv(grandStateRidership17, "grand_state.csv")
# You don't need dev.off() for data exports
