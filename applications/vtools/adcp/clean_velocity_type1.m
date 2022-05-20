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