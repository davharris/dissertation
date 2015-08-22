# Figure for correlated pairs of species

library(MASS)
set.seed(1)

# Red is mean(x_i * y_i): includes covariance information
# Black is mean(x_i) * mean(y_i): no covariance

n = 100

Sigma0 = matrix(c(0,0,0,0), ncol = 2)
Sigma1 = matrix(c(5, -4.95, -4.95, 5), ncol = 2) * 2
Sigma2 = matrix(c(6, 5.5, 5.5, 6), ncol = 2)
Sigma3 = matrix(c(4,0,0,4), ncol = 2)

# Ensure that both species will occur exactly half the time:
deviations = scale(
  mvrnorm(n = n, mu = c(0, 0), Sigma = Sigma2),
  scale = FALSE
)

# Scaling didn't actually work quite right...

p = plogis(deviations)



plot(
  p, 
  xlim = c(0, 1), 
  ylim = c(0,1),
  pch = 20, 
  col = "#00000070", 
  xaxs = "i", 
  yaxs = "i",
  xlab = "Probability of observing Species X",
  ylab = "Probability of observing Species Y",
  asp = 1,
  cex = 1,
  axes = FALSE
)
axis(1, c(0, .5, 1))
axis(2, c(0, .5, 1))
abline(v = c(0, 1), h = c(0, 1))


mean(apply(p, 1, prod))
prod(colMeans(p))

