Hi another comment
# 503FinalProject
March Madness Tournament Model

## Things each model has to have:
1. Each model should run independently
1. Each model should be able to run on a variety of transformed data
  1. Each model should include variations for running on any number of transformed parameters, etc
1. Each model should output a single file with the following conventions
  * The name of the file should be: [model]_ [DataTransform].csv (no spaces)
    * [model] is the short name for the model
    * [DataTransform] is one of "orig", "pca", "dimrec", or "other"
  * Each output file should only have two columns:
    * The first is an identifier to tell us what team and what year
      * Perhaps this should be referenced to a standard mapping
    * The second should be the prediction
    * The aim of this simple setup is so that we can adapt the stacking model on the fly and not worry about the dependencies between the models
1. I have a feeling long will love to see CV of this stuff... make sure to include some and possibly output some graphics for it.

## Currently in work
- RF model
- NN Model

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


Variable Description:
- Rk -- Rank
- School -- * = NCAA Tournament appearance
- Overall
- G -- Games
- W -- Wins
- L -- Losses
- W-L% -- Win-Loss percentage
- SRS -- Simple Rating System
- A rating that takes into account average point differential and strength of schedule. The rating is denominated in points above/below average, where zero is average. Non-Division I games are excluded from the ratings.
- SOS -- Strength of Schedule
- A rating of strength of schedule. The rating is denominated in points above/below average, where zero is average. Non-Division I games are excluded from the ratings.
- Conf.
- W -- Conference Wins
- L -- Conference Losses
- Home
- W -- Wins
- L -- Losses
- Away
- W -- Wins
- L -- Losses
- Points
- Tm. -- Points
- Opp. -- Opponent Points
- School Advanced
- Pace -- Pace Factor
- An estimate of school possessions per 40 minutes.
- ORtg -- Offensive Rating
- An estimate of points scored (for teams) or points produced (for players) per 100 possessions.
- FTr -- Free Throw Attempt Rate
- Number of FT Attempts Per FG Attempt
- 3PAr -- 3-Point Attempt Rate
- Percentage of FG Attempts from 3-Point Range
- TS% -- True Shooting Percentage
- A measure of shooting efficiency that takes into account 2-point field goals, 3-point field goals, and free throws.
- TRB% -- Total Rebound Percentage
- An estimate of the percentage of available rebounds a player grabbed while he was on the floor.
- AST% -- Assist Percentage
- An estimate of the percentage of teammate field goals a player assisted while he was on the floor.
- STL% -- Steal Percentage
- An estimate of the percentage of opponent possessions that end with a steal by the player while he was on the floor.
- BLK% -- Block Percentage
- An estimate of the percentage of opponent two-point field goal attempts blocked by the player while he was on the floor.
- eFG% -- Effective Field Goal Percentage; this statistic adjusts for the fact that a 3-point field goal is worth one more point than a 2-point field goal.
- TOV% -- Turnover Percentage; an estimate of turnovers per 100 plays.
- ORB% -- Offensive Rebound Percentage; an estimate of the percentage of available offensive rebounds a player grabbed while he was on the floor.
- FT/FGA -- Free Throws Per Field Goal Attempt
