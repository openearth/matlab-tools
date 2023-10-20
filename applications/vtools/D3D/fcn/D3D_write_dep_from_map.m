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
%Write xyz file from output in map file
%
%INPUT:
%   -fpath_map = filepath of the map-file to use [char]
%   -fpath_dep = filepath of the xyz-file to save [char]
%
%OUTPUT:
%   -
%
%OPTIONAL (pair input)
%   -'var' = variable name to extract from map-file. Default = 'mesh2d_mor_bl'
%

function D3D_write_dep_from_map(fpath_map,fpath_dep,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'var','mesh2d_mor_bl')

parse(parin,varargin{:})

varName=parin.Results.var;

%% CALC

messageOut(NaN,'Start reading')
[ismor,is1d,str_network1d,issus,structure]=D3D_is(fpath_map);
[time_r,time_mor_r,time_dnum,time_dtime]=D3D_results_time(fpath_map,ismor,NaN);
gridInfo=EHY_getGridInfo(fpath_map,{'XYcen','XYcor'});
data_map_etab=EHY_getMapModelData(fpath_map,'varName',varName,'t0',time_dnum,'tend',time_dnum,'disp',0);

messageOut(NaN,'Start interpolating')
F=scatteredInterpolant(gridInfo.Xcen,gridInfo.Ycen,data_map_etab.val','linear','linear');
dep_cor=F(gridInfo.Xcor,gridInfo.Ycor);

messageOut(NaN,'Start writing')
% dep_w=[gridInfo.Xcen,gridInfo.Ycen,data_map_etab.val'];
dep_w=[gridInfo.Xcor,gridInfo.Ycor,dep_cor];
D3D_io_input('write',fpath_dep,dep_w);


