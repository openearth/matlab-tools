
# $Id: OPeNDAP_access_with_R_tutorial.R 5340 2011-10-14 13:47:25Z boer_g $
# $Date: 2011-10-14 06:47:25 -0700 (Fri, 14 Oct 2011) $
# $Author: boer_g $
# $Revision: 5340 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/r/io/opendap/OPeNDAP_access_with_R_tutorial.R $
# $Keywords: $

# This document is also posted on a wiki: http://public.deltares.nl/display/OET/OPeNDAP+access+with+matlab

# Provided by Karline Soetaert (http://www.nioo.knaw.nl/users/ksoetaert) and Tom Engeland (http://www.nioo.knaw.nl/users/tvanengeland).
# Go to an OPeNDAP server (e.g. http://opendap.deltares.nl) and pick a netCDF file by copying the contents of the Data URL box. Because the netcdf packages for windows are not yet opendap-enabled, download them as a workaround.
url_grid <-
"http://opendap.deltares.nl/thredds/fileServer/opendap/rijkswaterstaat/vaklodingen_remapped/vaklodingenKB116_4544.nc"

url_time <-
"http://opendap.deltares.nl/thredds/fileServer/opendap/rijkswaterstaat/waterbase/concentration_of_suspended_matter_in_sea_water/id410-DELFZBTHVN.nc"

download.file(url_grid, "vaklodingenKB116_4544.nc", method = "auto",
quiet = FALSE, mode="wb", cacheOK = TRUE)

download.file(url_time, "id410-DELFZBTHVN.nc", method = "auto",
quiet = FALSE, mode="wb", cacheOK = TRUE)

# After manual downloading files from the internet
require(ncdf)
grid.nc <- open.ncdf("vaklodingenKB116_4544.nc")

# look what's in there...
grid.nc

# Get grid data
G.x <- get.var.ncdf(grid.nc,'x')
G.y <- get.var.ncdf(grid.nc,'y')

# get only first timestep
G.z <- get.var.ncdf(grid.nc,'z')[,,1]

# to get a black background, and set the scale of depth values to start from 0.
G.z[G.z == -9999] <- 0

# image.plot needs sorted x- and y-values;
# as y-values are descending, the order is reversed here...
G.y <- rev(G.y)
G.z <- G.z[,length(G.y):1]

# R-package fields provides nice image facilities and color schemes
par (mfrow = c(1,2))
library(fields)
image.plot(G.x,G.y,as.matrix(G.z),
        col = c(tim.colors(),"black"),
        xlab = "x [m]", ylab = "y [m]")


time.nc <- open.ncdf("id410-DELFZBTHVN.nc")
time.nc

T.t <- get.var.ncdf(time.nc,'time')
T.eta <-
get.var.ncdf(time.nc,'concentration_of_suspended_matter_in_sea_water')

plot(as.Date(T.t, origin="1970-01-01"), T.eta, type = "l", ylab = "spm
[mg/l]")
 