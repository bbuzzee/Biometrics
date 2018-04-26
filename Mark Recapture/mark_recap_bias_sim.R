library(tidyverse)



# Mark Recapture Simulation Study

mark_fish <- function(N, bias = "random", bias_amt = c(.7,.4)){
  
  # if bias criteria is met, the fish is tagged with probability bias[1], else prob is bias[2]
  # N is size of the entire fish population
  # they have normally distributed lengths
  
  
  #=========
  # initialize population - locations, lengths, and probability of being tagged
  #=========
  
  x <- runif(n=N, min = 0, max = 1)
  y <- runif(n=N, min = 0, max = 1)
  lengths <- rnorm(n = N, mean = 300, sd = 100)
  
  fish_pop <- data.frame(lengths, x, y)
  
  
  
  #========
  # tagging stage
  #========
  
  # all fish have equal probability of being captured
  
  if (bias == "random"){
  
    fish_pop$tagged <- rbinom(n = N, size = 1, p = .2)
  
  # if fish are in the top half of the lake, they get caught with .6 prob
  # bottom half have .1 prob of getting caught
  
  } else if (bias == "geo_bias") {
    
    num_true <- sum(fish_pop$y >= .5)
    num_false <- N-num_true
    
    fish_pop$tagged <- ifelse(fish_pop$y >= .5, rbinom(n = num_true, size = 1, p = bias_amt[1]), rbinom(n = num_false, size = 1, p = bias_amt[2]))
    
    # big fish have .6 chance of getting tagged
    # small fish .1
    
  } else if (bias == "size_bias"){
    
    num_true <- sum(fish_pop$length >= 400)
    num_false <- N-num_true
    
    fish_pop$tagged <- ifelse(fish_pop$length >= 400, rbinom(n = num_true, size = 1, p = bias_amt[1]), rbinom(n = num_false ,size = 1, p = bias_amt[2]))
  }
  
  
  # fish_pop$tagged <- as.factor(fish_pop$tagged)
  
  return(fish_pop)
  
  }



dat <- mark_fish(100, bias = "random")
dat <- mark_fish(150, bias = "size_bias")
dat <- mark_fish(150, bias = "geo_bias")
dat %>% ggplot(aes(x=x,y=y, color = as.factor(tagged), size = lengths)) + geom_point()




















recap_fish <- function(marked_pop, bias = "random", bias_amt = c(.7,.4)){
  
  N <- length(marked_pop$y)
  
  if (bias == "random"){
    
    marked_pop$recap <- rbinom(n = N, size = 1, p = .2)
    
    
  } else if (bias == "geo_bias") {
    
    # make a function to wrap these three lines -----==================================
    num_true <- sum(marked_pop$y >= .5)
    num_false <- N-num_true
    
    marked_pop$recap <- ifelse(marked_pop$y >= .5, rbinom(n = num_true, size = 1, p = bias_amt[1]), rbinom(n = num_false, size = 1, p = bias_amt[2]))
    
    # big fish have .6 chance of getting tagged
    # small fish .1
    
  } else if (bias == "size_bias"){
    
    num_true <- sum(marked_pop$length >= 350)
    num_false <- N-num_true
    
    marked_pop$recap <- ifelse(marked_pop$length >= 350, rbinom(n = num_true, size = 1, bias_amt[1]), rbinom(n = num_false, size = 1, bias_amt[2]))
    
  }
  marked_pop$both <- (marked_pop$tagged == 1 & marked_pop$recap == 1)
  return(marked_pop)
}
    
     
     
out <- mark_fish(1000) %>% recap_fish(bias = "geo_bias")
     
     
    
    n1 <- sum(as.logical(out$tagged))
    m <- sum(out$both)
    n2 <- sum(out$recap)
    
    n1*n2/m
    (n1+1)*(n2+1)/(m+1)
    
    
run_sim <- function(n){
  
  ests <- matrix(nrow = n, ncol = 2)
  i <- 1
  
  while (i < n){
    
    out <- mark_fish(1000, bias = "size_bias", bias_amt = c(.8,.4)) %>% recap_fish(bias = "geo_bias", bias_amt = c(.6,.4))
    
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

hist(sim[,1])
hist(sim[,2])
