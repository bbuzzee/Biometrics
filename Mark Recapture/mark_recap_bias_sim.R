# Mark Recapture Simulation Study
# To look at the consequences of different types of bias during one or both capture events

library(tidyverse)



mark_fish <- function(N, bias = "random", bias_amt = c(.7,.4)){
  
  # if bias criteria is met, the fish is tagged with probability bias[1], else prob is bias[2]
  # N is size of the entire fish population
  # Lengths are skewed
  
  # initialize population: locations and lengths

  x <- runif(n=N, min = 0, max = 1)
  y <- runif(n=N, min = 0, max = 1)
  lengths <- rgamma(n = N, shape = 5, scale = 50)
  
  
  # each row in fish_pop is a fish in the lake
  # a tagged column will determine whether it was caught during initial tagging event
  fish_pop <- data.frame(lengths, x, y)
  
  
  
  # potentially biased tagging stage
  
  # if all fish have equal probability of being captured
  if (bias == "random"){
  
    # size is the number of trials, so below is N bernoulli outcomes
    fish_pop$tagged <- rbinom(n = N, size = 1, p = .2)
  
    
  # if which half of the lake the fish is in influcnces prob of getting captured
  } else if (bias == "geo_bias") {
    
    num_true <- sum(fish_pop$y >= .5)
    num_false <- N-num_true
    
    fish_pop$tagged <- ifelse(test = fish_pop$y >= .5,
                              yes = rbinom(n = num_true, size = 1,p = bias_amt[1]),
                              no = rbinom(n = num_false, size = 1, p = bias_amt[2]))
    
  # if size influences prob of capture
  } else if (bias == "size_bias"){
    
    num_true <- sum(fish_pop$length >= 375)
    num_false <- N-num_true
    
    fish_pop$tagged <- ifelse(test = fish_pop$length >= 400,
                              yes = rbinom(n = num_true, size = 1, p = bias_amt[1]),
                              no = rbinom(n = num_false ,size = 1, p = bias_amt[2]))
  }
  
  return(fish_pop)
  
  }




recap_fish <- function(marked_pop, bias = "random", bias_amt = c(.7,.4)){
  
  N <- length(marked_pop$y)
  
  if (bias == "random"){
    
    marked_pop$recap <- rbinom(n = N, size = 1, p = .2)
    
    
  } else if (bias == "geo_bias") {
    
    # make a function to wrap these three lines -----==================================
    num_true <- sum(marked_pop$y >= .5)
    num_false <- N-num_true
    
    marked_pop$recap <- ifelse(test = marked_pop$y >= .5,
                               yes = rbinom(n = num_true, size = 1, p = bias_amt[1]),
                               no = rbinom(n = num_false, size = 1, p = bias_amt[2]))
    
    # big fish have .6 chance of getting tagged
    # small fish .1
    
  } else if (bias == "size_bias"){
    
    num_true <- sum(marked_pop$length >= 350)
    num_false <- N-num_true
    
    marked_pop$recap <- ifelse(test = marked_pop$length >= 350,
                               yes = rbinom(n = num_true, size = 1, bias_amt[1]),
                               no = rbinom(n = num_false, size = 1, bias_amt[2]))
    
  }
  marked_pop$both <- (marked_pop$tagged == 1 & marked_pop$recap == 1)
  return(marked_pop)
}
    
     
     

     
     

    
run_sim <- function(num_sims = 1000,
                    pop_size_per_sim = 1000,
                    event1bias = "random",
                    event2bias = "random",
                    bias_amt = c(.7,.4)){
  
  
  ests <- matrix(nrow = num_sims, ncol = 2)
  i <- 1
  
  while (i <= num_sims){
    
    out <- mark_fish(pop_size_per_sim, bias = event1bias, bias_amt = bias_amt) %>% recap_fish(bias = event2bias, bias_amt = bias_amt)
    
    n1 <- sum(as.logical(out$tagged))
    m <- sum(out$both)
    n2 <- sum(out$recap)
    lp <- n1*n2/m
    chap <- (n1+1)*(n2+1)/(m+1)
    ests[i,1] <- lp
    ests[i,2] <- chap
    
    i <- i+1
  }
  return(ests)
}


sim <- run_sim(1000)    



