function Data = EHY_interp_dfm2list (fileInp, timeRequested, list, varargin)

%% EHY_interp_dfm2list: Interpolate dflow-fm results from a map file to a list of points (a cartesian grid for example)
%  Example:
%
% %% Define grid
% grd = delft3d_io_grd('read','200x100_hvl.grd');
% 
% % Coordinates of grid points
% list.x = grd.cor.x;
% list.y = grd.cor.y;
% mmax   = size(list.x,2);
% nmax   = size(list.x,1);
% 
% % Make a vector of points 
% list.x = reshape(list.x,mmax*nmax,1);
% list.y = reshape(list.y,mmax*nmax,1);
% 
% % Interpolate x velocities
% ucx_list = EHY_interp_dfm2list (fileInp, time, list, varName, 'ucx');
% 
% % Interpolate y velocities
% ucy_list = EHY_interp_dfm2list (fileInp, time, list, varName, 'ucy');
%
%% Initialisation
OPT.varName = 'wl';
OPT         = setproperty(OPT,varargin);
varName     = OPT.varName;

%% Retrieve data from simulation
Info      = ncinfo(fileInp);
variables = {Info.Variables.Name};

%% Time
time     = ncread    (fileInp,'time');
att_time = ncreadatt (fileInp,'time','units');
itdate   = datenum   (att_time(15:24),'yyyy-mm-dd');
time     = itdate + time/(1440.*60.);

%% Coordinates
xcc = ncread(fileInp,'FlowElem_xcc');
ycc = ncread(fileInp,'FlowElem_ycc');

%% Values for parameter param
tmp = ncread(fileInp,varName);

no_faces = size(tmp,1);
no_times = size(tmp,2);

%% Interpolate to (x,y) as specified in list
i_time = find(time == timeRequested);
F     = TriScatteredInterp(xcc, ycc, tmp(:,i_time));
Data  = F(list.x,list.y);

