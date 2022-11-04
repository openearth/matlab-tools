%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17508 $
%$Date: 2021-09-30 11:17:04 +0200 (Thu, 30 Sep 2021) $
%$Author: chavarri $
%$Id: NC_nt.m 17508 2021-09-30 09:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_nt.m $
%
%

function nt=D3D_nt_single(fpath_res,res_type)

[~,~,ext]=fileparts(fpath_res);
switch ext
    case '.nc'
        nt=NC_nt(fpath_res);
    case '.dat'
        nt=NEFIS_nt(fpath_res,res_type);
end %ext

end %function