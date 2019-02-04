#############################################################
# merge.R: 
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
filenameA = '2018 AAA 020 final.csv'
filenameB = '2018 BBB 020 final.csv'
filenameM = '2018 merged.csv'

# Load the data
dataA = read_csv(filenameA)
dataB = read_csv(filenameB)

# Merge the data
dataM = rbind(dataA, dataB)

# Add a unified transect number 
dataM$unifiedTransect = 1:nrow(dataM)

# Reorder the columns
colNames = names(dataM)
colNames = colNames[ !colNames%in%c('unifiedTransect') ]
colNames = c( 'unifiedTransect', colNames)
dataM    = dataM[ colNames ]

# Write the data
write_csv(dataM, filenameM, na=' ')
