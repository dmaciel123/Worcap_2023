## Model generation: Random Forest and empirical (NDCI) algorithm for (Chl-a) 

# loading require packages

require(data.table)
require(dplyr)
require(Metrics)
require(randomForest)

source("Scripts/Functions.R")
## Loading data

data = fread("Outputs/oli_simulated_filtered.csv")



## Total Suspended Matter Random Forest 
# Steps:
# 1) Separate data into training / test 
# 2) Calibrate the model with training data
# 3) Validate the model with test data
# 4) Create the full model based on all data
# 5) Apply to satellite image
# 6) If available, validate the image predictions


## Creating the validation and training datasets (70% train / 30% validation)

set.seed(13) # To allow replicability

samples = sample(x = 1:nrow(data),
                 size = 0.7*nrow(data), 
                 replace = F)


train = data[samples,]
valid = data[-samples,]


dim(train)
dim(valid)



###### Create a random forest algorithm for Chl-a


tss.rf = randomForest(TSS~ x440+x490+x560+x660+nir_red+x850, data = train, 
                       ntree = 200, mtry = 4, importance = T)

varImpPlot(tss.rf)

valid$TSS_RF = (predict(tss.rf, valid))

plot(valid$TSS, valid$TSS_RF ,pch = 20, xlab = "Measured TSS",
     ylab = "Predicted TSS", xlim = c(0,400), ylim = c(0,400))

abline(0,1)

# Lets compare both models

stat_calc(real = valid$TSS, predicted = valid$TSS_RF)


## Random Forest presented better results. 


## Calculate empirical and RF final models

RF_FINAL = randomForest(TSS~ x440+x490+x560+x660+nir_red+x850, data = data, 
                        ntree = 200, mtry = 4, importance = T)


saveRDS(RF_FINAL, file = 'Outputs/rf_tss.R')






