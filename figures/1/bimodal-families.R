library(poibin)
load("birds.Rdata")
if(!exists("mistnet.prediction.array")){load("mistnet.predictions.Rdata")}
load("nnet.predictions.Rdata")

in.family = species.data$Family == "Anatidae"

stopifnot(sum(in.family) > 2)
z = sapply(
  1:280,
  function(i){sd(colSums(mistnet.prediction.array[i , in.family, ]))}
)

site = order(z, decreasing = TRUE)[2]

zz = sapply(
  1:500,
  function(i){
    dpoibin(0:sum(in.family), mistnet.prediction.array[site , in.family, i])
  }
)

zz2 = sapply(
  1:500,
  function(i){
    dpoibin(0:ncol(route.presence.absence), mistnet.prediction.array[site , , i])
  }
)

pdf("figures/family-richness.pdf", width = 4.5, height = 6)
par(mfrow = c(2, 1))
par(mar = c(5.1, 4.1, 2.1, 1.1))

plot(
  0:sum(in.family),
  dpoibin(0:sum(in.family), nnet.predictions[site, in.family]),
  type = "l",
  xlim = c(0, 23),
  ylim = range(c(0, dpoibin(0:sum(in.family), nnet.predictions[site, in.family]) * 1.1)),
  col = "darkgray",
  xlab = "Number of Anatid species\n(\"duck family\")",
  ylab = "Expected frequency",
  yaxs = "i",
  xaxs = "i",
  bty = "l",
  axes = FALSE,
  lwd = 2,
  main = "A: Family-level richness",
  cex = .7
)
points(
  0:sum(in.family),
  dpoibin(0:sum(in.family), nnet.predictions[site, in.family]),
  pch = 22,
  bg = "white",
  cex = .7
)
axis(2, seq(0, .9, by = .1))
axis(1, c(0, 5, 10, 15, 20, 25), c(0, 5, 10, 15, 20, 25))
lines(0:sum(in.family), rowMeans(zz), lwd = 2)
points(
  0:sum(in.family), 
  rowMeans(zz), 
  pch = 19,
  cex = .7
)
legend(
  "topright",
  legend = c("mistnet", "nnet baseline"),
  pch = c(19, 22),
  bg = "white",
  bty = "n"
)


plot(
  0:ncol(route.presence.absence),
  dpoibin(0:ncol(route.presence.absence), nnet.predictions[site, ]),
  type = "l",
  xlim = c(0, 150),
  ylim = range(c(0, dpoibin(0:ncol(route.presence.absence), nnet.predictions[site, ]))) * 1.1,
  col = "darkgray",
  xlab = "Number of Avian species\n(all families)",
  ylab = "Expected frequency",
  yaxs = "i",
  xaxs = "i",
  bty = "l",
  axes = FALSE,
  lwd = 2,
  main = "B: Class-level richness",
  cex = .7
)
points(
  0:ncol(route.presence.absence),
  dpoibin(0:ncol(route.presence.absence), nnet.predictions[site, ]),
  pch = 22,
  bg = "white",
  cex = .7
)
lines(0:ncol(route.presence.absence), rowMeans(zz2), lwd = 2)
points(
  0:ncol(route.presence.absence), 
  rowMeans(zz2), 
  pch = 19,
  cex = .7
)
axis(2, seq(0, .9, by = .02))
axis(1)
dev.off()


richness.p.values = sapply(
  1:sum(in.test),
  function(i){
    ppoibin(
      sum(route.presence.absence[which(in.test)[i], ]), 
      nnet.predictions[i, ]
    )
  }
)



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

observed.richness = rowSums(route.presence.absence[in.test, ])
mistnet.p.values = sapply(
  1:sum(in.test),
  function(i){
    sum(mixture.probs[1:observed.richness[i],i])
  }
)

mistnet.outside.interval = mistnet.p.values > .975 | mistnet.p.values < .025

1- mean(mistnet.outside.interval)
