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
%Convert the input flag for sediment transport in  a D3D simulation (simdef.mor.IHidExp) into the input for computing
%sediment transport with function `sediment_transport`.

function hiding=D3D_input_hiding_2_sediment_transport(IHidExp)

switch IHidExp
    case 1 %no hiding
        hiding=0;
    case 2 %Egiazaroff
        hiding=1;
    case 3 %Ashida-Michihue
        hiding=3;
    case 4 %power
        hiding=2;
    otherwise
        error('do')
end %IFORM

end %function