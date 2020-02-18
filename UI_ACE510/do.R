rm(list = ls())
library(dplyr)
library(raster)
library(data.table)

fips <- 17019 # Champaign county, IL. 
year_sel <- 2017

# Create URL for downloading data in year_sel (might not work)
url1 <- paste0('https://nassgeodata.gmu.edu/webservice/nass_data_cache/byfips/CDL_', year_sel, '_', fips, '.tif')
destfile1 <- paste0('./CDL_', year_sel, '_', fips, '.tif')
download.file(url1, destfile = destfile1, quiet = T, method = "libcurl", mode = 'wb')

url2 <- paste0('https://nassgeodata.gmu.edu/webservice/nass_data_cache/byfips/CDL_', year_sel + 1, '_', fips, '.tif')
destfile2 <- paste0('./CDL_', year_sel + 1, '_', fips, '.tif')
download.file(url2, destfile = destfile2, quiet = T, method = "libcurl", mode = 'wb')


# Read data 
Raster1 <- raster::raster(destfile1)
dataPoint1 <- raster::rasterToPoints(Raster1) %>% as.data.table()

Raster2 <- raster::raster(destfile2)
dataPoint2 <- raster::rasterToPoints(Raster2) %>% as.data.table()

# Plot the data
dev.off()
par(mar = c(1,1,1,1))
plot(Raster1, main = 'Champaign county in 2017')
dev.new()
plot(Raster2, main = 'Champaign county in 2018')

# Combine two datasets. 
isTRUE(identical(dataPoint1[,1], dataPoint2[,1]) & identical(dataPoint1[,2], dataPoint2[,2]))
dataPoints <- cbind(dataPoint1, dataPoint2[,3])
colnames(dataPoints) <- c('x', 'y', 'crop1', 'crop2')
  
# Create crop rotation matrices 
PixelCounts <- dataPoints[ , .(counts = .N), by = list(crop1, crop2)]
# The conversion factor for 30 meter pixels is 0.222394. 
PixelCounts[, acres := round(counts*0.222394, 2)]
PixelCounts <- PixelCounts[order(-acres)]

# Data in the first five rows. 
head(PixelCounts, 5)
