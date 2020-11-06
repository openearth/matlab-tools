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

function z_out=add_groyne_field(geom,x,y,z_in)

%% RENAME

%external
B_floodplane=geom.B_floodplane;
B_groyne_field=geom.B_groyne_field;
h_groyne_field=geom.h_groyne_field;
s_n1_groyne_field=geom.s_n1_groyne_field;
s_n2_groyne_field=geom.s_n2_groyne_field;

%internal
B2=h_groyne_field/tan(s_n2_groyne_field);
B1=B_groyne_field-B2;
h2=tan(s_n1_groyne_field)*B1;
ht=h_groyne_field+h2;
y_rel=y-B_floodplane;

%% CALC

if y>B_floodplane && y<B_floodplane+B_groyne_field
    %trapezoid uniform in x
    z=z_in+ht;

    %substratct transverse slope 
    if y_rel<=B1
        h_max=-s_n1_groyne_field*y_rel+ht+z_in;
        if z>h_max
            z=h_max;
        end
    elseif y_rel<=B_groyne_field
        h_max=-s_n2_groyne_field*(y_rel-B_groyne_field)+z_in;
        if z>h_max
            z=h_max;
        end
    else
        error('you should not get here')    
    end

    %output
    z_out=z;
else
    z_out=z_in;
end

end %function