library(MASS) # for mvrnorm

set.seed(1)

load("birds.Rdata")
if(!exists("mistnet.prediction.array")){load("mistnet.predictions.Rdata")}

dimnames(mistnet.prediction.array) = list(NULL, colnames(route.presence.absence), NULL)


i = 8 # i==8 gets me to 11%

covs = cov(t(mistnet.prediction.array[i, , ]))
diag(covs) = 0

spp = c(row(covs)[which.max(covs)], col(covs)[which.max(covs)])
Sigma = cov(qlogis(t(mistnet.prediction.array[i, spp, ])))

p = plogis(mvrnorm(1E5, mu = c(0, 0), Sigma = Sigma))

a.only = mean(p[,1] * (1 - p[,2]))
b.only = mean(p[,2] * (1 - p[,1]))
both = mean(p[,1] * p[,2])
neither = mean((1 - p[,1]) * (1 - p[,2]))

stopifnot(all.equal(1, sum(a.only, b.only, both, neither)))

pdf("figures/Figure-1.pdf", height = 2.8, width = 7)
par(mfrow = c(1, 3))
par(mgp = c(2.5, .75, 0))
plot(
  p[1:250, ], 
  pch = 16, 
  col = "#00000020", 
  asp = 1, 
  xaxs = "i", 
  yaxs = "i", 
  axes = FALSE,
  xlim = c(0, 1.02),
  ylim = c(0, 1),
  cex = .75,
  main = "A: Habitat suitability",
  xlab = paste0("P(", colnames(route.presence.absence)[spp[1]], ")"),
  ylab = paste0("P(", colnames(route.presence.absence)[spp[2]], ")")
)
points(.5, .5, pch = "+", cex = 3, col = "#000000AA")
axis(1, c(0, .5, 1))
axis(2, c(0, .5, 1))

par(mgp = c(.75, 0, 0))
plot(
  NULL,
  xlim = c(0, 1),
  ylim = c(0, 1),
  axes = FALSE,
  xlab = paste0("No                   Yes\n", colnames(route.presence.absence)[spp[1]], " observed?"),
  ylab = paste0(colnames(route.presence.absence)[spp[2]], " observed?\nNo                   Yes"),
  asp = 1,
  xaxs = "i",
  yaxs = "i",
  main = "B: Species composition"
)
polygon(c(0, 0, 1, 1), c(0, 1, 1, 0))
segments(0, .5, 1, .5)
segments(.5, 0, .5, 1)
text(
  c(.75, .25, .75, .25),
  c(.25, .75, .75, .25),
  label = paste0(round(100 * c(a.only, b.only, both, neither)), "%"),
  cex = sqrt(c(a.only, b.only, both, neither)) * 5
)

par(mgp = c(2, .75, 0))
barplot(
  c(neither, a.only + b.only, both), ylim = c(0, .45),
  names.arg =c(0, 1, 2),
  yaxs = "i",
  xlab = "Number of species observed",
  ylab = "Probability mass",
  space = 0,
  main = "C: Species richness"
)
dev.off()