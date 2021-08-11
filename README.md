# Sampling Distributions App

The objective of this application is to enable people to explore sampling
distributions of several statistics computed with samples coming from arbitrary
mixtures of probability distributions. 

## How to run it

This project uses `renv` to encapsulate packages and versions used to run this
application. You can clone this repository, call `renv::restore()` to install 
the packages in the `renv.lock` file, and then run 

```
shiny::shinyAppDir("src")
```

from the root of this project.

Anoher option is to install dependencies manually and run

```
shiny::runGitHub("tomicapretto/samplingdistributions", subdir = "src")
```

## How it works

### Add distributions to the mixture.

Choose one distribution at a time from the input on the left panel and click on **+**. 
This will add the distribution to the mixture and insert inputs to tune its 
parameters as well as the weight it has in the mixture. You can repeat this process 
as many times as you want, adding a new distribution to the mixture in each time.

### Tune sampling parameters

* **Sample size** is the number of draws we take from the (theoretical) mixture 
we construct. You can specify any integer number between 2 and 1000.
* **Repetitions** indicates how many times we repeat the sampling process. The larger
this number the better the approximation of the empirical sampling distribution. 
This must be between 10 and 1000.
* **Statistic** determines what statistic we compute with the sampled values. 
Currently, these are the available options:
  + Mean
  + Median
  + Minimum
  + Maximum
  + Percentile
* **Percentile** indicates which percentile we compute when we select Percentile option
in Statistic.

### Explore the charts

Just see the interactive charts and make up your conclusions!

## Dependencies

If you prefer to install dependencies manually, make sure you install the 
following libraries that are used directly by this app:

* echarts4r
* here
* katexR (from https://github.com/timelyportfolio/katexR)
* magrittr
* markdown
* purrr
* R6
* renv
* shiny
* shiny.semantic
* shinyjs