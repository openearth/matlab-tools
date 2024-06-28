%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19050 $
%$Date: 2023-07-14 09:55:51 +0200 (Fri, 14 Jul 2023) $
%$Author: chavarri $
%$Id: gdm_read_data_map_ls.m 19050 2023-07-14 07:55:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_ls.m $
%
%

function pliname=gdm_pli_name(fpath_pli)

if ischar(fpath_pli) %it is a file
    if exist(fpath_pli,'file')~=2
        error('pli file does not exist: %s',fpath_pli);
    end
    [~,pliname,~]=fileparts(fpath_pli);
    pliname=strrep(pliname,' ','_');
else %it is a double
    str=hash_matrix(fpath_pli);
    pliname=str(1:6);
end

end %function