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

function varname_read_variable=D3D_sediment_transport_offline_variables_read(varname)

[~,varname_read_variable,~,~]=D3D_var_num2str(varname); %This is the name used for saving the raw output

%But for `Ltot`, the variable which is read in raw is different...
%Not the nicest, but this is what it is. 
switch varname_read_variable
    case 'Ltot'
        varname_read_variable='mesh2d_thlyr';
end

end %function