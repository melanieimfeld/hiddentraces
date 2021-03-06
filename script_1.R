#------------------------------------------------1) Preparation---------------------------------------------------
#install these packages if not existent already
#install.packages('openair')
#install.packages('ggmap')

#load libraries
library(OpenStreetMap)
library(sp)
library(rgeos)
library(tmap)
library(tmaptools)
library(sf)
library(rgdal)
library(tidyverse)
library(ggplot2)
library(geosphere)
library(openair)
library(jsonlite)
library(gstat)
library(scales)
library(ggmap)

#set directory
#setwd("~/Desktop/yourfolder")

#-------------------------------------2) insert your Google location history here--------------------------------
#insert json
x <- fromJSON("Location History.json")

#set desired date
ddate <-"2017-12-11"

#set desired pollutants. nox, no2, pm10 can be loaded (note: pm10 has only few measurements). 
pollutants <- 'no2'

#-------------------------------------3) preparation of Google location history--------------------------------
#subsets location and time
loc <-  x$locations

#this transforms coordinates into long/lat. 'E7' notation means that 10^7 needs to be multiplied get the actual number
#source: https://stackoverflow.com/questions/30610225/how-do-i-read-my-google-location-history-in-r
loc$lat = loc$latitudeE7 / 1e7
loc$lon = loc$longitudeE7 / 1e7

#converts posix milliseconds into a readable format
loc$time = as.POSIXct(as.numeric(x$locations$timestampMs)/1000, 
                      origin = "1970-01-01")
#separate date
loc$date_only <- format(loc$time,"%Y-%m-%d")
loc$date_only <- as.POSIXct(loc$date_only)

#subset desired date
locDay <- loc[loc['date_only']== ddate,]

#calculate distance from one point to the next
len <- nrow(locDay)

locDay[1:len-1,13] <- distGeo(locDay[1:len-1,9:10],locDay[2:len,9:10])
names(locDay)[13] <-"distance in m"
locDay[13] <- round(locDay['distance in m'], 2)

#delete all FIRST points that have a distance of > 50 to the second point 
locDaygen <- locDay[locDay['distance in m']> 50.00 & !is.na(locDay['distance in m'])== TRUE,]

#add a column with hours only
locDaygen$hour_of_day <- strftime(locDaygen$time,format="%H")
locDaygen$hour_of_day <- as.numeric(locDaygen$hour_of_day)

#add 1 hour to each result
locDaygen$hour_of_day <- locDaygen$hour_of_day + 1

#-----------------------------4) load/prepare pollution data from Kings College (just METADATA)-------------------------
#list metadata
measurements_stations <- c("CT6", "TH2", "CT8", "WA2" ,"BT4" ,"WM5" ,"LB4" ,"MY7" ,"BT5" ,"EN5", "BL0", "WM0" ,"GR9" ,"KC7", "EA8","CD1", "IS2", "KC1", "LW1", "LW2","MY1",
                           "HG4", "RB4", "RI1", "RI2" ,"CR5", "EN1", "EN4", "GR7", "HG1", "HK6", "EA6","LB5" ,"ST5", "MR3" ,"GR8", "BT6","GN0", "TH4", "CT3", "IS6", 
                           "WAA", "NK3", "ME2", "CD9", "WM6" ,"WA9", "WA8","MY4", "CT2", "CT4", "EI1", "WA7", "LW4","HFX", "NK9","ST8",
                           "WAB", "LB6", "CR8", "BT8", "MR9", "NB1", "HFY", "WAC", "ME9","GN5", "SK5", "NK6", "EI3", "BT0", "TH0", "IM1")

#-------------------------5) load/prepare pollution data from Kings College (actual data) -----------------------------

#this is data for an area per hour KCL forn NO2
pollution <- importKCL(site = measurements_stations, year = 2017, pollutant = pollutants, met = FALSE,
                          units = "mass", extra = FALSE, meta = TRUE)

#subset the date from time and make new column
pollution$date_only <- format(pollution$date,"%Y-%m-%d")

#convert to datetime format
pollution$date_only <- as.POSIXct(pollution$date_only)

#subset desired day
pollutionDay <- pollution[pollution['date_only']== ddate,]

#delete rows with n/a values
pollutionDay <- pollutionDay[!is.na(pollutionDay[pollutants])== TRUE,]

#change pollution name for idw
names(pollutionDay)[2]<-'poll'

#---------------------------6) prepare location history and air pollution data for IDW -----------------------------
#bin location history data by hour
locBinned <-  by(locDaygen, locDaygen$hour_of_day, data.frame)

#bin pollution data, use location history data as index (+ 1 because eg 10.00 am is at index 11)
pollBinned <-  by(pollutionDay, pollutionDay$date, data.frame)[unique(locDaygen$hour_of_day)+1]

#-------------------------------------------7) make a IDW for each hour----------------------------------------
#save wgs projection
latlong <- "+init=epsg:4326"

#set up function
myIDW <- function(x,y){
  #transforms location history to spatial
  locBin<- SpatialPointsDataFrame(coords = x[,c("lon","lat")], data=x, proj4string = CRS(latlong))
  #transforms air pollution data to spatial
  pollBin <-  SpatialPointsDataFrame(coords = y[,c('longitude','latitude')], data=y, proj4string = CRS(latlong))
  #IDW formula
  IDWoutput <- idw(formula = pollBin$poll~ 1, locations=pollBin, newdata=locBin, idp=2)
  return(IDWoutput)
}

#apply function to both dataframes
IDWout <- mapply(myIDW,locBinned, pollBinned)

#concatenate IDW list of dataframes
IDWconc <-  do.call(rbind, IDWout)
IDWconc <- as.data.frame(IDWconc)

#change name back
names(IDWconc)[3] <- pollutants

#append IDW preductions to location history data
locDayPred<-merge(x=IDWconc,locDaygen, by = c("lon","lat"))

#---------------------------------------------8) set up theme for ggplot--------------------------------------------------
#create a custom theme
customtheme <- theme(
  text = element_text(family = "Helvetica", color = "#636363"),
  axis.line = element_blank(),
  #long/ lat values
  axis.text.x = element_text(color = "#636363"),
  axis.text.y = element_text(color = "#636363"),
  axis.ticks = element_line(color = "#ebebe5", size = 0.2),
  #axis titles
  axis.title.x = element_text(color = "#636363"),
  axis.title.y = element_text(color = "#636363"),
  panel.grid.major = element_line(color = "#ebebe5", size = 0.2),
  panel.grid.minor = element_blank(),
  plot.background = element_rect(fill = "#f5f5f2", color = NA), 
  panel.background = element_rect(fill = "#f5f5f2", color = NA), 
  legend.background = element_rect(fill = "#f5f5f2", color = NA),
  legend.text  = element_text(size = 8,color = "#636363")
)

#---------------------------------------------9) plotting timeseries----------------------------------------------------
#adaptable titles
chart_title <- paste(pollutants, " exposure on ", ddate)
axis_title <- paste(pollutants, " ug/m3 ")

#this the the time series plot
layer9 <- ggplot(locDayPred, aes(time, locDayPred[,3], color='red')) +
  geom_line(size=1, show.legend = FALSE) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  scale_x_datetime(labels = date_format("%H:%M:%S"),breaks = date_breaks("30 min")) + customtheme + labs(x = 'Time', y = axis_title, title = chart_title )

ggsave("myplot.png")

#---------------------------------------------10) plotting map----------------------------------------------------
#set mean of coordinates to center the ggmap
lat1 <- mean(locDayPred[,2])
lon1 <- mean(locDayPred[,1])

#set up map
#get_map seems pretty buggy, there will be warnings popping up...
map <- get_map(location = c(lon = lon1, lat = lat1), maptype = "toner-lines",zoom = 12, color = "bw",source = "stamen")
layer3<-geom_jitter(data=locDayPred, position=position_jitter(width=0.004, height=0.004), alpha = 0.8, aes(x=lon, y=lat,color=locDayPred[3]), size=3)

#palette
palette2 <- scale_colour_gradient(low = "#9ecae1", high = "red",name = pollutants)

#plot
ggmap(map)+layer3 + palette2 + customtheme + labs(x= 'longitude', y='latitude', title = chart_title)

ggsave("myplot-map.png")