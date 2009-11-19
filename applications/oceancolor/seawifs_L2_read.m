function [D,M] = seawifs_l2_read(fname,varname,varargin);
%SEAWIFS_L2_READ   load one image from a SeaWiFS L2 HDF file
%
%   D = seawifs_l2_read(filename,varname)
%
% load one image from a <a href="http://oceancolor.gsfc.nasa.gov/SeaWiFS/">SeaWiFS</a> L2 HDF file incl. full lat and lon arrays.
% D contains geophysical data (not integer data), units and long_name
%
%  [D,m] = seawifs_l2_read(...) also returns RAW meta-data.
%
% Example:
% 
%   D = seawifs_L2_read('S1998128121603.L2_HDUN_ZUNO.hdf','nLw_555')
%
%See also: HDFINFO, SEAWIFS_DATENUM

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

  %fname   = 'S1998128121603.L2_HDUN_ZUNO.hdf'
  %varname = 'nLw_555'

   %% Keywords

   OPT.debug = 0;
   OPT.plot  = 0;
   OPT.geo   = 1; % 0 = raw int data
   OPT       = setproperty(OPT,varargin{:});

   %% Load
   
   
   D.fname = fname;
   I       = hdfinfo(D.fname);
   
   for iatt=1:length(I.Attributes);if strcmpi(I.Attributes(iatt).Name,'start time');break;end;end   
   D.datenum(1) = seawifs_datenum(I.Attributes(iatt).Value);
   
   for iatt=1:length(I.Attributes);if strcmpi(I.Attributes(iatt).Name,'end time'  );break;end;end   
   D.datenum(2) = seawifs_datenum(I.Attributes(iatt).Value);

   D.(varname)    = hdfread(D.fname,varname);
   T.longitude    = hdfread(D.fname,'longitude');
   T.latitude     = hdfread(D.fname,'latitude' );
   T.cntl_pt_rows = hdfread(D.fname,'cntl_pt_rows');
   T.cntl_pt_cols = hdfread(D.fname,'cntl_pt_cols');
   
   %% meta-info

   for isds=1:length(I.Vgroup(5).SDS);
   
      if strcmpi(I.Vgroup(5).SDS(isds).Name,varname);
   
      M = I.Vgroup(5).SDS(isds);
   
      break;end;
      
   end   
   
   for iatt=1:length(M.Attributes);if strcmpi(M.Attributes(iatt).Name,'long_name');
      D.long_name = M.Attributes(iatt).Value;break;end
   end   
   
   for iatt=1:length(M.Attributes);if strcmpi(M.Attributes(iatt).Name,'units');
      D.units     = M.Attributes(iatt).Value;break;end
   end   

   for iatt=1:length(M.Attributes);if strcmpi(M.Attributes(iatt).Name,'slope');
      D.slope = M.Attributes(iatt).Value;break;end
   end   

   for iatt=1:length(M.Attributes);if strcmpi(M.Attributes(iatt).Name,'intercept');
      D.intercept = M.Attributes(iatt).Value;break;end
   end   
   
   %% (geodata = rawdata * slope + intercept)
   %  http://www.icess.ucsb.edu/seawifs/software/seadas4.8/src/idl_utils/io/wr_swf_hdf_sd.pro

   if OPT.geo
   D.(varname) = double(D.(varname)).*double(D.slope) + double(D.intercept);
   end

   %% georeference full matrices
   %  http://oceancolor.gsfc.nasa.gov/forum/oceancolor/topic_show.pl?pid=2029
   %  for each swatch the (lat,lon) arrays are only stored every 8th pixel.
   %  to get the full matrix interpolte to the full pixel range, with a spline.
   
   if size(D.(varname),1)==length(T.cntl_pt_rows)
      D.longitude = repmat(nan,size(D.(varname)));
      D.latitude  = repmat(nan,size(D.(varname)));
      nrow        =            size(D.(varname),1);
      ncol        =            size(D.(varname),2);
      for irow = 1:nrow
         D.longitude(irow,:) = interp1(single(T.cntl_pt_cols),double(T.longitude(irow,:)),1:ncol,'spline' );
         D.latitude (irow,:) = interp1(single(T.cntl_pt_cols),double(T.latitude (irow,:)),1:ncol,'spline' );
      end
   
   end   

   %% debug: for last row   
   
   if OPT.debug
      clf
      subplot(1,2,1)
      plot(single(T.cntl_pt_cols),T.longitude(irow,:),'.-b','Displayname','per 8')
      hold on
      plot(                1:ncol,D.longitude(irow,:),'.-r','Displayname','interp1')
      xlabel('pixel #')
      xlabel('longitude')
   
      subplot(1,2,2)
      plot(single(T.cntl_pt_cols),T.latitude (irow,:),'.-b','Displayname','per 8')
      hold on
      plot(                1:ncol,D.latitude (irow,:),'.-r','Displayname','interp1')
      xlabel('pixel #')
      xlabel('latitude')
      
   end
   if OPT .plot
      figure
      pcolorcorcen(D.longitude,D.latitude,double(D.nLw_555))
      L.url = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/northsea.nc';
      L.lon = nc_varget(L.url,'lon');
      L.lat = nc_varget(L.url,'lat');
      hold on
      plot(L.lon,L.lat,'w')
      
   end