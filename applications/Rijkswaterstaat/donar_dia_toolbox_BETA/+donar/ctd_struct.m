function [S,M]=ctd_struct(D,M0,ncolumn,varargin)
%ctd_struct convert matrix output from read to struct
%
%   [S,M]=ctd_struct(D,M)
%
% converts matrix D from donar.read to struct, and updates
% metadata struct M to include dimensions as for a CF trajectory.
%
%  File              = donar.open(diafile)
% [data ,  metadata] = donar.read(File,1,6) % 1st variable, residing in 6th column
% [struct, metadata] = donar.struct(data, metadata)
%
%See also: open, read, disp, trajectory_struct

if nargin==2
    ncolumn = size(D,2)-1; % last ones are / flags
end
 % TO DO make x,y, when M.data.hdr tells so
 
    M.data = M0;
    
    M.lon.standard_name  = 'degrees_east';
    M.lon.units          = 'Longitude';
    M.lon.long_name      = 'Longitude';

    M.lat.standard_name  = 'degrees_north';
    M.lat.units          = 'Latitude';
    M.lat.long_name      = 'Latitude';

    M.z.standard_name    = 'cm';
    M.z.units            = 'cm';
    M.z.long_name        = 'Vertical coordinate';
    M.z.positive         = 'down';
    
    M.datenum.standard_name = 'time';
    M.datenum.units         = 'days since 1970-01-01';
    M.datenum.long_name     = 'time';
     
    S.lon     = D(:,1);
    S.lat     = D(:,2);
    S.z       = D(:,3);
    S.datenum = D(:,4);
    S.data    = D(:,ncolumn);
    
    %% Store header as global attributes
   
   flds = donar.headercode2attribute(fields(M0.hdr));
   
   for i = 1:1:size(flds,1)
       for j = 1:1:size(    flds{i,2},1)
           attcode =        flds{i,2}{j,1}; % 1 or 2
           %varname =        flds{i,2}{j,2}; -1 for nc_global
           attname =        flds{i,2}{j,3};
           attval  = M0.hdr.(flds{i,1}){attcode};
           %nc_attput(ncfile, varname, attname, attval);
           M.nc_global.(attname) = attval;
         % M.data.nc_global.(attname) = attval;
       end
   end
   
  %%
 [S.station_lon,S.station_lat,S.station_id]=poly_unique(S.lon,S.lat,'eps',0.02);
  S.station_n = 0.*S.station_lon;
  for i=1:length(S.station_lon)
      S.station_n(i) = sum(S.station_id==i);
  end
  
  %%
 [S.profile_datenum,~,S.profile_id]=unique_rows_tolerance(S.datenum,10/24/60);
  S.profile_n = 0.*S.station_lon;
  for i=1:length(S.profile_datenum)
      S.profile_n(i) = sum(S.profile_id==i);
  end    

%%
% ctd_2000_-_2002.dia - 910 locations when eps=0
% ctd_2000_-_2002.dia -  56 locations when eps=0.01 ~ 1 km
% ctd_2000_-_2002.dia -  40 locations when eps=0.015
% ctd_2000_-_2002.dia -  36 locations when eps=0.02 ~ 2 km
        
%% we choose 5 min as seperate CTD cast
% t.dt_bnds = [0 [1 2 5 10 20]/24/3600 [1 2 5 10 20]/24/60 [1 2 5 10 20]/24 1 2 5 10 20];
% t.dt = histc(diff(S.datenum),t.dt_bnds)
% t.dt

%        69946 1 sec.
%        82693 2
%          137 5
%            1 10
%            0 20

%            0 1 min.
%            0 2
%            0 5 <<<<<<<
%            0 10
%           20 20

%          279 1 hour
%          124 2
%          165 5
%           33 10
%           59 20

%           10 day
%           14
%           28
%           54
%           16
%            0        

%%
   
   