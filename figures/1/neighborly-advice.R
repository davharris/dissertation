load("birds.Rdata")
if(!exists("mistnet.prediction.array")){load("mistnet.predictions.Rdata")}

dimnames(mistnet.prediction.array) = list(NULL, colnames(route.presence.absence), NULL)


i = 1 # Sites 56, 103, & 252, 198 get to 11% versus 39%

indicator.name = "Nashville Warbler"

out = cov(t(mistnet.prediction.array[i, , ]))
diag(out) = 0
spp = c(
  "Red-breasted Nuthatch",
  "Horned Lark"
)

p1 = mistnet.prediction.array[i, spp[1], ]
p2 = mistnet.prediction.array[i, spp[2], ]
p.indicator = mistnet.prediction.array[i, indicator.name, ]


pdf(file = "figures/neighborly-advice.pdf", width = 12, height = 11)
par(mfrow = c(2, 2))
par(mar = c(7, 14, 6, 2))
par(cex.main = 1.9)
for(conditional in c(FALSE, TRUE)){
  
  plot(
    p1, 
    p2, 
    xlim = c(0, 1),
    ylim = c(0, 1),
    main = if(conditional){
      paste("\nB: Samples weighted by\n", indicator.name, "presence")
    }else{
      "\nA: Raw Monte Carlo samples"
    },
    xlab = paste0("P(", spp[1], ")"),
    ylab = paste0("P(", spp[2], ")"),
    asp = 1,
    cex = if(conditional){sqrt(p.indicator) * 5}else{mean(sqrt(p.indicator) * 5)},
    col = "#00000040",
    pch = 16,
    xaxs = "i",
    yaxs = "i",
    axes = FALSE,
    cex.lab = 2,
    mgp = c(3.5, 1, 0)
  )
  axis(1, c(0, .5, 1), las = 1, cex.axis = 1.6)
  axis(2, c(0, .5, 1), las = 1, cex.axis = 1.6)
  rowMeans(mistnet.prediction.array[i, spp, ])
  if(conditional){
    arrows(
      x0 = mean(p1),
      x1 = sum(p1 * p.indicator) / sum(p.indicator),
      y0 = mean(p2), 
      y1 = sum(p2 * p.indicator) / sum(p.indicator),
      col = "white",
      lwd = 9,
      length = .25
    )
  }
  points(
    mean(p1), 
    mean(p2), 
    col = if(conditional){"#70CFAB"}else{"#009F6B"}, 
    pch = "*", 
    cex = 7
  )
  if(conditional){
    arrows(
      x0 = mean(p1),
      x1 = sum(p1 * p.indicator) / sum(p.indicator),
      y0 = mean(p2), 
      y1 = sum(p2 * p.indicator) / sum(p.indicator),
      col = "#009F6B",
      lwd = 7,
      length = .25
    )
  }
}

par(mar = c(5.1, 18, 4.1, 5.1))
for(j in 1:2){
  if(j == 2){
    i = 1
    indicator.name = "Redhead"
    p.indicator = mistnet.prediction.array[i, indicator.name, ]
  }
  conditional.probs = colSums(p.indicator * t(mistnet.prediction.array[i, , ])) / 
    sum(p.indicator)
  probs = rowMeans(mistnet.prediction.array[i, , ])
  
  sorted.species = names(sort(conditional.probs - probs))
  sorted.species = sorted.species[sorted.species != indicator.name]
  included.nums = c(1:3, seq(length(sorted.species) - 8, length(sorted.species)))
  included.species = sorted.species[included.nums]
  
  article = if(substr(indicator.name, 0, 1) %in% c("A", "E", "I", "O", "U")){
    "an "
  }else{
    "a "
  }
  plot(
    x = NA, 
    xlim = c(0, 1), 
    ylim = c(0.5, length(included.species) + 1),
    yaxs = "i",
    xaxs = "i",
    axes = FALSE,
    xlab = "Expected P(observation)",
    ylab = "",
    main = paste0(
      "\n",
      LETTERS[j + 2], 
      ". Model responses to\nobserving ",
      article, 
      indicator.name
    ),
    cex.lab = 2
  )
  axis(1, c(0, 1/2, 1), cex.axis = 1.6)
  axis(
    2, 
    0:length(included.species), 
    c("", included.species), 
    las = 2,
    cex.axis = 1.8
  )
  axis(
    4, 
    0:length(included.species), 
    labels = rep("", 1 + length(included.species)), 
    lwd.ticks = 0,
    las = 2
  )
  abline(h = 3.5, lwd = 2)
  abline(h = 1:length(included.species), col = "lightgray", lwd = 2)
  arrows(
    x0 = probs[included.species],
    x1 = conditional.probs[included.species],
    y0 = 1:length(included.species),
    y1 =  1:length(included.species),
    lwd = 5,
    length = .12,
    col = 1
    #col = ifelse(included.species %in% spp & j == 1, "#009F6B", "black")
  )
  segments(
    x0 = probs[included.species],
    x1 = probs[included.species],
    y0 = 1:length(included.species) - .12,
    y1 =  1:length(included.species) + .12,
    lwd = 5,
    col = 1
    # col = ifelse(included.species %in% spp & j == 1, "#009F6B", "black")
  )
}
dev.off()
###

# covar = cov(qlogis(t(mistnet.prediction.array[i,spp,])))
# library(MASS)
# fakep = plogis(mvrnorm(1E7, mu = c(0, 0), Sigma = covar))
# 
# plot(fakep[1:1000, ], col = "#00000020", pch = 16, asp = 1, cex = .75)
# p.a = mean(fakep[,1] * (1-fakep[,2]))
# p.b = mean((1-fakep[,1]) * fakep[,2])
# p.both = mean(fakep[,1] * fakep[,2])
# p.neither = mean((1-fakep[,1]) * (1-fakep[,2]))
# 
# stopifnot(all.equal(p.a + p.b + p.both + p.neither, 1))
# 
