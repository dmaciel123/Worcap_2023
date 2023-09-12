## Pre-processing of GLORIA data to predict and TSS ####

# loading require packages

require(data.table)
require(dplyr)
require(mapview)
require(PerformanceAnalytics)
require(terra)

## Configure the Project Directories 

dir.create("Data")
dir.create("Outputs")
dir.create("Scripts")


###### Download GLORIA data ##########

URL = 'https://download.pangaea.de/dataset/948492/files/GLORIA-2022.zip'

# Before download, let`s set timeout to 200s (sometimes PANGAEA download is slow)

options(timeout=300)

# If the directory with files doesn't exist, let's download GLORIA data.

if(dir.exists('Data/GLORIA_2022/') == FALSE) {
  
  # Download
  download.file(URL, 'Data/GLORIA.zip')
  
  # Extract
  unzip(zipfile = 'Data/GLORIA.zip', exdir = 'Data')
  
}


##### Analyzing GLORIA data #######

meta_and_lab = fread("Data/GLORIA_2022/GLORIA_meta_and_lab.csv")
rrs = fread("Data/GLORIA_2022/GLORIA_Rrs.csv")

head(meta_and_lab)
head(rrs)

##### Plot for different concentrations #######

# High Chl-a

meta_and_lab[meta_and_lab$Chla > 1000, 'GLORIA_ID']

matplot(t(select(rrs, paste("Rrs_", 400:900, sep = ''))[rrs$GLORIA_ID == 'GID_7403',]), ylim = c(0,0.06),
        x= c(400:900), pch = 20, xlab = '', ylab = '', type = 'l')

# High TSS

meta_and_lab[meta_and_lab$TSS > 1000, 'GLORIA_ID']

matplot(t(select(rrs, paste("Rrs_", 400:900, sep = ''))[rrs$GLORIA_ID == 'GID_1805',]), ylim = c(0,0.06),
        x= c(400:900), pch = 20, xlab = '', ylab = '', type = 'l')


# High aCDOM

meta_and_lab[meta_and_lab$aCDOM440 > 15, 'GLORIA_ID']

matplot(t(select(rrs, paste("Rrs_", 400:900, sep = ''))[rrs$GLORIA_ID == 'GID_2468',]), ylim = c(0,0.0005),
        x= c(400:900), pch = 20, xlab = '', ylab = '', type = 'l')


# Band simulation ####

devtools::install_github("dmaciel123/BandSimulation")

require(bandSimulation)

spectra_formated = select(rrs, paste("Rrs_", 400:900, sep = '')) %>% t()

head(spectra_formated[1:10,1:10])

OLI_sim = oli_simulation(spectra = spectra_formated, 
                         point_name = rrs$GLORIA_ID)


#It simulates for Landsat-8/OLI and gives the results in a list.

OLI = OLI_sim[,-1] %>% t() %>% data.frame()

head(OLI)


# Add names to a collumn
OLI$GLORIA_ID = row.names(OLI)

head(OLI)

# Change band names

names(OLI) = c('x440', "x490", 'x560', 'x660','x850', "GLORIA_ID")


selection = filter(rrs, GLORIA_ID == 'GID_207')
selection.s = filter(OLI, GLORIA_ID == 'GID_207')
meta.s = filter(meta_and_lab, GLORIA_ID == 'GID_207')

##### Plot example #####

matplot(t(select(selection, paste("Rrs_", 400:900, sep = ''))[,]), ylim = c(0,0.05),
        x= c(400:900), pch = 20, xlab = '', ylab = '')

par(new=T)

matplot(t(selection.s[,-6]), x= c(440,490,560,660,860), pch = 20,
        ylim = c(0,0.05), xlim = c(400,900), col = 'red', cex = 2, xlab = 'Wavelength (nm)', 
        ylab = 'Rrs (sr-1)')

legend('topleft', legend = c(paste("Chl-a = ", meta.s$Chla),
                             paste("Secchi = ", meta.s$Secchi_depth)))

## Merge dataset and prepare to export ########

## Merge with water quality, lat long (By GLORIA_ID)

merged = merge(select(meta_and_lab, c('GLORIA_ID', "TSS", "Latitude", "Longitude")),
               OLI, by = "GLORIA_ID")

head(merged)


###### Index calculation and NA remove #######

# We want to model TSS based on RF

merged = merged[is.na(merged$TSS) == FALSE, ]


merged = merged[(merged$TSS < 1000 & merged$TSS > 1), ]

#Index calculations

merged$nir_red = (merged$x850-merged$x660)/(merged$x850+merged$x660)+1


# Check dimension

dim(merged)

####### Vizualize #######

summary(merged)

chart.Correlation(log(select(merged, -contains(c("GLORIA_ID", 'Latitude', 'Longitude')))))

# Vectorize

vector = vect(merged, 
              geom = c('Longitude', 'Latitude'), 
              "EPSG:4326")

vector = sf::st_as_sf(vector)
# plot map

mapview(vector,  zcol = 'TSS')


## Saving results

write.table(merged, file = 'Outputs/oli_simulated_filtered.csv', row.names = F)






