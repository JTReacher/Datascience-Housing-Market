#Install the necessary packages
install.packages("DBI")
install.packages("RSQLite")

#Load libraries
library(DBI)
library(RSQLite)

#Set working directory and store database connection as a variable
#The working directory must be set to the PATH where the database file has been stored, in my case as below.
setwd("C:/Users/johnr/OneDrive/Data Science Coursework/Project")
databaseConnection <-
  dbConnect(SQLite(), "DataScienceProjectDB.db3")

#3. For a given ward in a particular district (e.g., City of Oxford, Cherwell, etc.) find the average prices of houses in a particular year such as 2018, 2019, etc.
Cherwell2018PriceAverage <-
  dbGetQuery(
    databaseConnection,
    "SELECT ROUND(AVG(price_paid_GBP), 2)FROM houseprices INNER JOIN wards ON houseprices.ward_key=wards.ward_key INNER JOIN districts ON wards.district_key=districts.district_key WHERE transaction_date LIKE '%2018%' AND districts.district_key=1;"
  )

#4. For a given ward in a particular district find the average increase in prices (in percent) between two years, for example, 2017 and 2018.

Ward88_2017_18_Change <- dbGetQuery(
  databaseConnection,
  "SELECT
ROUND((((SELECT AVG(price_paid_GBP) AS average_price_2018 FROM houseprices WHERE transaction_date LIKE '%2018%' AND ward_key=88)
- (SELECT AVG(price_paid_GBP) AS average_price_2017 FROM houseprices WHERE transaction_date LIKE '%2017%' AND ward_key=88))
/ (SELECT AVG(price_paid_GBP) AS average_price_2017 FROM houseprices WHERE transaction_date LIKE '%2017%' AND ward_key=88)) * 100, 2)
AS percentage_change;"
)

#5. Considering all districts (in Oxfordshire), find a ward which has the highest house price in a particular (quarter of a) year, for example, Mar 2019 or Dec 2019.


maxPurchasePriceQ12019 <-
  dbGetQuery(
    databaseConnection,
    "SELECT MAX(price_paid_GBP), transaction_key, wards.ward_name, transaction_date FROM houseprices INNER JOIN wards ON houseprices.ward_key=wards.ward_key WHERE transaction_date >= '2019-01-00' AND transaction_date < '2019-04-01';"
  )

#Transaction included given high value
#http://landregistry.data.gov.uk/data/ppi/transaction/8CAC1319-1359-0253-E053-6B04A8C08E51/current

#6. Considering all districts (in Oxfordshire), find a ward which has the lowest house price in a particular (quarter of a) year, for example, Dec 2018 or Jun 2019.

minPurchasePriceQ22017 <-
  dbGetQuery(
    databaseConnection,
    "SELECT MIN(price_paid_GBP), transaction_key, wards.ward_name, transaction_date FROM houseprices INNER JOIN wards ON houseprices.ward_key=wards.ward_key WHERE transaction_date >= '2017-04-00' AND transaction_date < '2017-07-01';"
  )

#7. Based on the data source (you use), find a broadband speed (average downland), or (superfast) broadband availability (%), in a particular ward (or a postcode) of a district.

banburyCrossNeithropDLSpeeds <-
  dbGetQuery(
    databaseConnection,
    "SELECT average_download_speed_Mbs, broadband.ward_key, wards.ward_name, districts.district_name FROM broadband INNER JOIN wards ON broadband.ward_key=wards.ward_key INNER JOIN districts ON wards.district_key=districts.district_key WHERE broadband.ward_key=3;"
  )

#8. Design a query of your choice using the broadband data. The query should retrieve certain data from the database, which you think, can be useful to a user. How many wards in Oxfordshire have high speed internet across the whole ward? i.e. 100% high speed internet

highSpeedWardsCount <-
  dbGetQuery(
    databaseConnection,
    "SELECT COUNT() FROM broadband WHERE broadband.SFBB_or_UFBB_availability_above30Mbs =
      1.0
    "
  )


