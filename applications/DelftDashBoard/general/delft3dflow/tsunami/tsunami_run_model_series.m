function tsunami_run_model_series(run,dr,prefx,thresholdlevel,ncores,checkforfinishedsimulations,varargin)

% Set defaults
rdur=120;
tsunamifile=[];
adjustbathymetry=0;

% Read input arguments
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'tsunamifile'}
                tsunamifile=varargin{ii+1};
                [xtsu ytsu ztsu info] = arc_asc_read(tsunamifile);
            case{'runduration'}
                rdur=varargin{ii+1};
            case{'adjustbathymetry'}
                adjustbathymetry=varargin{ii+1};
        end                
    end
end

inputdir=[dr filesep 'input' filesep];
runsdir=[dr filesep 'runs' filesep];


if ~isdir(runsdir)
    mkdir(runsdir);
end

if ~isdir([runsdir filesep run])
    mkdir([runsdir filesep run]);
end

modellist=dir([inputdir filesep prefx '*']);

nmodels=length(modellist);

nbatch=0;

for imodel=1:nmodels
    
    ok=1;
    
    mdlname=modellist(imodel).name;
    rundir=[runsdir filesep run filesep mdlname];
        
    xml=xml2struct([inputdir filesep mdlname filesep mdlname '.xml']);

    cs.name=xml.csname;
    cs.type=xml.cstype;
    
    if checkforfinishedsimulations
        if exist([rundir filesep 'finished.txt'],'file')
            disp([mdlname ' already finished!']);
            ok=0;
        end
    end

    if isfield(xml,'flownested') && ok
        if ~isempty(xml.flownested)
            %
            % Run nesting first
            %
            ok=0;
            if exist([runsdir filesep run filesep xml.flownested filesep 'trih-' xml.flownested '.dat'],'file')  
                
                if thresholdlevel>0
                    
                    % First check if water level along boundary exceeds threshold
                    fid=qpfopen([runsdir filesep run filesep xml.flownested filesep 'trih-' xml.flownested '.dat']);
                    stations = qpread(fid,1,'water level','stations');
                    
                    % Water level at middle of offshore boundary
                    istat=strmatch(mdlname,stations,'exact');
                    wl=qpread(fid,1,'water level','griddata',0,istat);
                    waveheight=max(wl.Val)-min(wl.Val);
                    
                    % Water level at LL corner of offshore boundary
                    istat=strmatch([mdlname ' - LL'],stations,'exact');
                    if ~isempty(istat)
                        wl=qpread(fid,1,'water level','griddata',0,istat);
                        waveheight=max(waveheight,max(wl.Val)-min(wl.Val));
                    end
                    
                    % Water level at LR corner of offshore boundary
                    istat=strmatch([mdlname ' - LR'],stations,'exact');
                    if ~isempty(istat)
                        wl=qpread(fid,1,'water level','griddata',0,istat);
                        waveheight=max(waveheight,max(wl.Val)-min(wl.Val));
                    end
                    
                else
                    waveheight=1e9;
                end
                
                if waveheight>thresholdlevel
                    
                    ok=1;
                    
                    % Copy input to run directory
                    if ~isdir(rundir)
                        mkdir(rundir);
                    end
                    copyfile([inputdir filesep mdlname filesep 'input' filesep '*'],rundir);

                    
                    % Change run duration
                    findreplace([rundir filesep mdlname '.mdf'],'RDURKEY',num2str(rdur));
                    findreplace([rundir filesep mdlname '.fou'],'RDURKEY',num2str(rdur));

                    
                    % nesthd2
                    fid=fopen('nesthd2.xml','wt');
                    fprintf(fid,'%s\n','<?xml version="1.0"?>');
                    fprintf(fid,'%s\n','<root>');
                    fprintf(fid,'%s\n',['  <runid>' mdlname '</runid>']);
                    fprintf(fid,'%s\n',['  <inputdir>' rundir filesep '</inputdir>']);
                    fprintf(fid,'%s\n',['  <admfile>' inputdir filesep mdlname filesep mdlname '.adm</admfile>']);
                    fprintf(fid,'%s\n','  <opt>hydro</opt>');
                    fprintf(fid,'%s\n',['  <hisfile>' runsdir filesep run filesep xml.flownested filesep 'trih-' xml.flownested '.dat</hisfile>']);
                    fprintf(fid,'%s\n','</root>');
                    fclose(fid);
                    nesthd2('nesthd2.xml');
                    delete('nesthd2.xml');
                    
                    
                else
                    disp(['Model ' mdlname ' skipped - water level along boundary does not exceed threshold.']);
                end
                
            else
                disp(['Model ' mdlname ' skipped - no output found from overall model.']);
            end
            
        end
        
    end
    
    if ok

        % Copy input to run directory
        if ~isdir(rundir)
            mkdir(rundir);
        end        
        copyfile([inputdir filesep mdlname filesep 'input' filesep '*'],rundir);
        
        % Copy batch files
        copyfile([inputdir 'batch' filesep '*.*'],rundir);
        findreplace([rundir filesep 'config_d_hydro.xml'],'RUNIDKEY',mdlname);
        
        % Change run duration
        findreplace([rundir filesep mdlname '.mdf'],'RDURKEY',num2str(rdur));
        findreplace([rundir filesep mdlname '.fou'],'RDURKEY',num2str(rdur));
        
        % >>> generate INITIAL CONDITIONS files <<<  
        if ~isempty(tsunamifile)
            
            newSys.name='WGS 84';
            newSys.type='geographic';

            grd=wlgrid('read',[rundir filesep mdlname '.grd']);
            [xz,yz]=getXZYZ(grd.X,grd.Y);
            
            newdepfile=[rundir filesep mdlname '.dep'];
            
            interpolateTsunamiToGrid('xgrid',xz,'ygrid',yz,'gridcs',cs,'tsunamics',newSys, ...
                'xtsunami',xtsu,'ytsunami',ytsu,'ztsunami',ztsu,'inifile',[rundir filesep mdlname '.ini'], ...
                'adjustbathymetry',adjustbathymetry,'newdepfile',newdepfile);
            
        end
    end
    
    if ok
        
        nbatch=nbatch+1;
        mdl{nbatch}=mdlname;
        
        disp(['Starting ' mdlname ' ...']);
        
        fid=fopen('runbatch.bat','wt');
        fprintf(fid,'%s\n',['cd ' rundir]);
        fprintf(fid,'%s\n','start runflow.bat');
        fclose(fid);
               
        system('runbatch.bat');
        delete('runbatch.bat');
        
    end
    
    if nbatch==ncores || imodel==nmodels
        % Start checking for finished simulations
        pause(1);
        while 1
            ok=1;
            for ii=1:nbatch
                if ~exist([runsdir filesep run filesep mdl{ii} filesep 'finished.txt'],'file')
                    ok=0;
                end
            end
            pause(1);
            if ok
                break
            end
        end
        nbatch=0;
        mdl=[];
    end
    
end
