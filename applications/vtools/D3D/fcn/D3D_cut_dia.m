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

