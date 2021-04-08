%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17077 $
%$Date: 2021-02-19 06:31:11 +0100 (Fri, 19 Feb 2021) $
%$Author: chavarri $
%$Id: D3D_comp.m 17077 2021-02-19 05:31:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_comp.m $
%
%cut initialization part of dia-file

function D3D_cut_dia(sim_path)

simdef.D3D.dire_sim=sim_path;
simdef=D3D_simpath(simdef);
dia_r=simdef.file.dia;
dia_w=strrep(dia_r,'.dia','.dia_ini');

fid_r=fopen(dia_r,'r');
fid_w=fopen(dia_w,'w');

write_lin=true;
kl=1;
while write_lin
lin=fgets(fid_r);
fprintf(fid_w,lin);
if contains(lin,'** INFO   : Done writing initial output to file(s).')==1
    write_lin=false;
end
kl=kl+1;
messageOut(NaN,sprintf('line %d',kl));
end
fclose(fid_r);
fclose(fid_w);

