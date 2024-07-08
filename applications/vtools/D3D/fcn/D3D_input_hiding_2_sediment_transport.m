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
%Convert the input flag for sediment transport in  a D3D simulation (simdef.mor.IHidExp) into the input for computing
%sediment transport with function `sediment_transport`.

function hiding=D3D_input_hiding_2_sediment_transport(IHidExp)

switch IHidExp
    case 1
        hiding=0;
    case 2
        hiding=1;
    case 3
        hiding=3;
    otherwise
        error('do')
end %IFORM

end %function