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

orange_voters <- read_csv("data/orange_voters.csv")



# Your turn (1) -----------------------------------------------------------

# read in the file orange_history.csv




# Load data: delimited ----------------------------------------------------

# Sometimes data comes with something separating columns other than a comma 
# For instance, sometimes you get a pipe delimited file.
# read_delim handles that! You can specify a comma as the delimiter, or anything else.

# Also, with read_csv and read_delim, you can specify column types

orange_history_extra <- read_delim(
  "data/orange_history.csv", 
  delim = ',' , 
  col_types = list(voterid = col_character())
  )

rm(orange_history_extra)



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

theme_parks <- read_excel("data/theme_park_incidents_excel.xlsx", sheet = "fullData")

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

# We no longer need 'gsLink' in our environment, so let's remove that. 
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
# What do you notice when we arrange the dates?
# We're going to take care of this problem in just a little while. 
dates <- alligator_bites %>% select(Date) %>% arrange(Date)
dates

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

# Let's use the dmy() function from lubridate to create a new date column called `date_formatted`
alligator_bites <- alligator_bites %>% mutate(date_formatted = dmy(Date))
# What does the new column look like?
# head() lets you see the top few rows of the data set
alligator_bites %>% select(Year,Date,date_formatted) %>% head(10)
# Uh oh! What do you notice about the first row?

# To fix this, we'll build up the date piece by piece 
# The month and day in the date_formatted column are right. Let's put them in their own columns using month() and day()
alligator_bites <- alligator_bites %>% 
  mutate(
    Month = date_formatted %>% month(), # Take a second to explain this is from Lubridate.
    Day   = date_formatted %>% day()
  )
# look again
alligator_bites %>% select(Date,date_formatted,Year,Month,Day) %>% head(10)

# Now we can put all the pieces together using make_date()
alligator_bites <- alligator_bites %>% 
  mutate(date_final = make_date(year=Year,month=Month,day=Day))

# How does it look now? 
alligator_bites %>% select(Year,Date,date_final) %>% head()


# We got no errors, but it's good practice to not just assume a transformation worked
# Let's also look at a random selection of rows.
alligator_bites %>% select(Year,Date,date_final) %>% sample_n(10)

# And let's also look any rows where the new date variable is missing
alligator_bites %>% filter(is.na(date_final)) %>% select(Year,Date,date_final) 
# It makes sense that those are missing. Everything looks good.


# Now that we're happy with our new date column, let's clean up the data set 
alligator_bites <- alligator_bites %>% 
  # remove the Date and date_formatted columns
  select(-Date,-date_formatted) 



# Let's also create a variable called Length_Total that measures aligator's total length in inches
alligator_bites <- alligator_bites %>% 
  rowwise() %>% # We run this so R doesn't try add the length of every single alligator into one.
  mutate(Length_Total = sum(Length_Feet*12, Length_Inches, na.rm=TRUE)) 
# Some have length zero. Be careful not to include these in computation of averages.

# check your column
alligator_bites %>% select(Length_Feet,Length_Inches,Length_Total)

# COUNT -------------------------------------------------------------------

# What if we want to look at how many bites happen in each county?
# you can use count()
counties <- alligator_bites %>% count(County)

# When we do a count with dplyr, it's going to store the count as a column named 'n'
counties %>% arrange(desc(n)) %>% View()



# Your turn (1) -----------------------------------------------------------

# How often is alcohol/drugs involved?

# Which state are most victims residents of? 

# How many people died? 


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

# List the people who voted early in the election. 

# Which party had the most voters?

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
  ) %>%
  arrange(mean_weight) # We think alligator weight might have something do with this, so let's check.
  





# hour 3: Data Visualization ----------------------------------------------

# Visualization in R can be confusing at first, because the syntax is unique
# But you will find that if you get the hang of it is very powerful and customizable

# Load ggplot2
# install.packages("ggplot2")

library(ggplot2)
library(RColorBrewer)

# The theory is that every plot can be broken down into three parts:
# Data
# A coordinate system
# Geom: visual marks that represent data points

# First we tell R what data we want it to use
ggplot(data = alligator_bites)

# We can see that created a blank field for us to plot on

# Then we tell ggplot which of the fields in our data are x and y coordinates
ggplot(data = alligator_bites, aes(Length_Total))

# We can see that now our x-axis is labeled with Length_Total

# Histogram ----------------------------------------------------------------

# Let's study the distribution of alligator lengths involved in attacks by making a histogram

# Start by designating our data and variable into an object
a <- ggplot(data = alligator_bites, aes(Length_Total))

# Then we add a 'geom'
a + geom_histogram()

# Yikes - that is too many bins! Let's specify a bin width
a + geom_histogram(binwidth = 20)

# Your turn: Try changing the bin width to something other than 20


# We can also see that there are many alligators with a reporter length of 0
# Looking at the data we can see that '0' means something more like 'don't know'
# A nice thing about ggplot is that we can use it in our pipe method

alligator_bites %>% filter(Length_Total != 0) %>% ggplot(aes(Length_Total)) + geom_histogram(binwidth = 20)

# From this we learn that the distribution of alligator lengths is fairly normal, with a mean around 100 inches

# There are also things we can do to make ggplots look prettier

alligator_bites %>% filter(Length_Total != 0) %>% ggplot(aes(Length_Total)) + geom_histogram(binwidth = 20, fill = "royal blue", color = "gray", alpha = .8) +
labs(x = "Alligator Length", title = "Alligators are terrifying")

# There are also themes

alligator_bites %>% filter(Length_Total != 0) %>% ggplot(aes(Length_Total)) + geom_histogram(binwidth = 20) + theme_light()

# Your turn -- try a theme other than theme_light

# Bar chart ----------------------------------------------------------------

# Let's use a bar chart to figure out what activity folks are up to when attacked
# The field that contains this information is Victim_Activity

# We start by specifying our data

b <- ggplot(data = alligator_bites, aes(Victim_Activity))

# Now we add the bar plot geom

b + geom_bar()

# We can also make this a horizontal bar chart this way

b + geom_bar() + coord_flip()

# You practice: Make a bar plot of the Injury Severity field


# Line chart --------------------------------------------------------

# Unlike the last two plots we made, a line chart has an x and a y data point
# In journalism, usually the x-axis is time

# Let's turn our attention to the voter file

# For convenience, let's date format the election_date field together

# First we filter for the regular general elections since 2006

gen_elections <- c(mdy('11/02/2010'), mdy('11/04/2008'), mdy('11/04/2014'), mdy('11/06/2012'), mdy('11/07/2006'), mdy('11/08/2016'))

gen_voters <- orange_joined %>% 
  filter(election_date_new %in% gen_elections) %>% 
  group_by(election_date_new) %>% 
  count() %>% 
  arrange(election_date_new)

# Now we specify our data and variables

d <- gen_voters %>% ggplot(aes(x = election_date_new, y = `n`))

d + geom_line()

# Fascinating - what if we want to know this pattern by party?
# ggplot can help

# First, we'll include party affiliation in our gen_voters table

gen_voters <- orange_joined %>% 
  filter(election_date_new %in% gen_elections) %>% 
  group_by(election_date_new, pty_aff) %>% 
  count() %>% 
  arrange(election_date_new)

# Now we add a new argument to the aes function

d <- gen_voters %>% ggplot(aes(x = election_date_new, y = `n`, color = pty_aff))

d + geom_line()

# You try - what if we want a chart that is just Republicans and Democrats?


# What if we want this same information for every race side-by-side?
# ggplot can help with that too

gen_voters <- orange_joined %>% 
  filter(election_date_new %in% gen_elections) %>% 
  group_by(election_date_new, pty_aff, race) %>% 
  count() %>% 
  arrange(election_date_new)

d <- gen_voters %>% ggplot(aes(x = election_date_new, y = `n`, color = pty_aff))

d + geom_line() + facet_wrap(~race)
                           
# Scatterplot ------------------------------------------------------------

# The final type of plot we'll talk about today is called a scatterplot
# In this plot, each observation in our data is a point on an x-y plane

# Let's explore whether larger alligators cause more serious injury

# As always, we'll set up our data

e <- alligator_bites %>% ggplot(aes(x = Length_Total, y = Injury_Severity_LowMedHigh))

e + geom_point()

# Hmm - let's make ggplot arrange the severity categories better

e <- alligator_bites %>% ggplot(aes(x = Length_Total, y = fct_relevel(Injury_Severity_LowMedHigh, "N","H","M","L")))

e + geom_point() 

# Do we see a pattern?

# You try - What if we look at gator weight instead of length?

# Let's also look at a case where both variables are continuous, instead of categorical

f <- alligator_bites %>% ggplot(aes(x = Length_Total, y = Weight_Lbs))

f + geom_point()

# You try - let's color the points by the alligator's sex

# Finally, it looks like there's a relationship between gator length and weight, but we can have ggplot fit a line to formalize this

f + geom_point() + geom_smooth(method = lm)

