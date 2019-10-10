

#================================ Section 1 ====================================# 
# Exploring the logistic curve

# sources: https://www4.stat.ncsu.edu/~reich/ABA/code/GLM


# a script that illustrates logistic regression
ages <- sample(1:100, size = 1000, replace=TRUE)

lp <- .2*ages - 12

pr <- 1/(1 + exp(-lp))

# note: we know the true A50 is -(b0)/b1 = ?


y <- rbinom(1000, 1, prob = pr)

plot(ages, y = y)
lines(1/(1 + exp(-(.2*1:100 - 12))))


# Now lets try to estimate it using frequentist methods:
model1 <- glm(y ~ ages, family = "binomial")
summary(model1)

b0 <- coef(model1)[1]
b1 <- coef(model1)[2]

A50_hat <- -b0/b1



#================================ Section 2 ====================================# 
# Defining functions

library(rjags)


# generates binary outcomes using a logistic probability function
gen_data <- function(sample_size, type = "length", b0 = -17, b1 = .437){

  # generates binary outcomes using a logistic probability function
  # b0 and b1 defaults are from Hannah et al
  
  if(type == "length"){
  obs <- runif(n = sample_size, min = 10, max = 70)
  } else{
  obs <- runif(n = sample_size, min = 6, max = 45)
  }
  
  lp <- b0  + b1*obs
  pr <- 1/(1 + exp(-lp))
  
  y <- rbinom(sample_size, 1, prob = pr)

return(list(X = as.matrix(obs), n = length(y), Y = y))
}




get_widths <- function(sample, label = "label", lower_quantile = .05, upper_quantile = .95){
  
  # This function takes in samples from a posterior distribution and creates the credible interval
  # and pulls the median as the estimate. It also computes the width of the interval in terms of percent
  # of the estimate.
  
  print(paste0("Generating quantile information for ", label, "."))
  quants <- quantile(sample, probs = c(lower_quantile, .5, upper_quantile))
  width <-  (quants[3] - quants[1])/2
  est <- quants[2]
  width_perc <- abs(width/est)
  
  return(data.frame(width = width, est = est, width_perc = width_perc, row.names = label))
  
}




# needs diagnostics output
fit_logit <- function(dat, width = .90){
  
  
  
  upper_quantile = width + (1-width)/2
  lower_quantile = (1-width)/2
  

  logistic_model <- "model{
  
     # Likelihood
  
     for(i in 1:n){
      Y[i] ~ dbern(q[i])
      logit(q[i]) <- beta[1] + beta[2]*X[i,1]
  
     }
  
     # Priors
     # sigma is reciprocal

     for(j in 1:2){
      beta[j] ~ dnorm(0,0.01)
     }
  
    }"
  
  model <- jags.model(textConnection(logistic_model), data = dat, n.chains=3, quiet=TRUE)
  
  update(model, 1000, progress.bar="none")
  
  samp <- coda.samples(model, 
                       variable.names=c("beta"), 
                       n.iter=2000, progress.bar="none")
  
  # combines samples from three chains
  beta1_sample <-  rbind(samp[[1]][,1], samp[[2]][,1], samp[[3]][,1])
  beta2_sample <-  rbind(samp[[1]][,2], samp[[2]][,2], samp[[3]][,2])
  L50_sample <- -beta1_sample/beta2_sample
  
  # calculates relevant information
  beta1_width <- get_widths(beta1_sample, label = "beta1", lower_quantile = lower_quantile, upper_quantile = upper_quantile)
  beta2_width <- get_widths(beta2_sample, label = "beta2", lower_quantile = lower_quantile, upper_quantile = upper_quantile)
  L50_width <- get_widths(L50_sample, label = "L50", lower_quantile = lower_quantile, upper_quantile = upper_quantile)
  
  # put it all together
  beta_info <- rbind(beta1_width, beta2_width, L50_width)

  
  sample <-  data.frame(beta1 = beta1_sample, beta2 = beta2_sample)
  
  return(list(sample = samp, beta_info = beta_info))
       
}


#================================ Section 3 ====================================# 
# Testing and implementation

# single fit
# True L50 would be 60 using b0 = 12 and b1 = .2
dat <- gen_data(100, b0 = -12, b1 = .2)
fit <- fit_logit(dat)
fit$beta_info[3,]


# function to run multiple fits

find_upper <- function(sample_size, runs = 100){
  
  out <- matrix(nrow = runs, ncol = 3)
  
  for (i in 1:runs){
    dat <- gen_data(sample_size)
    fit <- fit_logit(dat)
    print(paste0("Adding ", fit$beta_info[3,], " to matrix."))
    out[i,] <- as.numeric(fit$beta_info[3,])
  }
 return(out)
  
}


d <- find_upper(sample_size = 80, runs = 100)

max(d[,3])
