%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19340 $
%$Date: 2024-01-08 15:33:47 +0100 (Mon, 08 Jan 2024) $
%$Author: chavarri $
%$Id: gdb_read_variables_file.m 19340 2024-01-08 14:33:47Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/gdb_read_variables_file.m $
%

%%
%E.G.:
% fpath_cmd='p:\dflowfm\users\chavarri\240111_rst\commands.txt';
% fpath_exe_gdb='p:\dflowfm\users\ottevan\delft3d\delft3d\build_dflowfm_debug\install\bin\dflowfm'    ;
% fpath_sim='p:\dflowfm\users\chavarri\240111_rst\c67_erosilt_sand_mud';
% D3D_compare_restart_simulation(fpath_sim,fpath_cmd,'fpath_exe_gdb',fpath_exe_gdb,'overwrite',0);

function D3D_compare_restart_simulation(fpath_ref,fpath_cmd,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'DTUser_fact',10);
% addOptional(parin,'fpath_exe','p:\d-hydro\dimrset\latest\');
addOptional(parin,'fpath_exe_gdb','p:\d-hydro\dimrset\latest\');
addOptional(parin,'TStart_rst_fact',10);
addOptional(parin,'overwrite',1);

parse(parin,varargin{:});

DTUser_fact=parin.Results.DTUser_fact;
% fpath_exe=parin.Results.fpath_exe;
fpath_exe_gdb=parin.Results.fpath_exe_gdb;
TStart_rst_fact=parin.Results.TStart_rst_fact;
overwrite=parin.Results.overwrite;

%% CALC

[fdir_up,fdir_last]=folderUp(fpath_ref); %folder up and name of simulation folder

%copy reference simulation to main
fdirname_main=sprintf('%s_main',fdir_last);
fpath_main=fullfile(fdir_up,fdirname_main);

if ~isfolder(fpath_main) || overwrite
    copyfile_check(fpath_ref,fpath_main);
end

%modify reference simulation
    %mdf
simdef_main=D3D_simpath(fpath_main);
mdf_main=D3D_io_input('read',simdef_main.file.mdf);

mdf_main.output.RstInterval=mdf_main.time.DtUser*DTUser_fact;
mdf_main.output.Wrirst_bnd=1;

D3D_io_input('write',simdef_main.file.mdf,mdf_main);

%copy main simulation to restart
fdirname_rst=sprintf('%s_rst',fdir_last);
fpath_rst=fullfile(fdir_up,fdirname_rst);
if ~isfolder(fpath_main) || overwrite
    copyfile_check(fpath_main,fpath_rst);
end 

%modify restart simulation
    %mdf
simdef_rst=D3D_simpath(fpath_rst); 
mdf_rst=D3D_io_input('read',simdef_rst.file.mdf);

TStart_rst=TStart_rst_fact*mdf_rst.time.DtUser; %[TUnit]
mdf_rst.time.TStart=TStart_rst; %[TUnit]

TFact=time_factor(mdf_rst.time.Tunit);
mdf_rst.numerics.Tlfsmo=max([0,(mdf_main.time.TStart-TStart_rst)*TFact]); %`Tlfsmo` in [s]

rst_time_dtime=datetime(num2str(mdf_rst.time.RefDate),'InputFormat','yyyyMMdd')+seconds(TStart_rst*TFact); 
rst_time_str=string(rst_time_dtime,'yyyyMMdd_HHmmSS');
mdf_rst.restart.RestartFile=sprintf('%s_%s_rst.nc',simdef_rst.file.mdfid,rst_time_str); %tst_20140819_120000_rst.nc

D3D_io_input('write',simdef_rst.file.mdf,mdf_rst);

    %mor-file
mor=D3D_io_input('read',simdef_rst.file.mor);
mor.Morphology0.MorStt=max([0,mdf_main.time.TStart-mor.Morphology0.MorStt]); %`MorStt` in [TUnit]
D3D_io_input('write',simdef_rst.file.mor,mor);
    
%     %run reference simulation to create restart files
%     run_simulation(simdef_main,fpath_exe);
    
%     %copy restart file to main folder
%     fpath_rst_file_in =fullfile(simdef_main.file.output,mdf_rst.restart.RestartFile);
%     fpath_rst_file_out=fullfile(simdef_rst.D3D.dire_sim,mdf_rst.restart.RestartFile);
%     copyfile_check(fpath_rst_file_in,fpath_rst_file_out,1);

%create local path of restart file by removing the main directory and changing bars from Windows to Linux. 
%E.g. output: c87_restart_graded_inicomp/dflowfmoutput/str_20151101_000100_rst.nc
fpath_rel_rst=strrep(strrep(fullfile(simdef_main.file.output,mdf_rst.restart.RestartFile),fdir_up,''),'\','/');

%% GDB scripts

[~,fname,fext]=fileparts(simdef_main.file.mdf);
mdu_filename=sprintf('%s%s',fname,fext);

create_run_main_and_restart(fdir_up);
create_run_main_full(fdir_up,fdirname_main,fpath_exe_gdb,mdu_filename)
create_run_main(fdir_up,fdirname_main,'main');
create_run_main(fdir_up,fdirname_rst,'rst',fpath_rel_rst);
create_create_core(fdir_up,fpath_exe_gdb);
create_list_core(fdir_up,fpath_exe_gdb);
create_print_core(fdir_up,fpath_exe_gdb);
create_test_create(fdir_up,fpath_cmd,mdu_filename);
create_test_list(fdir_up);
create_postprocess_main_and_restart(fdir_up,fdirname_main,fdirname_rst);

%%

%run_main_and_restart
    %run_main
        %create_core
            %test_create
        %list_core
            %test_list
        %print_core
    %run_restart (same structure as <run_main>)

end %function

%%
%% FUNCTION
%%

function run_simulation(simdef,fpath_exe)

fdir_work=pwd; %working folder
simdef.D3D.OMP_num=1;
D3D_bat(simdef,fpath_exe,'check_existing',0);
cd(simdef.D3D.dire_sim);
if ispc
    system('run.bat');
else
    system('run.sh');
end
cd(fdir_work);

end %function

%%

function create_run_main_and_restart(fdir)

fpath=fullfile(fdir,'run_main_and_restart.sh');
fid=fopen(fpath,'w');

fprintf(fid,'#Change all to Unix and run: \n');
fprintf(fid,'#  dos2unix *.sh *.gdb \n');
fprintf(fid,'#  ./run_main_and_restart.sh \n');
fprintf(fid,' \n');
fprintf(fid,'./run_main_full.sh \n');
fprintf(fid,'./run_main.sh \n');
fprintf(fid,'./run_rst.sh \n');

fclose(fid);

end

%%

function create_run_main_full(fdir,dir_sim,fpath_exe_gdb,fname_mdu)

fpath=fullfile(fdir,'run_main_full.sh');
fid=fopen(fpath,'w');

fprintf(fid,'cd %s \n',dir_sim);
fprintf(fid,'%s %s -autostartstop \n',linuxify(fpath_exe_gdb),fname_mdu); %/p/dflowfm/users/ottevan/delft3d/delft3d/build_dflowfm_debug/install/bin/dflowfm tst.mdu -autostartstop
fprintf(fid,'cd .. \n');

fclose(fid);

end

%%

function create_run_main(fdir,dir_sim,str,fpath_rel_rst)

fpath=fullfile(fdir,sprintf('run_%s.sh',str));
fid=fopen(fpath,'w');

fprintf(fid,'cd %s \n',dir_sim);
if strcmp(str,'rst') %if restart file
    %remove restart file from the folder
    fprintf(fid,'rm *_rst.nc \n');
    fprintf(fid,'cp ../%s . \n',fpath_rel_rst);
end
fprintf(fid,'./../create_core.sh           \n');
fprintf(fid,'./../list_core.sh             \n');
fprintf(fid,'./../print_core.sh            \n');
fprintf(fid,'cd ..                         \n');

fclose(fid);

end

%%

function create_create_core(fdir,fpath_exe)

fpath=fullfile(fdir,'create_core.sh');
fid=fopen(fpath,'w');

fprintf(fid,'rm logs/create.log                       \n');
fprintf(fid,'mkdir logs                               \n');
fprintf(fid,'rm core.*                                \n');
fprintf(fid,'gdb --batch --command=../test_create.gdb %s \n',linuxify(fpath_exe)); %/p/dflowfm/users/ottevan/delft3d/delft3d/build_dflowfm_debug/install/bin/dflowfm

fclose(fid);

end

%%

function create_list_core(fdir,fpath_exe)

fpath=fullfile(fdir,'list_core.sh');
fid=fopen(fpath,'w');

fprintf(fid,'rm logs/list.log                                       \n');
fprintf(fid,'mkdir logs                                             \n');
fprintf(fid,'gdb --batch --command=../test_list.gdb %s core.* > tmp \n',linuxify(fpath_exe));

fclose(fid);

end 

%% 

function create_print_core(fdir,fpath_exe)

fpath=fullfile(fdir,'print_core.sh');
fid=fopen(fpath,'w');

fprintf(fid,'rm logs/print.log \n');
fprintf(fid,'mkdir logs \n');
fprintf(fid,'echo set print elements 0 > test_print.gdb \n'); %`>` for opening
fprintf(fid,'echo set print repeats 0 >> test_print.gdb \n'); %`>>` to append
fprintf(fid,'echo set pagination off >> test_print.gdb \n');
fprintf(fid,'echo set logging file logs/print.log >> test_print.gdb \n');
fprintf(fid,'echo set logging on >> test_print.gdb \n');
fprintf(fid,'sed ''s/.*m_\\([a-z0-9_]*\\)_mp_\\([a-z0-9_]*\\)_\\($*.*\\)/echo m_\\1::\\2\\\\n\\nprint m_\\1::\\2/g'' logs/list.log >> test_print.gdb \n');
fprintf(fid,'sed -i -z ''s/All variables matching regular expression "m_flow_mp_":\\n\\nNon-debugging symbols:\\n//g'' test_print.gdb \n');
fprintf(fid,'sed -i -z ''s/All variables matching regular expression "m_flowtimes_mp_":\\n\\nNon-debugging symbols:\\n//g'' test_print.gdb \n');
fprintf(fid,'sed -i -z ''s/All variables matching regular expression "m_flowgeom_mp_":\\n\\nNon-debugging symbols:\\n//g'' test_print.gdb \n');
fprintf(fid,'gdb --batch --command=test_print.gdb %s core.*  \n',linuxify(fpath_exe));

fclose(fid);

end 

%%

function create_test_create(fdir,fpath_cmd,mdu_filename)

fpath=fullfile(fdir,'test_create.gdb');
fid=fopen(fpath,'w');

fprintf(fid,'set print elements 0 \n');
fprintf(fid,'set print repeats 0 \n');
fprintf(fid,'set pagination off \n');
fprintf(fid,'set logging file logs/create.log \n');
fprintf(fid,'set logging on \n');

% fprintf(fid,'break step_reduce.f90:95 \n');
% fprintf(fid,'condition 1 time1.gt.ti_rst \n');
%read
fid_r=fopen(fpath_cmd,'r');
while ~feof(fid_r)
    lin=fgets(fid_r);
    fprintf(fid,lin);
end
fclose(fid_r);

fprintf(fid,'r --autostartstop %s \n',mdu_filename);
fprintf(fid,'print m_flowtimes::time1 \n');
fprintf(fid,'generate-core-file \n');

fclose(fid);

end 

%%

function create_test_list(fdir)

fpath=fullfile(fdir,'test_list.gdb');
fid=fopen(fpath,'w');

fprintf(fid,'set print elements 0 \n');
fprintf(fid,'set print repeats 0 \n');
fprintf(fid,'set pagination off \n');
fprintf(fid,'set logging file logs/list.log \n');
fprintf(fid,'set logging on \n');
fprintf(fid,'info variable m_flow_mp_ \n');
% fprintf(fid,'info variable m_flowtimes_mp_ \n');
% fprintf(fid,'info variable m_flowgeom_mp_ \n');

fclose(fid);

end

%%

function create_postprocess_main_and_restart(fdir,fdirname_main,fdirname_rst)

fpath=fullfile(fdir,'test_list.gdb');
fid=fopen(fpath,'w');

fprintf(fid,'cd %s \n',fdirname_main);
fprintf(fid,'./../list_core.sh \n');
fprintf(fid,'./../print_core.sh \n');
fprintf(fid,'cd .. \n');
fprintf(fid,'cd %s \n',fdirname_rst);
fprintf(fid,'./../list_core.sh \n');
fprintf(fid,'./../print_core.sh \n');
fprintf(fid,'cd .. \n');

fclose(fid);

end 