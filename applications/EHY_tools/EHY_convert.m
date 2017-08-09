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
A=textread(which('EHY_convert.m'),'%s','delimiter','\n');
searchLine='function output=EHY_convert_';
lineNrs=find(~cellfun('isempty',strfind(A,searchLine)));
availableConversions={};
for ii=2:length(lineNrs)
    availableConversions{end+1,1}=A{lineNrs(ii)}(length(searchLine)+1:length(searchLine)+3);
    availableConversions{end,2}=A{lineNrs(ii)}(length(searchLine)+5:length(searchLine)+7);
end
%% initialise
if length(varargin)==0
    disp(['EHY_convert  -  Conversion possible for following inputFiles: ',...
        strrep(strjoin(unique(availableConversions(:,1))),' ',', ')])
    availableExt=strcat('*.',[{'*'}; unique(availableConversions(:,1))]);
    [filename, pathname]=uigetfile(availableExt,'Open a file that you want to convert');
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

%% Choose and run conversion
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
        if OPT.saveOutputFile
            ldb2kml(ldb,outputFile,[1 0 0])
        end
        output=[];
    end
% ldb2pol
    function output=EHY_convert_ldb2pol(inputFile,outputFile,OPT)
        ldb=landboundary('read',inputFile);
        if OPT.saveOutputFile
            io_polygon('write',outputFile,ldb);
        end
        output=ldb;
    end
% pol2kml
    function output=EHY_convert_pol2kml(inputFile,outputFile,OPT)
        pol=landboundary('read',inputFile);
        if OPT.saveOutputFile
            ldb2kml(pol,outputFile,[1 0 0])
        end
        output=[];
    end
% pol2ldb
    function output=EHY_convert_pol2ldb(inputFile,outputFile,OPT)
        pol=landboundary('read',inputFile);
        if OPT.saveOutputFile
            output=landboundary('write',outputFile,pol);
        end
    end
% pol2xyz
    function output=EHY_convert_pol2xyz(inputFile,outputFile,OPT)
        xyz=landboundary('read',inputFile);
        xyz(isnan(xyz(:,1)),:)=[];
        if OPT.saveOutputFile
            dlmwrite(outputFile,xyz);
        end
        output=xyz;
    end
% xyz2kml
    function output=EHY_convert_xyz2kml(inputFile,outputFile,OPT)
        %         [lon lat ~]=textread(inputFile,'delimiter','\n');
        xyz=dlmread(inputFile);
        lon=xyz(:,1); lat=xyz(:,2);
        if OPT.saveOutputFile
            KMLPlaceMark(lat,lon,outputFile);
        end
        output=[lon lat];
    end
end

