# Calculating sample sizes for multinomial proportions
# Methods from Thomspon 1987, The American Statistician, Vol. 41 pg 42


# Objective:
# The probability is 1-alpha that each estimated proportion will be within the specified distance of the true value


# normal approximations to the binomial distribution work for two scenarios - n large, and npq > 3 
# both are an appeal to the CLT. npq > 3 implies counts are symmetric to begin with so it works for smaller n

multi_sample_size <- function(alpha, p){
  
  ns <- NULL
  
  # check equation 1 in paper for first handful of m's
  # since eq. 1 is largely decreasing (Appendix B in Paper)
  for (m in 1:15){
    ns[m] <- (qnorm(1-(alpha/(2*m)))^2*(1/m)*(1-1/m))/p^2
  }
  
  # m=1 means there is only one possible outcome, so exclude
  # then round up the highest value
  return(ceiling(max(ns[2:length(ns)])))
}
 

z <- multi_sample_size(.05, .05)




