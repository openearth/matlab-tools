%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16769 $
%$Date: 2020-11-05 11:40:08 +0100 (Thu, 05 Nov 2020) $
%$Author: chavarri $
%$Id: add_floodplane.m 16769 2020-11-05 10:40:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/bed_level_flume/add_floodplane.m $
%

function vmag=clean_velocity_type1(vmag,varargin)

flg.unit='cm';
flg=setproperty(flg,varargin);

vmag(vmag==-32768)=NaN;
switch flg.unit
    case 'cm'
        vmag=vmag./100;
    otherwise
        %left unchanged
end

end