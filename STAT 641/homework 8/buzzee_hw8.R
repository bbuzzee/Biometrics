setwd("~/UAF COURSES/STAT 641/homework 8")
library(rjags)


###### PROBLEM 1 ######

# A is pre-debate, B is post debate
# The numbers are counts of participants that 
# prefer Bush, Dukakis, Other/No Opinion respectively

y.A <- c(294, 307, 38)
y.B <- c(288, 332, 19)

K <- 3

my.y.AAA <- rep(1:K, y.A)
my.y.BBB <- rep(1:K, y.B)

my.n.A <- sum(y.A)
my.n.B <- sum(y.B)


alpha <- rep(1, K)

my.data <- list(y.AAA = my.y.AAA, y.BBB = my.y.BBB,
                alpha = alpha,
                n.A = my.n.A, n.B = my.n.B,
                K = K)

my.fname <- "model_prior.txt"

jags <- jags.model(file = my.fname, data = my.data,
                   n.chains = 1, n.adapt = 1000)

# shift is the output from using a step function on alpha2 - alpha1
# so its a 1 if the proportion of those who like bush is higher post debate
# the mean of this is the prior probability that a higher proportion will prefer bush post debate
params<-c("theta.A","theta.B", "alpha1", "alpha2", "D" ,"shift")



mcmc.samples <- coda.samples(jags, params, 10000)

# answers to 1

# mean, sd, intervals
summary(mcmc.samples)
head(mcmc.samples)

# prior prob of shift towards bush
shift <- mcmc.samples[,4][[1]]
mean(shift)


############# PROBLEM 2 #############

alpha <- c(48, 48, 4)
# why these alphas? It's neutral and roughly the same proportions as the pre-debate survey

my.data <- list(y.AAA = my.y.AAA, y.BBB = my.y.BBB,
                alpha = alpha,
                n.A = my.n.A, n.B = my.n.B,
                K = K)

my.fname <- "model_prior.txt"

jags <- jags.model(file = my.fname, data = my.data,
                   n.chains = 1, n.adapt = 1000)


params<-c("theta.A","theta.B", "alpha1", "alpha2", "D" ,"shift")


mcmc.samples <- coda.samples(jags, params, 10000)



# mean, sd, intervals
summary(mcmc.samples)

# prior prob of shift towards bush
shift <- mcmc.samples[,4][[1]]
mean(shift)



############# PROBLEM 3 #############

alpha <- c(12, 12, 1)


my.data <- list(y.AAA = my.y.AAA, y.BBB = my.y.BBB,
                alpha = alpha,
                n.A = my.n.A, n.B = my.n.B,
                K = K)

my.fname <- "model_prior.txt"

jags <- jags.model(file = my.fname, data = my.data,
                   n.chains = 1, n.adapt = 1000)


params<-c("theta.A","theta.B", "alpha1", "alpha2", "D" ,"shift")



mcmc.samples <- coda.samples(jags, params, 10000)



# mean, sd, intervals
summary(mcmc.samples)
head(mcmc.samples)

# prior prob of shift towards bush
shift <- mcmc.samples[,4][[1]]
mean(shift)

####### PROBLEM 5 POSTERIOR DISTRIBUTION ###############

alpha <- rep(1, K)

my.data <- list(y.AAA = my.y.AAA, y.BBB = my.y.BBB,
                alpha = alpha,
                n.A = my.n.A, n.B = my.n.B,
                K = K)

my.fname <- "model.txt"

jags <- jags.model(file = my.fname, data = my.data,
                   n.chains = 1, n.adapt = 1000)

params<-c("theta.A","theta.B", "alpha1", "alpha2", "D" ,"shift")



mcmc.samples <- coda.samples(jags, params, 10000)



# mean, sd, intervals
summary(mcmc.samples)
head(mcmc.samples)

# prior prob of shift towards bush
shift <- mcmc.samples[,4][[1]]
mean(shift)

D <- mcmc.samples[,1][[1]]
hist(D, probability = T, main = "Posterior of D w/ Dir(1,1,1) Prior")


### PROBLEM 6

alpha <- c(12, 12, 1)

my.data <- list(y.AAA = my.y.AAA, y.BBB = my.y.BBB,
                alpha = alpha,
                n.A = my.n.A, n.B = my.n.B,
                K = K)

my.fname <- "model.txt"

jags <- jags.model(file = my.fname, data = my.data,
                   n.chains = 1, n.adapt = 1000)


params<-c("theta.A","theta.B", "alpha1", "alpha2", "D" ,"shift")



mcmc.samples <- coda.samples(jags, params, 10000)



# mean, sd, intervals
summary(mcmc.samples)
head(mcmc.samples)

# prior prob of shift towards bush
shift <- mcmc.samples[,4][[1]]
mean(shift)

D <- mcmc.samples[,1][[1]]
hist(D, probability = T, main = "Dirichlet(12,12,1) Prior")






