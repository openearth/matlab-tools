%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_convert_aru_arv.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/convert_d3d_fm/D3D_convert_aru_arv.m $
%

function z_out=add_groynes(geom,x,y,z_in)

%% RENAME

% v2struct(geom) %expensive

%external
L_to_first_groyn=geom.L_to_first_groyn;
L_between_groynes=geom.L_between_groynes;
B_floodplane=geom.B_floodplane;
B_groyn=geom.B_groyn;
L_groyn=geom.L_groyn;
L_to_downstream_end=geom.L_to_downstream_end;

%% CALC

xfrac=rem(x-L_to_first_groyn,L_between_groynes);
groyn_field_number=floor((x-L_to_first_groyn)/L_between_groynes); 

if x<=L_to_first_groyn || y<=B_floodplane || y>=B_floodplane+B_groyn || x>=L_to_downstream_end
    z_out=z_in;
else
    if xfrac<=L_groyn
        x_rel=x-L_to_first_groyn-groyn_field_number*L_between_groynes;
        y_rel=y-B_floodplane;
        z_rel=z_in;
        z_out=add_one_groyn(geom,x_rel,y_rel,z_rel);
    else
        z_out=z_in;
    end
end

end %function