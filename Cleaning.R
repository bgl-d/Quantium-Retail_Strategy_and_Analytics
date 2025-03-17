library("dplyr")
library("psych")
library("ggplot2")
library("readxl")
library("readr")
library(data.table)

# Load data
filePath <- "/Users/di_bgl/Documents/PycharmProjects/Portfolio/Forage/quantium/Chip/"
customerDataPath <- "/Users/di_bgl/Documents/PycharmProjects/Portfolio/Forage/quantium/Chip/QVI_purchase_behaviour.csv"
transactionDataPath <- "/Users/di_bgl/Documents/PycharmProjects/Portfolio/Forage/quantium/Chip/QVI_transaction_data.xlsx"
customerData <- read.csv(customerDataPath)
transactionData <- read_xlsx(transactionDataPath)

# Transform data frames to data tables
setDT(transactionData)
setDT(customerData)

# Data examination
str(transactionData)
summary(transactionData)
str(customerData)
summary(transactionData)

# Check for issues in customer data
customerData[, .N, by = LIFESTAGE][order(-N)]
customerData[, .N, by = PREMIUM_CUSTOMER][order(N)]

# Transaaction date format fixing
transactionData$DATE <- as.Date(transactionData$DATE, origin="1899-12-30")
str(transactionData$DATE)

# Check for missing values
colSums(is.na(transactionData))
colSums(is.na(customerData))

# Parsing products names 
transactionData <- transactionData %>%
  mutate(PACK_SIZE = parse_number(PROD_NAME))
head(transactionData)

# Drop perfect duplicates
customerData[duplicated(customerData), ]
transactionData[duplicated(transactionData), ]
transactionData <- transactionData[!duplicated(transactionData), ]

# Extreme values
transactionData <- transactionData[transactionData$LYLTY_CARD_NBR != 226000, ]
ggplot(transactionData, aes(x=TOT_SALES, y=TXN_ID)) + geom_point()

# Parsing brand names
transactionData[, BRAND := toupper(substr(PROD_NAME, 1, regexpr(pattern = ' ', PROD_NAME) - 1))]
transactionData[, .N, by = BRAND][order(-N)]

# Fixing mistakes in chip brands
transactionData[BRAND == "RED", BRAND := "RRD"]
transactionData[BRAND == "SNBTS", BRAND := "SUNBITES"]
transactionData[BRAND == "INFZNS", BRAND := "INFUZIONS"]
transactionData[BRAND == "WW", BRAND := "WOOLWORTHS"]
transactionData[BRAND == "SMITH", BRAND := "SMITHS"]
transactionData[BRAND == "DORITO", BRAND := "DORITOS"]

transactionData[, .N, by = BRAND][order(BRAND)]

# Merging two tables
data <- merge(transactionData, customerData, all.x = TRUE)
sum(is.na(data))
class(data)

# Save cleaned data
fwrite(data, paste0(filePath,"QVI_data.csv"))
