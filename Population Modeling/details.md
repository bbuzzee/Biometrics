---
output: html_document

---

# Model Details


Note: This is a model for female pike only. Initial abundances, carrying capacity, and fecundity should be in terms of females. Deaths and harvests occur post-breeding.
 
## Flow Without YY Males: 
We start with an initial population. After a year passes, next year's abundances are equal to offspring plus the females that either survive or grow into the next age class. Then a certain percent of Age 2+ females are manually harvested, leaving the abundance levels to start next year with. For logistic growth, the amount of offspring produced is suppressed depending on the current population size and carrying capacity.

## Introduction of YY Males

This is where the model can/should be tweaked to make it better reflect reality. 

Assumptions:

 1. We introduce a fixed number of YY males each year, all of Age 1.
 2. A fixed proportion of all age 2+ pike are harvested every year.
 3. YY males and wild females share the same survival rates.
 4. YY males only mate with females that are of the same age. 'Mating' means pairing off and that a male successfully fertilizes 100% of the females eggs.
 5.  __% of YY's that succesfuly mate with their age__ represents the proportion of the YY males we introduced that are __guaranteed__ to mate with females of the same age class for the rest of their life. This is equivalent to removing females from that age class because that number of females will no longer produce female offspring.

__Example__: Suppose there are 1000 Age 2 females, each of which produces 5 females. Without YY males, 5000 Age 1 females would be produced next year. After introducing YY males, suppose 200 survive to age 2, and "50% of them successfuly mate with their age." The following year only 900 females will create 5 female offspring, so 4500 Age 1 females are produced the next year.

Once the number of stocked YY males multplied by the percent that successfully mate outnumbers the number of females in that age class, no females are produced from that point on, and it takes several years for the remaining female pike to die off.






## The Math (for biometricians)

The matrix model formulation for logistic growth is taken from A.L. Jensen (1995) and is based on leslie matrix models. https://www.sciencedirect.com/science/article/pii/0304380093E0081D

Harvests are implemented by making the post-harvest vector of abundances equal to n - H*n where n is the vector of age abundances and H is a diagonal matrix with element [1,1] equal to zero since age 1's are not harvested. The other diagonal elements are the proportion harvested each year.
