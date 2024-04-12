%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19059 $
%$Date: 2023-07-17 18:44:36 +0200 (Mon, 17 Jul 2023) $
%$Author: chavarri $
%$Id: input_D3D_layout.m 19059 2023-07-17 16:44:36Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/source/input_D3D_layout.m $
%

function str=svn_info

fpath_oet=which('oetsettings');

if isempty(fpath_oet)
    str='No OET';
else
    fdir=fileparts(fpath_oet);
    cmd=sprintf('svn info %s',fdir);
    [~,str]=system(cmd);
end

end %function