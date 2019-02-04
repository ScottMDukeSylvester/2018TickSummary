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