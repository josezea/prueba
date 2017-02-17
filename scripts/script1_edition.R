
#--- Loading packages ---#
library(RSocrata)
library(RJSONIO)
library(forcats)
library(scales)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(cowplot)
library(devtools)
library(stringi)
library(pander)
library(lubridate)
#--- Extracting information of "Datos abiertos" portal ---#
url <- "https://www.datos.gov.co"
list_OD <- ls.socrata(url) # Dataframe with Metadata "Datos Abiertos"
names_datasets <- paste0(gsub("https://www.datos.gov.co/api/views/", "", list_OD$identifier))


#---- Revisar si todos tienen el miemo tamaño ----#
#metada_OD <-fromJSON("https://www.datos.gov.co/api/views/67ih-hqxi")

#numcols_metada <- NA
#for(i in 1:nrow(list_OD)){
#numcols_metada[i] <- length(fromJSON(list_OD$identifier[i]))
#}
#max(numcols_metada) # 45 es el máximo
#table(numcols_metada)

#sum(names(fromJSON(list_OD$identifier[1652])) %in% names(fromJSON(list_OD$identifier[1788])))
#1788 1667  1652 (45)
#sum(names(fromJSON(list_OD$identifier[1788])) %in% names(fromJSON(list_OD$identifier[1652])))

#--- Get a dataframe of metadadata of Datos Abiertos Colombia ---#
metadata_OD <- bind_rows(data.frame(t(as.matrix(fromJSON(list_OD$identifier[1])))),
                         data.frame(t(as.matrix(fromJSON(list_OD$identifier[2])))))

for(i in 3:nrow(list_OD)){
  metadata_OD <- bind_rows(metadata_OD,
                           data.frame(t(as.matrix(fromJSON(list_OD$identifier[i])))))
}

metadata_OD <- as.data.frame(metadata_OD)

for(i in 1:ncol(metadata_OD)){
  metadata_OD[,i] <- as.character(metadata_OD[,i])
}

#--- Tidy format of some variables ---#

metadata_OD$averageRating <- as.numeric(metadata_OD$averageRating)
metadata_OD$downloadCount <- as.numeric(metadata_OD$downloadCount)
metadata_OD$numberOfComments <- as.numeric(metadata_OD$numberOfComments)
metadata_OD$viewCount <- as.numeric(metadata_OD$viewCount)


metadata_OD$createdAt <- as.Date(as.POSIXct(as.numeric(metadata_OD$createdAt), origin="1970-01-01"))
metadata_OD$indexUpdatedAt <- as.Date(as.POSIXct(as.numeric(metadata_OD$indexUpdatedAt), origin="1970-01-01"))
metadata_OD$publicationAppendEnabled <- as.Date(as.POSIXct(as.numeric(metadata_OD$publicationAppendEnabled), origin="1970-01-01"))
metadata_OD$viewLastModified <- as.Date(as.POSIXct(as.numeric(metadata_OD$viewLastModified), origin="1970-01-01"))

metadata_OD$hideFromCatalog <- as.logical(metadata_OD$hideFromCatalog)
metadata_OD$newBackend <- as.logical(metadata_OD$newBackend)
metadata_OD$hideFromDataJson <- as.logical(metadata_OD$hideFromDataJson)
metadata_OD$owner <- as.logical(metadata_OD$owner)
metadata_OD$tableAuthor <- as.logical(metadata_OD$tableAuthor)

#--- Fix some names ---#
metadata_OD$name <- iconv(metadata_OD$name, from="UTF-8", to="LATIN1") 
metadata_OD$attribution <- iconv(metadata_OD$attribution, from="UTF-8", to="LATIN1") 
metadata_OD$category <- iconv(metadata_OD$category, from="UTF-8", to="LATIN1") 
metadata_OD$description <- iconv(metadata_OD$description, from="UTF-8", to="LATIN1") 
metadata_OD$columns <- iconv(metadata_OD$columns, from="UTF-8", to="LATIN1") 
metadata_OD$metadata <- iconv(metadata_OD$metadata, from="UTF-8", to="LATIN1") 
metadata_OD$tags <- iconv(metadata_OD$tags, from="UTF-8", to="LATIN1")

metadata_OD$name <- toupper(metadata_OD$name)
metadata_OD$attribution <-  toupper(metadata_OD$attribution)


#--- Import metadata dataset #
setwd("datasets/metadata")
saveRDS(metadata_OD, "metadata_OD.rds")
