load("birds.Rdata")
png("figures/map.png", width = 3200, height = 2800, res = 1000)
library(maps)
library(mapdata)
library(mapproj)

proj = "albers"
parameters = c(29.5, 45.5)
par("mai" = c(0, 0, 0, 0))
map(
  "worldHires", 
  proj = proj,
  parameters = parameters,
  res = 0,
  interior = TRUE,
  ylim = c(25, 75),
  xlim = c(-167, -53),
  col = "gray",
  mar = c(0, 0, 0, 0),
  myborder = 0,
  orientation = c(95, -102, 0),
  lwd = 1
)
points(
  mapproject(latlon[,1], latlon[,2]),
  col = in.train + 2 * in.test,
  pch = 16,
  cex = (in.train | in.test) * .2
)
dev.off()