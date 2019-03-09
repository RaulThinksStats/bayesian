#**************************************************************************
# Bayesian Analysis- bayes.R
#
# Author: Raul JTA
#
# Summary: Cursory overview of a simple bayesian analysis in R. 
#***************************************************************************


#***************************************************************************
# preliminary settings------------------------------------------------------
#***************************************************************************

library(tidyverse)
library(rstanarm)
library(ggmcmc)

#***************************************************************************
# setting up data-----------------------------------------------------------
#***************************************************************************

data("womensrole", package = "HSAUR3")
womensrole <- womensrole %>% as_tibble() %>%
  mutate(total = agree + disagree) 

womensrole %>% slice(1, 2, 3, 23, 24, 25)

#***************************************************************************
# exploring open paths  ----------------------------------------------------
#***************************************************************************

#frequentist model (negative binomial)
womensrole_glm_1 <- glm(cbind(agree, disagree) ~ education + gender,
                        data = womensrole, family = binomial(link = "logit"))
round(coef(summary(womensrole_glm_1)), 3)

#bayesian model
womensrole_bglm_1 <- stan_glm(cbind(agree, disagree) ~ education + gender,
                              data = womensrole,
                              family = binomial(link = "logit"), 
                              prior = student_t(df = 7), 
                              prior_intercept = student_t(df = 7),
                              chains = 4, iter = 100000,
                              warmup = 10000, thin = 50, seed = 36, cores = 6)

#point, interval, and covariance matrix estimates for bayesian
ci95 <- posterior_interval(womensrole_bglm_1, prob = 0.95, pars = "education")
round(ci95, 2)
cbind(Median = coef(womensrole_bglm_1), MAD_SD = se(womensrole_bglm_1))
summary(residuals(womensrole_bglm_1)) # not deviance residuals
cov2cor(vcov(womensrole_bglm_1))

#comparing parameters and point estimates
vcov(womensrole_bglm_1) - vcov(womensrole_glm_1)

#***************************************************************************
# visualizing estimates and diagnostics  -----------------------------------
#***************************************************************************

mcmc_mod <- ggs(womensrole_bglm_1)
ggs_traceplot(mcmc_mod, greek = T) 
ggs_density(mcmc_mod, greek = T)
ggs_caterpillar(mcmc_mod, line = 0, greek = T, sort = F)


