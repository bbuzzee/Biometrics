
# Robson and Regier 1964 sample size calculations






sample_size <- function(alpha, p, N){
  
   # p <- .1
   # N <- 5000
   # alpha <- .25
  # alpha is the precision (percent of time the confidence interval will contain the parameter)
  # p is the accuracy, the estimate will be within p% of the true value
  # N is the guesstimate of the population size
  
  # output will be M and C the number of fish that need to be captured 
  # during the first and second event respectively
  
  # phyper(q,m,n,k)
  # q = fish recaptures
  # m = number of fish captured in first event
  # n = N - n, number of non-tagged fish
  # k = number of fish captured in second event
  
  # in a lake with n+m fish, m have tags. Find the probability that q out of k fish captured
  # during the second event have tags
  
  #============================================
  # Chapmans algorithm:
  # 1: Guess values for M and C
  # 2: Substitute into probability statement to see if 1-alpha <= P(RL < R < RR)
  # 3. If true, decrease sample size, if false, increase 
  # 4. Return to Step 2 until the smallest values of M and C that satisfy eq. 2 are found
  #============================================
  

  check_prec <- function(guess){
    # function returns true or false 
    
    RU <- round(guess^2/((1-p)*N))
    RL <- round(guess^2/((1+p)*N))
    
    precision <- phyper(q = RU, m = guess, n = N-guess, k = guess) - phyper(q = RL, m = guess, n = N-guess, k = guess)
    
    return(1-alpha <= precision)
  }
  
  #2 
  # Calculate upper and lower bounds from Robson and Reiger 1964 pg 218
  

  # Find probability R is between these two values
  


  
  guess_vec <- NULL
  i <- 1
  guess_vec[i] <- round(N*.1)
  
  while (TRUE){
    
    if(length(guess_vec) > 1){
      if(check_prec(guess_vec[i]) & !check_prec(guess_vec[i-1])){
        break
    }}

    if(check_prec(guess_vec[i])){
      guess_vec[i+1] <- guess_vec[i] - 1
      i <- i + 1
      
    }else{
      guess_vec[i+1] <- guess_vec[i] + 1
      i <- i + 1
    }
  
    
  }
  
  return(list(captures = guess_vec[length(guess_vec)], iter = i))
  
}


sample_size(N = 25000, p = .25, alpha = .05)  
