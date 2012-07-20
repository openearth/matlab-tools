function varargout = analyseHis(varargin)
%dflowfm.analyseHis   analyse waterlevel time series against OPeNDAP data in time and frequency domain
%
%    dflowfm.analyseHis(<ncfile>,<keyword,value>)
%
% * For Delft3D-flow the trih history file can be converted to netCDF
%   with VS_TRIH2NC such that dflowfm.analyseHis also works on it.
% * For dflowfm.analyseHis to be able to detect associated data
%   automatically, the observation points names have to be 
%   generated with dflowfm.opendap2obs or delft3d_opendap2obs.
%
% Example: dflowfm, using a local cache of netCDF files
%          You can create such a local cache with opendap_get_cache
%
%    ncbase = 'F:\opendap\thredds\rijkswaterstaat/waterbase/sea_surface_height'
%    epsg   = 28992
%
%    dflowfm.delft3d_opendap2obs(ncbase,...
%                          'epsg', epsg,...
%                          'file',['F:\delft3dfm\run01\rijkswaterstaat_waterbase_sea_surface_height_',num2str(epsg),'.obs'])
%    % ~ run model ~
%         dflowfm.analyseHis('nc','F:\delft3dfm\run01\trih-s01.nc',...
%                       'datelim',datenum(1998,[1 5],[1 28]),...
%                        'ncbase',ncbase,...
%                            'vc','F:\opendap\thredds\noaa/gshhs/gshhs_i.nc')
%
% Example: Delft3D-flow, using a local cache of netCDF files, making monthly plots
%
%    ncbase = 'F:\opendap\thredds\rijkswaterstaat/waterbase/sea_surface_height'
%    epsg   = 28992
%
%    delft3d_opendap2obs(ncbase,...
%                          'epsg', epsg,...
%                          'file',['F:\delft3dfm\run01\rijkswaterstaat_waterbase_sea_surface_height_',num2str(epsg),'.obs'],...
%                           'grd', 'F:\delft3dfm\run01\wadden4.grd',...
%                          'plot', 1)
%    % ~ run model ~
%         vs_trih2nc('F:\delft3dfm\run01\trih-s01.dat',...
%                          'epsg',epsg)
%         for m=1:12
%         dflowfm.analyseHis('F:\delft3dfm\run01\trih-s01.nc,...
%                       'datelim',datenum(1998,[m m+1],1),...
%                       'datestr','mmm-dd',...
%                        'ncbase',ncbase,...
%                            'vc','F:\opendap\thredds\noaa/gshhs/gshhs_i.nc',...
%                        't_tide',0)
%         end
%
%See also: dflowfm, NC_T_TIDE_COMPARE, NC_T_TIDE, T_TIDE, delft3d, OPENDAP_GET_CACHE, 
%          nc2struct, dflowfm.indexHis

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

   OPT.nc             = '';
   OPT.datelim        = [];
   OPT.datestr        = 'mmm'; % for timeaxis
   OPT.datefmt        = 'yyyy-mm-dd'; %  make empty if you do not want date in filename
   OPT.t_tide         = 1;
   OPT.label          = '';
   OPT.names          = {}; % id names of stations to include
   OPT.units          = [];
   OPT.timezone       = '+00:00'; % common time zone for data and model comparison in plots
   OPT.model_timezone = '+01:00'; % time zone of model is not present in model output (model is not time zone aware)

   OPT.pause          = 0;
   OPT.standard_name  = 'sea_surface_height';
   
switch OPT.standard_name
case 'sea_surface_height'
   OPT.ncbase      = 'http://opendap.deltares.nl/thredds/dodsC/opendap\rijkswaterstaat/waterbase/sea_surface_height';
   OPT.ylim        = [-2 2.5];
   OPT.varname     = 'sea_surface_height';
   OPT.hisname     = 'waterlevel';
   OPT.hisnamename = 'station_name';
   OPT.hislatname  = nan;
   OPT.hislonname  = nan;

case 'water_volume_transport_into_sea_water_from_rivers'
   OPT.ncbase      = '';
   OPT.ylim        = [-2 2].*1e5;
   OPT.varname     = 'Q';
   OPT.hisname     = 'cross_section_discharge';
   OPT.hisnamename = 'cross_section_name';
   OPT.hislatname  = nan;
   OPT.hislonname  = nan;
end

   % for nc_t_tide_compare
   
   OPT.axis    = [4.6000    6.4000   52.7000   53.6000];
   OPT.vc      = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
   OPT.vc      = 'http://opendap.deltares.nl/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc';
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
   if odd(nargin)
      OPT.nc   = varargin{1};
      varargin = {varargin{2:end}};
   end

   OPT = setProperty(OPT,varargin{:});
   
%% add full path to be able to save in its ssubfolders

   if isempty(fileparts(OPT.nc))
      OPT.nc = fullfile(pwd,OPT.nc)
   end

%% load model data
% TO DO: [M,Mmeta]   = nc_cf_stationTimeSeries(OPT.nc,OPT.hisname,'period',OPT.datelim([1 end]))

  [M.datenum,...
   Mmeta.datenum.timezone]   = nc_cf_time(OPT.nc,'time'); % USE nc_cf_time_range()
   M.(OPT.varname)           = nc_varget (OPT.nc,OPT.hisname);
   M.name                    = cellstr(nc_varget (OPT.nc,OPT.hisnamename)); % mind getpref ('SNCTOOLS','PRESERVE_FVD')==0
   M.lon                     = nan;
   M.lat                     = nan;
   Mmeta.(OPT.varname).units = nc_attget(OPT.nc,OPT.hisname,'units'); % in case there is no data

%% prepare

   dataurls = opendap_catalog(OPT.ncbase);
   
   FIG(1) = figure('name','time series','position',[100   300   560   420]);
   FIG(2) = figure('name','scatter'    ,'position',[668   300   560   420]);
   
   nc_t_tide_datas  = {};
   nc_t_tide_models = {};

for ist=1:length(M.name); if ismember(M.name{ist},OPT.names) | isempty(OPT.names)
    
  disp(['>> Processing ',M.name{ist}])
  
  if ~isempty(OPT.ncbase)
    
%%  find and load associated observational data
   % TODO replace (i) by more intelligent query based on location, or 
   %             (ii) full netCDF url as name of observation point for direct retrieval
     [bool,ind] = strfindb(dataurls,upper(M.name{ist}));
      dataurl   = dataurls{bool};
     [D,Dmeta]   = nc_cf_stationTimeSeries(dataurl,OPT.varname,'period',OPT.datelim([1 end])); % returns lon and lat

     if ~isequal(Mmeta.(OPT.varname).units, Dmeta.(OPT.varname).units)
     error(['units of model and data differ, model: "',...
               char(Mmeta.(OPT.varname).units),'"   - data: "',...
               char(Dmeta.(OPT.varname).units),'"'])
     OPT.units
     end
     
     if ~isequal(Mmeta.datenum.timezone,Dmeta.datenum.timezone)
     disp(['time zones of model and data differ, model: "',...
               char(Mmeta.datenum.timezone),'"   - data: "',...
               char(Dmeta.datenum.timezone),'"'])
     disp(['converted to common timezone ',OPT.timezone]);
     
     if isempty(char(Mmeta.datenum.timezone))
         Mmeta.datenum.timezone = OPT.model_timezone;
     end

     M.datenum = M.datenum - timezone_code2datenum(char(Mmeta.datenum.timezone)) ...
                           + timezone_code2datenum(OPT.timezone);
     D.datenum = D.datenum - timezone_code2datenum(char(Dmeta.datenum.timezone)) ...
                           + timezone_code2datenum(OPT.timezone);
     end
     
     % copy meta-data that is not in model output (yet ...)
     M.lon          = D.lon;
     M.lat          = D.lat;
     M.station_id   = D.station_id;
     M.station_name = D.station_name;
  else
     D.datenum       = [];
     D.(OPT.varname) = [];
    %D.station_id    = char(M.name{ist});
    %D.station_name  = char(M.name{ist});
    %D.lat           = M.lat;
    %D.lon           = M.lon;
  end
   
  OPT.ext = [datestr(OPT.datelim(1),OPT.datefmt),'_',datestr(OPT.datelim(end),OPT.datefmt)];
  if length(OPT.ext)==1
     OPT.ext = '';
  end
  
  OPT.txt = mktex({['Created with OpenEarthTools <www.OpenEarth.eu> ',OPT.ext],...
                   ['model: ',filename(OPT.nc),' & data:',OPT.ncbase]}); % ,' @ ',datestr(now,'yyyy-mmm-dd')
   
%%  process only if observational data is present
    
D.title = [OPT.label,char(D.station_name(:)'),' (',...
                      char(D.station_id(:)'),') [',...
                      num2str(D.lon),'\circ E, ',...
                      num2str(D.lat),'\circ N]'];

 if ~isempty(D.datenum)
   
    %% interpolate model to data times in common timezone

    DM.(OPT.varname) = interp1(M.datenum,M.(OPT.varname)(:,ist),D.datenum)';  % mind getpref ('SNCTOOLS','PRESERVE_FVD')==0
    
    DM.(OPT.varname) = reshape(DM.(OPT.varname),size(D.(OPT.varname)));
    
%% plot timeseries difference

    figure(FIG(1));subplot_meshgrid(1,1,.05,.05);clf
    
    plot    (D.datenum,DM.(OPT.varname) - D.(OPT.varname),'g','DisplayName','model - data')
    legend  ('Location','NorthEast')
    title   (D.title)
    grid on
    ylim    (OPT.ylim)
    ylabel  (['\eta [',Dmeta.(OPT.varname).units,']']);
    timeaxis(OPT.datelim,'fmt',OPT.datestr,'tick',-1,'type','text'); %datetick('x')
    text    (1,0,OPT.txt,'rotation',90,'units','normalized','verticalalignment','top','fontsize',6)
    
    print2screensizeoverwrite([fileparts(OPT.nc),filesep,'timeseries',filesep,OPT.ext,filesep,filename(OPT.nc),'_',OPT.ext,'_',mkvar(M.name{ist}),'_diff']) % ,'v','t'

%% plot time series scatter
%  TO DO: calculate R2 or GoF or Taylor diagram ??
%  TO DO: show density of points

    figure(FIG(2));subplot_meshgrid(1,1,.05,.05);clf
    
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
    title   (D.title)
    text    (0,1,txte,'units','normalized','verticalalignment','top','FontName','fixedwidth')
    grid on
    axis equal
    ylim  (OPT.ylim)
    ylabel(['\color{blue}\eta [',Dmeta.(OPT.varname).units,'] (model)'])
    xlim  (OPT.ylim)
    xlabel(['\color{red}\eta [',Dmeta.(OPT.varname).units,'] (data)'])
    plot  (xlim,ylim,'k--','linewidth',1)
    for deta = [.25 .5]
    plot  (xlim+deta,ylim-deta,'k:')
    plot  (xlim-deta,ylim+deta,'k:')
    end
    text    (1,0,OPT.txt,'rotation',90,'units','normalized','verticalalignment','top','fontsize',6)
    
    print2screensizeoverwrite([fileparts(OPT.nc),filesep,'timeseries',filesep,OPT.ext,filesep,filename(OPT.nc),'_',OPT.ext,'_',mkvar(M.name{ist}),'_scatter'],[1024],[120],[-257 0]) % ,'v','t'

 end % if ~isempty(D.datenum)

%% plot time series (also if data is absent)

    figure(FIG(1));subplot_meshgrid(1,1,.05,.05);clf
    
    plot    (M.datenum,M.(OPT.varname)(:,ist),'b','DisplayName','model')
    hold on
    if ~isempty(OPT.ncbase)    
    plot    (D.datenum,D.(OPT.varname),'r','DisplayName','data')
    end
    legend  ('Location','NorthEast')
    title   (D.title)
    grid on
    ylim    (OPT.ylim)
    ylabel  (['\eta [',Dmeta.(OPT.varname).units,']']);
    timeaxis(OPT.datelim,'fmt',OPT.datestr,'tick',-1,'type','text'); %datetick('x')
    text    (1,0,OPT.txt,'rotation',90,'units','normalized','verticalalignment','top','fontsize',6)
    
    print2screensizeoverwrite([fileparts(OPT.nc),filesep,'timeseries',filesep,OPT.ext,filesep,filename(OPT.nc),'_',OPT.ext,'_',mkvar(M.name{ist})]) % ,'v','t'
    
%%  perform tidal analysis

    if OPT.t_tide
    
    nc_t_tide_data  = [fileparts(OPT.nc),filesep,'t_tide_data',filesep,mkvar(M.name{ist})                     ,'_t_tide.nc'];
    nc_t_tide_model = [fileparts(OPT.nc),filesep,'t_tide'     ,filesep,filename(OPT.nc),'_',mkvar(M.name{ist}),'_t_tide.nc'];

 if isempty(D.datenum)
     t_tide_msg = [];
 else
    t_tide_msg = nc_t_tide(D.datenum,D.(OPT.varname),... % add period and midpoint
      'station_id',D.station_id,...
    'station_name',D.station_name,...
          'period',OPT.datelim, ... % D.datenum([1 end]),... % use OPT.datelim
             'lat',D.lat,...
             'lon',D.lon,...
           'units',Dmeta.(OPT.varname).units,...
         'ascfile',[fileparts(OPT.nc),filesep,'t_tide_data',filesep,mkvar(M.name{ist}),'_t_tide.t_tide'],...
          'ncfile',nc_t_tide_data);
    clear D
 end %   if ~isempty(D.datenum)
 
    nc_t_tide(M.datenum,M.(OPT.varname)(:,ist),...% add period and midpoint
      'station_id',M.station_id,...
    'station_name',M.station_name,...
          'period',OPT.datelim, ... % M.datenum([1 end]),... % use OPT.datelim
             'lat',M.lat,...
             'lon',M.lon,...
           'units',Dmeta.(OPT.varname).units,...
         'ascfile',[fileparts(OPT.nc),filesep,'t_tide',filesep,filename(OPT.nc),'_',mkvar(M.name{ist}),'_t_tide.t_tide'],...
          'ncfile',nc_t_tide_model);
     
    if OPT.pause;pausedisp;end

    % if t_tide succesful, remember stations 
    % for which model and data are present for tidal comparison
    if  ~isempty(t_tide_msg)
       nc_t_tide_datas {end+1} = nc_t_tide_data ;
       nc_t_tide_models{end+1} = nc_t_tide_model;
    end
    
   end % OPT.t_tide
    
  %end % if ~isempty(D.datenum)
    
end;end % station loop

%%  plot tidal analysis

   if OPT.t_tide
   %-% make sure these match pairwise
   %-% nc_t_tide_model              = sort(opendap_catalog(fileparts(OPT.nc),filesep,'t_tide'));
   %-% nc_t_tide_data               = sort(opendap_catalog(fileparts(OPT.nc),filesep,'t_tide_data');

   if ~isempty(OPT.ncbase)
   nc_t_tide_compare(nc_t_tide_models,...
                     nc_t_tide_datas ,'export',1,...
                                        'vc',OPT.vc,...
                                      'axis',OPT.axis,...
                                 'directory',[fileparts(OPT.nc),filesep,'t_tide']);
   end
   end
