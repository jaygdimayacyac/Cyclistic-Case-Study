# Load basic data analysis packages
library(dplyr)
library(tidyverse)

# Load data cleaning packages
library(skimr)
library(janitor)

# Load package for date manipulation
library(lubridate)

# Load packages for visualization
library(ggplot2)
library(htmltools)
library(leaflet)
library(leaflet.extras)

#Import .csv files to RStudio (these .csv have mostly been processed via Excel)
nov22 <- read.csv("202211-divvy-tripdata.csv")
dec22 <- read.csv("202212-divvy-tripdata.csv")
jan23 <- read.csv("202301-divvy-tripdata.csv")
feb23 <- read.csv("202302-divvy-tripdata.csv")
mar23 <- read.csv("202303-divvy-tripdata.csv")
apr23 <- read.csv("202304-divvy-tripdata.csv")
may23 <- read.csv("202305-divvy-tripdata.csv")
jun23 <- read.csv("202306-divvy-tripdata.csv")
jul23 <- read.csv("202307-divvy-tripdata.csv")
aug23 <- read.csv("202308-divvy-tripdata.csv")
sep23 <- read.csv("202309-divvy-tripdata.csv")
oct23 <- read.csv("202310-divvy-tripdata.csv")

# Combine files into one data frame
rawyeardata <- rbind(nov22,dec22,jan23,feb23,mar23,apr23,may23,jun23,jul23,aug23,sep23,oct23)

# Check for errors in the data with by ensuring correct ride length, clean and distinct names
yeardata <- rawyeardata %>% 
  filter(ride_duration>0) %>% 
  clean_names() %>% 
  unique()

# Summarize ride_duration column to ensure proper data type
summary(yeardata$ride_duration)

# Compare ride data for members and casual users
aggregate(yeardata$ride_duration ~ yeardata$member_casual, FUN = mean)
aggregate(yeardata$ride_duration ~ yeardata$member_casual, FUN = median)
aggregate(yeardata$ride_duration ~ yeardata$member_casual, FUN = max)
aggregate(yeardata$ride_duration ~ yeardata$member_casual, FUN = min)

# Summarize the total and average number of rides per day of the week by rider type
summary_wd <- yeardata %>% 
  group_by(member_casual, day_of_week) %>%  
  summarise(number_of_rides = n(),
            average_duration = mean(ride_duration)) %>%    
  arrange(member_casual, day_of_week) %>% 
  mutate(week_day=wday(day_of_week,label=TRUE))

# Visualize the number of rides and average duration of rides by rider type and day of the week
plot_wd <- ggplot(summary_wd, aes(x = week_day, fill = member_casual)) +
  geom_col(aes(y = number_of_rides), position = position_dodge(width = 0.8), 
           color = "black") +
  geom_col(aes(y = average_duration), position = position_dodge(width = 0.8), 
           color = "black") +
  labs(title = "Number of Rides and Average Duration by Rider Type and Day of the Week",
       x = "Day of the Week", y = "Count") +
  scale_fill_manual(values = c("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3"))

# Summarize the total and average number of monthly rides by rider type
summary_month <- yeardata %>% 
  group_by(ride_month,member_casual) %>%  
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_duration)) %>%    
  arrange(ride_month, member_casual) %>% 
  mutate(month = month(ride_month,label=TRUE)) %>% 
  subset(select=-ride_month)

# Visualize the number of rides and average duration of rides by rider type and month
plot_month <- ggplot(summary_month, aes(x = month, fill = member_casual)) +
  geom_col(aes(y = number_of_rides), position = position_dodge(width = 0.5), 
           color = "black") +
  geom_col(aes(y = average_duration), position = position_dodge(width = 0.5), 
           color = "black") +
  labs(title = "Number of Rides and Average Duration by Rider Type and Month",
       x = "Month", y = "Count") +
  scale_fill_manual(values = c("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3"))


# Determine number of rides based on time of day
summary_tod <- yeardata %>% 
  mutate(start_time = as.POSIXct(start_time, format = "%H"), hour = hour(start_time)) %>%
  group_by(hour) %>%
  summarise(number_of_rides = n(),
            average_duration = mean(ride_duration)) %>% 
  arrange(hour) %>% 
  mutate(hour = sprintf("%02d:00", hour))

# Visualize the number of rides per time of the day
plot_tod <- ggplot(summary_tod, aes(x = hour), axis.text.x=element_text(size=1)) +
  geom_col(aes(y = number_of_rides), fill = "#66c2a5") +
  labs(title = "Number of Rides by Hour of the Day",
       x = "Hour of the Day",
       y = "Number of Rides") + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Summarize the stations most used by each user group
summary_station <- yeardata %>% 
  mutate(station = start_station_name) %>%
  drop_na(start_station_name) %>% 
  group_by(station, member_casual) %>% 
  summarise(latitude = mean(start_lat),
            longitude = mean(start_lng),
            number_of_rides = n()) %>%    
  arrange(desc(number_of_rides)) %>% 
  filter(number_of_rides > 10, station != "") %>% # filter for number of rides greater than 10

summary_station_casual <- summary_station %>%
  filter(member_casual == "casual")

summary_station_member <- summary_station %>%
  filter(member_casual == "member")

# Visualize number of rides using heatmap in City of Chicago
station_map <- leaflet(summary_station) %>%
  addTiles() %>%
  addHeatmap(
    lng = summary_station$longitude,
    lat = summary_station$latitude,
    intensity = summary_station$number_of_rides,
    blur = 20,
    max = 20000,
    radius = 20
  )

# Export summary files for further analysis
write_csv(yeardata,"2022-2023-divvy-tripdata-clean.csv")
write_csv(summary_wd, "summary_ride_length_weekday.csv")
write_csv(summary_month, "summary_ride_length_month.csv")
write_csv(summary_tod, "summary_ride_length_tod.csv")
write_csv(summary_station, "summary_stations.csv")
write_csv(summary_station_casual, "summary_stations_casual.csv")
write_csv(summary_station_member, "summary_stations_member.csv")

# View plots
print(plot_wd)
print(plot_month)
print(plot_tod)
print(station_map)