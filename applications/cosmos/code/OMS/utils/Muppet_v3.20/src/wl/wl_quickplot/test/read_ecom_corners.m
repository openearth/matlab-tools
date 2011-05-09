function Grid = read_ecom_corners(file)
%READ_ECOM_CORNERS reads ECOMSED corners grid file.
%   G = READ_ECOM_CORNERS(FILENAME) reads the grid information from the ECOMSED
%   grid file and returns a structure G with fields X and Y.
%
%   Example
%      G = read_ecom_corners('corners.utm');
%      drawgrid(G.X,G.Y)
%
%   See also QPFOPEN, WLGRID, DRAWGRID.


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
