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
%Create pathst to send single files to Cartesius

function copy_single_files_to_cartesius(surf_userid,file2send_win,cartesius_project_folder_lin,folder_commands)

path_commands=fullfile(folder_commands,'commands_send_single_files.sh');
fid=fopen(path_commands,'w');
nf=numel(file2send_win);
for kf=1:nf
   file2send_lin_t=linuxify(file2send_win{kf}); 
   file_ca_t=strrep(file2send_lin_t,'/p/',cartesius_project_folder_lin);
   fprintf(fid,'scp %s %s@cartesius.surfsara.nl:%s \n',file2send_lin_t,surf_userid,file_ca_t); %scp /p/11205258-016-kpp2020rmm-3d/C_Work/00_temporal/scripts_cartesius/run_3.sh  pr1n0147@cartesius.surfsara.nl:/projects/0/hisigem/11205258-016-kpp2020rmm-3d/C_Work/01_RMM_simulations/computations/a_022/run_3.sh
end

fclose(fid);
messageOut(NaN,'Run in H6: ');
fprintf('\n')
fprintf('%s \n',linuxify(path_commands))

end %function