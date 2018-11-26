function EHY_xyn2obs(varargin)
% EHY_xyn2obs  converts DflowFM xyn file     (x,y,station name) to Delft3D-Flow obs file (m,n,station name)
%              given a curvilinear grid file (*.grd)
%
% <keyword,value> pairs
% file_xyn  Name of the xyn file
% file_obs  Name of the obs file             
% file_grd  Name of the curvilinear grid file 
%
% Example:  EHY_xyn2obs('file_obs','test.obs');
%
% See also: delft3d_io_obs                  
clearvars -except varargin; oetsettings('quiet');

%% Filenames
OPT.file_xyn = 'd:\projects\11200570_Haringvliet_Kier\runs\r11\mdu\Haring_03_obs.xyn';
OPT.file_obs = 'haringvliet.obs';
OPT.file_grd = 'd:\projects\11200570_Haringvliet_Kier\runs\r11\mdf\r11.grd';
if length(varargin)~= 0
    OPT          = setproperty(OPT,varargin);
end
file_xyn     = OPT.file_xyn;
file_obs     = OPT.file_obs;
file_grd     = OPT.file_grd;


%% Read xyn file
Values = dflowfm_io_xydata('read',file_xyn);
xv     = cell2mat(Values.DATA(:,1));
yv     = cell2mat(Values.DATA(:,2));
names  = Values.DATA(:,3);

%% Restrict to names only
for i_stat = 1: length(names)
    i_startstop   = strfind(names{i_stat},'''');
    names{i_stat} = names{i_stat}(i_startstop(1) + 1:i_startstop(2) - 1);
end

%% Read the grid file and retrieve coordinates of centres
grid = delft3d_io_grd('read',file_grd);
x    = grid.cend.x';
y    = grid.cend.y';

%% Find mn-coordinates
[m,n] = xy2mn(x,y,xv,yv);

%% Write to obs file
delft3d_io_obs('write',file_obs,m,n,names); 



