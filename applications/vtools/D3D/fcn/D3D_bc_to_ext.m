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

function ext=D3D_bc_to_ext(bc)

ext.General.fileVersion='2.00';
ext.General.fileType='extForce';

nbc=numel(bc);

idx_block=-1; %the first one is 0
for kbc=1:nbc
    idx_block=idx_block+1;
    str_block=sprintf('Boundary%d',idx_block);

    switch bc(kbc).function
        case 'timeseries'
            %search for which quantity is time (usually the first one)
            bol_time=strcmpi(bc(kbc).quantity,'time');
            if sum(bol_time)~=1
                error('There is no time or more than one time quantity.')
            end
            if numel(bc(kbc).quantity)>2
                error('Only prepared for 2 quantities.')
            end
            quantity=bc(kbc).quantity{~bol_time};
        case 'qhtable'
            quantity='qhbnd';
        otherwise
            error('Unknown function in BC file: %s',bc(kbc).function)
    end
  
    %fill `ext`
    ext.(str_block).quantity=quantity;
    ext.(str_block).nodeId=bc(kbc).name;
    ext.(str_block).forcingfile=bc(kbc).forcingfile;
end %nbc

end %function