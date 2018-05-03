
# Basic population modeling
# this is the original exploratory script
# used to create yyApp from

model <- function(n0, r, K, t){
  
  # n0 <- 100; r <- .1; K <- 1000; t <- 50

  N <- NULL
  growth <- r
  N[1] <- n0
  

  for (i in 1:t){
    N[i+1] <- N[i] + growth*N[i]*(1 - N[i]/K) 
  }
  
  return(N)
}


x <- model(100, .1, 10000, 100)

plot(x)

a <- matrix(c(0, 3, 5, 0.2, 0, 0 , 0,  0.57, 0), nrow=3, byrow=T)
n <- c(0,100,0)

# =================================== Age Structured logistic growth model =====================================
# # x_ij * N move from age j to age i





leslie <- function(n, A, K, H, t, nYY, pYY = 1){
  
  # n is the vector of intial age-class abundances of reproducing females
  # A is the leslie matrix - fecundity is the per capita number of females produced by each age class
  # K is the carrying capacity in terms of total fish
  # t is the number of years to run the model
  # H is the harvest matrix: The diagonal elements are the percent of each age class harvested
  # nYY is the vector of initial YY male abundances - must be same length as n, and it is assumed the same number are stocked each year
  
  
  # sup_mat is to become the matrix with fecundity surpressed
  # N is a vector that keeps track of total population size
  # out is a matrix where each column is the vector of female abundances that year
  
  sup_mat <- A 
  I <- diag(dim(A)[1])
  N <- NULL
  out <- matrix(0, nrow = length(n), ncol = t)
  
  for (i in 1:t){
    
    out[,i] <- n
    N[i] <- sum(n)
    
    
    # print(c("n= ", n))
    # print((K-N[i])/K)
    # print(sup_mat-I)
    # print((sup_mat-I)%*%n)
    # print(((K-N[i])/K)*(sup_mat - I)%*%n )
    
    
    # source for below: A.L. Jensen 1995 page 46 equation 15
    # The fish population grows, post breeding census
    n <- n + ((K-N[i])/K)*(sup_mat - I)%*%n 
    
    # of the ones that survive, remove some
    n <- n - H%*%n
    
    # after removing some, add YY stock
    # Fish released are Myy supermales, producing only xy males
    # only a fraction of the YY stock (pYY) will successfully mate
    # Dampen the number by the percent expected to successfully mate with a female
    nYY <- nYY*pYY
    

    # if there are more successful males than females, 90% of the age class will mate with a YY male
    age_p <- ifelse(nYY/n < 1, nYY/n, 1)

    # the number of females that emerge next year will be reduced by
    # the percent of females that paired with YY males
    # The original fecundity rates are the ones that need to be suppressed each year by a potentially different number of YY males
    sup_mat[1,] <- A[1,]*(1-age_p)
    
    # a year passes and apply survival rates to YY males (same as females) and add new stock
    # zero fecundity since they produce no females
    B <- A
    B[1,] <- rep(0, times = length(B[1,]))
    nYY <- nYY + B%*%nYY

  }
  
  return(list(age_vec = out, pop_size = N))
}



#=================== inputs for pike =======================

# we will do 6 age classes. Fish 6 or older stay in the same class
# Growth is age-structured logistic


A <- matrix(c( 0, 0, 5, 10, 15, 30,
              .25,0,0,0,0,0,
               0,.4,0,0,0,0,
               0,0,.4,0,0,0,
               0,0,0,.6,0,0,
               0,0,0,0,.6,.6), nrow = 6, byrow = T)


H <- matrix(c(0,0,0,0,0,0,
              0,.1,0,0,0,0,
              0,0,.2,0,0,0,
              0,0,0,.2,0,0,
              0,0,0,0,.3,0,
              0,0,0,0,0,.3), nrow = 6, byrow = T)

n <- c(200,100,20,7,3,1)
nYY <- c(5,0,0,0,0,0)
H0 = matrix(rep(0, times = 36), nrow = 6)

x <- leslie(n=n, A=A, K = 10000, H=H, t=30, nYY = nYY, pYY=1)  


plot(1:length(x$pop_size), y =x$pop_size, xlab = "Year", ylab = "Total Pike", main = "Pike Extirpation")







