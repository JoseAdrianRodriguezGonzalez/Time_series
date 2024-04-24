#Librerias y paquetes

#attach(Arimar)
#names(Arimar)
#install.packages("tseries")
#install.packages("astsa")
#install.packages("foreign")
#install.packages("quantmod")
#install.packages("lubridate")
#install.packages("tidyverse")
#install.packages("forecast")


library(astsa)
library(tseries)
library(lubridate)
library(tidyverse)
library(forecast)
library(lubridate)


###### Graficas raficas por dias #####
DATASET<-read.csv('./dataset/DATASET.CSV')
DATASET1<-read.csv('./dataset/Dias/DATASET1.CSV')
DATASET2<-read.csv('./dataset/Dias/DATASET2.CSV')
DATASET3<-read.csv('./dataset/Dias/DATASET3.CSV')
DATASET4<-read.csv('./dataset/Dias/DATASET4.CSV')
DATASET5<-read.csv('./dataset/Dias/DATASET5.CSV')
plotanydata<-function(dataframe,titledata){
  dataframe$DATE=format(as.POSIXct(dataframe$DATE,format="%d/%m/%Y %H:%M"))
  dataframe$date=as.Date(dataframe$DATE)
  dataframe$time=format(as.POSIXct(dataframe$DATE),format="%H:%M")
  h <- seconds(hm(dataframe$time))
  plot(dataframe$Humidity,type = "l",lwd = 2, col = "red", xlab = "Iteraciones por 10 segundos", ylab = "Humedad")
  title(main=titledata)
  plot(dataframe$Temperature, type = "l",lwd = 2, col = "blue", xlab = "Iteraciones por 10 segundos", ylab = "Temperatura")
  title(main=titledata)
}
lookingForAnomalies<-function(dataframe){
  print("The maximum value from temperature and humidity are: ")
  print("Temperature")
  print(max(dataframe$Temperature))
  print("Humidity")
  print(max(dataframe$Humidity))
  print("The minimum value from temperature and humidity are: ")
  print("Temperature")
  print(min(dataframe$Temperature))
  print("Humidity")
  print(min(dataframe$Humidity))
  print("Existen nans en la temperatura")
  print(which(is.nan(dataframe$Temperature)))
  print("Existen nans en la humedad")
  print(which(is.nan(dataframe$Humidity)))
}
#first dataset fridaay-saturday
print("First dataset")
plotanydata(DATASET,"Friday-Saturday")
lookingForAnomalies(DATASET)
#Second dataset sunday-monday
print("second dataset")
plotanydata(DATASET1,"Sunday-Monday")
lookingForAnomalies(DATASET1)
#third dataset monday-tuesday
print("Third dataset")
plotanydata(DATASET2,"Monday-Tuesday")
lookingForAnomalies(DATASET2)
#fourth dataset tuesday-wednesday
print("Fourth dataset")
plotanydata(DATASET3,"Tuesday-wednesday")
lookingForAnomalies(DATASET3)
#FIFTH DATASET
print("Fifth dataset")
plotanydata(DATASET4,"Wednesday-Thursday")
lookingForAnomalies(DATASET4)
#sixTH DATASET
print("Sixth dataset")
plotanydata(DATASET5,"Thursday-Friday")
lookingForAnomalies(DATASET5)

#Funcion para detectectar si es una serie estacionaria y convertila a una

serieEstacionaria <- function(dataframe, day, hour, minute, second,textoa,textob,parametro) {
  baseDatos <- dataframe[[parametro]]
  serieDeTiempo <- ts(baseDatos, start = c(2024, 4, day, hour, minute, second), frequency = 10)
  varAux <- adf.test(serieDeTiempo)
  print(varAux)
  if(varAux$p.value > 0.05) {
    serieDeTiempo <- log(serieDeTiempo)
    plot(serieDeTiempo,main = textoa)
    varAux <- adf.test(serieDeTiempo)
    print(varAux)
    if(varAux$p.value > 0.05){
      serieDeTiempo <- diff(serieDeTiempo)
      plot(serieDeTiempo,main = textob)
      varAux <- adf.test(serieDeTiempo)
      print(varAux)
    }
    }
  return(serieDeTiempo)
}

#Graficas par
graficasPar <- function(estacionariedad, textoA, dataframe, parametro, day, hour, minute, second){
  par(mfrow=c(2,1), mar=c(4,4,4,1)+.1)
  acf(estacionariedad, main = paste("ACF de", textoA))
  pacf(estacionariedad, main = paste("PACF de", textoA))
  acf_val <- acf(ts(estacionariedad, frequency = 1), plot = FALSE)
  pacf_val <- pacf(ts(estacionariedad, frequency = 1), plot = FALSE)
  plot(acf_val, main = paste("ACF de", textoA))
  plot(pacf_val, main = paste("PACF de", textoA))
  mtext(textoA, side = 3, line = 1, outer = TRUE)
  
  #MA y AR
  baseDatos <- dataframe[[parametro]]
  serieDeTiempo <- ts(baseDatos, start = c(2024, 4, day, hour, minute, second), frequency = 10)
  modelo1 = arima(dataframe[[parametro]], order = c(1,1,1))
  print(modelo1)
  tsdiag(modelo1)
  Box.test(residuals(modelo1), type = "Ljung-Box")
  error=residuals(modelo1)
  plot(error, main = paste("Gráfica de error de:", parametro, " de ", deparse(substitute(dataframe))))
  
  #Pronostico
  pronostico = forecast::forecast(modelo1, h=8640)
  print(pronostico)
  plot(pronostico)
}

pdf(file='plot.pdf')

#comprobar si la temperatura son series estacionarias
resultadoPrueba1 <- serieEstacionaria(DATASET1, 14, 19, 10, 40, "Log Sunday-Monday", "Diff Sunday-Monday", "Temperature")
resultadoPrueba2 <- serieEstacionaria(DATASET2, 15, 19, 28, 20, "Log Monday-Tuesday", "Diff Monday-Tuesday", "Temperature")
resultadoPrueba3 <- serieEstacionaria(DATASET3, 16, 19, 43, 20, "Log Tuesday-Wednesday", "Diff Tuesday-Wednesday", "Temperature")
resultadoPrueba4 <- serieEstacionaria(DATASET4, 17, 20, 22, 50, "Log Wednesday-Thursday", "Diff Wednesday-Thursday", "Temperature")
resultadoPrueba5 <- serieEstacionaria(DATASET5, 17, 20, 41, 20, "Log Thursday-Friday", "Diff Thursday-Friday", "Temperature")

print(resultadoPrueba1)
print(resultadoPrueba2)
print(resultadoPrueba3)
print(resultadoPrueba4)
print(resultadoPrueba5)

graficasPar(resultadoPrueba1,"Sunday-Monday Temperature",DATASET1,"Temperature", 14, 19, 10, 40)
graficasPar(resultadoPrueba2,"Monday-Tuesday Temperature",DATASET2,"Temperature", 15, 19, 28, 20)
graficasPar(resultadoPrueba3,"Tuesday-Wednesday Temperature",DATASET3,"Temperature", 16, 19, 43, 20)
graficasPar(resultadoPrueba4,"Wednesday-Thursday Temperature",DATASET4,"Temperature", 17, 20, 22, 50)
graficasPar(resultadoPrueba5,"Thursday-Friday Temperature",DATASET5,"Temperature", 17, 20, 41, 20)

#Comprobar si los resultados de la uhmedad son estacionarios o no

resultadoPrueba1 <- serieEstacionaria(DATASET1, 14, 19, 10, 40, "Log Sunday-Monday", "Diff Sunday-Monday", "Humidity")
resultadoPrueba2 <- serieEstacionaria(DATASET2, 15, 19, 28, 20, "Log Monday-Tuesday", "Diff Monday-Tuesday", "Humidity")
resultadoPrueba3 <- serieEstacionaria(DATASET3, 16, 19, 43, 20, "Log Tuesday-Wednesday", "Diff Tuesday-Wednesday", "Humidity")
resultadoPrueba4 <- serieEstacionaria(DATASET4, 17, 20, 22, 50, "Log Wednesday-Thursday", "Diff Wednesday-Thursday", "Humidity")
resultadoPrueba5 <- serieEstacionaria(DATASET5, 17, 20, 41, 20, "Log Thursday-Friday", "Diff Thursday-Friday", "Humidity")

#Graficar la humedad
graficasPar(resultadoPrueba1,"Sunday-Monday Humidity",DATASET1,"Humidity", 14, 19, 10, 40)
graficasPar(resultadoPrueba2,"Monday-Tuesday Humidity",DATASET2,"Humidity", 15, 19, 28, 20)
graficasPar(resultadoPrueba3,"Tuesday-Wednesday Humidity",DATASET3,"Humidity", 16, 19, 43, 20)
graficasPar(resultadoPrueba4,"Wednesday-Thursday Humidity",DATASET4,"Humidity", 17, 20, 22, 50)
graficasPar(resultadoPrueba5,"Thursday-Friday Humidity",DATASET5,"Humidity", 17, 20, 41, 20)
dev.off()