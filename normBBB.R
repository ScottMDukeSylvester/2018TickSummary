remove(list=ls())

library(tidyverse)
library(readxl)
library(lubridate)

#####################################
# User defined parameters
#
#####################################
filenameRaw   = '2018 BBB 000 raw.csv'
filenameFull  = '2018 BBB 010 full.csv'
filenameFinal = '2018 BBB 020 final.csv'

#####################################
# Read in the data
#
#####################################
cat('normBBB.R: Msg: Loading the raw data\n')
data = read_csv(filenameRaw)

#####################################
# Fix the data 
#     Rename columns to standard names
#     Add missing columns that are standard
#     Fix data formatting issues.
#####################################

# First, lets fix the names
cat('normBBB.R: Msg: Fixing the columns names\n')
names(data) = c('date', 
                'site', 
                'time', 
                'startLat', 
                'startLng', 
                'endLat', 
                'endLng',
                'numTicks',
                'notes',
                'fieldCode' )

# lets add the transect number
cat('normBBB.R: Msg: Adding transect number\n')
data$transect = 1:nrow(data)

# Find and report broken field codes
cat('normBBB.R: Msg: Reporting broken field codes\n')
data$fieldCode[ is.na(data$fieldCode) ] = ''
indexCode   = regexpr('^[0-9a-zA-Z]+$', data$fieldCode) != -1
indexBroken = indexCode & (regexpr('^BBB2018[0-9]{6}$', data$fieldCode) == -1)
cat('normAAA.R: Msg: There are ',nrow(data),' records total\n')
cat('normAAA.R: Msg: There are ',sum(indexCode),' records with field codes\n')
cat('normAAA.R: Msg: There are ',sum(indexBroken),' records with broken field codes\n')
print(subset(data, indexBroken))

# Now create the day, month and year columns 
cat('normBBB.R: Msg: Creating date columns\n')
data$day   = day  ( parse_date_time(data$date, 'dmy') )
data$month = month( parse_date_time(data$date, 'dmy') )
data$year  = year ( parse_date_time(data$date, 'dmy') )

# Create the hours and minutes columns
cat('normBBB.R: Msg: creaing hour and minute columns\n')
data$hour = hour( parse_date_time(data$time, 'HM') )
data$min  = minute( parse_date_time(data$time, 'HM') )

# Create the transect centers
cat('normBBB.R: Msg: Creating transect center\n')
data$lng = (data$startLng + data$endLng)/2.0
data$lat = (data$startLat + data$endLat)/2.0

# Add the collector column
cat('normBBB.R: Msg: Adding collector column\n')
data$collector = 'BBB'

# Place the columns in the correct order
cat('normBBB.R: Msg: Giving the columns the correct order\n')
data = data[c('collector',
                'transect',
                'fieldCode',
                'day',
                'month',
                'year',
                'hour',
                'min',
                'startLng',
                'startLat',
                'endLng',
                'endLat',
                'lng',
                'lat',
                'site',
                'numTicks', 
                'notes')]

cat('normBBB.R: Msg: Writting final data\n')
write_csv(data, filenameFinal, na=' ')

cat('normBBB.R: Msg: Done\n')
