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

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Population Growth Models"),
   

     plotOutput("distPlot"),
   
   # Sidebar with a slider input for number of bins 

        fluidRow(
          
         column(3,
         radioButtons(inputId = "growth",
                      label = "Type of Growth",
                      choices = list("Logistic" = 1,
                                     "Exponential" = 2)),
         numericInput(inputId = "K",
                      label = "Carrying Capacity",
                      value = 10000),
         
         textInput(inputId = "n", "Intial abundances (comma sep)", "1,10,20,10"),
         
         numericInput(inputId = "yy",
                      label = "Number of Age 1 YY males stocked each year",
                      value = 100)
         
         
         ),
         
         
         
         
         column(3,
                
         sliderInput(inputId = "s1",
                     label = "Yearly Survival % Age 1",
                     min = 0, max = 100, value = 25),
         sliderInput(inputId = "s2",
                     label = "Survival % Age 2-3",
                     min = 0, max = 100, value = 50),
         sliderInput(inputId = "s3",
                     label = "Survival % Age 4-5",
                     min = 0, max = 100, value = 50),
         sliderInput(inputId = "s4",
                     label = "Survival % Age 5+",
                     min = 0, max = 100, value = 50)
         ),
         
         column(3,

         numericInput(inputId = "f1",
                     label = "Age 1 produced by Age 1",
                     value = 2),
         numericInput(inputId = "f2",
                     label = "Age 1 produced by Age 2-3",
                     value = 10),
         numericInput(inputId = "f3",
                      label = "Age 1 produced by Age 4-5",
                      value = 20),
         numericInput(inputId = "f4",
                      label = "Age 1 produced by Age 5+",
                      value = 20)
         ),
         
         column(3,
                
                sliderInput(inputId = "materate",
                            label = "% of YY's that succesfuly mate with their age",
                            min = 0, max = 100, value = 25)

         )
         
         
         
         
         
         
        )
)

      




# to fix, assign all innputs values and run throug server code


server <- function(input, output) {
  
  leslie_log <- function(n, A, K){
    
    # n is the vector of intial age-class abundances
    # A is the leslie matrix
    # K is the carrying capacity
    # t is the number of years to run the model
    # H is a diagonal matrix of proportion harvested
    
    I <- diag(length(n))
    N <- NULL
    out <- matrix(0, nrow = length(n), ncol = 25)
    
    for (i in 1:25){
      
      out[,i] <- n
      N[i] <- sum(n)
      
      # source for below: A.L. Jensen 1995 page 46 equation 15
      n <- n + ((K-N[i])/K)*(A - I)%*%n  
    }
    
    return(list(age_vec = out, pop_size = N))
  }
  

  leslie_exp <- function(n, A, K){
    
    # n is the vector of intial age-class abundances
    # A is the leslie matrix
    # K is the carrying capacity
    # t is the number of years to run the model
    # H is a diagonal matrix of proportion harvested
    
    I <- diag(length(n))
    N <- NULL
    out <- matrix(0, nrow = length(n), ncol = 25)
    
    for (i in 1:25){
      
      out[,i] <- n
      N[i] <- sum(n)
      
      # source for below: A.L. Jensen 1995 page 46 equation 15
      n <- A%*%n
    }
    
    return(list(age_vec = out, pop_size = N))
  }
  
   
   output$distPlot <- renderPlot(
     if(input$growth == 1){
       
       
       # following lines are repeated twice - take out of if statement
       # diag elements should be zero
       
       n <- as.numeric(unlist(strsplit(input$n, ",")))
       A <- diag(4)
       A[2,1] <- input$s1*.01
       A[3,2] <- input$s2*.01
       A[4,3] <- input$s3*.01
       A[4,4] <- input$s4*.01
       
       A[1,] <- c(input$f1, input$f2, input$f3, input$f4)
       
       x <- leslie_log(n=n, A=A, K = input$K)
       
       plot(x$pop_size, ylab = "Population Size", xlab = "Years")
       
     }else{
       
       n <- as.numeric(unlist(strsplit(input$n, ",")))
       A <- diag(4)
       A[2,1] <- input$s1*.01
       A[3,2] <- input$s2*.01
       A[4,3] <- input$s3*.01
       A[4,4] <- input$s4*.01
       
       A[1,] <- c(input$f1, input$f2, input$f3, input$f4)
       

       z <- leslie_exp(n=n, A=A, K = input$K)
       
       plot(z$pop_size, ylab = "Population Size", xlab = "Years")
     }
   )
}

# Run the application 
shinyApp(ui = ui, server = server)


# A <- diag(4)
# A[2,1] <- 10*.01
# A[3,2] <- 10*.01
# A[4,3] <- 10*.01
# A[4,4] <- 10*.01
# 
# A[1,] <- c(10*.01, 10*.01, 10*.01,10*.01)
# A
# n <- c("10,20,30,40")
# n <- as.numeric(unlist(strsplit(n, ",")))
# 
# z <- leslie_exp(n=n, A=A, K=10000)
# 
# plot(z$pop_size)
