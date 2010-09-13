function varargout = analyseHis(varargin)
%unstruc.analyseHis   analyse waterlevel time series against OPeNDAP data in time and frequency domain
%
%    unstruc.analyseHis(<keyword,value>)
%
% * For Delft3D-flow the trih history file can be converted to netCDF
%   with VS_TRIH2NC such that unstruc.analyseHis also works on it.
% * For unstruc.analyseHis to be able to detect associated data
%   automatically, the observation points names have to be 
%   generated with unstruc.opendap2obs or delft3d_opendap2obs.
%
% Example: unstruc, using a local cache of netCDF files
%
%    ncbase = 'F:\opendap\thredds\rijkswaterstaat/waterbase/sea_surface_height'
%    epsg   = 28992
%
%    unstruc.delft3d_opendap2obs('ncbase',ncbase,...
%                          'epsg', epsg,...
%                          'file',['F:\unstruc\run01\rijkswaterstaat_waterbase_sea_surface_height_',num2str(epsg),'.obs'])
%    % ~ run model ~
%         unstruc.analyseHis('nc','F:\unstruc\run01\trih-s01.nc',...
%                          'tlim',datenum(1998,[1 5],[1 28]),...
%                        'ncbase',ncbase,...
%                            'vc','F:\opendap\thredds\noaa/gshhs/gshhs_i.nc')
%
% Example: Delft3D-flow, using a local cache of netCDF files
%
%    ncbase = 'F:\opendap\thredds\rijkswaterstaat/waterbase/sea_surface_height'
%    epsg   = 28992
%
%    delft3d_opendap2obs('ncbase',ncbase,...
%                          'epsg', epsg,...
%                          'file',['F:\unstruc\run01\rijkswaterstaat_waterbase_sea_surface_height_',num2str(epsg),'.obs'],...
%                           'grd', 'F:\unstruc\run01\wadden4.grd',...
%                          'plot', 1)
%    % ~ run model ~
%         vs_trih2nc(        'F:\unstruc\run01\trih-s01.dat',...
%                          'epsg',epsg)
%         unstruc.analyseHis('nc','F:\unstruc\run01\trih-s01.nc',...
%                          'tlim',datenum(1998,[1 5],[1 28]),...
%                        'ncbase',ncbase,...
%                            'vc','F:\opendap\thredds\noaa/gshhs/gshhs_i.nc')
%
%See also: UNSTRUC, NC_T_TIDE_COMPARE, NC_T_TIDE, T_TIDE

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

   OPT.nc      = '';
   OPT.ncbase  = 'http://opendap.deltares.nl/thredds/dodsC/opendap\rijkswaterstaat/waterbase/sea_surface_height';
   OPT.tlim    = [];
   OPT.t_tide  = 1;

   OPT.pause   = 0;
   OPT.ylim    = [-2 2.5];
   OPT.varname = 'sea_surface_height';

   % for nc_t_tide_compare
   
   OPT.axis    = [4.6000    6.4000   52.7000   53.6000];
   OPT.vc      = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
   OPT.vc      = 'http://opendap.deltares.nl/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc';

   OPT = setProperty(OPT,varargin{:});
   
   if nargin==0
      varargout = {OPT};
      return
   end

%% load model data

   M.datenum       =         nc_cf_time(OPT.nc,'time');
   M.(OPT.varname) =         nc_varget (OPT.nc,'waterlevel');
   M.name          = cellstr(nc_varget (OPT.nc,'station_name'));

%% prepare

   dataurls = opendap_catalog(OPT.ncbase);
   
   FIG(1) = figure('name','time series','position',[100   300   560   420]);
   FIG(2) = figure('name','scatter'    ,'position',[668   300   560   420]);
   
   nc_t_tide_data  = {};
   nc_t_tide_model = {};

for ist=1:length(M.name)
    
    disp(['Processing ',M.name{ist}])
    
%%  find and load associated observational data
    
   % TODO replace (i) by more intelligent query based on location, or 
   %             (ii) full netCDF url as name of observation point for direct retrieval
   [bool,ind] = strfindb(dataurls,upper(M.name{ist}));
    dataurl   = dataurls{bool};
   [D,meta]   = nc_cf_stationTimeSeries(dataurl,OPT.varname,'period',OPT.tlim);
   
%%  process only if observational data present
   
    if ~isempty(D.datenum)
   
    %% interpolate model to data times

    DM.(OPT.varname) = interp1(M.datenum,M.(OPT.varname)(:,ist),D.datenum)';
    
%% plot time series

    figure(FIG(1));clf
    
    plot    (M.datenum,M.(OPT.varname)(:,ist),'b','DisplayName','model')
    hold on
    plot    (D.datenum,D.(OPT.varname),'r','DisplayName','data')
    legend  ('Location','NorthEast')
    title   (M.name{ist})
    grid on
    ylim    (OPT.ylim)
    ylabel  (['\eta [',meta.(OPT.varname).units,']']);
    timeaxis(OPT.tlim,'fmt','mmm','tick',-1,'type','text'); %datetick('x')
    text    (1,0,'Created with OpenEarthTools <www.OpenEarth.eu>','rotation',90,'units','normalized','verticalalignment','top','fontsize',6)
    
    print2screensizeoverwrite([fileparts(OPT.nc),filesep,'timeseries',filesep,filename(OPT.nc),'_',M.name{ist}]) % ,'v','t'
    
    %% plot timeseries difference

    figure(FIG(1));clf
    
    plot    (D.datenum,DM.(OPT.varname) - D.(OPT.varname),'g','DisplayName','model - data')
    legend  ('Location','NorthEast')
    title   (M.name{ist})
    grid on
    ylim    (OPT.ylim)
    ylabel  (['\eta [',meta.(OPT.varname).units,']']);
    timeaxis(OPT.tlim,'fmt','mmm','tick',-1,'type','text'); %datetick('x')
    text    (1,0,'Created with OpenEarthTools <www.OpenEarth.eu>','rotation',90,'units','normalized','verticalalignment','top','fontsize',6)
    
    print2screensizeoverwrite([fileparts(OPT.nc),filesep,'timeseries',filesep,filename(OPT.nc),'_',M.name{ist},'_diff']) % ,'v','t'

%% plot time series scatter

% TO DO: calculate R2 or GoF or Taylor diagram ??
% TO DO: show density of points

    figure(FIG(2));clf
    
    maxe =      max(DM.(OPT.varname) - D.(OPT.varname));
    mine =      min(DM.(OPT.varname) - D.(OPT.varname));
    rmse =      rms(DM.(OPT.varname) - D.(OPT.varname));
    R    = corrcoef(DM.(OPT.varname)  ,D.(OPT.varname));R = R(2,1); % same as (2,1)
    
    fmte = '%+1.3f'; %
    txte = {[' R    = ',num2str(R   ,fmte)],...
            [' \epsilon_{rms}  = ',num2str(rmse,fmte)],...
            [' \epsilon_{min}  = ',num2str(mine,fmte)],...
            [' \epsilon_{max}  = ',num2str(maxe,fmte)]};

    plot    (D.(OPT.varname),DM.(OPT.varname),'k.','DisplayName','model vs. data') % model on y-axis: 'model to high' visible as higher results
    hold on
    title   ([M.name{ist}])
    text    (0,1,txte,'units','normalized','verticalalignment','top','FontName','fixedwidth')
    grid on
    axis equal
    ylim  (OPT.ylim)
    ylabel(['\color{blue}\eta [',meta.(OPT.varname).units,'] (model)'])
    xlim  (OPT.ylim)
    xlabel(['\color{red}\eta [',meta.(OPT.varname).units,'] (data)'])
    plot  (xlim,ylim,'k--','linewidth',1)
    for deta = [.25 .5]
    plot  (xlim+deta,ylim-deta,'k:')
    plot  (xlim-deta,ylim+deta,'k:')
    end
    text    (1,0,'Created with OpenEarthTools <www.OpenEarth.eu>','rotation',90,'units','normalized','verticalalignment','top','fontsize',6)
    
    print2screensizeoverwrite([fileparts(OPT.nc),filesep,'timeseries',filesep,filename(OPT.nc),'_',M.name{ist},'_scatter']) % ,'v','t'
    
%%  perform tidal analysis

    if OPT.t_tide
    
    nc_t_tide_data {end+1} = [fileparts(OPT.nc),filesep,'t_tide_data',filesep,M.name{ist},'_t_tide.nc']
    nc_t_tide_model{end+1} = [fileparts(OPT.nc),filesep,'t_tide',filesep,filename(OPT.nc),'_',M.name{ist},'_t_tide.nc'];
    
    nc_t_tide(D.datenum,D.(OPT.varname),... % add period and midpoint
      'station_id',D.station_id,...
    'station_name',D.station_name,...
          'period',D.datenum([1 end]),...
             'lat',D.lat,...
             'lon',D.lon,...
           'units',meta.(OPT.varname).units,...
         'ascfile',[fileparts(OPT.nc),filesep,'t_tide_data',filesep,M.name{ist},'_t_tide.t_tide'],...
          'ncfile',nc_t_tide_data{end});

    nc_t_tide(M.datenum,M.(OPT.varname)(:,ist),...% add period and midpoint
      'station_id',D.station_id,...
    'station_name',D.station_name,...
          'period',M.datenum([1 end]),...
             'lat',D.lat,...
             'lon',D.lon,...
           'units',meta.(OPT.varname).units,...
         'ascfile',[fileparts(OPT.nc),filesep,'t_tide',filesep,filename(OPT.nc),'_',M.name{ist},'_t_tide.t_tide'],...
          'ncfile',nc_t_tide_model{end});
     
    if OPT.pause;pausedisp;end
    
    end % OPT.t_tide
    
    end % if ~isempty(D.datenum)
    
end % station loop

%%  plot tidal analysis

   if OPT.t_tide

   %-% make sure these match pairwise
   %-% nc_t_tide_model              = sort(opendap_catalog(fileparts(OPT.nc),filesep,'t_tide'));
   %-% nc_t_tide_data               = sort(opendap_catalog(fileparts(OPT.nc),filesep,'t_tide_data');

   nc_t_tide_compare(nc_t_tide_model,...
                     nc_t_tide_data,'export',1,...
                                        'vc',OPT.vc,...
                                      'axis',OPT.axis,...
                                 'directory',[fileparts(OPT.nc),filesep,'t_tide']);
   end
