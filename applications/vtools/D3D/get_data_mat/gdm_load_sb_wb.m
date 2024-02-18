%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19233 $
%$Date: 2023-11-09 10:23:03 +0100 (Thu, 09 Nov 2023) $
%$Author: chavarri $
%$Id: D3D_var_num2str.m 19233 2023-11-09 09:23:03Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_var_num2str.m $
%

function [sb,wb]=gdm_load_sb_wb(flg_loc,simdef)

sb=D3D_io_input('read',flg_loc.fpath_sb,'xy_only',1);
if isfield(flg_loc,'fpath_wb')
    wb=D3D_io_input('read',flg_loc.fpath_wb,'xy_only',1);
elseif isfield(simdef.file,'enc')
    wb=D3D_io_input('read',simdef.file.enc,'ver',3); %result in array
else
    error('There is no definition of winter bed. Provide either an enclosure file or a file directly as input.')
end

end %function