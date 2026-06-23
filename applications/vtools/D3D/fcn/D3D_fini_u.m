%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%generate depths in rectangular grid 

function D3D_fini_u(simdef,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'check_existing',true)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%%

ini=D3D_ini_etabwv(simdef);
D3D_io_input('write',simdef.file.IniFieldFile,ini,'check_existing',check_existing);
% D3D_ext(simdef);

%% XYcen
fpath_netmap=fullfile(pwd,'tmpgrd_net.nc');
D3D_grd2map(simdef.file.grd,'fpath_map',fpath_netmap,'fpath_exe',simdef.file.exe_grd2map);
gridInfo=EHY_getGridInfo(fpath_netmap,{'XYcen','XYcor'});
delete(fpath_netmap);

Xtot=[gridInfo.Xcen;gridInfo.Xcor];
Ytot=[gridInfo.Ycen;gridInfo.Ycor];

%% 

file_name=simdef.file.ini_vx;
matwrite=[Xtot,Ytot,simdef.ini.u.*ones(size(Xtot))];
write_2DMatrix(file_name,matwrite,'check_existing',check_existing);

file_name=simdef.file.ini_vy;
matwrite=[Xtot,Ytot,simdef.ini.v.*ones(size(Xtot))];
write_2DMatrix(file_name,matwrite,'check_existing',check_existing);
  
end %function

%%

function ini=D3D_ini_etabwv(simdef)

% Create struct array with 4 Initial blocks for iniField file
ini = struct();

% [Initial] - bedlevel
ini(1).quantity = 'bedlevel';
ini(1).dataFile = relative_path(simdef.file.dep, simdef.D3D.dire_sim);
ini(1).dataFileType = 'sample';
ini(1).interpolationMethod = 'averaging';
ini(1).averagingType = 'nearestNb';

% [Initial] - initialWaterLevel
ini(2).quantity = 'initialWaterLevel';
ini(2).dataFile = relative_path(simdef.file.etaw, simdef.D3D.dire_sim);
ini(2).dataFileType = 'sample';
ini(2).interpolationMethod = 'averaging';
ini(2).averagingType = 'nearestNb';

% [Initial] - initialVelocityX
ini(3).quantity = 'initialVelocityX';
ini(3).dataFile = relative_path(simdef.file.ini_vx, simdef.D3D.dire_sim);
ini(3).dataFileType = 'sample';
ini(3).interpolationMethod = 'averaging';
ini(3).averagingType = 'nearestNb';

% [Initial] - initialVelocityY
ini(4).quantity = 'initialVelocityY';
ini(4).dataFile = relative_path(simdef.file.ini_vy, simdef.D3D.dire_sim);
ini(4).dataFileType = 'sample';
ini(4).interpolationMethod = 'averaging';
ini(4).averagingType = 'nearestNb';

end %function