```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, eval = FALSE)
library(tidyverse)
library(dplyr)
```

## Cyclistic Case Study - Google Data Analytics Capstone
*by Gabriel Dimayacyac*

### Background & Challenge

Cyclistic is a company based in Chicago that has provided bike-share services in the city since 2016. The director of marketing believes that the success of the company depends on maximizing the number of annual memberships. Financial analysts at the company have concluded that annual members are more profitable than casual members, so there is a push to convert casual members to annual members rather than target all-new customers.

### Scenario

As a hypothetical junior data analyst at the company, I am tasked with with identifying trends in the bike-share data to determine: 1. How casual riders and Cyclistic (annual) members use the bikes differently 2. Why casual riders would want to convert to annual memberships? 3. How Cyclistic can use digital media to influence conversion of casual riders to Cyclistic (annual) members?

The main task for this case study is to answer the first question, which is to conclude as to how annual members and casual riders differ in their use of Cyclistic bikes. Through answering this question, the marketing team can better understand how to answer the second question, which asks about the reasons that casual riders would convert to annual members. Conclusions made with these questions will help the marketing team strategize to meet Cyclistic’s goals of converting casual riders to annual members.

### Business Task

Analyze historical ridership data to identify trends in how annual members and casual members use Cyclistic differently.

The stakeholders on the team include:

-   Lily Moreno – director of Marketing and direct report of the analyst.

-   Cyclistic Marketing Analytics Team – data analysts that collect, analyze and report data that guide marketing strategy at the company.

-   Cyclistic Executive Team – Detail-oriented executive team that will decide whether to approve recommended marketing program.

### Data Preparation

As Cyclistic is a fictional company, the data for this case study has been taken from Divvy and the City of Chicago, which can be found [here](https://divvy-tripdata.s3.amazonaws.com/index.html): .

The data has been made available by Motivate International Inc, under this [license](https://divvybikes.com/data-license-agreement):

The data is in a structured format, where each file corresponds to a different month of the year. Each ride corresponds to a row on the table, and the following information is provided per ride:

-   ride_id
-   rideable_type
-   started_at
-   ended_at
-   start_station_name
-   start_station_id
-   end_station_name
-   end_station_id
-   start_lat
-   start_lng
-   end_lat
-   end_lng
-   member_casual

According to the standards used under Google's Data Analysis Career Certificate, data integrity is assessed using the acronym, ROCCC...

| **ROCCC** | **Criterion** | **Cyclistic Assessment**                                                                                                                               |
|---------------|---------------|-----------------------------------------|
| R         | Reliable      | The data provided is unbiased and is accessible by the public.                                                                                         |
| O         | Original      | The data provided is original and collected by the City of Chicago itself.                                                                             |
| C         | Comprehensive | The schema of the data provided gives a clear picture of the trends that will help in understanding the differences between annual and casual members. |
| C         | Current       | The data provided was collected from the past year, between November 2022 to October 2023.                                                             |
| C         | Cited         | The data provided is publicly made available by Divvy and the city of Chicago                                                                          |

### Data Processing

Excel was utilized to process and ensure consistency throughout the data. As the data was divided into different data sets based on month, a simple procedure could be performed on each dataset to prepare the data for analysis.Before this procedure was performed, however, the original .csv datasets were duplicated just in case any errors occurred during data processing. The original .csv files, before any data was manipulated, can be found [here](<https://drive.google.com/drive/folders/11672Bxyp6PUyaW7QC7ikX29n-IbzCihP?usp=sharing>). After successful duplication of the data, the following procedure was performed for data processing:

**1. Change “started_at” and “ended_at” columns to proper DATETIME format**

-   Format \> Cells \> Custom \> yyyy-mm-dd h:mm:ss

**2. Create ride_duration**

-   = 86400\*(D2 – C2)
-   Format \> Cells \> Custom \> Number

**3. Created ride_date**

-   DATE(Year(C2),Month(C2),Day(C2))
-   Format \> Cells \> Date \> Short Date

**4. Created ride_year**

-   = Year(C2)

**5. Created ride_month**

-   = Month(C2)
-   Format \> Cells \> Number

**6. Created start_time**

-   = TIME(Hour(C2),minute(C2),second(C2))
-   Format \> Cells \> Time \> hh:mm:ss

**7. Created end_time** + = TIME(hour(C2),minute(C2),second(C2)) + Format \> Cells \> Time \> hh:mm:ss

**8. Created day_of_week**

-   = WEEKDAY(C2,1)
-   Return type [1] means Monday is 1, Sunday is 7
-   Format \> Cells \> Time \> Number (0 decimals)

**9. Repeat for each tripdata .csv file**

To sum it up, after each data set was processed on Excel, each data set had the following new columns:

-   ride_duration (seconds)
-   ride_date
-   ride_year
-   ride_month
-   start_time
-   end_time
-   day_of_week

The data, after manipulation on Excel, can be found [here](<https://drive.google.com/drive/folders/1pbiFv0hNqH2aZv8wOO6uMfWCbY9tzcuk?usp=sharing>). From here, the data was ready to be further processed and analyzed on R.

### Further Data Processing and Analysis

At this point, the clean trip data is consolidated as separate .csv files in a directory, such as /TripData. A .R file is created, where the working directory should be set to /TripData, in order for the .csv files to be pulled by the code.

The following packages were installed and loaded:

```{r packages}
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
```

With these packages downloaded and applied, the .csv files from the /TripData folder can be read and imported.

```{r read_files, eval=FALSE}
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
```

After files have been combined into a single, comprehensive dataset, the following code can be used to check for duplicates, filter for any rides that have invalid values and place the clean data into a new dataframe:

```{r filter_yeardata, , eval=FALSE}
yeardata <- rawyeardata %>% 
  filter(ride_duration>0) %>% 
  clean_names() %>% 
  unique()
```

From here, analysis can be conducted on the data. For example, simple aggregates of the data, such as ride_duration, can be analyzed to determine certain traits about the data, such as mean, min, max, etc.

```{r aggregate, eval=FALSE}
# Summarize ride_duration column to ensure proper data type
summary(yeardata$ride_duration)

# Compare ride data for members and casual users
aggregate(yeardata$ride_duration ~ yeardata$member_casual, FUN = mean)
aggregate(yeardata$ride_duration ~ yeardata$member_casual, FUN = median)
aggregate(yeardata$ride_duration ~ yeardata$member_casual, FUN = max)
aggregate(yeardata$ride_duration ~ yeardata$member_casual, FUN = min)
```

From here, the goal for analysis was to determine:

1.  How did rides vary between casual members and regulars depending on day of the week?
2.  How did rides vary between casual members and regulars depending on the month?
3.  How did rides vary between casual members and regulars depending on the time of day?
4.  Where are the stations that have the most demand for Cyclistic bike share?

To tackle the first question, the data had to be summarized with according to membership status and day of the week. Please see the code below:

```{r summary_wd}
summary_wd <- yeardata %>% 
  group_by(member_casual, day_of_week) %>%  
  summarise(number_of_rides = n(),
            average_duration = mean(ride_duration)) %>%    
  arrange(member_casual, day_of_week) %>% 
  mutate(week_day=wday(day_of_week,label=TRUE))

view(summary_wd)
```

```{r summary_wd_view, echo=FALSE, eval=TRUE}
summary_wd <- read.csv("summary_ride_length_weekday.csv")
view(summary_wd)
```

The summary table can be plotted as a visual:

```{r plot_wd}
plot_wd <- ggplot(summary_wd, aes(x = week_day, fill = member_casual)) +
  geom_col(aes(y = number_of_rides), position = position_dodge(width = 0.8), 
           color = "black") +
  geom_col(aes(y = average_duration), position = position_dodge(width = 0.8), 
           color = "black") +
  labs(title = "Number of Rides and Average Duration by Rider Type and Day of the Week",
       x = "Day of the Week", y = "Count") +
  scale_fill_manual(values = c("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3"))

print(plot_wd)
```

The same can be done for:

*Per-Month Basis*

```{r summary_month}
summary_month <- yeardata %>% 
  group_by(ride_month,member_casual) %>%  
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_duration)) %>%    
  arrange(ride_month, member_casual) %>% 
  mutate(month = month(ride_month,label=TRUE)) %>% 
  subset(select=-ride_month)

View(summary_month)
```

```{r plot_month}
plot_month <- ggplot(summary_month, aes(x = month, fill = member_casual)) +
  geom_col(aes(y = number_of_rides), position = position_dodge(width = 0.5), 
           color = "black") +
  geom_col(aes(y = average_duration), position = position_dodge(width = 0.5), 
           color = "black") +
  labs(title = "Number of Rides and Average Duration by Rider Type and Month",
       x = "Month", y = "Count") +
  scale_fill_manual(values = c("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3"))

print(plot_month)
```

*Time of Day Basis*

```{r summary_tod}
summary_tod <- yeardata %>% 
  mutate(start_time = as.POSIXct(start_time, format = "%H"), hour = hour(start_time)) %>%
  group_by(hour) %>%
  summarise(number_of_rides = n(),
            average_duration = mean(ride_duration)) %>% 
  arrange(hour) %>% 
  mutate(hour = sprintf("%02d:00", hour))

view(summary_tod)
```

```{r plot_tod}
plot_tod <- ggplot(summary_tod, aes(x = hour), axis.text.x=element_text(size=1)) +
  geom_col(aes(y = number_of_rides), fill = "#66c2a5") +
  labs(title = "Number of Rides by Hour of the Day",
       x = "Hour of the Day",
       y = "Number of Rides") + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(plot_tod)
```

Lastly a summary table can be established for each of the Cyclistic stations in the Chicago city area. The table is ordered by the most popular stations.

```{r summary_station}
summary_station <- yeardata %>% 
  mutate(station = start_station_name) %>%
  drop_na(start_station_name) %>% 
  group_by(station, member_casual) %>% 
  summarise(latitude = mean(start_lat),
            longitude = mean(start_lng),
            number_of_rides = n()) %>%    
  arrange(desc(number_of_rides)) %>% 
  filter(number_of_rides > 10, station != "") %>% # filter for number of    rides greater than 10
view(summary_station)
```

A map (using the Leaflet package) can be created using the summary_station data. You can find the link to the leaflet package (here){}

```{r station_map}
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

print(station_map)
```

### Conclusions and Recommendations for Cyclistic

*Observations* 

After analyzing the ride data from 2022-2023, we have a clearer picture on how to address the following questions:

1.  How do annual members and casual riders use Cyclistic bikes differently?
2.  Why would casual riders buy Cyclistic annual memberships?
3.  How can Cyclistic use digital media to influence casual riders to become members?

There are clear trends that we see in the data from the past year. Let's take a look at the figures to determine some trends in the data.

![summary_plot_wd](/summary_plot_wd.png)

If we take a look at the data based on days of the week, we see that the most rides for members occur between Monday to Friday. As for casual riders, we see the majority of rides occurring during the weekend. In addition to this, it is apparent from the following table that casual riders tend to use the bikes for longer durations of time than members:

| member_casual |number_of_rides | average_duration_sec | week_day |
|--------------|--------------|-----------------|--------------|
| casual        | 332102          | 1997   | Sun      |
| casual        | 233786          | 1664   | Mon      |
| casual        | 251698          | 1494   | Tue      |
| casual        | 251547          | 1460   | Wed      |
| casual        | 270811          | 1504    | Thu      |
| casual        | 310988          | 1654   | Fri      |
| casual        | 401967          | 1942   | Sat      |
| member        | 397940          | 835    | Sun      |
| member        | 486724          | 711    | Mon      |
| member        | 582163          | 720    | Tue      |
| member        | 577674          | 715    | Wed      |
| member        | 575679          | 720    | Thu      |
| member        | 518038          | 751    | Fri      |
| member        | 456076          | 833    | Sat      |

It can be concluded that casual riders tend to ride more often on the weekends for longer periods of time, and members tend to ride more during the weekdays for shorter periods of time. If the assumption can be made that most people work between Monday to Friday, we can also assume that members possibly use bicycles for their daily commute. Let's look at the data based on time of day to see when in the day members tend to use Cyclistic bikes the most.

![summary_plot_tod](/summary_plot_tod.png)

The figure shows that the most rides occur between 8 am to 8pm, with the first spike in rides occurring around 7-8 am and the number of rides peaking right around 5 pm. These times of the day generally coincide with work day rush hour times, so we can tentatively conclude that members are likely to be using Cyclistic bikes for their daily commute to work.

![summary_plot_month](/summary_plot_month.png)

A closer look at the performance of Cyclistic bikes throughout the year shows particularly strong demand between the months of May to October for 2022 to 2023. This is, of course, a metric that should be measured year after year to ensure certainty of the summer months being higher demand, but the results are consistent with our general knowledge of consumer preferences. Weather can greatly affect the demand of Cyclistic bikes. It may be worth exploring how to maintain demand of our service over the non-summer months.

*Recommendations*

From analysis of the data, the following actions are recommended as next steps:

*1. Create advertisements to promote bicycles for everyday commuting*

If the goal of the Cyclistic marketing team is to determine how to convert casual riders to members, it can be concluded from the data that most members generally use the bikes to commute to and from work. If more casual riders are exposed to using the bikes in this manner, Cyclistic could have a higher conversion of casual riders to members over the following year.

Research should be conducted into the pros and cons of commuting via bike as opposed to other modes of transportation. This can help with creating digital marketing material to encourage conversion of casual riders. Placing these advertisements at hotspots where casual riders generally start their rides could be strategic in improving the conversion rate. The most popular stations are shown below:

| station                               | member_casual | latitude           | longitude          | number_of_rides |
|--------------|--------------|--------------|-----------------|--------------|
| Streeter Dr & Grand Ave               | casual        | 41.892277654572105 | -87.61206966705109 | 46156           |
| DuSable Lake Shore Dr & Monroe St     | casual        | 41.88098505017817  | -87.61676695074928 | 30309           |
| Michigan Ave & Oak St                 | casual        | 41.90096583310227  | -87.62376370810604 | 22519           |
| DuSable Lake Shore Dr & North Blvd    | casual        | 41.911724571052346 | -87.62681749807803 | 20250           |
| Millennium Park                       | casual        | 41.88107125714321  | -87.62409548210196 | 20243           |
| Shedd Aquarium                        | casual        | 41.867232171100476 | -87.61541745355305 | 17765           |
| Theater on the Lake                   | casual        | 41.92623791787845  | -87.63088415990748 | 16323           |
| Dusable Harbor                        | casual        | 41.88697103347725  | -87.6128249672318  | 15147           |
| Wells St & Concord Ln                 | casual        | 41.9120858054155   | -87.63473702493924 | 12178           |
| Montrose Harbor                       | casual        | 41.963961775912374 | -87.638199876766   | 11914           |
| Adler Planetarium                     | casual        | 41.8661052473746   | -87.60728781733829 | 11842           |
| Indiana Ave & Roosevelt Rd            | casual        | 41.86791526142343  | -87.62304034435093 | 11655           |
| Clark St & Armitage Ave               | casual        | 41.91829297154982  | -87.63631076643206 | 11040           |
| Michigan Ave & 8th St                 | casual        | 41.872706968321644 | -87.62399283394353 | 10838           |
| Clark St & Lincoln Ave                | casual        | 41.915706450250234 | -87.63460852240074 | 10830           |
| Clark St & Elm St                     | casual        | 41.902887843574405 | -87.63142506824799 | 10799           |
| Wilton Ave & Belmont Ave              | casual        | 41.94014579242387  | -87.65297120269435 | 10574           |
| Wells St & Elm St                     | casual        | 41.90315905149631  | -87.63444607355272 | 9891            |
| Wabash Ave & Grand Ave                | casual        | 41.89144540779151  | -87.6267583510629  | 9794            |
| Clark St & Newport St                 | casual        | 41.944523918371644 | -87.65471552574903 | 9746            |
| Broadway & Barry Ave                  | casual        | 41.93760927423465  | -87.64409862366365 | 9597            |
| Michigan Ave & Washington St          | casual        | 41.8839704974753   | -87.62458039504295 | 9312            |
| DuSable Lake Shore Dr & Diversey Pkwy | casual        | 41.93257593979363  | -87.63642667373095 | 9255            |
| New St & Illinois St                  | casual        | 41.89080966975599  | -87.61854335927451 | 9180            |
| DuSable Lake Shore Dr & Belmont Ave   | casual        | 41.940761721863545 | -87.63918731815411 | 9058            |
| LaSalle St & Illinois St              | casual        | 41.89078214470238  | -87.63169389212038 | 9055            |
| McClurg Ct & Ohio St                  | casual        | 41.892601752000004 | -87.61729865133937 | 8840            |

For a visualization of the popular Cyclistic hotspots around Chicago, please see the heatmap below:

[City of Chicago Heatmap](https://jaygdimayacyac.github.io/Cyclistic-Case-Study/summary_plot_station_map.html)

*2. Survey customers to gather satisfaction data and potential suggestions*

It can be tentatively concluded from the data that members generally use Cyclistic to commute to work. Through conducting a survey, this tentative conclusion can be confirmed. In addition to this, a survey will help the marketing team understand how often people use the service and what suggestions they have to further improve the service. The surveys can generally confirm most of the tentative conclusions developed in this study.

*3. Research methods of increasing demand during the non-summer months* As the summer months exhibited the most demand over the past year, it can be tentatively concluded that the demand over non-summer months is generally much lower. Research should be conducted into how to enhance the demand during non-summer months. Questions can even be asked during customer surveying to gain a perspective of why customers may choose not to use Cyclistic bikes during the non-summer months. This feedback can point the company towards pinpointing and directly tackling the biggest hurdles that inhibit demand.
