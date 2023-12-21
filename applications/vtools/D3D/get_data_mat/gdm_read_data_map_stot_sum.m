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

function data_var=gdm_read_data_map_stot_sum(fdir_mat,fpath_map,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'var_idx',[]);
% addOptional(parin,'tol',1.5e-7);
addOptional(parin,'idx_branch',[]);
addOptional(parin,'branch','');
addOptional(parin,'layer',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
var_idx=parin.Results.var_idx;
% tol=parin.Results.tol;
layer=parin.Results.layer;
idx_branch=parin.Results.idx_branch;
branch=parin.Results.branch;

%% READ

data_var=gdm_read_data_map_stot(fdir_mat,fpath_map,varname,'tim',time_dnum,'var_idx',var_idx,'idx_branch',idx_branch,'branch',branch,'layer',layer); 

%get desired fractions
%     idx_f=D3D_search_index_in_dimension(data_lyrfrac,'sedimentFraction'); 
idx_f=D3D_search_index_fraction(data_var); 
%This is not the best. What we should do is that, at the start, if `var_idx` is empty, it is made equal to all of them.
% if isempty(var_idx)
%     var_idx=1:1:size(data_var.val,idx_f);
% end
data_var.val=submatrix(data_var.val,idx_f,var_idx); %take submatrix along dimension
%sum over sediment dimension
data_var.val=sum(data_var.val,idx_f); %I cannot see why do we need to sum over fractions. I don't remember for which case did I do this. 

end %function