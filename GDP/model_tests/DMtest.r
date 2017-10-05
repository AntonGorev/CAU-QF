##### Diebold-Mariano test statistic
DMtest <- function(d,l){
  
  # Diebold-Mariano test of predictive accuracy, JBES 1995, 13(3), p.253-263
  #
  # H0: equality of forecast accuracy of two forecasts
  # H1: difference of forecast accuracy of two forecasts
  #
  # d:		(T x 1) loss-differential series, usually e1^2-e2^2, where e1 and e2
  #				are the errors of two competing forecasts
  # l:        lag window (forecast step: h)
  # DMstat	Diebold-Mariano test statistic ~ N(0,1) distributed!!!
  # use: pnorm(DMstat, lower.tail = F) to get the p-value of the test!!!
  
  
  t_caps <- length(d)
  m <- mean(d)
  
  # Newey-West variance estimator
  e <- d-m
  lag <- seq(-l,l,1)
  gamma <- vector(length = (2*l+1))
  for (j in 1:(2*l+1)){
    gamma[j] <- t(e[(abs(lag[j])+1):t_caps])%*%e[1:(t_caps-abs(lag[j]))]/t_caps
  }
  weights <- 1-abs(t(lag)/(l+1))
  s2 <- sum(gamma*weights)/t_caps
  # test statistic
  DMstat <- m / sqrt(s2)
  p_val <- pnorm(abs(DMstat), lower.tail = FALSE)
  return(structure(
    list(DMStat = DMstat,
         p.value = p_val)))
}