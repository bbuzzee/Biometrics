#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)
library(tidyverse)


ui <- fluidPage(
   
   # Application title
   titlePanel("Pike Population Modeling"),
   

     plotOutput("distPlot"),
   
   # create three rows of input widgets  

        fluidRow(
          
         column(3,
         radioButtons(inputId = "growth",
                      label = "Type of Growth",
                      choices = list("Logistic" = 1,
                                     "Exponential" = 2)),
         numericInput(inputId = "K",
                      label = "Carrying Capacity",
                      value = 5000),
         
         textInput(inputId = "n", "Intial age class abundances (comma sep)", "1000,50,40,10")
        
         
         ),
         
         
         
         
         column(3,
                
         sliderInput(inputId = "s1",
                     label = "Yearly Survival % Age 1",
                     min = 0, max = 1, value = .25),
         sliderInput(inputId = "s2",
                     label = "Survival % Age 2-3",
                     min = 0, max = 1, value = .6),
         sliderInput(inputId = "s3",
                     label = "Survival % Age 4-5",
                     min = 0, max = 1, value = .6),
         sliderInput(inputId = "s4",
                     label = "Survival % Age 5+",
                     min = 0, max = 1, value = .4)
         ),
         
         column(3,

         numericInput(inputId = "f1",
                     label = "Age 1 produced by Age 1",
                     value = 0),
         numericInput(inputId = "f2",
                     label = "Age 1 produced by Age 2-3",
                     value = 5),
         numericInput(inputId = "f3",
                      label = "Age 1 produced by Age 4-5",
                      value = 10),
         numericInput(inputId = "f4",
                      label = "Age 1 produced by Age 5+",
                      value = 15)
         ),
         
         column(3,
                
                numericInput(inputId = "num_yy",
                             label = "Number of Age 1 YY males stocked each year",
                             value = 100),
                
                sliderInput(inputId = "materate",
                            label = "% of YY's that succesfuly mate with their age",
                            min = 0, max = 1, value = .75),
                sliderInput(inputId = "hrate",
                            label = "% of age 2+ harvested each year",
                            min = 0, max = 1, value = .5)

         )
         
         
         
         
         
         
        )
)

      




# to fix, assign all innputs values and run throug server code


server <- function(input, output) {
  
  leslie_log <- function(n, A, K, H, nYY, pYY = 1){
    
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
    I <- diag(length(n))
    N <- NULL
    out <- matrix(0, nrow = length(n), ncol = 25)
    
    for (i in 1:25){
      
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
      age_p <- ifelse(nYY/n < .99, nYY/n, 1)
      
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
    
    #list(age_vec = out, pop_size = N)
    return(data.frame(pop_size = N))
  }
  

  leslie_exp <- function(n, A, K, H, nYY, pYY = 1){
    
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
    I <- diag(length(n))
    N <- NULL
    out <- matrix(0, nrow = length(n), ncol = 25)
    
    for (i in 1:25){
      
      out[,i] <- n
      N[i] <- sum(n)
      
      
      
      # The fish population grows, post breeding census
      n <- sup_mat%*%n 
      
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
    
    # for objects w/ differing number of rows output a list
    # list(age_vec = out, pop_size = N)
    return(data.frame(pop_size = N))
  }
  
   
   output$distPlot <- renderPlot(
     
     
     
     
     if(input$growth == 1){
       
       
       # following lines are repeated twice - take out of if statement
       # diag elements should be zero
       
       # create A matrix
       n <- as.numeric(unlist(strsplit(input$n, ",")))
       A <- diag(length(n))
       diag(A) <- 0
       
       A[2,1] <- input$s1
       A[3,2] <- input$s2
       A[4,3] <- input$s3
       A[4,4] <- input$s4
       
       A[1,] <- c(input$f1, input$f2, input$f3, input$f4)
       
       
       # create H matrix 
       
       H <- diag(length(n))
       diag(H) <- c(0, rep(input$hrate, times = length(n)-1))
       
       nYY <- c(input$num_yy,0,0,0)
       
       z <- leslie_log(n=n, A=A, H=H, nYY = nYY, pYY = input$materate, K = input$K)
       xint <- ifelse(test = is.finite(min(which(z$pop_size < 1))), yes = min(which(z$pop_size < .5)), no = NaN)
       
       z %>% ggplot(aes(x = 1:length(pop_size),y=pop_size)) + geom_line(size = 1.05) +
         geom_vline(aes(xintercept = xint, color = paste("Year:", xint)), show.legend=T) + xlab("Year") + ylab("Population Size") +
         scale_color_manual(name = "Extirpation", values = "red") +
         theme(legend.position = c(.9,.9)) 
       
      
       
       
     }else{
       
       # following lines are repeated twice - take out of if statement
       # diag elements should be zero
       
       # create A matrix
       n <- as.numeric(unlist(strsplit(input$n, ",")))
       A <- diag(length(n))
       diag(A) <- 0
       
       A[2,1] <- input$s1
       A[3,2] <- input$s2
       A[4,3] <- input$s3
       A[4,4] <- input$s4
       
       A[1,] <- c(input$f1, input$f2, input$f3, input$f4)
       
       
       # create H matrix 
       
       H <- diag(length(n))
       diag(H) <- c(0, rep(input$hrate, times = length(n)-1))
       
       nYY <- c(input$num_yy,0,0,0)
      
       
       z <- leslie_exp(n=n, A=A, H=H, nYY = nYY, pYY = input$materate, K = input$K)
       xint <- ifelse(test = is.finite(min(which(z$pop_size < 1))), yes = min(which(z$pop_size<.5)), no = NaN)
       
       
       z %>% ggplot(aes(x = 1:length(pop_size),y=pop_size)) + geom_line(size = 1.05) +
         geom_vline(aes(xintercept = xint, color = paste("Year:", xint)), show.legend=T) + xlab("Year") + ylab("Population Size") +
         scale_color_manual(name = "Extirpation", values = "red") +
         theme(legend.position = c(.9,.9))
    
     }
   )
}

# Run the application 
shinyApp(ui = ui, server = server)

# 
# A <- diag(4)
# A[2,1] <- .1
# A[3,2] <- .1
# A[4,3] <- .1
# A[4,4] <- .1
# A[1,] <- c(0,.1,.1,.1)
# 
# H <- diag(4)
# diag(H) <- .5
# 
# nYY <- c(1000,10,10,10)
# 
# n <- c("10,20,30,40")
# n <- as.numeric(unlist(strsplit(n, ",")))
# 
# z <- leslie_exp(n=n, A=A, K=1000, H = H, nYY = nYY)
# 
# 
# z %>% ggplot(aes(x= 1:length(pop_size),y=pop_size)) + geom_line() + geom_vline(xintercept = min(which(z$pop_size<.5)))
# plot(z)
# 
# diag(A) <- 0



# N <- NULL
# K <- 5000
# n <- c(200,100,100,900)
# sup_mat <- diag(c(.25,.6,.6,.6))
# I <- diag(length(n))
# 
# for(i in 1:30){
#   N[i] <- sum(n)
#   n <- n + ((K-N[i])/K)*(sup_mat - I)%*%n
# }



