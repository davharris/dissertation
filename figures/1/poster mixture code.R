library(poibin)

set.seed(1)

n = 368
nlines = 3
x = rnorm(n, sd = 2)



z = qnorm(seq(0.05, .95, length = nlines))
x.sequence = seq(-4, 4, length = 1000)

p_fun = function(x, z){plogis(x + z/3 - 3)}

color_grad = function(z){
  rgb(plogis(2 * pmax(0, -z) - 1.5), 0, plogis(2 * pmax(0, z) - 1.5))
}

y.sequence = dnorm(x.sequence)

pdf("figures/poster mixture.pdf", height = 5, width = 4)
par(mfrow = c(2, 1))
plot(
  y = y.sequence,
  x = x.sequence,
  type = "n",
  axes = FALSE,
  bty = NULL,
  main = "Unobserved \"suitability\" value",
  xlab = "",
  ylab = "",
  xaxs = "i",
  mgp = c(1, 1, 1)/2
)
for(i in 2:length(x.sequence)){
  polygon(
    x.sequence[c(i-1, i-1, i, i)],
    c(0, y.sequence[i-1], y.sequence[i], 0),
    col = color_grad(x.sequence[i]),
    border = color_grad(x.sequence[i]),
    density = NA
  )
}

xlim = c(0, 100)
ylim = c(0, .09)
par(mgp = c(1.5, .5, 0))
plot(
  NULL, 
  xlim = xlim, 
  ylim = ylim, 
  bty = "l", 
  yaxs = "i", 
  xaxs = "i", 
  axes = FALSE, 
  bty = "n",
  xlab = "Species richness",
  ylab = ""
)
sapply(z[order(abs(z), decreasing = TRUE)], function(z){
  p = p_fun(x, z)
  lines(
    0:n, 
    dpoibin(0:n, p), 
    type = "l", col = color_grad(z), lwd = 4)
})
abline(h = 0, lwd = 2)
axis(1)

dev.off()