### "MSPE-adjusted" test of Clark and West
CW_test <- function(e1,e2,yf1,yf2,nwlag){
  # Clark-West test
  # Alternative: larger model has smaller MSPE 
  # e1, e2: forecast errors
  # yf1 yf2: forecasts
  # nwlag: Newey-West lag window (forecast step: h)
  # output: CWstat statistic is t distributed with Inf degrees of freedom
  # to obtain a p-value of the test simply use: pt(CWstat, df = Inf, lower.tail = FALSE)
  
  P <- length(e1)
  froll_adj <- e1^2-( e2^2-(yf1-yf2)^2 )
  varfroll_adj <- nw(froll_adj,nwlag)
  CWstat <- sqrt(P)*(mean(froll_adj))/sqrt(varfroll_adj)
  p_val <- pt(abs(CWstat), df = Inf, lower.tail = FALSE)
  return(structure(
    list(CWStat = CWstat,
         p.value = p_val)))
} 

nw <- function(y,qn){
  #input: y is a T*k vector and qn is the truncation lag (forecast step: h)
  #output: the newey west HAC covariance estimator
  #Formulas are from Hayashi
  t_caps <- NROW(y); k <- NCOL(y); ybar <- matrix(1,t_caps,1)*((sum(y))/t_caps)
  dy <- y-ybar
  G0 <- t(dy)%*%dy/t_caps
  for (j in 1:(qn-1)){
    gamma <- (t(dy[(j+1):t_caps,])%*%dy[1:(t_caps-j),])/(t_caps-1)
    G0 <- G0+(gamma+t(gamma))*(1-abs(j/qn))
  }
  return(G0)
}