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

function [varname_save_mat,varname_read_variable,varname_load_mat]=D3D_var_num2str_structure(varname,simdef,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'res_type','map');

parse(parin,varargin{:});

res_type=parin.Results.res_type;

%%
[varname_save_mat,varname_read_variable,varname_load_mat]=D3D_var_num2str(varname,'structure',simdef.D3D.structure,'ismor',simdef.D3D.ismor,'is1d',simdef.D3D.is1d,'res_type',res_type,'is3d',simdef.D3D.is3d);

%not necessary! it is done in <gdm_read_data_map_#>
% if simdef.D3D.structure==1
%     switch var_str_read
%         case 'bl'
%             var_str_read='DPS';
%     end
% end

end
