%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18039 $
%$Date: 2022-05-10 19:09:44 +0200 (Tue, 10 May 2022) $
%$Author: chavarri $
%$Id: gdm_load_rkm_polygons.m 18039 2022-05-10 17:09:44Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_load_rkm_polygons.m $
%
%

function data=D3D_clock_time(fpath_in)

%% get path dia

if isfolder(fpath_in)    
    simdef.D3D.dire_sim=fpath_in;
    fpath_dia=simdef.file.dia;
else
    fpath_dia=fpath_in;
end

%% read

fid_log=fopen(fpath_dia,'r');

npre=1e3;
tok_all=cell(npre,1);

kc=0;
while ~feof(fid_log)
    lin=fgetl(fid_log);
    if numel(lin)>6 && strcmp(lin(1:7),'** INFO')==0
        continue
    end
    % ** INFO   :    Sim. time done   Sim. time left   Real time used   Real time left Steps left Complete% Interval-averaged time step 
    % ** INFO   :           0d  0:40:00        193d 23:20:00          0d  0:01:09          5d 12:58:52     279320     0.0%     8.53933 
%     lin='** INFO   :           0d  0:40:00        193d 23:20:00          0d  0:01:09          5d 12:58:52     279320     0.0%     8.53933 ';
    tok=regexp(lin,'** INFO   :\s+(\d+)d\s+(\d+):(\d+):(\d+)\s+(\d+)d\s+(\d+):(\d+):(\d+)\s+(\d+)d\s+(\d+):(\d+):(\d+)\s+(\d+)d\s+(\d+):(\d+):(\d+)\s+(\d+)\s+(\d+.\d+)%\s+(\d+.\d+)','tokens');
    if isempty(tok)
        continue
    end
    kc=kc+1;
    tok_all{kc,1}=tok{1,1};
    
    %preallocating does not help speed-up in this case :(
    if kc==numel(tok_all)
        tok_all=cat(1,tok_all,cell(npre,1));
    end
    
   %disp
   fprintf('Lines found: %d \n',kc)
    
end %while

tok_all=tok_all(1:kc);

%% rework

tok_double=cellfun(@(X)str2double(X),tok_all,'UniformOutput',false);
tok_mat=cell2mat(tok_double);

sim_time_done=days(tok_mat(:,1))+hours(tok_mat(:,2))+minutes(tok_mat(:,3))+seconds(tok_mat(:,4));
sim_time_left=days(tok_mat(:,5))+hours(tok_mat(:,6))+minutes(tok_mat(:,7))+seconds(tok_mat(:,8));
clock_time_done=days(tok_mat(:,9))+hours(tok_mat(:,10))+minutes(tok_mat(:,11))+seconds(tok_mat(:,12));
clock_time_left=days(tok_mat(:,13))+hours(tok_mat(:,14))+minutes(tok_mat(:,15))+seconds(tok_mat(:,16));
steps_left=tok_mat(:,17);
percentage_done=tok_mat(:,18);
interval_dt=tok_mat(:,19);

%% out

data=v2struct(sim_time_done,sim_time_left,clock_time_done,clock_time_left,steps_left,percentage_done,interval_dt);

end %function

