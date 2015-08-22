load("birds.Rdata")
load("mistnet.model.Rdata")
library(MASS)

hab = read.csv("AAB_traits.csv", as.is = TRUE)[,3]

# Remove habitat types that include 15 or fewer species
hab[hab %in% names(which(table(hab) <= 15))] = NA

sub_hab = hab[!is.na(hab)]

coefs = net$layers[[3]]$weights
colnames(coefs) = colnames(route.presence.absence)



a = lda(x = t(coefs)[!is.na(hab), ], grouping = sub_hab, CV = TRUE)
b = lda(x = t(coefs)[!is.na(hab), ], grouping = sub_hab, CV = FALSE)


mygreen = "#10BD90"
mybrown = "#D09205"


colors = rep("#FFFFFF", length = length(sub_hab))
colors[sub_hab == "Forest"] = mygreen
colors[sub_hab == "Grassland"] = mybrown
colors[sub_hab %in% c("Lake/Pond", "Marsh")] = "#0000FF"
colors[sub_hab %in% c("Open Woodland", "Scrub")] = "black"

pch = rep(0, length(sub_hab))
pch[sub_hab == "Forest"] = 16
pch[sub_hab == "Grassland"] = 17
pch[sub_hab == "Marsh"] = 1
pch[sub_hab == "Lake/Pond"] = 1
pch[sub_hab == "Scrub"] = 4
pch[sub_hab == "Open Woodland"] = 4



lda.space = t(coefs[,!is.na(hab)])%*% b$scaling

pdf("figures/lda.pdf", width = 7, height = 7)
par(mar = c(4, 4, 3, 2) + .1)
plot(
  lda.space[,2],
  lda.space[,1],
  col = colors,
  cex = (colors != "#FFFFFF") * 1.2,
  pch = pch,
  bty = "l",
  asp = 1,
  cex.lab = 1.2,
  ylim = c(min(lda.space[,1])-1, max(lda.space[,1])),
  xlab = "LDA 2",
  ylab = "LDA 1",
  axes = FALSE,
  mgp = c(2, 1, 0),
  lwd = ifelse(pch == 4, 1.5, 2)
)
axis(1, c(-8, -6, -4, -2, 0, 2, 4))
axis(2, c(-8, -6, -4, -2, 0, 2, 4))
legend(
  "bottomright", 
  legend = c("Marsh or Lake/Pond", "Grassland", "Scrub or Open Woodland", "Forest"), 
  col = c("blue", mybrown, "black", mygreen),
  pch = c(1, 17, 4, 16),
  bty = "n",
  cex = 1.2,
  lwd = c(2, 2, 1.5, 2),
  lty = 0
)
dev.off()



library(vegan)
rd = rda(t(coefs[, !is.na(hab)]) ~ lda.space[,1:2], scale = TRUE)

library(caret)
lda_accuracy = confusionMatrix(a$class, sub_hab)$overall

collapsed_lda = lda(x = t(coefs)[!is.na(hab), ], grouping = colors, CV = TRUE)
collapsed_lda_accuracy = confusionMatrix(collapsed_lda$class, colors)$overall


colnames(route.presence.absence)[!is.na(hab)][sub_hab == "Marsh" & a$class == "Grassland"]
colnames(route.presence.absence)[!is.na(hab)][sub_hab == "Marsh" & a$class == "Forest"]

