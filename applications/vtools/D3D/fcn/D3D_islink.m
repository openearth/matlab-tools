%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17520 $
%$Date: 2021-10-13 15:24:55 +0200 (Wed, 13 Oct 2021) $
%$Author: chavarri $
%$Id: NC_read_map.m 17520 2021-10-13 13:24:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_map.m $
%
%get data from 1 time step in D3D, output name as in D3D

function islink=D3D_islink(which_v)

islink=0;
switch which_v
    case [43]
        islink=1;
    otherwise
        islink=0;
end

end