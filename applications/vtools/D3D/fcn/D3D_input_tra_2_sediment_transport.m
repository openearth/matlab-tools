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