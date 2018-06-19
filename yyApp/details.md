---
output: html_document

---


<br>
__Note:__ This is a model for female pike only. Initial abundances, carrying capacity, and fecundity should be in terms of females. Deaths and harvests occur post-breeding.
 
## Flow of Model Without YY Males: 
We start with an initial population. After a year passes, next year's abundances are equal to offspring plus the females that either survive or grow into the next age class. Then a certain percent of Age 2+ females are manually harvested, leaving the abundance levels to start next year with. For logistic growth, the amount of offspring produced is suppressed depending on the current population size and carrying capacity.

## Introduction of YY Males

This is where the model can/should be tweaked to make it better reflect reality. 

Assumptions:

 1. We introduce a fixed number of YY males each year, all of Age 1.
 2. A fixed proportion of age 2+ females (no YY males) are harvested every year.
 3. YY males and wild females share the same survival rates.
 4. YY males only fertilize eggs from females that are in the same age class.
 5. Fertilization happens pairwise, meaning a male successfully fertilizes 100% of only one females eggs.
 6.  __Probability of Successful YY Fertilization__ is the probability a YY male successfully fertilizes 100% of one females eggs. No females will be produced when a YY male successfuly fertilizes the eggs.

### Possible Improvements

Assumption 5 is definitely not realistic. But what is a simple way to mimic reality without introducing many unknown parameters?


## The Math (for biometricians)

The matrix model formulation for logistic growth is taken from A.L. Jensen (1995) and is based on leslie matrix models. https://www.sciencedirect.com/science/article/pii/0304380093E0081D

Harvests are implemented by subtracting a fixed proportion from all age classes except age 1. In matrix form, this means redefining the post-harvest vector of abundances to n - H*n where n is the vector of age abundances and H is a diagonal matrix with element [1,1] equal to zero since age 1's are not harvested. The other diagonal elements are the proportion harvested each year.

All the code is available at: https://github.com/bbuzzee/Biometrics/blob/master/yyApp/app.R
