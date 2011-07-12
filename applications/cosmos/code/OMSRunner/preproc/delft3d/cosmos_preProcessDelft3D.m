function PreProcessDelft3D(hm,m)

Model=hm.Models(m);

dr=Model.Dir;

tmpdir=hm.TempDir;

if ~isempty(Model.FlowRstFile)
    rstdir=[dr 'restart' filesep 'tri-rst' filesep];
    fname=[rstdir Model.FlowRstFile '.zip'];
    if exist(fname,'file')
       unzip(fname,tmpdir);
       [success,message,messageid]=movefile([tmpdir Model.FlowRstFile],[tmpdir 'tri-rst.rst'],'f');
    end
end

AdjustInputDelft3DFLOW(hm,m);

if strcmpi(Model.Type,'delft3dflowwave')
    AdjustInputDelft3DWAVE(hm,m);
    if ~isempty(Model.WaveRstFile)
        rstdir=[dr 'restart' filesep 'hot' filesep];
        fname=[rstdir Model.WaveRstFile '.zip'];
        if exist(fname,'file')
            unzip(fname,tmpdir);
            movefile([tmpdir Model.WaveRstFile],[tmpdir 'hot_1_00000000.000000']);
        end
    end
end

if Model.FlowNested || strcmpi(Model.FlowNestType,'oceanmodel')
    NestingDelft3DFLOW(hm,m);
end

if Model.WaveNested
    NestingDelft3DWave(hm,m);
end


% %% PART

% % Couplnef
% fname=[tmpdir 'couplnef.inp'];
% t0=num2str(round((Model.TOutputStart-Model.RefTime)*86400));
% t1=num2str(round((Model.TStop-Model.RefTime)*86400));
% findreplace(fname,'STARTTIMEKEY',t0);
% findreplace(fname,'STOPTIMEKEY',t1);
% % Hyd
% fname=[tmpdir 'com-' Model.Runid '.hyd'];
% tref=datestr(Model.RefTime,'yyyymmddHHMMSS');
% t0=datestr(Model.TOutputStart,'yyyymmddHHMMSS');
% t1=datestr(Model.TStop,'yyyymmddHHMMSS');
% findreplace(fname,'REFTIMEKEY',tref);
% findreplace(fname,'STARTTIMEKEY',t0);
% findreplace(fname,'STOPTIMEKEY',t1);
% 
% % Part
% 
% tref=Model.RefTime;
% t0=Model.TOutputStart;
% t1=Model.TStop;
% 
% d0=floor(t0-tref);
% h0=floor(24*((t0-tref)-d0));
% 
% d1=floor(t1-tref);
% h1=floor(24*((t1-tref)-d1));
% 
% t0str=[num2str(d0) ' ' num2str(h0) '  0  0'];
% t1str=[num2str(d1) ' ' num2str(h1) '  0  0'];
% 
% fname=[tmpdir Model.Runid '.inp'];
% 
% findreplace(fname,'STARTTIMEKEY',t0str);
% findreplace(fname,'STOPTIMEKEY',t1str);
% 
% [success,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'delpar.exe'],tmpdir,'f');
% [success,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'coup203.exe'],tmpdir,'f');

% Make run batch file
switch lower(Model.Type)
    case{'delft3dflow'}
        switch lower(Model.RunEnv)
            case{'win32'}
                [success,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'delftflow.exe'],tmpdir,'f');
                fid=fopen([tmpdir 'run.bat'],'wt');
                fprintf(fid,'%s\n',['echo -r ' Model.Runid ' > runid']);
                fprintf(fid,'%s\n','delftflow runid dummy delft3d');
                % fprintf(fid,'%s\n','coup203');
                % fprintf(fid,'%s\n','delpar');
                fclose(fid);
            case{'h4'}
                fid=fopen([tmpdir 'run.sh'],'wt');
                fprintf(fid,'%s\n','#!/bin/sh');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','# Start with: qsub -V -N runname run.sh');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','# for SWAN on h3/devux:');
                fprintf(fid,'%s\n','. /opt/intel/cc/9.0/bin/iccvars.sh');
                fprintf(fid,'%s\n','# for SWAN on h4:');
                fprintf(fid,'%s\n','# /opt/intel/cc-old/9.0/bin/iccvars.sh');
                fprintf(fid,'%s\n','# for Delft3D:');
                fprintf(fid,'%s\n','. /opt/intel/Compiler/11.0/081/bin/ifortvars.sh ia32');
                fprintf(fid,'%s\n','# . /opt/intel/fc/10/bin/ifortvars.sh');
                fprintf(fid,'%s\n','# . /opt/intel/idb/10/bin/idbvars.sh');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','export ARCH=intel');
                fprintf(fid,'%s\n','export DHSDELFT_LICENSE_FILE="/f/license/"');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','# ============ set runid');
                fprintf(fid,'%s\n',['runid=' Model.Runid '.mdf']);
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','argfile=delft3d-flow_args.txt');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','# === local    executables:');
                fprintf(fid,'%s\n','#D3D_HOME=/u/mourits/delft3d');
                fprintf(fid,'%s\n','exedir=/u/ormondt/d3d_versions/delftflow_trunk2/bin');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','export D3D_HOME=/opt/delft3d');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','export ARCH=intel');
                fprintf(fid,'%s\n','export PATH=$exedir:$PATH');
                fprintf(fid,'%s\n','export LD_LIBRARY_PATH=$exedir:$LD_LIBRARY_PATH');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','StageIn');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','cd $DELTAQ_LocalTempDir');
                fprintf(fid,'%s\n','date -u ''+%Y%m%d %H%M%S'' >> running.txt');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','echo ===================================================================');
                fprintf(fid,'%s\n','echo === ddbound = $ddboundfile');
                fprintf(fid,'%s\n','echo === exedir  = $exedir');
                fprintf(fid,'%s\n','echo ===================================================================');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','#    # ============ remove output files');
                fprintf(fid,'%s\n','# ./run_delft3d_init.sh $runid');
                fprintf(fid,'%s\n','# rm -f $argfile');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','    # ============ put arguments in file');
                fprintf(fid,'%s\n','echo -r $runid >$argfile');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','    # === start trisim.exe ===');
                fprintf(fid,'%s\n','$exedir/delftflow.exe $argfile dummy delft3d > screen.log');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','date -u ''+%Y%m%d %H%M%S'' >> running.txt');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','StageOut');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','cd $DELTAQ_JobDir');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','mv running.txt finished.txt');
                fclose(fid);
        end
    case{'delft3dflowwave'}
        switch lower(Model.RunEnv)
            case{'win32'}
                [success,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'delftflow.exe'],tmpdir,'f');
                [success,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'swan.bat'],tmpdir,'f');
                [success,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'wave.exe'],tmpdir,'f');
                [success,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'swan4072Ad.exe'],tmpdir,'f');
                [success,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'mod.exe'],tmpdir,'f');
                fid=fopen([tmpdir 'run.bat'],'wt');
                fprintf(fid,'%s\n',['echo -r ' Model.Runid ' > runid']);
                fprintf(fid,'%s\n','start delftflow runid dummy delft3d');
                fprintf(fid,'%s\n',['wave.exe ' Model.Runid '.mdw 1']);
                fclose(fid);
            case{'h4'}

                [success,message,messageid]=copyfile([hm.MainDir 'exe' filesep 'linux' filesep 'swan.bat'],tmpdir,'f');
                
                fid=fopen([tmpdir 'run.sh'],'wt');
                fprintf(fid,'%s\n','#!/bin/sh');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','# Start with: qsub -V -N runname run.sh');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','# for SWAN on h3/devux:');
                fprintf(fid,'%s\n','. /opt/intel/cc/9.0/bin/iccvars.sh');
                fprintf(fid,'%s\n','# for SWAN on h4:');
                fprintf(fid,'%s\n','# /opt/intel/cc-old/9.0/bin/iccvars.sh');
                fprintf(fid,'%s\n','# for Delft3D:');
                fprintf(fid,'%s\n','. /opt/intel/Compiler/11.0/081/bin/ifortvars.sh ia32');
                fprintf(fid,'%s\n','# . /opt/intel/fc/10/bin/ifortvars.sh');
                fprintf(fid,'%s\n','# . /opt/intel/idb/10/bin/idbvars.sh');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','export ARCH=intel');
                fprintf(fid,'%s\n','export DHSDELFT_LICENSE_FILE="/f/license/"');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','# ============ set runid');
                fprintf(fid,'%s\n',['runid=' Model.Runid '.mdf']);
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n',['mdwave=' Model.Runid '.mdw']);
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','argfile=delft3d-flow_args.txt');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','# === local    executables:');
                fprintf(fid,'%s\n','#D3D_HOME=/u/mourits/delft3d');
                fprintf(fid,'%s\n','exedir=/u/ormondt/d3d_versions/delftflow_trunk2/bin');
                fprintf(fid,'%s\n','exedirwave=/u/ormondt/d3d_versions/delftflow_trunk/bin');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','export D3D_HOME=/opt/delft3d');
                fprintf(fid,'%s\n','');
%                fprintf(fid,'%s\n','swanbatdir=./');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','export ARCH=intel');
%                fprintf(fid,'%s\n','export PATH=$swanbatdir:$PATH');
                fprintf(fid,'%s\n','export PATH=$exedir:$PATH');
                fprintf(fid,'%s\n','export LD_LIBRARY_PATH=$exedir:$LD_LIBRARY_PATH');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','StageIn');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','cd $DELTAQ_LocalTempDir');
                fprintf(fid,'%s\n','date -u ''+%Y%m%d %H%M%S'' >> running.txt');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','echo ===================================================================');
                fprintf(fid,'%s\n','echo === ddbound = $ddboundfile');
                fprintf(fid,'%s\n','echo === exedir  = $exedir');
                fprintf(fid,'%s\n','echo ===================================================================');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','#    # ============ remove output files');
                fprintf(fid,'%s\n','# ./run_delft3d_init.sh $runid');
                fprintf(fid,'%s\n','# rm -f $argfile');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','    # ============ put arguments in file');
                fprintf(fid,'%s\n','echo -r $runid >$argfile');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','    # === start waves.exe ===');
                fprintf(fid,'%s\n','$exedirwave/wave.exe $mdwave 1 &');
                fprintf(fid,'%s\n','    # in separate window:');
                fprintf(fid,'%s\n','    #xterm -e $exedirwave/wave.exe $mdwave 1 &');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','    # === start trisim.exe ===');
                fprintf(fid,'%s\n','$exedir/delftflow.exe $argfile dummy delft3d > screen.log');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','date -u ''+%Y%m%d %H%M%S'' >> running.txt');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','StageOut');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','cd $DELTAQ_JobDir');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','mv running.txt finished.txt');
                fclose(fid);

        end
end
