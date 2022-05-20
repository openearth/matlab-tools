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
%grid creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_grid(simdef)
%% RENAME

D3D_structure=simdef.D3D.structure;

%% FILE

%% before conversion function
% if D3D_structure==1
%     D3D_grd(simdef)
%     D3D_enc(simdef)
% else
%     D3D_grd_copy(simdef);
% end

%% with conversion function

% D3D_grd(simdef)
% D3D_enc(simdef)
%     
% if D3D_structure==2
%     if simdef.grd.cell_type==1
%         D3D_grd_convert(simdef)
%     else
%         D3D_grd_copy(simdef);
%     end
% end

%% direct write in FM

switch D3D_structure
    case 1
        D3D_grd(simdef)
        D3D_enc(simdef)
    case 2
        switch simdef.grd.type
            case 1
                D3D_grd_rect_u(simdef)
        end %simdef.grd.type
end
