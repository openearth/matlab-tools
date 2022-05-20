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
function D3D_convert_bnd_q_xcell(paths_grd_in,paths_bnd_in,folder_out)

grd=delft3d_io_grd('read',paths_grd_in);
bnd=delft3d_io_bnd('read',paths_bnd_in,grd);

upstream_nodes=numel(bnd.DATA);

for kun=1:upstream_nodes
    
xcor_1=grd.cor.x(bnd.DATA(kun).n,bnd.DATA(kun).m-1); 
ycor_1=grd.cor.y(bnd.DATA(kun).n,bnd.DATA(kun).m-1);
xcor_2=grd.cor.x(bnd.DATA(kun).n,bnd.DATA(kun).m); 
ycor_2=grd.cor.y(bnd.DATA(kun).n,bnd.DATA(kun).m);

name_node=bnd.DATA(kun).name;

kl=1;
data{kl, 1}=sprintf('%s',name_node); kl=kl+1;
data{kl, 1}=        '    2    2'; kl=kl+1;
data{kl, 1}=sprintf('%0.7E  %0.7E %s_0001',xcor_1,ycor_1,name_node); kl=kl+1;
data{kl, 1}=sprintf('%0.7E  %0.7E %s_0002',xcor_2,ycor_2,name_node); %kl=kl+1;

%% WRITE

file_name=fullfile(folder_out,sprintf('%s.pli',name_node));
writetxt(file_name,data)

end

end %function