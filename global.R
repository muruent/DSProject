library(readr)
library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
library(maps)
library(knitr)
library(fiftystater)
library(testthat)
library(readr)
library(RColorBrewer)
library(dplyr)
library(plotly)
library(scales)
library(viridis)
library(assertive, warn.conflicts = FALSE)
gv = read_csv("gvdata13to18.csv")
#str(gv)
# Convert the inspection.date column from character to date format.
gv.df <- gv %>% mutate(date = as.Date(date, "%m/%d/%Y"))

# Extract the month from the inspection.date column.

sum(is.na(gv.df$latitude))

gv.df <- gv.df %>% mutate(month=as.numeric(format(date,"%m")), year=as.numeric(format(date, "%Y")))
write.csv(gv.df, file="gvclean.csv")

newDATA = gv.df[complete.cases(gv.df),]

d = newDATA[sample(nrow(newDATA), 50000),]


d$rdate = as.Date(d$date, "%m/%d/%Y")
#sort earliest to latest.  Important for time series functionality later
d=d[order(d$rdate),]

#create a normalized weight for sizing points on leaflet map in Rshiny
d['Total.victims'] = d$n_injured + d$n_killed
d$size = (d$Total.victims)

annual_staging = aggregate(d[,6:7],list(year=d$year),FUN=sum)
##in some years there were no shootings....we will imput zeros for these
year_vec=min(d$year):max(d$year)
#zero_years=year_vec[!(year_vec %in% d$year)]
#zero_rows=data.frame(year=zero_years, Fatalities=0L,Injured=0L,Total.victims=0L)
annual_d=annual_staging
#annual_d =annual_d[order(annual_d$year),]
#create cummulative sum for total n_Killed
annual_d$Total_Fatalities = cumsum(annual_d$n_killed)
#create moving average series for fatalities
ny = nrow(annual_d)
ma = numeric(ny)
ma[1]=mean(annual_d$n_killed[1:2])
for(i in 2:(ny-1)){
  temp_ind=c(i-1,i,i+1)
  ma[i] = mean(annual_d$n_killed[temp_ind])
}
ma[ny]=mean(annual_d$n_killed[c(ny-1,ny)])
annual_d$ma = ma
#create "end of year" series.  This will be useful for the slidebar functionality
annual_d$eoy = as.Date(paste0("12/31/",annual_d$year), "%m/%d/%Y")
#create time series object from annual_d for output to dygraph
annual_victims =xts(annual_d[,2:6],order.by= as.Date(as.character(annual_d$year),"%Y"))
indexFormat(annual_victims ) <- "%Y"

########################################
#save Data in list to be loaded in shiny app
DATA=list(d=d,annual_victims=annual_victims,annual_d=annual_d)
save(DATA,file="msdata.RData")

statelist = sort(unique(gv.df$state))

