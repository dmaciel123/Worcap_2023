# Remote Sensing applied to freshwater ecosystems studies 


The use of remote sensing data to predict water quality (WQ) parameters that are optically active (i.e., interacts with light) has been applied to ocean and coastal waters for ~50 years. Thanks to the new generation of sensors with adequate spectral, radiometric and spatial resolution (i.e., Landsat, Sentinel-2, etc) in the last 15 years the community started to use RS to freshwater studies. Remote sensing allow us to predict some WQ parameters: Suspended sediments, chlorophyl-a, phycocianin, dissolved organic matter, carbon, secchi disk depth, turbidity...It is an important source of data that could help biologists, limnologists, and all the aquatic science community into understanding of water pattern. 

In this workshop, we gonna learn how to use Remote Sensing data applied to aquatic sciences. We gonna use in situ dataset available in the GLORIA dataset (Lehmann et al. 2023) to generate a Chorophyll-a concentration empirical model based on Normalized Difference Chlorophyll-a Index (NDCI) and Random Forests. Therefore, with a calibrated algorithm, we gonna apply the developed models to Sentinel-2/MSI Surface Reflectance data atmospherically corrected using Sen2Cor and available in the Miscrosoft Planetary Computer STAC platform. 

The processing flow is divided into three topics:

1. Installing the packages, downloading the data, simulate the bands and removing outliers (pre-processing step)
2. Model development (train, validation, and full model development)
3. Model application: application of the algorithms to satellite data using STAC from Microsoft Planetary Computer.

# What we are expecting to get as result?

1. A Chlorophyll-a Random Forest and Empirical algorithm;
2. A prediction of Chl-a concentration for a specific date
3. A time-series of Chlorophyll-a concentration for Billings Reservoir, Sao Paulo, Brazil (Figure below). 


![Figure 01](https://github.com/dmaciel123/HackingLimnology_RS_day/blob/main/animation.gif)




# Required software 

For running the scripts, we reccomend the attendes to install R and RSTUDIO. 

R could be downloaded here: 

RSTUDIO could be downloaded here:

We also encourage attendes to create a Microsoft Planetary Computer and Google Earth Engine accounts. Althought we're not gonna use these platforms directly, thei could be both used to process and work with satellite big data. Advantages of MPC is that they allow programming in R :)

# Required packages 

During the workshop, we will present the necessary packages. However, we encourage attendes to install it in advance. For that, just run in your R console:

```r

# Required packages

packages = c('data.table','dplyr','terra','mapview','httr','Metrics','geodrawr',
             'svDialogs','rstac','wesanderson','PerformanceAnalytics', 'remotes',
             'ggpmisc','gdalcubes','Metrics','randomForest','rasterVis','RColorBrewer')

install.packages(packages)

```

We also need to download the bandSimulation package available on GitHub. If we want to develop RS models, we will need to simulate (i.e. integrate based on the Relative Spectral Response) each band of the desiered sensor


```r

devtools::install_github("dmaciel123/BandSimulation")

require(bandSimulation)

```



# GLORIA Dataset

The GLORIA dataset is a compilation of remote sensing reflectance (Rrs) and water quality data for global waters, with dedicated data for freshwater ecosystems. It is free and available for everyone, and covers most part of the globe with more than 7,000 samples (Figure 01)

Let's remember that Remote Sensing Reflectance is the ratio between water leaving radiance and downwelling irradiance, compensated by the sky radiance and corrected by glint effects (Equation 01).



For more information, users are refered to the publication [(Lehmann et al. 2023)](https://www.nature.com/articles/s41597-023-01973-y), the dataset in [PANGAEA](http://https://doi.pangaea.de/10.1594/PANGAEA.948492) and the [Nature Earth and Environmment blog post](http://https://earthenvironmentcommunity.nature.com/posts/gloria-challenges-in-developing-a-globally-representative-hyperspectral-in-situ-dataset-for-the-remote-sensing-of-water-resources)



![Figure 01](https://earthenvironmentcommunity.nature.com/cdn-cgi/image/metadata=copyright,fit=scale-down,format=auto,sharpen=1,quality=95/https://images.zapnito.com/uploads/hiCMOprnTtSCTJNv78gu_locations.jpg)


# Band simulation

When we simulate a satellite band, we are compensating for the differences in detector sensibility to each wavelength. The Figure below shows differences in the spectral response function for Sentinel-2A/MSI, Landsat-8/OLI and Landsat-7/ETM+. You can note that relative spectral response values close to "1" indicates that the detector can measure (or detect) all the radiance in this wavelength.


A sensor band is composed by an interval of these wavelengths and then, the simulated band is the integral the R[rs] considering the Relative Spectral Response curve, or Equation 02.

![Figure 02](https://upload.wikimedia.org/wikipedia/commons/7/7d/Spectral_responses_of_Landsat_7_ETM%2B%2C_Landsat_8_OLI_and_Sentinel_2_MSI_in_the_visible_and_near_infrared.png)



# Other intallations and reccomendations

We don't need to download and/or install other softwares and download any other data. We gonna use R to download, organize and process the in situ and satellite data. 
