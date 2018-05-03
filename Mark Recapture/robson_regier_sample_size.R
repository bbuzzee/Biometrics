
# Sample Size Calculations Based on Robson and Regier 1964 
# Written by Ben Buzzee 4/26/2018



sample_size <- function(alpha, p, N){
  
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
  # Proposed Algorithm:
  # 1: Guess values for M and C
  # 2: Substitute into probability statement to see if 1-alpha <= P(RL < R < RR)
  # 3. If true, decrease sample size, if false, increase 
  # 4. Return to Step 2 until the smallest values of M and C that satisfy the eq. in line 2 are found
  #============================================
  
  # NOTE: to simplify the guessing and checking, we will assume M = C
  # in the phyper() parameterization, this means m = k

  check_prec <- function(guess){
    # function returns true or false 
    
    
    # Equivalent interpretation derived from Eq. 2 in paper:
    # For the guessed values of M and C, the probability
    # that N_hat is between N - Np and N + Np is (precision)
    
    RU <- round(guess^2/((1-p)*N))
    RL <- round(guess^2/((1+p)*N))
    
    precision <- phyper(q = RU, m = guess, n = N-guess, k = guess) - phyper(q = RL, m = guess, n = N-guess, k = guess)
    
    return(1-alpha <= precision)
  }
  

  # initialize values for looping procedure
  guess_vec <- NULL
  i <- 1
  guess_vec[i] <- round(N*.1)
  
  while (TRUE){
    
    # Check: Is the precision criteria met for the current guess but not the previous? If so, stop.
    if(length(guess_vec) > 1){
      if(check_prec(guess_vec[i]) & !check_prec(guess_vec[i-1])){
        break
      }
    }
    
    
    # Is the precion criteria met for M and C? If so, tick down sample size by 1 and check again.
    # If the precision criteria is not met, increase sample size and check again.
    if(check_prec(guess_vec[i])){
      
      guess_vec[i+1] <- guess_vec[i] - 1
      i <- i + 1
      
    }else{
      guess_vec[i+1] <- guess_vec[i] + 1
      i <- i + 1
    }
  
    
  }
  
  # return the number of fish that need to be captured in both events
  # and the number of iterations it took to get there 
  return(list(captures = guess_vec[length(guess_vec)], iter = i))
  
}


sample_size(N = 25000, p = .25, alpha = .05)  
