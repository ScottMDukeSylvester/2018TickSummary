#############################################################
# <script>.R: 
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
filenameRaw   = '2018 AAA 000 raw.csv'
filenameFull  = '2018 AAA 010 full.csv'
filenameFinal = '2018 AAA 020 final.csv'

cat('normAAA.R: Msg: Loading data from ',filenameRaw,'\n')
data     = read_csv(filenameRaw)

##########################################
# Reformate data into correct format
#
##########################################

# rename the columns
cat('normAAA.R: Msg: Renaming columns \n')
data = data %>% rename(transect = Transect)
data = data %>% rename(startLng = long)
data = data %>% rename(startLat = lat)
data = data %>% rename(endLng   = long_1)
data = data %>% rename(endLat   = lat_1)
data = data %>% rename(y0       = y)
data = data %>% rename(y1       = y_1)
data = data %>% rename(y2       = y_2)
data = data %>% rename(y3       = y_3)
data = data %>% rename(m0       = m)
data = data %>% rename(m1       = m_1)
data = data %>% rename(d0       = d)
data = data %>% rename(d1       = d_1)
data = data %>% rename(numTicks = X21)
data = data %>% rename(collector= X22)
data = data %>% rename(notes    = X23)

# build the final fieldCode column
cat('normAAA.R: Msg: Building fieldCode\n')
data$fieldCode = with(data, paste(INIT,y0,y1,y2,y3,m0,m1,d0,d1,sprintf('%02d',as.integer(SeqNum) ),sep='') )

# Strip out incomplete or broken field codes
cat('normAAA.R: Msg: Dropping broken field codes\n')
index = regexpr('^JTB[0-9a-zA-Z]+', data$fieldCode) == -1
data$fieldCode[index] = ''

# build the location for each transect
cat('normAAA.R: Msg: Building transect locations\n')
data$startLNGDegrees = (data$startLng %>% str_split(' ', simplify=TRUE))[,1] 
data$startLNGMinutes = (data$startLng %>% str_split(' ', simplify=TRUE))[,2] 
data$startLNG        = as.numeric(data$startLNGDegrees) - as.numeric(data$startLNGMinutes)/60.0
data$startLATDegrees = (data$startLat %>% str_split(' ', simplify=TRUE))[,1] 
data$startLATMinutes = (data$startLat %>% str_split(' ', simplify=TRUE))[,2] 
data$startLAT        = as.numeric(data$startLATDegrees) + as.numeric(data$startLATMinutes)/60.0

data$endLNGDegrees   = (data$endLng %>% str_split(' ', simplify=TRUE))[,1] 
data$endLNGMinutes   = (data$endLng %>% str_split(' ', simplify=TRUE))[,2] 
data$endLNG          = as.numeric(data$endLNGDegrees) - as.numeric(data$endLNGMinutes)/60.0
data$endLATDegrees   = (data$endLat %>% str_split(' ', simplify=TRUE))[,1] 
data$endLATMinutes   = (data$endLat %>% str_split(' ', simplify=TRUE))[,2] 
data$endLAT          = as.numeric(data$endLATDegrees) + as.numeric(data$endLATMinutes)/60.0

data$lng             = (data$startLNG + data$endLNG)/2.0
data$lat             = (data$startLAT + data$endLAT)/2.0

# write the data
cat('normAAA.R: Msg: Writing full data set\n')
write_csv(data, filenameFull, na=' ')

# Drop extra columns
cat('normAAA.R: Msg: Dropping unneeded columns\n')
data = data %>% select( -INIT, -y0, -y1, -y2, -y3, -m0, -m1, -d0, -d1, -SeqNum)
data = data %>% select( -startLNGDegrees )
data = data %>% select( -startLNGMinutes )
data = data %>% select( -startLATDegrees )
data = data %>% select( -startLATMinutes )
data = data %>% select( -endLNGDegrees )
data = data %>% select( -endLNGMinutes )
data = data %>% select( -endLATDegrees )
data = data %>% select( -endLATMinutes )

data = data %>% select( -startLng )
data = data %>% select( -startLat )
data = data %>% select( -endLng )
data = data %>% select( -endLat )

# rename final columns
cat('normAAA.R: Msg: Renaming final columns\n')
data = data %>% rename(startLng = startLNG)
data = data %>% rename(startLat = startLAT)
data = data %>% rename(endLng   = endLNG)
data = data %>% rename(endLat   = endLAT)

# Add a site column that we will need to fill in later
cat('normAAA.R: Msg: Adding site column\n')
data$site = ''

# Add collector column
cat('normAAA.R: Msg: Adding collector column\n')
data$collector = 'AAA'


# Give the columns the correct order
cat('normAAA.R: Msg: Reordering columns\n')
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

cat('normAAA.R: Msg: Writting final data\n')
write_csv(data, filenameFinal, na=' ')

cat('normAAA.R: Msg: Done\n')
