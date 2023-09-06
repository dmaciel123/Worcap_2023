# Using RSTAC to get Sentinel-2 image and apply the algorithm developed

require(data.table)
require(dplyr)
require(rstac)
require(terra)
require(mapview)
require(httr)
require(Metrics)
require(geodrawr)
require(svDialogs)
require(rstac)
require(wesanderson)
require(randomForest)
library(rasterVis)
require(RColorBrewer)
require(terrainr)

# What is STAC? https://stacspec.org/en

# What we need to get the images?

#
# 1) Collection and STAC provider (from where we gonna get that?)
# 2) Location and/or image name/date (which date and where we want that data?)


# We gonna use the Microsoft Planetary Computer STAC to get Sentinel-2 images

stac_obj <- stac('https://planetarycomputer.microsoft.com/api/stac/v1/')


dates = c("2021-01-01/2021-12-31")
CLOUD_COVER = 20

BBOX = c(-51.38, -30.38, -51.03, -29.97 ) #xmin, ymin, xmax, ymax

it_obj <- stac_obj %>%
  stac_search(collections = "landsat-c2-l2",
              bbox = BBOX,
              datetime = dates) %>%
  get_request() %>% 
  items_filter(`eo:cloud_cover` < as.numeric(CLOUD_COVER)) %>%
  items_filter(`platform` == 'landsat-8') %>%
  
  items_sign(sign_fn = sign_planetary_computer())


print(it_obj)


crop_pt = ext(460000, 510000, -3450000, -3310000) 


blue <- paste0("/vsicurl/", it_obj$features[[1]]$assets$blue$href) %>% rast() %>% terra::crop(crop_pt)
green <- paste0("/vsicurl/", it_obj$features[[1]]$assets$green$href) %>% rast() %>% terra::crop(crop_pt)
red <- paste0("/vsicurl/", it_obj$features[[1]]$assets$red$href) %>% rast() %>% terra::crop(crop_pt)
nir <- paste0("/vsicurl/", it_obj$features[[1]]$assets$nir08$href) %>% rast() %>% terra::crop(crop_pt)
swir <- paste0("/vsicurl/", it_obj$features[[1]]$assets$swir22$href) %>% rast() %>% terra::crop(crop_pt)
coastal <- paste0("/vsicurl/", it_obj$features[[1]]$assets$coastal$href) %>% rast() %>% terra::crop(crop_pt)

img.full = c(coastal,blue, green, red, nir) 

plotRGB(img.full, r = 4, g = 3, b = 2, stretch = 'lin')

# Water Mask 

mNDWI = (green-swir)/(swir+green)

img.agua = img.full

img.agua[mNDWI < 0] = NA

plotRGB(img.agua, r = 4, g = 3, b = 2, stretch = 'lin')

# Reprojecting nir/swir to match the 20m spatial res


# Glitn correction

img.agua = img.agua-swir

plotRGB(img.agua, r = 4, g = 3, b = 2, stretch = 'lin')


img.agua.scaled = (img.agua*0.0000275 + -0.2)/pi

names(img.agua.scaled) = c('x440', 'x490', 'x560', 'x660', 'x850')

# Calculate index

img.agua.scaled$nir_red = (img.agua.scaled$x850-img.agua.scaled$x660)/(img.agua.scaled$x850+img.agua.scaled$x660)+1


## Random forest prediction


# load model

rf.tss = readRDS('Outputs/rf_tss.R')

rf.tss.pred = predict(img.agua.scaled, rf.tss)


names(rf.tss.pred) = c("Random Forest")

colr <- colorRampPalette(rev(brewer.pal(11, 'RdBu')))

rf.tss.pred[rf.tss.pred > 200] = NA

levelplot(raster::stack(rf.tss.pred),col.regions = viridis::viridis, maxpixels = 1e6, 
          main = "Total Suspended Sediments (TSS) Concentration - mg/L", 
          colorkey=list(
            space='bottom',                   # plot legend at bottom
            labels=list(at=seq(from = 0, to = 200, by = 20), font=4)      # legend ticks and labels 
          )) 


