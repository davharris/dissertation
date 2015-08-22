load("birds.Rdata")
load("mistnet.predictions.Rdata")

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


pdf(file = "figures/poster scatterplot.pdf", width = 8, height = 5)
par(mfrow = c(1, 2))
par(mar = c(7, 6, 6, 2))
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
    xlab = paste0("P(", spp[1], " observation)"),
    ylab = paste0("P(", spp[2], " observation)"),
    asp = 1,
    cex = if(conditional){sqrt(p.indicator) * 2}else{mean(sqrt(p.indicator) * 2)},
    col = "#00000040",
    pch = 16,
    xaxs = "i",
    yaxs = "i",
    axes = FALSE
  )
  axis(1, c(0, .5, 1), las = 1)
  axis(2, c(0, .5, 1), las = 1)
  rowMeans(mistnet.prediction.array[i, spp, ])
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

dev.off()
