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
%E.G. 1
%
%[fid_lin,fid_win]=D3D_create_run_batch('open',path_folder_sims);
%D3D_create_run_batch('add',path_folder_sims,fid_lin,fid_win,sim_id,strsoft_lin,strsoft_win);
%D3D_create_run_batch('close',path_folder_sims,fid_lin,fid_win);
%
%
%E.G. 2 (loop)
%
%
% path_folder_sims='d:\temporal\210804_fm_1d_implicit\06_models\03_multiple_branch\03_runs_test_reference\';
% simdef.file.software='p:\dflowfm\projects\2022_fm_1d_implicit\08_executables\exe_08\';
% 
% fdir_v=1:1:13;
% 
% [fid_lin,fid_win]=D3D_create_run_batch('open',path_folder_sims);
% for kdir=1:numel(fdir_v)
%     sim_id=sprintf('r%03d',fdir_v(kdir));
%     
%     simdef.D3D.dire_sim=fullfile(path_folder_sims,sim_id);
%     simdef.D3D.structure=2;
%     simdef.runid.name='sc'; %maybe same as <sim_id>
%     
%     [strsoft_lin,strsoft_win]=D3D_bat(simdef,simdef.file.software,'check_existing',false);
%     D3D_create_run_batch('add',path_folder_sims,fid_lin,fid_win,sim_id,strsoft_lin,strsoft_win);
% end
% D3D_create_run_batch('close',path_folder_sims,fid_lin,fid_win);

%%
function varargout=D3D_create_run_batch(do_what,path_folder_sims,varargin)

call_script_par='run_cases_par';
call_script_seq='run_cases_seq';
run_script_lin='run.sh'; %this must be the same as in D3D_bat
run_script_win='run.bat'; %this must be the same as in D3D_bat
        
fout_name_lin=sprintf('%s.sh',call_script_par);
fout_lin=fullfile(path_folder_sims,fout_name_lin);
fout_c_lin=fullfile(pwd,fout_name_lin);

fout_name_win=sprintf('%s.bat',call_script_par);
fout_win=fullfile(path_folder_sims,fout_name_win);
fout_c_win=fullfile(pwd,fout_name_win);

fout_name_lin_seq=sprintf('%s.sh',call_script_seq);
fout_lin_seq=fullfile(path_folder_sims,fout_name_lin_seq);
fout_c_lin_seq=fullfile(pwd,fout_name_lin_seq);

fout_name_win_seq=sprintf('%s.bat',call_script_seq);
fout_win_seq=fullfile(path_folder_sims,fout_name_win_seq);
fout_c_win_seq=fullfile(pwd,fout_name_win_seq);

switch do_what
    case 'open'
        fid_lin=fopen(fout_c_lin,'w');
        fid_win=fopen(fout_c_win,'w');
        fid_lin_seq=fopen(fout_c_lin_seq,'w');
        fid_win_seq=fopen(fout_c_win_seq,'w');
        
        varargout{1}=[fid_lin,fid_lin_seq];
        varargout{2}=[fid_win,fid_win_seq];
    case 'add'
        fid_lin=varargin{1}(1);
        fid_lin_seq=varargin{1}(2);
        fid_win=varargin{2}(1);
        fid_win_seq=varargin{2}(2);
        sim_id=varargin{3};
        strsoft_lin=varargin{4};
        strsoft_win=varargin{5};
        
        %lin
        fprintf(fid_lin,'cd ./%s \n',sim_id);  
        fprintf(fid_lin,'dos2unix %s \n',run_script_lin);
        fprintf(fid_lin,'./%s \n',run_script_lin);
        fprintf(fid_lin,'cd ../ \n');

        %win
        fprintf(fid_win,'cd %s \n',sim_id);  
        fprintf(fid_win,'start "w1" %s \n',run_script_win);
        fprintf(fid_win,'cd ../ \n');
        
        %lin
        fprintf(fid_lin_seq,'cd ./%s \n',sim_id);  
        fprintf(fid_lin_seq,'%s \n',strsoft_lin);
        fprintf(fid_lin_seq,'cd ../ \n');

        %win
        fprintf(fid_win_seq,'cd %s \n',sim_id);  
        fprintf(fid_win_seq,'%s \n',strsoft_win);
        fprintf(fid_win_seq,'cd ../ \n');
    case 'close'
        fid_lin=varargin{1}(1);
        fid_lin_seq=varargin{1}(2);
        fid_win=varargin{2}(1);
        fid_win_seq=varargin{2}(2);
        
        fclose(fid_lin);
        copyfile(fout_c_lin,fout_lin);

        fclose(fid_win);
        copyfile(fout_c_win,fout_win);
        
        fclose(fid_lin_seq);
        copyfile(fout_c_lin_seq,fout_lin_seq);

        fclose(fid_win_seq);
        copyfile(fout_c_win_seq,fout_win_seq);
    otherwise 
        error('not sure what to do')
end

end %function
