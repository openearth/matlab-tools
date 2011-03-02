function varargout = ddb_dnami(varargin)
%
global Mw        lat_epi     lon_epi    fdtop     totflength  fwidth   disloc     foption
global iarea     filearea    xareaGeo   yareaGeo  overviewpic fltpatch mrkrpatch flinepatch
global dip       strike      slip       fdepth    userfaultL  tolFlength
global nseg      faultX      faultY     faultTotL xvrt        yvrt
global mu        raddeg      degrad     rearth
%global Areaeq

global progdir   datadir    workdir     tooldir ldbfile
global xgrdarea  ygrdarea   grdsize

xgrdarea = [];   ygrdarea = [];
d3dfilgrd= [];   d3dfildep= [];
%
%initialise all necessary constants and data
%
raddeg= 180./pi;   degrad= pi/180.;
rearth= 6378137.;  mu    = 30.0e9;
iarea = 0;         Mw    = 0;        nseg = 1;
%
% Reinitialise all values
%
ddb_dnami_initValues()

%Start always in the path with ddb_dnami.m
cd(strrep(which('dnami.m'),'ddb_dnami.m',''));

%Reset paths
path(pathdef);
%Add current path and code-path
addpath(pwd);
% check Delft3D environment variable
tooldir=getINIValue('DTT_config.txt','Tooldir');
progdir=getINIValue('DTT_config.txt','Progdir');
datadir=getINIValue('DTT_config.txt','Datadir');
workdir=getINIValue('DTT_config.txt','Workdir');

addpath(tooldir);
addpath(datadir);

dum=str2num(getINIValue('DTT_config.txt','GridAreaLft')); xgrdarea= dum;
dum=str2num(getINIValue('DTT_config.txt','GridAreaRgt')); xgrdarea=[xgrdarea;dum];
dum=str2num(getINIValue('DTT_config.txt','GridAreaBot')); ygrdarea= dum;
dum=str2num(getINIValue('DTT_config.txt','GridAreaTop')); ygrdarea=[ygrdarea;dum];
grdsize   =str2num(getINIValue('DTT_config.txt','GridSize'));
tolFlength=str2num(getINIValue('DTT_config.txt','TolerancefLength'));

 
 
 %wlsettings
fig1 = openfig(mfilename,'reuse');
% Generate a structure of handles to pass to callbacks, and store it.
handles = guihandles(fig1);
guidata(fig1, handles);

% Use system color scheme for figure:
set(fig1,'Color',get(0,'defaultUicontrolBackgroundColor'));
set(fig1,'name','Tsunami Toolkit')
set(fig1,'Units','normalized')
set(fig1,'Position', ddb_dnami_getPlotPosition('LR'))

if nargout > 0
    varargout{1} = fig1;
end

%
% Set all values for initial start
%
ddb_dnami_setValues();
