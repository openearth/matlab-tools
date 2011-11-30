function cosmos_preProcessDelft3D(hm,m)

model=hm.models(m);

dr=model.dir;

tmpdir=hm.tempDir;

if ~isempty(model.flowRstFile)
    rstdir=[dr 'restart' filesep 'tri-rst' filesep];
    fname=[rstdir model.flowRstFile '.zip'];
    if exist(fname,'file')
       unzip(fname,tmpdir);
       [success,message,messageid]=movefile([tmpdir model.flowRstFile],[tmpdir 'tri-rst.rst'],'f');
    end
end

cosmos_adjustInputDelft3DFLOW(hm,m);

if strcmpi(model.type,'delft3dflowwave')
    cosmos_adjustInputDelft3DWAVE(hm,m);
    if ~isempty(model.waveRstFile)
        rstdir=[dr 'restart' filesep 'hot' filesep];
        fname=[rstdir model.waveRstFile '.zip'];
        if exist(fname,'file')
            unzip(fname,tmpdir);
            movefile([tmpdir model.waveRstFile],[tmpdir 'hot_1_00000000.000000']);
        end
    end
end

if model.flowNested || strcmpi(model.flowNestType,'oceanmodel')
    NestingDelft3DFLOW(hm,m);
end

if model.waveNested
    NestingDelft3DWave(hm,m);
end


% %% PART

% % Couplnef
% fname=[tmpdir 'couplnef.inp'];
% t0=num2str(round((model.tOutputStart-model.refTime)*86400));
% t1=num2str(round((model.tStop-model.refTime)*86400));
% findreplace(fname,'STARTTIMEKEY',t0);
% findreplace(fname,'STOPTIMEKEY',t1);
% % Hyd
% fname=[tmpdir 'com-' model.runid '.hyd'];
% tref=datestr(model.refTime,'yyyymmddHHMMSS');
% t0=datestr(model.tOutputStart,'yyyymmddHHMMSS');
% t1=datestr(model.tStop,'yyyymmddHHMMSS');
% findreplace(fname,'REFTIMEKEY',tref);
% findreplace(fname,'STARTTIMEKEY',t0);
% findreplace(fname,'STOPTIMEKEY',t1);
% 
% % Part
% 
% tref=model.refTime;
% t0=model.tOutputStart;
% t1=model.tStop;
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
% fname=[tmpdir model.runid '.inp'];
% 
% findreplace(fname,'STARTTIMEKEY',t0str);
% findreplace(fname,'STOPTIMEKEY',t1str);
% 
% [success,message,messageid]=copyfile([hm.exeDir 'delpar.exe'],tmpdir,'f');
% [success,message,messageid]=copyfile([hm.exeDir 'coup203.exe'],tmpdir,'f');

% Make run batch file
switch lower(model.type)
    case{'delft3dflow'}
        switch lower(model.runEnv)
            case{'win32'}
                [success,message,messageid]=copyfile([hm.exeDir 'delftflow.exe'],tmpdir,'f');
                fid=fopen([tmpdir 'run.bat'],'wt');
                fprintf(fid,'%s\n',['echo -r ' model.runid ' > runid']);
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
                fprintf(fid,'%s\n',['runid=' model.runid '.mdf']);
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
%                fprintf(fid,'%s\n','StageIn');
                fprintf(fid,'%s\n','');
%                fprintf(fid,'%s\n','cd $DELTAQ_LocalTempDir');
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
%                fprintf(fid,'%s\n','StageOut');
                fprintf(fid,'%s\n','');
%                fprintf(fid,'%s\n','cd $DELTAQ_JobDir');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','mv running.txt finished.txt');
                fclose(fid);
        end
    case{'delft3dflowwave'}
        switch lower(model.runEnv)
            case{'win32'}
                [success,message,messageid]=copyfile([hm.exeDir 'delftflow.exe'],tmpdir,'f');
                [success,message,messageid]=copyfile([hm.exeDir 'swan.bat'],tmpdir,'f');
                [success,message,messageid]=copyfile([hm.exeDir 'wave.exe'],tmpdir,'f');
                [success,message,messageid]=copyfile([hm.exeDir 'swan4072Ad.exe'],tmpdir,'f');
                [success,message,messageid]=copyfile([hm.exeDir 'mod.exe'],tmpdir,'f');
                fid=fopen([tmpdir 'run.bat'],'wt');
                fprintf(fid,'%s\n',['echo -r ' model.runid ' > runid']);
                fprintf(fid,'%s\n','start delftflow runid dummy delft3d');
                fprintf(fid,'%s\n',['wave.exe ' model.runid '.mdw 1']);
                fclose(fid);
            case{'h4'}

                switch lower(model.whiteCapping)
                    case{'komenrogers'}
                        fname='swan.komenrogers.sh';
                    otherwise
                        fname='swan.sh';
                end
                [success,message,messageid]=copyfile([hm.exeDir 'linux' filesep fname],[tmpdir 'swan.sh'],'f');
                
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
                fprintf(fid,'%s\n',['runid=' model.runid '.mdf']);
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n',['mdwave=' model.runid '.mdw']);
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
                fprintf(fid,'%s\n','swanbatdir=./');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','export ARCH=intel');
                fprintf(fid,'%s\n','export PATH=$swanbatdir:$PATH');
                fprintf(fid,'%s\n','export PATH=$exedir:$PATH');
                fprintf(fid,'%s\n','export LD_LIBRARY_PATH=$exedir:$LD_LIBRARY_PATH');
                fprintf(fid,'%s\n','');
%                fprintf(fid,'%s\n','StageIn');
                fprintf(fid,'%s\n','');
%                fprintf(fid,'%s\n','cd $DELTAQ_LocalTempDir');
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
%                fprintf(fid,'%s\n','StageOut');
                fprintf(fid,'%s\n','');
%                fprintf(fid,'%s\n','cd $DELTAQ_JobDir');
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','mv running.txt finished.txt');
                fclose(fid);

        end
end
