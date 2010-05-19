function handles=ddb_initializeTideDatabase(handles,varargin)

ii=strmatch('TideDatabase',{handles.Toolbox(:).Name},'exact');

if nargin>1
    switch varargin{1}
        case{'veryfirst'}
            handles.Toolbox(ii).LongName='Tide Database';

            lst=dir([handles.ToolBoxDir '\tidedatabase\*.mat']);
            for i=1:length(lst)
                disp(['Loading tide database ' lst(i).name(1:end-4) ' ...']);
                load([handles.ToolBoxDir 'tidedatabase\' lst(i).name(1:end-4) '.mat']);
                handles.Toolbox(ii).Databases{i}=s.DatabaseName;
                handles.Toolbox(ii).Database{i}=s;
                handles.Toolbox(ii).Database{i}.ShortName=lst(i).name(1:end-4);
                if size(handles.Toolbox(ii).Database{i}.x,1)==1
                    handles.Toolbox(ii).Database{i}.x=handles.Toolbox(ii).Database{i}.x';
                    handles.Toolbox(ii).Database{i}.y=handles.Toolbox(ii).Database{i}.y';
                end
            end

            return
    end
end

handles.Toolbox(ii).StartTime=floor(now);
handles.Toolbox(ii).StopTime=floor(now)+30;
handles.Toolbox(ii).TimeStep=10.0;

handles.Toolbox(ii).ActiveDatabase=1;
