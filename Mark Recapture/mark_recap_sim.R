# Mark Recapture Simulation 
# To look at the consequences of different types of bias during one or both capture events
# and coverage probability of different types of confidence intervals

library(tidyverse)


#==== Stage 1: Create fish population and mark them 

mark_fish <- function(N, bias = "random", bias_amt = c(.5,.2)){
  
  # if bias criteria is met, the fish is tagged with probability bias[1], else prob is bias[2]
  # N is size of the entire fish population
  # Lengths are skewed
  
  # initialize population: locations and lengths

  x <- runif(n=N, min = 0, max = 1)
  y <- runif(n=N, min = 0, max = 1)
  lengths <- rgamma(n = N, shape = 5, scale = 50)
  
  
  # each row in fish_pop is a fish in the lake

  fish_pop <- data.frame(lengths, x, y)
  
  
  
  # potentially biased tagging stage
  # a tagged column will determine whether it was caught during initial tagging event
  
  # if all fish have equal probability of being captured
  if (bias == "random"){
  
    # size is the number of trials, so below is N iid bernoulli outcomes
    fish_pop$M <- rbinom(n = N, size = 1, p = bias_amt[2])
  
    
  # if which half of the lake the fish is in changes capture prob
  } else if (bias == "geo_bias") {
    
    num_true <- sum(fish_pop$y >= .5)
    num_false <- N-num_true
    
    fish_pop$M <- ifelse(test = fish_pop$y >= .5,
                              yes = rbinom(n = num_true, size = 1,p = bias_amt[1]),
                              no = rbinom(n = num_false, size = 1, p = bias_amt[2]))
    
  # if size influences capture prob
  } else if (bias == "size_bias"){
    
    num_true <- sum(fish_pop$length >= 375)
    num_false <- N-num_true
    
    fish_pop$M <- ifelse(test = fish_pop$length >= 375,
                              yes = rbinom(n = num_true, size = 1, p = bias_amt[1]),
                              no = rbinom(n = num_false ,size = 1, p = bias_amt[2]))
  }
  
  return(fish_pop)
  
  }



# ==== Stage 2: Recapture event 

recap_fish <- function(marked_pop, bias = "random", bias_amt = c(.5,.2)){
  
  N <- length(marked_pop$y)
  
  if (bias == "random"){
    
    marked_pop$C <- rbinom(n = N, size = 1, bias_amt[2])
    
    
  } else if (bias == "geo_bias") {
    
    # ============= make a function to wrap these three lines ===============
    num_true <- sum(marked_pop$y >= .5)
    num_false <- N-num_true
    
    marked_pop$C <- ifelse(test = marked_pop$y >= .5,
                               yes = rbinom(n = num_true, size = 1, p = bias_amt[1]),
                               no = rbinom(n = num_false, size = 1, p = bias_amt[2]))
    
    
  } else if (bias == "size_bias"){
    
    num_true <- sum(marked_pop$length >= 375)
    num_false <- N-num_true
    
    marked_pop$C <- ifelse(test = marked_pop$length >= 375,
                               yes = rbinom(n = num_true, size = 1, bias_amt[1]),
                               no = rbinom(n = num_false, size = 1, bias_amt[2]))
    
  }
  
  marked_pop$R <- ((marked_pop$M == 1) & (marked_pop$C == 1))
  return(marked_pop)
}
    
     
     

     
     
# left off: fringe cases for phat and m on pg 63 of seber
# employ different techniques depending on scenario and compare
    
run_sim <- function(num_sims = 1000,
                    pop_size_per_sim = 1000,
                    event1bias = "random",
                    event2bias = "random",
                    bias_amt1 = c(.5,.2),
                    bias_amt2 = c(.5,.2)){
  
  
  estimates <- data.frame(pop = rep(pop_size_per_sim, times = num_sims))
  i <- 1
  
  while (i <= num_sims){
    
  
    out <- mark_fish(pop_size_per_sim, bias = event1bias, bias_amt = bias_amt1) %>% recap_fish(bias = event2bias, bias_amt = bias_amt2)
    
    
    M <- sum(out$M)
    C <- sum(out$C)
    R <- sum(out$R)
    
    
    
    estimates$M[i] <- M
    estimates$C[i] <- C
    estimates$R[i] <- R
   
    lp <- (M*C)/R
    chap <- (M + 1)*(C + 1)/(R + 1)
    
    estimates$lp[i] <- lp
    estimates$chap[i] <- chap
     
    # varianceS rom Ricker 1975 pg 78

    estimates$var_lp[i] <- M^2*C*(C-R)/R^3
    estimates$inv_lp[i] <- 1/estimates$lp[i]
    estimates$var_inv_lp[i] <- (R*(C-R))/(M^2*C^3)
    
    estimates$z_lower[i] <- estimates$lp[i] - 1.96*sqrt(estimates$var_lp[i])
    estimates$z_upper[i] <- estimates$lp[i] + 1.96*sqrt(estimates$var_lp[i])
    
    estimates$inv_z_lower[i] <- 1/(estimates$inv_lp[i] + 1.96*sqrt(estimates$var_inv_lp[i]))
    estimates$inv_z_upper[i] <- 1/(estimates$inv_lp[i] - 1.96*sqrt(estimates$var_inv_lp[i]))
    
    # source for pois interval http://ms.mcmaster.ca/peter/s743/poissonalpha.html
    # Find interval for R, then use it in lp estimate for N
    estimates$pois_lower[i] <- (estimates$C[i]*estimates$M[i])/(qchisq(0.975, 2*estimates$R[i])/2)
    estimates$pois_upper[i] <- (estimates$C[i]*estimates$M[i])/(qchisq(0.025, 2*estimates$R[i])/2)
    
    
    i <- i+1
  }
  
  return(as_tibble(estimates))
}


sim <- run_sim(num_sims = 1000, pop_size_per_sim = 300, bias_amt1 = c(0,.15), bias_amt2 = c(0,.2))    

sim <- sim %>% mutate(z_yes = (pop <= z_upper & pop >= z_lower),
                      inv_z_yes = (pop <= inv_z_upper & pop >= inv_z_lower),
                      pois_yes = (pop >= pois_lower & pop <= pois_upper) )


sum(sim$z_yes/length(sim$z_yes))
sum(sim$inv_z_yes/length(sim$inv_z_yes))
sum(sim$pois_yes/length(sim$pois_yes))

mean(sim$R)
sim

hist(1/sim$chap)
hist(1/sim$lp)
