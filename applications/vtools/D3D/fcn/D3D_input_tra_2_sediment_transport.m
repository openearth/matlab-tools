%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19687 $
%$Date: 2024-06-24 17:30:38 +0200 (Mon, 24 Jun 2024) $
%$Author: chavarri $
%$Id: twoD_study.m 19687 2024-06-24 15:30:38Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/ECT/twoD_study.m $
%
%Convert the input flag for sediment transport in  a D3D simulation (simdef.tra.IFORM) into the input for computing
%sediment transport with function `sediment_transport`.

function tra=D3D_input_tra_2_sediment_transport(IFORM)

nf=numel(IFORM);
tra=NaN(size(IFORM));

for kf=1:nf
    switch IFORM(kf)
        case 4
            tra(kf)=1;
        otherwise
            error('do')
    end %IFORM
end %kf

end %function