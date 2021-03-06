rm(list=ls())
#Loading the required libraries and data
library(ggplot2)
library(forecast)
library(tseries)
library(stats)
?gas
plot(gas,xlab="Years",ylab="Cubic feet",main="Gas production in Austrailia from 1956/01-1995/08")

#Descriptive analysis
class(gas)
start(gas)
end(gas)
frequency(gas)
summary(gas)
cycle(gas)
gas.qr=aggregate(gas,nfrequency=4)
plot(gas.qr,main="Gas Production by quarter",xlab="quarter",ylab="Cubic feet")
library(graphics)
gas.yr=aggregate(gas,nfrequency = 1)
plot(gas.yr,main="Gas Production by year",xlab="year",ylab="Cubic feet")

boxplot(gas~cycle(gas),ylab="Cubic feet",xlab="Month",col="red",pch=19,main="Monthly gas production in Australia")
###seasonplot
seasonplot(gas, year.labels = TRUE, year.labels.left=TRUE, col=1:10,pch=19, main = "Monthly gas Production in Australia - seasonplot", xlab = "Month", ylab = "Cubic feet")

####Monthly plot
monthplot(gas, col=1:5,pch=19, main = "Monthly gas Production in Australia - seasonplot",xlab = "Month", ylab = "Cubic feet")

#Deocmposing the data to check the individual components which clearly shows multiplicative seasonality and trend has the most prominent impact on the time series.

decomp_gas=decompose(gas,type="additive")
plot(decomp_gas)

decomp_gas=decompose(gas,type="multiplicative")
plot(decomp_gas)

dd=stl(gas,s.window="p")
plot(dd,main="Decomposition using periodic window")

#Adjusting Seasonality componenet and plotting it against actual data
deseasonal_gas=seasadj(decomp_gas)
plot(deseasonal_gas)

ts.plot(deseasonal_gas,gas,col=c("red","blue"),xlab="Years",ylab="Cubic feet",main="Actual vs De Seasoned")

#Checking for stationarity by using Augmented Dickey-Fuller
#H0= Not Stationary
#HA= Is Stationary
adf.test(gas, alternative = "stationary")

#Building arima model manually by checking for Auto-correlation and 
#Partial auto-correlation leaving out the first 44 years.
acf(gas)
acf(gas,lag.max = 50)
pacf(gas,lag.max = 50)

###Differencing to stationarize
count_d1 = diff(deseasonal_gas,differences = 1)
plot(count_d1)
adf.test(count_d1, alternative = "stationary")

acf(count_d1,lag=50,main="ACF for the differenced series")
pacf(count_d1,lag=50)

#arima(3,1,1)

gasTStrain = window(deseasonal_gas, start=c(1970,1), end=c(1990,12),frequency=12)
gasTStest= window(deseasonal_gas, start=c(1991,1),end=c(1995,8),frequency=12)
plot(gasTStest)

plot(gasTStrain)
plot(gasTStest)
start(gasTStrain)
end(gasTStrain)
start(gasTStest)
end(gasTStest)
gasARIMA = arima(gasTStrain, order=c(3,1,1))
gasARIMA
tsdisplay(residuals(gasARIMA), lag.max=10, main='Model Residuals')

library(stats)
Box.test(gasARIMA$residuals,type="Ljung")
hist(gasARIMA$residuals,col="blue",main="Histogram of Residuals",xlab="gasArima")

#Building an auto arima model
fit<-auto.arima(gasTStrain, seasonal=F)
fit
tsdisplay(residuals(fit), lag.max=10, main='Auto ARIMA Model Residuals')
Box.test(fit$residuals,type="Ljung")
hist(fit$residuals,col="blue",main="Histgram of Residuals",xlab="Auto Arima")

#Validate both the manul and automatically fitted ARIMA models
fcast <- forecast(gasARIMA, h=56)
fcast1 <- forecast(fit, h=56)
plot(fcast,gasTStest)
plot(fcast1)

ts.plot(gasTStrain,fcast$fitted,col=c("red","blue"),ylab="Cubic feet",xlab="Year",main="Arima Fitted values on Train")
ts.plot(gasTStrain,fcast1$fitted,col=c("red","blue"),ylab="Cubic feet",xlab="Year",main="Auto-arima Fitted values on Train")


autoplot(fcast)
fcast$mean
autoplot(fcast1)

#Accuracy of the forecast. Manual ARIMA
f7=forecast(gasARIMA,h=56)
accuracy(f7, gasTStest)
plot(f7,gasTStest)

#Accuracy of auto arima model
f8=forecast(fit,h=56)
accuracy(f8, gasTStest)
plot(fcast1,gasTStest)

#Forecast into the future seasonality false 
fit1<-auto.arima(deseasonal_gas,seasonal=F)
fit1
fcast2=forecast(fit1, h=12)
plot(fcast2)
fcast2
autoplot(fcast2)

#Forecast into the future seasonality true
fit1<-auto.arima(gas,seasonal=T)
fit1
fcast2=forecast(fit1, h=12)
plot(fcast2)
fcast2
autoplot(fcast2)
