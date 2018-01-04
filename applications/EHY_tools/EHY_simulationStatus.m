function varargout=EHY_simulationStatus(varargin)
%% EHY_simulationStatus(varargin)
%
% This function returns the status of a D-FLOW FM, Delft3D and SIMONA simulation.
%
% Example1: EHY_simulationStatus
% Example2: EHY_simulationStatus('D:\run1\model.mdu')
%
% created by Julien Groenenboom, August 2017
EHYs(mfilename);
%%
if nargin==0
    disp('Open a .mdu, .mdf or SIMONA file as input')
    [filename, pathname]=uigetfile({'*.mdu';'*.mdf';'*siminp*';'*.*'},'Open a .mdu, .mdf or SIMONA file as input');
    mdFile=[pathname filename];
elseif nargin==1
    mdFile=varargin{1};
end

%%
[modelType,mdFile]=EHY_getModelType(mdFile);
if strcmp(modelType,'none')
    error('No .mdu, .mdf or siminp found in this folder')
end
[refdate,tunit,tstart,tstop]=getTimeInfoFromMdFile(mdFile);
simPeriod_S=(tstop-tstart)*timeFactor(tunit,'S');
simPeriod_D=(tstop-tstart)*timeFactor(tunit,'D');

switch modelType
    case 'mdu'
        [pathstr, name, ext] = fileparts(mdFile);
        mdu=dflowfm_io_mdu('read',mdFile);
        if ~isempty(mdu.output.OutputDir)
            folder=[pathstr mdu.output.OutputDir filesep];
        else
            [~,name]=fileparts(mdFile);
            folder=[pathstr 'DFM_OUTPUT_' name filesep];
        end

        D=dir([folder '*_timings.txt']);
        if ~isempty(D) % try to get the runPeriod from the timings file
            timingsFile=[folder filesep D(1).name];
            fid=fopen(timingsFile,'r');
            while feof(fid)~=1
                line=fgetl(fid);
            end
            fclose(fid);
            line=regexp(line,'\s+','split');
            runPeriod_S=str2num(line{2})-tstart*timeFactor(tunit,'S');
            
            if mod((mdu.time.TStop-mdu.time.TStart)*timeFactor(tunit,'S'),mdu.output.TimingsInterval)~=0
                diaFile0001=[pathstr name '_0001.dia'];
                if exist(diaFile0001,'file')
                    fid=fopen(diaFile0001,'r');
                    l=fgetl(fid);
                    while feof(fid)~=1 & isempty(strfind(l,'Computation finished at'))
                        l=fgetl(fid);
                        DONE=1;
                    end
                    fclose(fid);
                else
                    fid=fopen([pathstr 'out.txt'],'r');
                    l=fgetl(fid);
                    while feof(fid)~=1 & isempty(strfind(l,'Computation finished at'))
                        l=fgetl(fid);
                        DONE=1;
                    end
                    fclose(fid);
                end
                
                if exist('DONE','var')
                    runPeriod_S=simPeriod_S;
                end
                
            end
        else % get the runPeriod from the his nc file
            hisncfiles=dir([folder '*his*.nc']);
            hisncfile=[folder hisncfiles(1).name];
            infonc=ncinfo(hisncfile);
            indNC=strmatch('time',{infonc.Dimensions.Name},'exact');
            no_times=infonc.Dimensions(indNC).Length;
            nctimesEnd=nc_varget(hisncfile,'time',no_times-1,1); % sec from ref date
            runPeriod_S=nctimesEnd-tstart*timeFactor(tunit,'S');
        end
        runPeriod_D=runPeriod_S/3600/24;
        
    case 'mdf'
        [pathstr, name, ext] = fileparts(mdFile);
        D=dir([pathstr '\*.o*']);
        [~,order] = sort([D.datenum]);
        runFile=[pathstr filesep D(order(end)).name];
        fid=fopen(runFile,'r');
        while feof(fid)~=1
            line=fgetl(fid);
            if ~isempty(strfind(line,'Time to finish'))
                line2=line;
            end
        end
        fclose(fid);
        line2=regexp(line2,'\s+','split');
        indexPerc=find(~cellfun('isempty',strfind(line2,'%')));
        runperiod_perc=str2num(strrep((line2{indexPerc}),'%',''))/100;
        
        runPeriod_S=simPeriod_S*runperiod_perc;
        runPeriod_D=runPeriod_S*timeFactor('S','D');
    case {'siminp','SIMONA'}
        [pathstr, name, ext] = fileparts(mdFile);
        D=dir([pathstr '\waqpro-m.*']);
        [~,order] = sort([D.datenum]);
        runFile=[pathstr filesep D(order(end)).name];
        fid=fopen(runFile,'r');
        while feof(fid)~=1
            line=fgetl(fid);
            if ~isempty(strfind(line,'Corresponding date & time'))
                line2=line;
            end
        end
        fclose(fid);
        line2=regexp(line2,'\s+','split');
        runPeriod_D=datenum(strtrim(sprintf('%s ',line2{end-1:end})))-refdate-tstart*timeFactor('M','D');
        runPeriod_S=runPeriod_D*timeFactor('D','S');
end

percentage=runPeriod_S/simPeriod_S*100;

disp(['Status of ' name ext ': ' num2str(round(runPeriod_D)) '/' num2str(round(simPeriod_D)) ' of simulation days - ',...
    sprintf('%0.1f',percentage) '%']);

if nargout==1
    varargout{1}=percentage;
end
