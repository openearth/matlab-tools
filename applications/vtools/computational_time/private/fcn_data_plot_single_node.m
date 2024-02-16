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

function data_plot=fcn_data_plot_single_node(input_m,timeloop)

partitions_u=unique({input_m.D3D__partition});
partitions_u=partitions_u([2,5,1,3,4]); %adhoc reordering for legend
npart=numel(partitions_u);
bol_1_node=[input_m.D3D__nodes]==1;

data_plot=struct();
for kpart=1:npart
    str_part=partitions_u{kpart};
    bol_part=cellfun(@(X)strcmp(X,str_part),{input_m.D3D__partition});
    bol_get=bol_1_node & bol_part;

    data_plot(kpart).val=timeloop(bol_get);
    data_plot(kpart).x=[input_m(bol_get).D3D__tasks_per_node];
    data_plot(kpart).leg=str_part;
end %kpart

end %function