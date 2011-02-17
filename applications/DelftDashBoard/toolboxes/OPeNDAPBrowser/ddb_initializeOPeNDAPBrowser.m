function handles=ddb_initializeOPeNDAPBrowser(handles,varargin)

ii=strmatch('OPeNDAPBrowser',{handles.Toolbox(:).name},'exact');

if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'} % initialisation scripts
            handles.Toolbox(ii).longName='OPeNDAP Browser';

%            lst=dir([handles.ToolBoxDir '\tidedatabase\*.mat']);
%            for i=1:length(lst)
%                disp(['Loading tide database ' lst(i).name(1:end-4) ' ...']);
%                load([handles.ToolBoxDir 'tidedatabase\' lst(i).name(1:end-4) '.mat']);
%                handles.Toolbox(ii).Databases{i}=s.DatabaseName;
%                handles.Toolbox(ii).Database{i}=s;
%                handles.Toolbox(ii).Database{i}.ShortName=lst(i).name(1:end-4);
%                if size(handles.Toolbox(ii).Database{i}.x,1)==1
%                    handles.Toolbox(ii).Database{i}.x=handles.Toolbox(ii).Database{i}.x';
%                    handles.Toolbox(ii).Database{i}.y=handles.Toolbox(ii).Database{i}.y';
%                end
%            end

            return
    end
end

handles.Toolbox(ii).OPeNDAPServers={'http://opendap.deltares.nl/thredds/'};
%handles.Toolbox(ii).StopTime=floor(now)+30;
%handles.Toolbox(ii).TimeStep=10.0;

handles.Toolbox(ii).activeServer=1;
