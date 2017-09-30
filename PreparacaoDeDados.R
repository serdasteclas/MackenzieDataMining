source('installLibs.R')
source('Distancia.R')

# descompacta arquivos do dataset
unzip(zipfile = 'datasets/test.zip',exdir = 'datasets')
unzip(zipfile = 'datasets/train.zip',exdir = 'datasets')

test.original <- read_csv("datasets/test.csv")
train.original <- read_csv("datasets/train.csv")

#analisa hor�rios de pico
rush <- hour(train.original$pickup_datetime)
rush.hist <- hist(pickingHours,  breaks = 23, plot = FALSE)
rush.mean <- mean(rush.hist$counts) #media
rush.sd <- sd(rush.hist$counts) #desvio padr�o
hcol <- rep('orange',24) #padr�o laranja (transito moderado)
hcol[rush.hist$counts<rush.mean] <- 'green' #transito abaixo da m�dia
hcol[rush.hist$counts>rush.mean+rush.sd] <- 'red' #transito Intenso (media + desvio padr�o)
hist(rush,  breaks = 23, plot = TRUE, freq = TRUE,main = 'Histograma dos hor�rios (Rush)', xlab = 'Hora', ylab='Viagens', col = hcol)
abline(rush.mean,0, lty=2)
abline(rush.mean+rush.sd,0, col='red', lty=2)

cat('Calculando dist�ncias, limpando dados e classificando hor�rios de pico.\nEssa opera��o pode demorar alguns minutos')

train <- transmute(train.original, id, vendor_id, passenger_count, recording=store_and_fwd_flag=='Y',
       distance = distancia(pickup_latitude,pickup_longitude,dropoff_latitude, dropoff_longitude), 
       traffic=ifelse(is.na(pickup_datetime),rush.mean,rush.hist$counts[hour(pickup_datetime)]) , trip_duration)

test <- transmute(test.original, id, vendor_id, passenger_count, recording=store_and_fwd_flag=='Y',
                  distance = distancia(pickup_latitude,pickup_longitude,dropoff_latitude, dropoff_longitude), 
                  traffic=ifelse(is.na(pickup_datetime),rush.mean,rush.hist$counts[hour(pickup_datetime)]))