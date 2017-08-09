function output=EHY_convert(varargin)
%% output=EHY_convert(inputFile,outputExt)
%
% Converts the inputFile to a file with the outputExt.
% It makes use of available conversion scripts in the OET.

% Example1: EHY_convert
% Example2: EHY_convert('D:\path.kml')
% Example3: EHY_convert('D:\path.kml','ldb')
% Example4: EHY_convert('D:\path.kml','ldb','saveOutputFile',0)
% created by Julien Groenenboom, August 2017

OPT.saveOutputFile=1; % 0=do not save, 1=save
OPT.outputFile=''; % if isempty > outputFile=strrep(inputFile,inputExt,outputExt);

if nargin>2
    if mod(nargin,2)==0
        OPT         = setproperty(OPT,varargin{3:end});
    else
        error('Additional input arguments must be given in pairs.')
    end
end

%% availableConversions
availableConversions={'kml','ldb';,...
    'kml','pol';,...
    'kml','xyz';,...
    'ldb','kml';,...
    'ldb','pol';,...
    'pol','kml';,...
    'pol','ldb';,...
    'xyz','kml'};
%% initialise
if length(varargin)==0
    [filename, pathname]=uigetfile('*.*','Open a file that you want to convert');
    varargin{1}=[pathname filename];
end
if length(varargin)==1
    inputFile=varargin{1};
    [~,~,inputExt]= fileparts(inputFile);
    inputExt=strrep(inputExt,'.','');
    
    availableInputId=strmatch(inputExt,availableConversions(:,1));
    if isempty(availableInputId)
        error(['No conversions available for ' inputExt '-files.'])
    end
    availableOutputExt=availableConversions(availableInputId,2);
    [availableOutputId,~]=  listdlg('PromptString',['Convert this ' inputExt '-file to:'],...
        'SelectionMode','single',...
        'ListString',availableOutputExt,...
        'ListSize',[300 50]);
    if isempty(availableOutputId)
        error('No output extension was chosen.')
    end
    outputExt=availableOutputExt{availableOutputId};
else
    inputFile=varargin{1};
    [~,~,inputExt]= fileparts(inputFile);
    inputExt=strrep(inputExt,'.','');
    outputExt=varargin{2};
end

%%
if isempty(OPT.outputFile)
    [pathstr, name, ext] = fileparts(inputFile);
    outputFile=[pathstr filesep name '.' outputExt];
else % outputFile was specified by user
    outputFile=OPT.outputFile;
end

if OPT.saveOutputFile && exist(outputFile,'file')
    [YesNoID,~]=  listdlg('PromptString',{'The outputFile already exists. Overwrite the file below?',outputFile},...
        'SelectionMode','single',...
        'ListString',{'Yes','No'},...
        'ListSize',[500 50]);
    if YesNoID==2
        OPT.saveOutputFile=0;
    end
end
eval(['output=EHY_convert_' inputExt '2' outputExt '(''' inputFile ''',''' outputFile ''',OPT);'])
if OPT.saveOutputFile
    disp([char(10) 'EHY_convert created the file: ' char(10) outputFile char(10)])
end
%% conversion functions - in alphabetical order
% kml2ldb
    function output=EHY_convert_kml2ldb(inputFile,outputFile,OPT)
        output=kml2ldb(OPT.saveOutputFile,inputFile);
    end
% kml2pol
    function output=EHY_convert_kml2pol(inputFile,outputFile,OPT)
        output=kml2pol(OPT.saveOutputFile,inputFile);
    end
% kml2xyz
    function output=EHY_convert_kml2xyz(inputFile,outputFile,OPT)
        xyz=kml2ldb(OPT.saveOutputFile,inputFile);
        xyz(isnan(xyz(:,1)),:)=[];
        if OPT.saveOutputFile
            dlmwrite(outputFile,xyz);
        end
        output=xyz;
    end
% ldb2kml
    function output=EHY_convert_ldb2kml(inputFile,outputFile,OPT)
        ldb=landboundary('read',inputFile);
        ldb2kml(ldb,outputFile,[1 0 0])
        output=[];
    end
% ldb2pol
    function output=EHY_convert_ldb2pol(inputFile,outputFile,OPT)
        ldb=landboundary('read',inputFile);
        io_polygon('write',outputFile,ldb);
        output=ldb;
    end
% pol2kml
    function output=EHY_convert_pol2kml(inputFile,outputFile,OPT)
        pol=landboundary('read',inputFile);
        ldb2kml(pol,outputFile,[1 0 0])
        output=[];
    end
% pol2ldb
    function output=EHY_convert_pol2ldb(inputFile,outputFile,OPT)
        pol=landboundary('read',inputFile);
        output=landboundary('write',outputFile,pol)
    end
% xyz2kml
    function output=EHY_convert_xyz2kml(inputFile,outputFile,OPT)
        %         [lon lat ~]=textread(inputFile,'delimiter','\n');
        xyz=dlmread(inputFile);
        lat=xyz(:,1); lon=xyz(:,2);
        if OPT.saveOutputFile
            KMLPlaceMark(lat,lon,outputFile);
        end
        output=[lon lat];
    end

end
