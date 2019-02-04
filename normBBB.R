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
data = read_csv(filenameRaw)

#####################################
# Fix the data 
#     Rename columns to standard names
#     Add missing columns that are standard
#     Fix data formatting issues.
#####################################

# First, lets fix the names
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
data$transect = 1:nrow(data)


# Now create the day, month and year columns 
data$day   = day  ( parse_date_time(data$date, 'dmy') )
data$month = month( parse_date_time(data$date, 'dmy') )
data$year  = year ( parse_date_time(data$date, 'dmy') )

# Create the hours and minutes columns
data$hour = hour( parse_date_time(data$time, 'HM') )
data$min  = minute( parse_date_time(data$time, 'HM') )

# Create the transect centers
data$lng = (data$startLng + data$endLng)/2.0
data$lat = (data$startLat + data$endLat)/2.0

# Place the columns in the correct order
data = data[c('transect',
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

write_csv(data, filenameFinal, na=' ')
