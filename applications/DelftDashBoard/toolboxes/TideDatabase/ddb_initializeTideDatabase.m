function handles=ddb_initializeTideDatabase(handles,varargin)

ii=strmatch('TideDatabase',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).longName='Tide Database';

            lst=dir([handles.toolBoxDir '\tidedatabase\*.mat']);
            for i=1:length(lst)
                disp(['Loading tide database ' lst(i).name(1:end-4) ' ...']);
                load([handles.toolBoxDir 'tidedatabase\' lst(i).name(1:end-4) '.mat']);
                handles.Toolbox(ii).databases{i}=s.DatabaseName;
                handles.Toolbox(ii).database{i}=s;
                handles.Toolbox(ii).database{i}.shortName=lst(i).name(1:end-4);
                if size(handles.Toolbox(ii).database{i}.x,1)==1
                    handles.Toolbox(ii).database{i}.x=handles.Toolbox(ii).database{i}.x';
                    handles.Toolbox(ii).database{i}.y=handles.Toolbox(ii).database{i}.y';
                end
            end

            return
    end
end

handles.Toolbox(ii).startTime=floor(now);
handles.Toolbox(ii).stopTime=floor(now)+30;
handles.Toolbox(ii).timeStep=10.0;

handles.Toolbox(ii).activeDatabase=1;
