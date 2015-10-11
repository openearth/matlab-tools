clear variables;close all;

% Limits
xlower = 135;
xupper = 150;
ylower = 30;
yupper = 45;

dx=180; % horizontal resolution in seconds
dt=6;   % time step in sdu file in seconds
grdfile='japan.grd'; % Delft3D grid file
sdufile='japan01.sdu'; % Delft3D sdu file
inifile='japan01.ini';

refdate=datenum(2015,10,9); % reference data in sdu file

subfaultfile='ucsb_subfault_2011_03_11_v3.cfg';

dynamic_fault_rupture('subfaultfile',subfaultfile,'xlim',[xlower xupper],'ylim',[ylower yupper],'dx',dx,'dt',dt,'grdfile',grdfile,'sdufile',sdufile,'refdate',refdate,'inifile',inifile);

