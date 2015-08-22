load("mistnet.predictions.Rdata")
load("mistnet.model.Rdata")
load("birds.Rdata")

hab = read.csv("AAB_traits.csv", as.is = TRUE)[,3]
hab.matrix = sapply( 
  sort(na.omit(unique(hab))),
  function(x){hab == x}
)
hab.matrix = hab.matrix[!is.na(rowSums(hab.matrix)), ]
hab.matrix = hab.matrix[ , colSums(hab.matrix) > 5]
colnames(hab.matrix) = gsub("^hab", "", colnames(hab.matrix))

coefs = net$layers[[3]]$coefficients
colnames(coefs) = colnames(route.presence.absence)

# I'm doing t(A) %*% A %*% B.  Projecting cross products onto hab.matrix.
# So I'm looking at the proportion of covariance among species that can
# be explained by habitat differences.
# Alternatively, A%*%B says how much each coefficient contributes to each class,
# and then projecting the coefficient matrix onto that.
X = t(scale(t(coefs[, !is.na(hab)]), scale = FALSE)) %*% hab.matrix

library(ggplot2)
library(reshape2)

pairs(X)

# Similarity among habitats, based on 
similarity = lsa::cosine(X)
melted = melt(similarity) # Don't need to plot the intercept
#melted$value = melted$value * (abs(melted$value) > .7)

#png("b.png", width = 1600, height = 1200, res = 150)
ggplot(melted, aes(x = Var1, y = Var2, fill = value)) + 
  geom_raster() + scale_fill_gradient2(space = "Lab") + coord_equal() + 
  geom_text(
    aes(x = Var1, y = Var2), 
    color ="white", 
    cex = abs(melted$value) * 10 * (melted$Var1 != melted$Var2), 
    #pch = ifelse(sign(melted$value) > 0, "+", "-")
    label = as.character(floor(rank(-abs(melted$value)))/2-3)
  )
#dev.off()


ordered.hab = rep(NA, length(hab))
ordered.hab[hab == "Grassland"] = 0
ordered.hab[hab == "Scrub"] = 1
ordered.hab[hab == "Open Woodland"] = 1
ordered.hab[hab == "Forest"] = 2


p.values = sapply(
  1:sum(in.test),
  function(i){
    pc = prcomp(qlogis(mistnet.prediction.array[i, , ]))
    wilcox.test(ordered.hab, pc$rotation[,2])$p.value
  }
)

