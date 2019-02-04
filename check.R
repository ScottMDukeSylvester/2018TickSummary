#############################################################
# check.R: 
#
#############################################################
remove(list=ls())
assign("last.warning", NULL, envir = baseenv())

#############################################################
# Load libraries
#
#############################################################
library(tidyverse)
library(rgdal)
library(rgeos)
library(sp)

#############################################################
# 
#
#############################################################
data = read_csv('2018 merged.csv')

indexPresent = !is.na(data$fieldCode)
indexCorrect = regexpr('^(AAA|BBB)2018[0-9]{6}$', data$fieldCode) == 1
indexCorrect[is.na(indexCorrect)] = F

cat('check.R: Msg: Number of records with field codes         = ',sum(indexPresent),'\n')
cat('check.R: Msg: Number of records with correct field codes = ',sum(indexCorrect),'\n')
indexBroken = indexPresent == T & indexCorrect == F
print(data[indexBroken, ])

indexDay    = regexpr('^[0-9]{1,2}$', data$day  ) == -1
indexMonth  = regexpr('^[0-9]{1,2}$', data$month) == -1
indexYear   = regexpr('^[0-9]{4}$'  , data$year ) == -1
indexBroken = indexDay & indexMonth & indexYear
cat('check.R: Msg: Number of records with broken date information = ',sum(indexBroken),'\n')
print(data[indexBroken, ])

#############################################################
# Check that all the data points are in Louisiana
#
#############################################################
cat('check.R: Msg: Checking the location of data poitns\n')

index = is.na(data$lng) 
cat('check.R: Msg: Number of rows that have no longitudes     = ',sum(index),'\n')
index = !is.na(data$lng) & (data$lng < -94 | -88 < data$lng)
cat('check.R: Msg: Number of rows that have broken longitudes = ',sum(index),'\n')
print(data[index, ])

index = is.na(data$lat)
cat('check.R: Msg: Number of rows that have no latitude      = ',sum(index),'\n')
index = !is.na(data$lat) & (data$lat < 28 | 33 < data$lat)
cat('check.R: Msg: Number of rows that have broken latitudes = ',sum(index),'\n')
print(data[index, ])

# Drop locations with broken or missing coordinates for now
cat('check.R: Msg: Dropping rows with broken or missing coordinates\n')
data = subset(data, !is.na(data$lng) & (-94 < data$lng & data$lng < -88) )
data = subset(data, !is.na(data$lat) & ( 28 < data$lat & data$lat < 33 ) )

# Load the states shapefile
filename = list( dsn = './SpatialData/US States', layer = 'cb_2017_us_state_5m')
stateSF  = readOGR( dsn = filename$dsn , layer = filename$layer )

# Turn the sampling location data into a shapefile object
dataSF = subset( data, !is.na(lng) & !is.na(lat) )
coordinates(dataSF) = ~lng + lat
proj4string(dataSF) = "+proj=longlat +datum=WGS84 +no_defs"

# Reproject the data to the same system as the stateSF shapefile
dataSF = spTransform(dataSF, proj4string(stateSF) )

ret = over(dataSF, stateSF)
index = is.na(ret$NAME) | ret$NAME != 'Louisiana'