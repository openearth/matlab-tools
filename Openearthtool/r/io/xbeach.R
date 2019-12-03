# R file to read XBeach output
# very prelimary based on plotdata.m

# $Id: xbeach.R 5340 2011-10-14 13:47:25Z boer_g $
# $Date: 2011-10-14 06:47:25 -0700 (Fri, 14 Oct 2011) $
# $Author: boer_g $
# $Revision: 5340 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/r/io/xbeach.R $
# $Keywords: $

read.xbeach = function(datadir, parameter) {
  header <- readBin(file.path(datadir, "dims.dat"), double(), n=3)
  header[1] -> nt
  header[2] -> nx
  header[3] -> ny
  xy <- readBin(file.path(datadir, "xy.dat"), double(), n=(nx+1)*(ny+1)*2)
  dim(xy) <- c(nx+1, ny+1, 2)
  
  zb <- readBin(file.path(datadir, paste(parameter,".dat",sep="")), double(), n=(nx+1)*(ny+1)*nt)
  dim(zb) <- c(nx+1, ny+1,nt)
  if (ny == 2){
    x <- (xy[,2,1])
    y <- (xy[,2,2])
  }
  else{
    stop("ny is not equal to 2 but: ", ny)
  }
  zb = zb[,2,]
  return(list(x,y,zb))
}
# datadir <- "/Users/fedorbaart/Documents/checkouts/XBeach/trunk"
datadir <- "test/output"
result <- read.xbeach(datadir)
