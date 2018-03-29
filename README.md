Hi another comment
# 503FinalProject
March Madness Tournament Model
## Aim
Implement a stacking model that is able to predict the round of a tournament play for NCAA Tournaments

## Implementation details
Need to implement the following:
- Random Forest Model - Base
- Neural Net Model - Base
- SVM
- Boosting
- Linear Model
- Functions for transforming data transforms
- Stacking Second and third layer
- Base aggregator - for the stacking model

Every prediction model needs the following:
- Data preprocessing function - Especially for neural nets. Most will be just identity
- Training function
- opt function
- CV function
- prediction function
- analytics function - To determine the loss function assigned to each model

Theoretical work
- Look for a good link function for moving ordinal to continuous scale
- Look into categorical predictor in place of ordinal (replace proportional odds with constant odds)
- Look for Netflix papers that reference stacking

# Document to-do
- Description of stacking
-- Need to build out flow charts such as the animation here: https://mlwave.com/kaggle-ensembling-guide/ or here http://www.overkillanalytics.net/more-is-always-better-the-power-of-simple-ensembles/
