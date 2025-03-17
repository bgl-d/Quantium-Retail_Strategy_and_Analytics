library("dplyr")
library("psych")
library("ggplot2")
library("readxl")
library("readr")
library(data.table)

filePath <- "/Users/di_bgl/Documents/PycharmProjects/Portfolio/Forage/quantium/Chip/"
data <- fread(paste0(filePath,"QVI_data.csv"))

              