#!/usr/bin/env r

# $Id: elevation.R 5340 2011-10-14 13:47:25Z boer_g $
# $Date: 2011-10-14 06:47:25 -0700 (Fri, 14 Oct 2011) $
# $Author: boer_g $
# $Revision: 5340 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/r/spatial/elevation.R $
# $Keywords: $

library("fields")
library("ncdf")
library("geoR")
## Not run: 
# generating a simulated data-set
ex.data <- grf(50, cov.pars=c(10, .25))
#
# defining the grid of prediction locations:
ex.grid <- as.matrix(expand.grid(seq(0,1,l=21), seq(0,1,l=21)))
#
# computing posterior and predictive distributions
# (warning: the next command can be time demanding)
ex.bayes <- krige.bayes(ex.data, loc=ex.grid, prior =
                 prior.control(phi.discrete=seq(0, 2, l=21)))
#
# Prior and posterior for the parameter phi
plot(ex.bayes, type="h", tausq.rel = FALSE, col=c("red", "blue"))
#
# Plot histograms with samples from the posterior
par(mfrow=c(3,1))
hist(ex.bayes)
par(mfrow=c(1,1))

# Plotting empirical variograms and some Bayesian estimates:
# Empirical variogram
plot(variog(ex.data, max.dist = 1), ylim=c(0, 15))
# Since ex.data is a simulated data we can plot the line with the "true" model 
lines(ex.data)
# adding lines with summaries of the posterior of the binned variogram
lines(ex.bayes, summ = mean, lwd=1, lty=2)
lines(ex.bayes, summ = median, lwd=2, lty=2)
# adding line with summary of the posterior of the parameters
lines(ex.bayes, summary = "mode", post = "parameters")

# Plotting again the empirical variogram
plot(variog(ex.data, max.dist=1), ylim=c(0, 15))
# and adding lines with median and quantiles estimates
my.summary <- function(x){quantile(x, prob = c(0.05, 0.5, 0.95))}
lines(ex.bayes, summ = my.summary, ty="l", lty=c(2,1,2), col=1)

# Plotting some prediction results
op <- par(no.readonly = TRUE)
par(mfrow=c(2,2))
par(mar=c(3,3,1,1))
par(mgp = c(2,1,0))
image(ex.bayes, main="predicted values")
image(ex.bayes, val="variance", main="prediction variance")
image(ex.bayes, val= "simulation", number.col=1,
      main="a simulation from the \npredictive distribution")
image(ex.bayes, val= "simulation", number.col=2,
      main="another simulation from \nthe predictive distribution")
#
par(op)
## End(Not run)
##
## For a extended list of exemples of the usage of krige.bayes()
## see http://www.leg.ufpr.br/geoR/tutorials/examples.krige.bayes.R
##


## filename <- "../../../OpenEarthRawData/trunk/rijkswaterstaat/vaklodingen/raw/grid/KB117_4140_19960101.asc.nc"
## ncfile <- open.ncdf(filename)
## Z <- get.var.ncdf(ncfile,"Band1")
## Z[Z==-32768] <- NA
## image(Z)
## X <- 1:dim(Z)[1]
## Y <- 1:dim(Z)[2]
