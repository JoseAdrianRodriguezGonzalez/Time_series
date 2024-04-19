library(lubridate)
DATASET<-read.csv('./dataset/DATASET.CSV')
plotanydata<-function(dataframe){
    DATASET$DATE=format(as.POSIXct(DATASET$DATE,format="%d/%m/%Y %H:%M"))
    DATASET$date=as.Date(DATASET$DATE)
    DATASET$time=format(as.POSIXct(DATASET$DATE),format="%H:%M")
    h <- seconds(hm(DATASET$time))
    plot(h, DATASET$Temperature)
    plot(h, DATASET$Humidity)
}
plotanydata(DATASET)
