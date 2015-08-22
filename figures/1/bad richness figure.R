library(poibin)

set.seed(1)
load("birds.Rdata")
load("gbm.predictions.Rdata")
load("mistnet.predictions.Rdata")

mistnet.expectations = apply(mistnet.prediction.array, 2, rowMeans)

max.richness = ncol(route.presence.absence)

richness = rowSums(route.presence.absence[in.test, ])
gbm.richness = rowSums(gbm.predictions)
mistnet.richness = rowSums(mistnet.expectations)

percent.explained = function(y, yhat){
  numerator = mean((y - yhat)^2)
  denominator = mean((y - mean(y))^2)
  
  1 - numerator / denominator
}

gbm.R2 = percent.explained(richness, gbm.richness)
mistnet.R2 = percent.explained(richness, mistnet.richness)

gbm.richness.liks = sapply(
  1:sum(in.test),
  function(i){
    dpoibin(richness[[i]], gbm.predictions[i, ])
  }
)

mistnet.prediction.array = mistnet.prediction.array[,,1:100]

mistnet.richness.liks = sapply(
  1:sum(in.test),
  function(i){
    mean(sapply(
      1:dim(mistnet.prediction.array)[[3]],
      function(j){
        dpoibin(richness[[i]], mistnet.prediction.array[i, , j])
      }
    ))
  }
)









