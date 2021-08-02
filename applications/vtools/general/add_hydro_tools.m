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
%Add paths of hydro tools

function add_hydro_tools(path_hyd)

fid_log=NaN;
if exist('update_hydro_tools','file')~=2
    messageOut(fid_log,sprintf('Start adding repository '));
    addpath(genpath(path_hyd)); 
else
    messageOut(fid_log,sprintf('Repository already exists'));
end