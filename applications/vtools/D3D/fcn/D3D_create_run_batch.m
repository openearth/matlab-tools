%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17937 $
%$Date: 2022-04-05 13:43:41 +0200 (Tue, 05 Apr 2022) $
%$Author: chavarri $
%$Id: D3D_bat.m 17937 2022-04-05 11:43:41Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_bat.m $
%

function varargout=D3D_create_run_batch(do_what,path_folder_sims,varargin)

call_script='run_cases';
run_script_lin='run.sh'; %this must be the same as in D3D_bat
run_script_win='run.bat'; %this must be the same as in D3D_bat
        
fout_name_lin=sprintf('%s.sh',call_script);
fout_lin=fullfile(path_folder_sims,fout_name_lin);
fout_c_lin=fullfile(pwd,fout_name_lin);

fout_name_win=sprintf('%s.bat',call_script);
fout_win=fullfile(path_folder_sims,fout_name_win);
fout_c_win=fullfile(pwd,fout_name_win);

switch do_what
    case 'open'
        fid_lin=fopen(fout_c_lin,'w');
        fid_win=fopen(fout_c_win,'w');
        
        varargout{1}=fid_lin;
        varargout{2}=fid_win;
    case 'add'
        fid_lin=varargin{1};
        fid_win=varargin{2};
        sim_id=varargin{3};
        
        %lin
        fprintf(fid_lin,'cd ./%s \n',sim_id);  
        fprintf(fid_lin,'dos2unix %s \n',run_script_lin);
        fprintf(fid_lin,'./%s \n',run_script_lin);
        fprintf(fid_lin,'cd ../ \n');

        %win
        fprintf(fid_win,'cd %s \n',sim_id);  
        fprintf(fid_win,'start "w1" %s \n',run_script_win);
        fprintf(fid_win,'cd ../ \n');
    case 'close'
        fid_lin=varargin{1};
        fid_win=varargin{2};
        
        fclose(fid_lin);
        copyfile(fout_c_lin,fout_lin);

        fclose(fid_win);
        copyfile(fout_c_win,fout_win);
    otherwise 
        error('not sure what to do')
end

end %function
