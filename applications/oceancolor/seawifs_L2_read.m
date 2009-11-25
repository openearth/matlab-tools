function varargout = seawifs_l2_read(fname,varargin);
%SEAWIFS_L2_READ   load one image from a SeaWiFS (subscened) L2 HDF file
%
%   D = seawifs_l2_read(filename,varname,<keyword,value>)
%
% load one image from a <a href="http://oceancolor.gsfc.nasa.gov/SeaWiFS/">SeaWiFS</a> L2 HDF file 
% incl. full latitude, longitude arrays and L2 flags.
% The Lw hdf file can be gzipped.
% D contains geophysical data (not integer data), l2_flags, units and long_name.
%
%  [D,M] = seawifs_l2_read(...) also returns RAW meta-data.
%
% For <keyword,value> pairs call: OPT = seawifs_l2_read()
%
% Example:
% 
%   D = seawifs_L2_read('S1998045125841.L2_HDUN_ZUNO.gz','nLw_555','plot',1)
%
%See also: HDFINFO, SEAWIFS_DATENUM, SEAWIFS_MASK, SEAWIFS_FLAGS

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
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

% TO DO: calculate mask in D ?

%% Keywords

   OPT.debug   = 0;
   OPT.plot    = 0;
   OPT.export  = 1; % only when plot=1
   OPT.geo     = 1; % 0 = raw int data, 1 = geophysical DATA
   OPT.gunzip  = 1; % unzip *.gz files
   OPT.delete  = 0; % cleanup unzipped files after gunzip
   OPT.ldb     = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_c.nc';
   OPT.ldb     = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/northsea.nc';
   
   if odd(nargin)
      OPT        = setProperty(OPT,varargin{:});
   elseif nargin==0
      varargout = {OPT};
      return
   else
      OPT        = setProperty(OPT,varargin{2:end});
      varname    = varargin{1};
   end
   
%% gunzip (and clean up at end of function)

   if OPT.gunzip 
      if strcmpi(fname(end-2:end),'.gz')
      gunzip(fname)
      zipname = fname;
      fname   = fname(1:end-3);
      disp(['gunzipped ',zipname]);
      OPT.delete = 1;
      end
   end

%% Variable selection

   D.fname = fname;
   I       = hdfinfo(D.fname);
   
   %% find correct group
   
   % TO DO group_index = h4_group_find(I,'group_name')

   for group=1:length(I.Vgroup);if strcmpi(I.Vgroup(group).Name,'Geophysical Data');
      break;end
   end   

   if odd(nargin)
   
      varnames = {I.Vgroup(group).SDS.Name};

    % varnames = {'chlor_a',...
    %             'angstrom_510',...
    %             'K_490',...
    %             'nLw_412',...
    %             'nLw_443',...
    %             'nLw_490',...
    %             'nLw_510',...
    %             'nLw_555',...
    %             'nLw_670',...
    %             'tau_865',...
    %             'eps_78',...
    %             'l2_flags',...
    %             'tau_555'}; % better to get them from file 
                  
      [varind, ok] = listdlg('ListString', varnames, .....
                          'SelectionMode', 'single', ...                           % we can only plot one for now
                           'PromptString', 'Select a geophysical parameter:', .... % title of pulldown menu
                                   'Name', 'Loading SeaWiFS L2 file:',...          % title of window
                               'ListSize', [500, 300]);
                               varname = varnames{varind};
   end

   

%% Data, coordinates, time
   
   for iatt=1:length(I.Attributes);if strcmpi(I.Attributes(iatt).Name,'start time');break;end;end   
   D.datenum(1) = seawifs_datenum(I.Attributes(iatt).Value);
   
   for iatt=1:length(I.Attributes);if strcmpi(I.Attributes(iatt).Name,'end time'  );break;end;end   
   D.datenum(2) = seawifs_datenum(I.Attributes(iatt).Value);

   D.(varname)    = hdfread(D.fname,varname);
   if ~strcmpi(varname,'l2_flags')
   D.l2_flags     = hdfread(D.fname,'l2_flags');
   end
   T.longitude    = hdfread(D.fname,'longitude');
   T.latitude     = hdfread(D.fname,'latitude' );
   T.cntl_pt_rows = hdfread(D.fname,'cntl_pt_rows');
   T.cntl_pt_cols = hdfread(D.fname,'cntl_pt_cols');
   
%% meta-info

   for isds=1:length(I.Vgroup(group).SDS); 
   
      if strcmpi(I.Vgroup(group).SDS(isds).Name,varname);
   
      M = I.Vgroup(group).SDS(isds);
   
      break;end;
      
   end   
   
   % TO DO D.(att_name) = h4_att_get(I,'sds_name','att_name')
   
   for iatt=1:length(M.Attributes);if strcmpi(M.Attributes(iatt).Name,'long_name');
      D.long_name = M.Attributes(iatt).Value(1:end-1);break;end % rmoeve traling char(0)
   end   
   
   D.units     = ''; % for L2 flags
   for iatt=1:length(M.Attributes);if strcmpi(M.Attributes(iatt).Name,'units');
      D.units     = M.Attributes(iatt).Value(1:end-1);break;end % rmoeve traling char(0)
   end   

   for iatt=1:length(M.Attributes);if strcmpi(M.Attributes(iatt).Name,'slope');
      D.slope = M.Attributes(iatt).Value;break;end
   end   

   for iatt=1:length(M.Attributes);if strcmpi(M.Attributes(iatt).Name,'intercept');
      D.intercept = M.Attributes(iatt).Value;break;end
   end   
   
%% (geodata = rawdata * slope + intercept)
%  http://www.icess.ucsb.edu/seawifs/software/seadas4.8/src/idl_utils/io/wr_swf_hdf_sd.pro

   if OPT.geo & isfield(D,'slope') & isfield(D,'intercept') % note l2_flags have no slope, intercept
   D.(varname) = double(D.(varname)).*double(D.slope) + double(D.intercept);
   end

%% georeference full matrices
%  http://oceancolor.gsfc.nasa.gov/forum/oceancolor/topic_show.pl?pid=2029
%  for each swath the (lat,lon) arrays are only stored every 8th pixel.
%  To get the full matrix interpolate to the full pixel range, with a spline.
   
   if size(D.(varname),1)==length(T.cntl_pt_rows)
      D.longitude = repmat(nan,size(D.(varname)));
      D.latitude  = repmat(nan,size(D.(varname)));
      nrow        =            size(D.(varname),1);
      ncol        =            size(D.(varname),2);
      for irow = 1:nrow
         D.longitude(irow,:) = interp1(single(T.cntl_pt_cols),double(T.longitude(irow,:)),1:ncol,'spline');
         D.latitude (irow,:) = interp1(single(T.cntl_pt_cols),double(T.latitude (irow,:)),1:ncol,'spline');
      end
   
   end   

%% debug: show results last row   
   
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

%% plot image (can be slow: no default)

   if OPT.plot
      figure
      D.mask     = seawifs_mask(D.l2_flags,[2 10],'disp',0); % remove clouds, ice and land
      pcolorcorcen(D.longitude,D.latitude,double(D.(varname)).*D.mask)
      title(['SeaWiFS image ',...
             datestr(D.datenum(1),'yyyy-mm-dd  HH:MM:SS'),' - ',...
             datestr(D.datenum(2),            'HH:MM:SS'),' (doy:',...
             num2str(yearday(D.datenum(1))),')'])
      colorbarwithhtext([char(D.long_name),'  [',mktex(D.units),']'],'horiz');
      axislat
      grid on
      tickmap('ll')
      %% plot outline of image
      hold on
      plot(D.longitude(  1,  :),D.latitude(  1,  :),'color',[.5 .5 .5])
      plot(D.longitude(  :,  1),D.latitude(  :,  1),'color',[.5 .5 .5])
      plot(D.longitude(end,  :),D.latitude(end,  :),'color',[.5 .5 .5])
      plot(D.longitude(  :,end),D.latitude(  :,end),'color',[.5 .5 .5])
      %% plot land
      try
       L.lon = nc_varget(OPT.ldb,'lon');
       L.lat = nc_varget(OPT.ldb,'lat');
       hold on
       plot(L.lon,L.lat,'k')
      end
      text(1,0,' image: $Id$','units','normalized','rotation',90,'verticalalignment','top','fontsize',6)
      if OPT.export
         print2screensize([D.fname,'.png']);
      end
      
   end
   
   if OPT.gunzip & OPT.delete
      delete(fname)
   end
   
   if nargout==1
      varargout = {D};
   else
      varargout = {D,M};
   end