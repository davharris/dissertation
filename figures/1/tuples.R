set.seed(1)

load("birds.Rdata")
load("mistnet.predictions.Rdata")
load("gbm.predictions.Rdata")
devtools::load_all("../marsrover/") # I should change that directory name...

n = 100


# Just use the first 1000 samples to save memory...
mistnet.prediction.array = mistnet.prediction.array[,,1:1000]


colnames(gbm.predictions) = colnames(route.presence.absence)
dimnames(mistnet.prediction.array) = list(
  NULL, 
  colnames(route.presence.absence), 
  NULL
)

gbm.log.probs = dbinom(
  route.presence.absence[in.test, ],
  size = 1,
  prob = gbm.predictions[ , ],
  log = TRUE
)


logprobdiff = function(tuple){
  
  mistnet.sample.log.probs = apply(
    mistnet.prediction.array[ , tuple, , drop = FALSE], 
    3,
    function(x){
      rowSums(
        dbinom(
          route.presence.absence[in.test, tuple, drop = FALSE],
          size = 1,
          prob = x,
          log = TRUE
        )
      )
    }
  )
  
  mistnet.log.probs = apply(mistnet.sample.log.probs, 1, logMeanExp)
  
  mistnet.log.probs - rowSums(gbm.log.probs[, tuple, drop = FALSE])
}

tuple.sizes = c(2^(0:8), ncol(route.presence.absence))


z = sapply(
  seq(2, length(tuple.sizes) - 1),
  function(i){
    replicate(
      n, 
      mean(
        logprobdiff(
          sample(colnames(route.presence.absence), tuple.sizes[[i]])
        )
      )
    )
  }
)

complete.logprob = logprobdiff(colnames(route.presence.absence))
single.species.logprob = sapply(
  colnames(route.presence.absence),
  logprobdiff
)


pdf("figures/tuples.pdf", height = 3, width = 9)
par(mar = c(5, 6, 4, 2) + 0.1)
plot(
  c(exp(z)) ~ tuple.sizes[col(z) + 1], 
  log = "xy", 
  pch = 1, 
  col = "#00000040",
  xlim = c(.9, ncol(route.presence.absence)*1.08),
  ylab = "Expected likelihood ratio\n(mistnet/BRT)\n",
  xlab = "Number of species to predict",
  axes = FALSE,
  xaxs = "i",
  yaxs = "i",
  ylim = c(
    min(exp(z), exp(colMeans(single.species.logprob))) * .6,
    exp(1.04 * mean(complete.logprob))
  ),
  cex = 1,
  main = "Predictive improvement versus\nassemblage size",
  mgp = c(2, 1, 1)
)
axis(2, 10^(0:5), 10^(0:5), las = 1, mgp = c(3, .7, 0))
axis(1, c(0, tuple.sizes), las = 1, mgp = c(3, .7, 0))
abline(h = 1, col = "#00000088")
abline(h = 10^(1:5), col = "#00000022")
points(ncol(route.presence.absence), exp(mean(complete.logprob)), pch = 1, cex = 1)
points(rep(1, ncol(single.species.logprob)), exp(colMeans(single.species.logprob)), pch = 1, col = "#00000030", cex = 1)
dev.off()


means = c(mean(single.species.logprob), colMeans(z), mean(complete.logprob))

data.frame(
  tuple.size = tuple.sizes,
  expected.log.ratio = round(means, 2), 
  ratio = round(exp(means), 2)
)
