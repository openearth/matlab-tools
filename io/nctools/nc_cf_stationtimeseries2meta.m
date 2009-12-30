function varargout = nc_cf_stationtimeseries2meta(varargin)
%NC_CF_STATIONTIMESERIES2META   extract meta info from all NetCDF files in directory to ...
%
%      nc_cf_stationtimeseries2meta(<keyword,value>) 
%  M = nc_cf_stationtimeseries2meta(<keyword,value>) 
%
%  reads standard meta info from CF convention (station_id,min(time),max(time),
%  longitude,latitude,number_of_observations,<station_name>
%  min(), mean(), max() and std() of standard_names
%  from all NetCDF files in a directory, make a plan view plot and saves table to excel file.
%  Optionally returns result to struct M.
%  The following <keyword,value> pairs have been implemented:
%
%   * directory_nc    directory where to put the nc data to (default [])
%   * mask            file mask (default '*.nc')
%   * basename        name of *.png and *.xls of output files (default 'catalog')
%   * vc              opendap adress of vector coastline for overview plot
%   * standard_names  standard_name of parameters for which to calculate min, mean, max and std
%
%See also: snctools

% Copyright notice:
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       G.J.de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Version:
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

% 2009 06 23: added extraction of station_name, in addition to station_id [GJdB]
% 2009 08 14: added extraction of min, mean, max and std [GJdB]

%TO DO: put results in MySQL server (a la MATROOS approach)
%TO DO: put results in catalog.xml zetten (according to opendap specifications)
%TO DO: put results in catalog.nc 
%TO DO: rename nt to number_of_observations

   OPT.directory_nc   = [];
   OPT.mask           = '*.nc'; % exclude catalog.nc
   OPT.basename       = 0; %'catalog';
   OPT.datestr        = 'yyyy-mm-dd HH:MM:SS';
   OPT.vc             = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/deltares/landboundaries/northsea.nc'; % vector coastline, WVC in future ?
   OPT.standard_names = [];
   
%% Keyword,value

   OPT = setProperty(OPT,varargin{:});

   OPT.attname       = {'title',...
                        'institution',...
                        'source',...
                        'history',...
                        'references',...
                        'email',...
                        'comment',...
                        'version',...
                        'Conventions',...
                        'CF:featureType',...
                        'terms_for_use',...
                        'disclaimer'};

%% Output names

      OPT.directory_out = OPT.directory_nc;
   if OPT.basename==0
      OPT.basename      = last_subdir (OPT.directory_nc);
      OPT.directory_out = first_subdir(OPT.directory_nc,-1);
   end

%% File loop to get meta-data

   OPT.files = dir([OPT.directory_nc,filesep,OPT.mask]);
   OPT.files = OPT.files(~strcmp({OPT.files.name},'catalog.nc')); % exclude catalog.nc

   for ifile=1:length(OPT.files)
   
      OPT.filename = [OPT.directory_nc, filesep, OPT.files(ifile).name]; % e.g. 'etmgeg_273.txt'
   
      disp(['Processing ',num2str(ifile),'/',num2str(length(OPT.files)),': ',filename(OPT.filename)]);
      
%% Get global attributes

      for iatt = 1:length(OPT.attname)
      
         attname = OPT.attname{iatt};
         fldname = mkvar(attname);
         try
         OPT.(fldname) = nc_attget(OPT.filename, nc_global,attname);
         end
      
      end

%% Get ordinates ~(dimensions)

      OPT.lat          = nc_varfind(OPT.filename, 'attributename', 'standard_name', 'attributevalue','latitude'       );
      OPT.lon          = nc_varfind(OPT.filename, 'attributename', 'standard_name', 'attributevalue','longitude'      );
      OPT.time         = nc_varfind(OPT.filename, 'attributename', 'standard_name', 'attributevalue','time'           );
      OPT.station_id   = nc_varfind(OPT.filename, 'attributename', 'standard_name', 'attributevalue','station_id'     );
      
      files(ifile).latitude               = nc_varget(OPT.filename,OPT.lat);
      files(ifile).longitude              = nc_varget(OPT.filename,OPT.lon);
      time                                = nc_varget(OPT.filename,OPT.time);
      isounits                            = nc_attget(OPT.filename,OPT.time,'units');
      files(ifile).number_of_observations = length(time);
      files(ifile).datenummin             = min(time);
      files(ifile).datenummax             = max(time);
      files(ifile).station_id             = nc_varget(OPT.filename,OPT.station_id);
      try
      files(ifile).station_name           = nc_varget(OPT.filename,'station_name');
      end

      for iname=1:length(OPT.standard_names)
      OPT.standard_name = OPT.standard_names{iname};    
      OPT.parameter     = nc_varfind(OPT.filename, 'attributename', 'standard_name', 'attributevalue',OPT.standard_name);
      parameter         = nc_varget(OPT.filename,OPT.parameter);
      files(ifile).([OPT.parameter,'_min' ]) = nanmin (parameter);
      files(ifile).([OPT.parameter,'_mean']) = nanmean(parameter);
      files(ifile).([OPT.parameter,'_max' ]) = nanmax (parameter);
      files(ifile).([OPT.parameter,'_std' ]) = nanstd (parameter);
      end
      
   end % for ifile=1:length(OPT.files)

%% Reorganize meta-data

   A.filename                  = {OPT.files.name};
   A.latitude                  = [files.latitude];
   A.longitude                 = [files.longitude];
   A.number_of_observations    = [files.number_of_observations];
   A.datenummin                = [files.datenummin];
   A.datenummax                = [files.datenummax];
   A.datestrmin                = datestr(udunits2datenum(A.datenummin,isounits),OPT.datestr);
   A.datestrmax                = datestr(udunits2datenum(A.datenummax,isounits),OPT.datestr);
   
   A.station_id                = {files.station_id};
   A.station_name              = {files.station_name};
   
   for iname=1:length(OPT.standard_names)
   OPT.standard_name = OPT.standard_names{iname};    
   OPT.parameter    = nc_varfind(OPT.filename, 'attributename', 'standard_name', 'attributevalue',OPT.standard_name);
   A.([OPT.parameter,'_min' ]) = [files.([OPT.parameter,'_min' ])];
   A.([OPT.parameter,'_mean']) = [files.([OPT.parameter,'_mean'])];
   A.([OPT.parameter,'_max' ]) = [files.([OPT.parameter,'_max' ])];
   A.([OPT.parameter,'_std' ]) = [files.([OPT.parameter,'_std' ])];
   end

   if isnumeric(A.station_id{1})
   A.station_id                             = num2str(cell2mat(A.station_id)');
   else
   A.station_id                             = char   (A.station_id); % cell2  char
   end
   A.station_name                           = char   (A.station_name); % cell2  char

   units.filename                           = 'string';
   units.latitude                           = nc_attget(OPT.filename,OPT.lat ,'units');
   units.longitude                          = nc_attget(OPT.filename,OPT.lon ,'units');
   units.number_of_observations             = 'number of observations';
   units.datenummin                         = nc_attget(OPT.filename,OPT.time,'units');
   units.datenummax                         = nc_attget(OPT.filename,OPT.time,'units');
   units.datestrmin                         = OPT.datestr;
   units.datestrmax                         = OPT.datestr;
   units.station_id                         = 'string';
   units.station_name                       = 'string';
   
   for iname=1:length(OPT.standard_names)
   OPT.standard_name = OPT.standard_names{iname};
   OPT.parameter     = nc_varfind(OPT.filename, 'attributename', 'standard_name', 'attributevalue',OPT.standard_name);
   units.([OPT.parameter,'_min' ])          = nc_attget(OPT.filename,OPT.parameter,'units');
   units.([OPT.parameter,'_mean'])          = units.([OPT.parameter,'_min' ]);
   units.([OPT.parameter,'_max' ])          = units.([OPT.parameter,'_min' ]);
   units.([OPT.parameter,'_std' ])          = units.([OPT.parameter,'_min' ]);
   end

%% Plot locations

   TMP = figure;
   plot   (A.longitude,A.latitude,'ko','linewidth',2)
   hold    on
   OPT.ctick = 10.^[2:6];
   colormap(jet((length(OPT.ctick)-1)*2));
   caxis  (log10(OPT.ctick([1 end])))
   plotc  (A.longitude,A.latitude,log10(A.number_of_observations),'o','linewidth',2)
   axislat(52)
   tickmap('ll')
  %caxis  (log10([min(A.number_of_observations) max(A.number_of_observations)]))
   [ax,h]=colorbarwithtitle('n [#]',log10(OPT.ctick));
   set(ax,'YTickLabel',num2str(OPT.ctick'))
   grid    on
   hold    on
   title  ({mktex(OPT.basename),['# stations: ',num2str(length(OPT.files))]})
   
   %% Add vector coastline

   OPT.USE_JAVA = getpref ('SNCTOOLS', 'USE_JAVA');
   setpref ('SNCTOOLS', 'USE_JAVA', 1)

   tmp.lat        = nc_varfind(OPT.vc, 'attributename', 'standard_name', 'attributevalue','latitude'  );
   tmp.lon        = nc_varfind(OPT.vc, 'attributename', 'standard_name', 'attributevalue','longitude' );
   tmp.lat        = nc_varget (OPT.vc,tmp.lat);
   tmp.lon        = nc_varget (OPT.vc,tmp.lon);
   
   setpref ('SNCTOOLS', 'USE_JAVA', OPT.USE_JAVA);

   axis(axis)
   plot(tmp.lon,tmp.lat,'k');
   
   print2screensize([OPT.directory_out,filesep,OPT.basename,'.png']);

%% Save all meta-data

   A.filename   = char(A.filename);
   
   header = {'Generated by $https://repos.deltares.nl/repos/OpenEarthTools/trunk/matlab/io/nctools/nc_cf_stationtimeseries2meta.m$ $Revision$ $Date$ $Author$',...
             ['This file has been created with struct2xls.m > xlswrite.m @ ',datestr(now)],...
             ['This file can be read in matlab with xls2struct.m < xlsread.m']};
   
   ok = struct2xls([OPT.directory_out,filesep,OPT.basename,'.xls'],A,'units',units,'header',header);
   
  % TO DO nc_putall ([OPT.directory_nc,filesep,OPT.basename,'.nc'] ,A,'units',units,'header',header);
  
  % TO DO write2('catalog.xml',A)
   
%% Output

   if     nargout==1
        varargout = {A};
   elseif nargout==2
        varargout = {A,units};
   end

   close(TMP)
   
%% EOF   


