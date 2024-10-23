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
%

function data=gdm_read_data_map_q(fdir_mat,fpath_map,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'idx_branch',[]);
addOptional(parin,'branch','');

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
idx_branch=parin.Results.idx_branch;
branch=parin.Results.branch;

%% CALC

[ismor,is1d,str_network1d,issus]=D3D_is(fpath_map);
if is1d
    error('make it 1D proof')
end

[~,varname]=D3D_var_num2str('ucmag','is1d',is1d,'ismor',ismor);
data_umag=gdm_read_data_map(fdir_mat,fpath_map,varname,'tim',time_dnum,'idx_branch',idx_branch,'branch',branch); 
[~,varname]=D3D_var_num2str('h','is1d',is1d,'ismor',ismor);
data_h=gdm_read_data_map(fdir_mat,fpath_map,varname,'tim',time_dnum,'idx_branch',idx_branch,'branch',branch); 
% data_Ltot=gdm_order_dimensions(NaN,data_Ltot);

data=data_umag;
data.val=data_umag.val.*data_h.val;

end %function