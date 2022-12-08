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

function nt=D3D_nt_single(fpath_res,res_type)

[~,~,ext]=fileparts(fpath_res);
switch ext
    case '.nc'
        nt=NC_nt(fpath_res);
    case '.dat'
        nt=NEFIS_nt(fpath_res,res_type);
end %ext

end %function