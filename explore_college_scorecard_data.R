# Setup environment and read in data --------------------
# Clear currently defined objects in R
rm(list=ls())

# Set working directory to location containing datafile
setwd('/Users/eroo/Google Drive/wharton/high performance r/data/')

# Read in data; interperet "NULL" as NA
raw.data <- read.csv("MERGED2013_PP.csv", header=TRUE, na.strings="NULL")

# Ensure data are loaded as expected --------------------
# Are these data loaded as a data frame?
is.data.frame(raw.data)

# How many rows (observations) and columns (variables) are in these data?
dim(raw.data)

# Of the ~13mm possible values, how many are missing?
sum(is.na(raw.data)) # missing obs are prevalent

# Attch will allow you to signal reference vars from a dataframe w/o the df name
attach(raw.data)
length(raw.data$UNITID)  # with df reference
length(UNITID)  # without df reference; allowed because of attach

# There are a few variables we're particularly interested in:
    # INSTNM - school name
    # UNITID - school id
    # STABBR - state
    # LATITUDE
    # LONGITUDE
    # ADM_RATE - admission rate
    # SAT_AVG - mean SAT
    # ACTCMMID - mean ACT
    # ADM_RATE - admission rate

# Let's look at the average SAT and ACT test score data
# We'll do it multiple times, so we might as well make functions
ListHiToLow <- function(v) {
    v[order(v, decreasing = T, na.last = NA)]    
}

ListOverX <- function(vlist, vtest, x) {
    vlist[vtest >= x & !is.na(vtest)]
}

# Let's look at SATs and make some observations
ListHiToLow(SAT_AVG)
summary(SAT_AVG)
ListOverX(INSTNM, SAT_AVG, 1400)  # test ge 1400 SAT

# Now, let's look at ACTs and make some observations
ListHiToLow(ACTCMMID)
summary(ACTCMMID)
ListOverX(INSTNM, ACTCMMID, 32)  # test ge 32 ACT

# You could argue that we could streamline the repeated function calls for SAT and ACTs,
  # but there's good reason to suspect that there is actually value is walking through
  # line by line to get a feel for these data and not print too many results at once.

