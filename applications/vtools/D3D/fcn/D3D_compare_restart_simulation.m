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
%Starting from a reference simulation, it creates a 'main' and 'restart' simulation to
%compare them running GDB. 
%The 'main' simulation is as the reference one but creating restart files when
%specified. 
%The 'restart' simulation is as the main simulation but starting from one restart
%file as created by the 'main' simulation. 
%This function also creates the scripts necessary to run GDB (in Linux) for printing 
%the desired variables to file, for later comparing them using `gdb_compare_files`.
%The main output files are:
%   - <fpath_main/logs/print.log>
%   - <fpath_rst/logs/print.log>
%where, <fpath_main> is the full path to the main simulation and <fpath_rst> the 
%full path to the restarted simulation. Both are at the same level as <fpath_ref>. 
%The main file to run is <./run_main_and_restart.sh>, at the same level as <fpath_ref>.
%
%INPUT:
%   -fpath_ref = full path to the simulation to test. 
%   -fpath_cmd = full path to the file with debug commands. If NaN, default debug commands. 
%
%INPUT (pair input)
%   -DTUser_fact     = `DtUser` times every which a restart file is created. 
%   -fpath_exe_gdb   = full path to executables with debug symbols. 
%   -TStart_rst_fact = `DtUser` times after which the 'restart' simulation starts. If NaN, 
%                       this is equal to the first time at which a restart file is created. 
%                       As such, one can stop in debug mode after the first restart file is
%                       created.
%   -overwrite       = Overwrite 'main' and 'restart' folders if exists: 0 = NO; 1=YES.
%
%OUTPUT:
%
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
addOptional(parin,'fpath_exe','p:\d-hydro\dimrset\latest\');
addOptional(parin,'TStart_rst_fact',NaN);
addOptional(parin,'overwrite',1);

parse(parin,varargin{:});

DTUser_fact=parin.Results.DTUser_fact;
% fpath_exe=parin.Results.fpath_exe; 
fpath_exe=parin.Results.fpath_exe;
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
TFact=time_factor(mdf_main.time.Tunit); %TUnit->s

if mdf_main.time.DtUser*DTUser_fact ~= round(mdf_main.time.DtUser*DTUser_fact)
    DtUser_maxMultiple=(mdf_main.time.TStop*TFact-mdf_main.time.TStart*TFact)/mdf_main.time.DtUser;
    DtUser_MultipleSecondsCheck = (DTUser_fact:DtUser_maxMultiple);
    potential_restart_times = mdf_main.time.TStart*TFact+DtUser_MultipleSecondsCheck*DTUser_fact*mdf_main.time.DtUser; 
    DtUser_SecondsIndex = find(potential_restart_times==round(potential_restart_times),1);
    DTUser_fact = DtUser_MultipleSecondsCheck(DtUser_SecondsIndex);
    warning(sprintf('DTUser_fact is updated to %i to ensure restart time is in whole seconds', DTUser_fact));
end
mdf_main.output.RstInterval=mdf_main.time.DtUser*DTUser_fact; %[s]

mdf_main.output.Wrirst_bnd=1;

D3D_io_input('write',simdef_main.file.mdf,mdf_main);

%copy main simulation to restart
fdirname_rst=sprintf('%s_rst',fdir_last);
fpath_rst=fullfile(fdir_up,fdirname_rst);
if ~isfolder(fpath_rst) || overwrite
    copyfile_check(fpath_main,fpath_rst);
end 

%modify restart simulation
    %mdf
simdef_rst=D3D_simpath(fpath_rst); 
mdf_rst=D3D_io_input('read',simdef_rst.file.mdf);

%`TStart_rst` is the time at which the restarted simulation starts. 
if isnan(TStart_rst_fact)
    %Restart after the first restart file is created. This is useful to set the breakpoint after the first restart file.
    TStart_rst=mdf_main.output.RstInterval/TFact; %[TUnit] 
else
    %Restart `TStart_rst_fact` times `DtUser`. The user is responsible from setting a break point after the right restart file is created. 
    TStart_rst=TStart_rst_fact*mdf_rst.time.DtUser/TFact; %[TUnit]
end
mdf_rst.time.TStart=mdf_main.time.TStart+TStart_rst; %[TUnit]
mdf_rst.time.TStartTlfsmo=mdf_main.time.TStart;

rst_time_dtime=datetime(num2str(mdf_rst.time.RefDate),'InputFormat','yyyyMMdd')+seconds(mdf_rst.time.TStart*TFact); 
rst_time_str=string(rst_time_dtime,'yyyyMMdd_HHmmss');
mdf_rst.restart.RestartFile=sprintf('%s_%s_rst.nc',simdef_rst.file.mdfid,rst_time_str); %tst_20140819_120000_rst.nc

D3D_io_input('write',simdef_rst.file.mdf,mdf_rst);

    %mor-file
if isfield(simdef_rst.file,'mor')
    mor=D3D_io_input('read',simdef_rst.file.mor);
    mor.Morphology0.MorStt=max([0,mor.Morphology0.MorStt-(TStart_rst-mdf_main.time.TStart)]); %`MorStt` in [TUnit]
    D3D_io_input('write',simdef_rst.file.mor,mor);
end
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
create_run_main(fdir_up,fdirname_main,'main');
create_run_main(fdir_up,fdirname_rst,'rst',fpath_rel_rst);
create_create_core(fdir_up,fpath_exe);
create_list_core(fdir_up,fpath_exe);
create_print_core(fdir_up,fpath_exe);
create_test_create(fdir_up,fpath_cmd,mdu_filename);
create_test_list(fdir_up);
create_postprocess_main_and_restart(fdir_up,fdirname_main,fdirname_rst);

%not necessary, because it only makes sense to set the breakpoint after a point in which the restart file to which we start has been created.
% create_run_main_full(fdir_up,fdirname_main,fpath_exe_gdb,mdu_filename); 

%% structure

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
% fprintf(fid,'./run_main_full.sh \n');
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

fprintf(fid,'rm logs/type.log \n');
fprintf(fid,'rm logs/print.log \n');
fprintf(fid,'mkdir logs \n');
fprintf(fid,'echo set print elements 0 > test_type.gdb \n');
fprintf(fid,'echo set print repeats 0 >> test_type.gdb \n');
fprintf(fid,'echo set pagination off >> test_type.gdb \n');
fprintf(fid,'echo set logging file logs/type.log >> test_type.gdb \n');
fprintf(fid,'echo set logging on >> test_type.gdb \n');
fprintf(fid,'sed ''s/0x0.*\\bm_\\([a-z0-9_]*\\)_mp_\\([a-z0-9_]*\\)_\\($*.*\\)/echo m_\\1::\\2\\\\n\\nwhatis m_\\1::\\2/g'' logs/list.log >> test_type.gdb \n');
fprintf(fid,'sed -i ''s/All variables matching regular expression.*//g'' test_type.gdb \n');
fprintf(fid,'sed -i ''s/Non-debugging symbols://g'' test_type.gdb \n');
%Remove empty line. Repeated 3 times for safety.
fprintf(fid,'sed -i -z ''s/\\n\\n/\\n/g'' test_type.gdb \n');
fprintf(fid,'sed -i -z ''s/\\n\\n/\\n/g'' test_type.gdb \n');
fprintf(fid,'sed -i -z ''s/\\n\\n/\\n/g'' test_type.gdb \n');
fprintf(fid,'gdb --batch --command=test_type.gdb %s core.* > tmp \n',linuxify(fpath_exe));
fprintf(fid,'echo set print elements 0 > test_print.gdb \n');
fprintf(fid,'echo set print repeats 0 >> test_print.gdb \n');
fprintf(fid,'echo set pagination off >> test_print.gdb \n');
fprintf(fid,'echo set logging file logs/print.log >> test_print.gdb \n');
fprintf(fid,'echo set logging on >> test_print.gdb \n');
fprintf(fid,'sed -z ''s/\\([a-z0-9_:]*\\)\\ntype = PTR TO -> [\\*:()a-zA-Z0-9 ,]*/echo \\1\\\\n\\nwhatis \\1\\nprint *\\1/g'' logs/type.log >> test_print.gdb \n');
fprintf(fid,'sed -i -z ''s/\\([a-z0-9_:]*\\)\\ntype = <object is not a[a-z]*ated>\\n//g'' test_print.gdb \n');
fprintf(fid,'sed -i -z ''s/\\([a-z0-9_:]*\\)\\ntype = [\\*:()a-zA-Z0-9 ,]*/echo \\1\\\\n\\nwhatis \\1\\nprint \\1/g'' test_print.gdb \n');
fprintf(fid,'gdb --batch --command=test_print.gdb %s core.* > tmp \n',linuxify(fpath_exe));

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

%read
if isempty(fpath_cmd)
    fprintf(fid,'break flow_run_usertimestep.f90:56 \n');
    fprintf(fid,'condition 1 m_flowtimes::time0.eq.m_flowtimes::ti_rst \n');
elseif ~isfile(fpath_cmd)
    error('File with commands not found: %s',fpath_cmd);
else
    fid_r=fopen(fpath_cmd,'r');
    while ~feof(fid_r)
        lin=fgets(fid_r);
        fprintf(fid,lin);
    end
    fclose(fid_r);
end
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
fprintf(fid,'info variable m_flowtimes_mp_time1_ \n');
fprintf(fid,'info variable m_flowtimes_mp_time0_ \n');
fprintf(fid,'info variable m_flowtimes_mp_tstart_user_ \n');
fprintf(fid,'info variable m_cell_geometry_mp_ \n');
fprintf(fid,'info variable m_restart_debug_mp_ \n');
% fprintf(fid,'info variable m_flowtimes_mp_ \n');
% fprintf(fid,'info variable m_flowgeom_mp_ \n');

fclose(fid);

end

%%

function create_postprocess_main_and_restart(fdir,fdirname_main,fdirname_rst)

fpath=fullfile(fdir,'post_process_main_and_restart.sh');
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