# OPeNDAP_subsetting_with_R_tutorial: Author: Maarten Plieger (KNMI), date: 2011-Oct-10

# $Date: 2011-10-14 06:47:25 -0700 (Fri, 14 Oct 2011) $
# $Revision: 5340 $
# $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/r/io/opendap/OPeNDAP_subsetting_with_R_tutorial.R $

# This document is also posted on a wiki: http://public.deltares.nl/display/OET/OPeNDAP+subsetting+with+R

# R script to obtain data from opendap and convert it to a SpatialGridDataFrame

# Install the required packages:
# To install sp, use the command: install.packages("sp")
# To install ncdf for linux, use the command: install.packages("ncdf")
# To install ncdf for Windows, you need to install a precompiled version by: 
# Menu->Packages->Install Package(s) from local zip files and select ncdf.zip
# Pre compiled versions for windows with opendap are currently experimental

# Load the packages:
library("sp")
library("ncdf")

getOpenDapURLAsSpatialGrid = function(opendapURL,variableName,bboxInDegrees){
  print(paste("Loading opendapURL",opendapURL));
  # Open the dataset
  dataset = open.ncdf(opendapURL)


  bbox=bboxInDegrees;
  # Get lon and lat variables, which are the dimensions of depth. For this specific dataset they have the names lon and lat
  G.x=get.var.ncdf(dataset,"lon")
  G.y=get.var.ncdf(dataset,"lat")

  # Make a selection of indices which fall in our subsetting window
  # E.g. translate degrees to indices of arrays.
  xindicesinwindow=which(G.x>bbox[1]&G.x<bbox[3]);
  xmin=min(xindicesinwindow)
  xmax=max(xindicesinwindow)
  xcount=(xmax-xmin)+1; # needs to be at least 1

  yindicesinwindow=which(G.y>bbox[2]&G.y<bbox[4]);
  ymin=min(yindicesinwindow)
  ymax=max(yindicesinwindow)
  ycount=(ymax-ymin)+1;# needs to be at least 1
  
  print(paste("Indices:",xmin,ymin,xmax,ymax));# <== print bbox in indices

  # Get the variable depth
  G.z=get.var.ncdf(dataset, variableName,start=c(xmin,ymin), count=c(xcount,ycount));

  # Transpose this dataset, sometimes X and Y are swapped
  #G.z=t(G.z)
  
  # At the beginning we loaded the complete lat and lon variables
  # in order to find which indices belong in our subset window
  # In order to create a spatialdatagrid frame, we need to make the lat and lon variables
  # the same size as the requested matrix. E.g. The lat and lon (or y and x) needs to be subsetted:
  G.sx = G.x[xmin:xmax]
  G.sy = G.y[ymin:ymax]

  # Optionally create dims with equal cellsizes
  # This is sometimes needed because there can be small errors in the values of the x and y variables.
  makeCellsizesEqual=TRUE
  if(makeCellsizesEqual){
    # Make cellsizes equal for X dimension
    cellsizex=(G.sx[length(G.sx)]-G.sx[1])/(length(G.sx)-1)
    tempX=(((1:length(G.sx))-1))*cellsizex+G.sx[1]
    G.sx=tempX

    # Make cellsizes equal for Y dimension
    cellsizey=(G.sy[length(G.sy)]-G.sy[1])/(length(G.sy)-1)
    tempY=(((1:length(G.sy))-1))*cellsizey+G.sy[1]
    G.sy=tempY
  }

  # We have now x, y, and z complete. In order to create a SpatialGridDataFrame
  # We need to make the shape of all variables the same
  # This means that the x and y variables also need to become a matrix.

  # Create a matrix of X values
  G.mx=rep(G.sx,dim(G.z)[2])

  # Create a matrix field of Y values
  G.my=(as.vector(t(matrix(rep(G.sy,dim(G.z)[1]),nrow=dim(G.z)[2],ncol=dim(G.z)[1]))))

  # Make a dataframe of the X, Y and Z values
  myspatialgrid=data.frame(topo=as.vector(G.z),lon=G.mx,lat=G.my)

  # We have now gathered all information required to create a SpatialGridDataFrame object

  # Assign X and Y coordinates
  coordinates(myspatialgrid)=~lon+lat

  # Make a gridded dataset, previousely the object was just a bunch of points with XY coodinates
  gridded(myspatialgrid) = TRUE
  fullgrid(myspatialgrid) = TRUE

  # This can be converted to a SpatialGridDataFrame
  myspatialgrid = as(myspatialgrid, "SpatialGridDataFrame")

  # Optionally assign a projection string to this object
  attributes(myspatialgrid)$proj4string=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs  <>")

  myspatialgrid;
}


# Set the bounding box window we want to subset for, in degrees
# order: min-x, min-y, max-x, max-y
bboxInDegrees=c(0,50,10,55)

url_grid = array();
url_grid[1] = 'http://geoport.whoi.edu/thredds/dodsC/bathy/etopo1_bed_g2';
url_grid[2] = 'http://geoport.whoi.edu/thredds/dodsC/bathy/etopo2_v2c.nc';
url_grid[3] = 'http://geoport.whoi.edu/thredds/dodsC/bathy/srtm30plus_v1.nc';
url_grid[4] = 'http://geoport.whoi.edu/thredds/dodsC/bathy/srtm30plus_v6';
url_grid[5] = 'http://geoport.whoi.edu/thredds/dodsC/bathy/smith_sandwell_v9.1.nc';
url_grid[6] = 'http://geoport.whoi.edu/thredds/dodsC/bathy/smith_sandwell_v11';


# Get the data, choose i=1 till 6
i=6;
topogrid=getOpenDapURLAsSpatialGrid(url_grid[i] ,"topo",bboxInDegrees);
print(paste("mean:",mean(topogrid$topo)));
spplot(topogrid,at=c(-60:40,200),col.regions=bpy.colors,main=url_grid[i],xlab=paste("Mean: ",mean(topogrid$topo)))


