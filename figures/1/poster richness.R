library(poibin)
load("gbm.predictions.Rdata")
load("birds.Rdata")

predicted.richness = rowSums(gbm.predictions)
observed.richness =rowSums(route.presence.absence[in.test, ])

p.values = sapply(
  1:sum(in.test),
  function(i){ppoibin(observed.richness[i], gbm.predictions[i, ])}
)
outside.interval = p.values > .975 | p.values < .025


# mistnet -----------------------------------------------------------------
if(!exists("mistnet.prediction.array")){
  load("mistnet.predictions.Rdata")
}
N = dim(mistnet.prediction.array)[[3]]

mixture.probs = matrix(
  0, 
  nrow = 1 + ncol(route.presence.absence), 
  ncol = sum(in.test)
)
for(i in 1:sum(in.test)){
  for(j in 1:N){
    probs = mistnet.prediction.array[i, , j]
    mixture.probs[,i] = mixture.probs[,i] + dpoibin(0:length(probs), probs) / N
  }
}

mistnet.p.values = sapply(
  1:sum(in.test),
  function(i){
    sum(mixture.probs[1:observed.richness[i],i])
  }
)

mistnet.outside.interval = mistnet.p.values > .975 | mistnet.p.values < .025

# plot --------------------------------------------------------------------


pdf("figures/poster richness.pdf", height = 4, width = .85 * 4)
par(mgp = c(2, 0.5, 0))
plot(
  predicted.richness, 
  observed.richness, 
  asp = 1,
  col = ifelse(outside.interval, ifelse(p.values > .975, 4, 2), 1),
  pch = ifelse(outside.interval, 4, 16),
  xlim = range(observed.richness),
  cex = ifelse(outside.interval, 1, .5),
  bty = "l",
  axes = FALSE,
  xlab = "Predicted species richness",
  ylab = "Observed species richness"
)
abline(0,1)
axis(1, (0:10) * 20)
axis(2, (0:10) * 20)
dev.off()

mistnet.predicted.richness = apply(
  mistnet.prediction.array/ dim(mistnet.prediction.array)[[3]], 
  1, 
  sum
)

pdf("figures/poster mistnet richness.pdf", height = 4, width = .85 * 4)
par(mgp = c(2, 0.5, 0))
plot(
  mistnet.predicted.richness, 
  observed.richness, 
  asp = 1,
  col = ifelse(mistnet.outside.interval, ifelse(p.values > .975, 4, 2), 1),
  pch = ifelse(mistnet.outside.interval, 4, 16),
  xlim = range(observed.richness),
  cex = ifelse(mistnet.outside.interval, 1, .5),
  bty = "l",
  axes = FALSE,
  xlab = "Predicted species richness",
  ylab = "Observed species richness"
)
abline(0,1)
axis(1, (0:10) * 20)
axis(2, (0:10) * 20)
dev.off()


R2 = function(observed, predicted){
  ybar = mean(observed)
  residSS = sum((predicted - observed)^2)
  totalSS = sum((observed - ybar)^2)
  explainedSS = totalSS - residSS
  explainedSS / totalSS
}

R2(observed = observed.richness, predicted = predicted.richness)
R2(observed = observed.richness, predicted = mistnet.predicted.richness)
