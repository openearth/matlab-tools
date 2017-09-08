function varargout=EHY_convert(varargin)
%% output=EHY_convert(inputFile,outputExt)
%
% Converts the inputFile to a file with the outputExt.
% It makes use of available conversion scripts in the OET.

% Example1: EHY_convert
% Example2: EHY_convert('D:\path.kml')
% Example3: ldb=EHY_convert('D:\path.kml','ldb')
% Example4: EHY_convert('D:\path.kml','ldb','saveoutputFile',0)

% created by Julien Groenenboom, August 2017

OPT.saveoutputFile=1; % 0=do not save, 1=save
OPT.outputFile=''; % if isempty > outputFile=strrep(inputFile,inputExt,outputExt);
OPT.lineColor=[1 0 0]; % default is red

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
availableConversions={'pli'};
for ii=2:length(lineNrs)
    availableConversions{end+1,1}=A{lineNrs(ii)}(length(searchLine)+1:length(searchLine)+3);
    availableConversions{end,2}=A{lineNrs(ii)}(length(searchLine)+5:length(searchLine)+7);
end
%% initialise
if length(varargin)==0
    listOfExt=unique(availableConversions(:,1));
    disp(['EHY_convert  -  Conversion possible for following inputFiles: ',...
        strrep(strtrim(sprintf('%s ',listOfExt{:})),' ',', ')])
    availableExt=strcat('*.',[{'*'}; listOfExt]);
    disp('Open a file that you want to convert')
    [filename, pathname]=uigetfile(availableExt,'Open a file that you want to convert');
    varargin{1}=[pathname filename];
end
if length(varargin)==1
    inputFile=varargin{1};
    [~,~,inputExt]= fileparts(inputFile);
    inputExt=strrep(inputExt,'.','');
    
    if strcmp(inputExt,'pli'); inputExt='pol'; end
    
    availableInputId=strmatch(inputExt,availableConversions(:,1));
    if isempty(availableInputId)
        error(['No conversions available for ' inputExt '-files.'])
    end
    availableoutputExt=availableConversions(availableInputId,2);
    [availableoutputId,~]=  listdlg('PromptString',['Convert this ' inputExt '-file to:'],...
        'SelectionMode','single',...
        'ListString',availableoutputExt,...
        'ListSize',[300 50]);
    if isempty(availableoutputId)
        error('No output extension was chosen.')
    end
    outputExt=availableoutputExt{availableoutputId};
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

if OPT.saveoutputFile && exist(outputFile,'file')
    [YesNoID,~]=  listdlg('PromptString',{'The outputFile already exists. Overwrite the file below?',outputFile},...
        'SelectionMode','single',...
        'ListString',{'Yes','No','No, but save as...'},...
        'ListSize',[500 50]);
    if YesNoID==2
        OPT.saveoutputFile=0;
    elseif YesNoID==3
        [pathstr,~,ext] = fileparts(outputFile);
        [FileName,PathName] = uiputfile([pathstr filesep ext]);
        outputFile=[PathName FileName];
    end
end

eval(['output=EHY_convert_' inputExt '2' outputExt '(''' inputFile ''',''' outputFile ''',OPT);'])
if OPT.saveoutputFile
    disp([char(10) 'EHY_convert created the file: ' char(10) outputFile char(10)])
end
%% conversion functions - in alphabetical order
% crs2kml
    function output=EHY_convert_crs2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveoutputFile=0;
        pli=EHY_convert_crs2pli(inputFile,outputFile,OPT);
        [x,y]=EHY_convert_coorCheck(pli(:,1),pli(:,2));
        output=[x y];
        OPT=OPT_user;
        if OPT.saveoutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(output,tempFile,OPT.lineColor)
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
    end
% crs2pli
    function output=EHY_convert_crs2pli(inputFile,outputFile,OPT)
        crs=delft3d_io_crs('read',inputFile);
        x=[];y=[];
        disp('Open the corresponding .grd-file')
        [grdName,grdPath]=uigetfile([pathstr filesep '.grd'],'Open the corresponding .grd-file');
        tempFile=[tempdir 'tmp.grd'];
        copyfile([grdPath grdName],tempFile);
        grd=wlgrid('read',tempFile);
        delete(tempFile);
        
        for iM=1:length(crs.m)
            mrange=min(crs.DATA(iM).m):max(crs.DATA(iM).m);
            nrange=min(crs.DATA(iM).n):max(crs.DATA(iM).n);
            if length(mrange)~=1
                mrange=[mrange(1)-1 mrange];
            elseif length(nrange)~=1
                nrange=[nrange(1)-1 nrange];
            end
            x=[x;reshape(grd.X(mrange,nrange),[],1); NaN];
            y=[y;reshape(grd.Y(mrange,nrange),[],1); NaN];
        end
        output=[x y];
        if OPT.saveoutputFile
            io_polygon('write',outputFile,x,y,'dosplit');
        end
    end
% dry2xyz
    function output=EHY_convert_dry2xyz(inputFile,outputFile,OPT)
        pathstr = fileparts(inputFile);
        dry=delft3d_io_dry('read',inputFile);
        disp('Open the corresponding .grd-file')
        [grdName,grdPath]=uigetfile([pathstr filesep '.grd'],'Open the corresponding .grd-file');
        [x,y]=EHY_mn2xy(dry.m,dry.n,[grdPath grdName]);
        xyz=[x y zeros(length(x),1)];
        if OPT.saveoutputFile
            dlmwrite(outputFile,xyz,'delimiter',' ','precision','%20.7f')
        end
        output=xyz;
    end
% grd2kml
    function output=EHY_convert_grd2kml(inputFile,outputFile,OPT)
        if OPT.saveoutputFile
            [~,name]=fileparts(inputFile);
            tempFileGrd=[tempdir name '.grd'];
            tempFileKml=[tempdir name '.kml'];
            copyfile(inputFile,tempFileGrd);
            grd=wlgrid('read',tempFileGrd);
            [x,y]=EHY_convert_coorCheck(grd.X,grd.Y);
            if ~any(any(grd.X==x)) % coordinates have been converted
                grd.X=x; grd.Y=y; grd.CoordinateSystem='Spherical';
                wlgrid('write',tempFileGrd,grd);
            end
            grid2kml(tempFileGrd,OPT.lineColor*255);
            copyfile(tempFileKml,outputFile);
            delete(tempFileGrd)
            delete(tempFileKml)
        end
        output=[];
    end
% kml2ldb
    function output=EHY_convert_kml2ldb(inputFile,outputFile,OPT)
        output=kml2ldb(OPT.saveoutputFile,inputFile);
    end
% kml2pol
    function output=EHY_convert_kml2pol(inputFile,outputFile,OPT)
        output=kml2pol(OPT.saveoutputFile,inputFile);
    end
% kml2xyz
    function output=EHY_convert_kml2xyz(inputFile,outputFile,OPT)
        xyz=kml2ldb(OPT.saveoutputFile,inputFile);
        xyz(isnan(xyz(:,1)),:)=[];
        if OPT.saveoutputFile
            dlmwrite(outputFile,xyz);
        end
        output=xyz;
    end
% ldb2kml
    function output=EHY_convert_ldb2kml(inputFile,outputFile,OPT)
        ldb=landboundary('read',inputFile);
        if OPT.saveoutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(ldb,tempFile,OPT.lineColor)
            copyfile(tempFile,outputFile);
            delete(tempFile);
        end
        output=[];
    end
% ldb2pol
    function output=EHY_convert_ldb2pol(inputFile,outputFile,OPT)
        ldb=landboundary('read',inputFile);
        if OPT.saveoutputFile
            io_polygon('write',outputFile,ldb);
        end
        output=ldb;
    end
% obs2kml
    function output=EHY_convert_obs2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveoutputFile=0;
        xyn=EHY_convert_obs2xyn(inputFile,outputFile,OPT);
        [x,y]=EHY_convert_coorCheck(xyn{1,1},xyn{1,2});
        xyn{1,1}=x;xyn{1,2}=y;
        OPT=OPT_user;
        if OPT.saveoutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            KMLPlaceMark(xyn{1,2},xyn{1,1},tempFile,'name',xyn{1,3});
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output=[];
    end
% obs2xyn
    function output=EHY_convert_obs2xyn(inputFile,outputFile,OPT)
        pathstr = fileparts(inputFile);
        obs=delft3d_io_obs('read',inputFile);
        disp('Open the corresponding .grd-file')
        [grdName,grdPath]=uigetfile([pathstr filesep '.grd'],'Open the corresponding .grd-file');
        [x,y]=EHY_mn2xy(obs.m,obs.n,[grdPath grdName]);
        
        if OPT.saveoutputFile
            fid=fopen(outputFile,'w');
            for iM=1:length(x)
                fprintf(fid,'%20.7f%20.7f ',[x(iM,1) y(iM,1)]);
                fprintf(fid,'%-s\n',obs.namst(iM,:));
            end
            fclose(fid);
        end
        output={x y cellstr(obs.namst)};
    end
% pol2kml
    function output=EHY_convert_pol2kml(inputFile,outputFile,OPT)
        pol=landboundary('read',inputFile);
        if OPT.saveoutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(pol,tempFile,OPT.lineColor)
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output=[];
    end
% pol2ldb
    function output=EHY_convert_pol2ldb(inputFile,outputFile,OPT)
        pol=landboundary('read',inputFile);
        if OPT.saveoutputFile
            output=landboundary('write',outputFile,pol);
        end
        output=[];
    end
% pol2xyz
    function output=EHY_convert_pol2xyz(inputFile,outputFile,OPT)
        xyz=landboundary('read',inputFile);
        xyz(isnan(xyz(:,1)),:)=[];
        if OPT.saveoutputFile
            dlmwrite(outputFile,xyz);
        end
        output=xyz;
    end
% shp2kml
    function output=EHY_convert_shp2kml(inputFile,outputFile,OPT)
        ldb=shape2ldb(inputFile,0);
        if OPT.saveoutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(ldb,tempFile,OPT.lineColor)
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output=[];
    end
% shp2ldb
    function output=EHY_convert_shp2ldb(inputFile,outputFile,OPT)
        output=shape2ldb(inputFile,OPT.saveoutputFile);
    end
% shp2pol
    function output=EHY_convert_shp2pol(inputFile,outputFile,OPT)
        output=shape2ldb(inputFile,0);
        if OPT.saveoutputFile
            io_polygon('write',outputFile,output);
        end
    end
% thd2kml
    function output=EHY_convert_thd2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveoutputFile=0;
        pli=EHY_convert_thd2pli(inputFile,outputFile,OPT);
        [x,y]=EHY_convert_coorCheck(pli(:,1),pli(:,2));
        output=[x y];
        OPT=OPT_user;
        if OPT.saveoutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(output,tempFile,OPT.lineColor)
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
    end
% thd2pli
    function output=EHY_convert_thd2pli(inputFile,outputFile,OPT)
        thd=delft3d_io_thd('read',inputFile);
        x=[];y=[];
        disp('Open the corresponding .grd-file')
        [grdName,grdPath]=uigetfile([pathstr filesep '.grd'],'Open the corresponding .grd-file');
        tempFile=[tempdir 'tmp.grd'];
        copyfile([grdPath grdName],tempFile);
        grd=wlgrid('read',tempFile);
        delete(tempFile);
        
        for iM=1:length(thd.m)
            if strcmpi(thd.DATA(iM).direction,'U')
                x=[x;grd.X(thd.DATA(iM).m,thd.DATA(iM).n);...
                    grd.X(thd.DATA(iM).m,thd.DATA(iM).n-1); NaN];
                y=[y;grd.Y(thd.DATA(iM).m,thd.DATA(iM).n);...
                    grd.Y(thd.DATA(iM).m,thd.DATA(iM).n-1); NaN];
            else
                x=[x;grd.X(thd.DATA(iM).m,thd.DATA(iM).n);...
                    grd.X(thd.DATA(iM).m-1,thd.DATA(iM).n); NaN];
                y=[y;grd.Y(thd.DATA(iM).m,thd.DATA(iM).n);...
                    grd.Y(thd.DATA(iM).m-1,thd.DATA(iM).n); NaN];
            end
        end
        output=[x y];
        if OPT.saveoutputFile
            io_polygon('write',outputFile,x,y,'dosplit');
        end
    end
% xyn2kml
    function output=EHY_convert_xyn2kml(inputFile,outputFile,OPT)
        try
            xyn=delft3d_io_xyn('read',inputFile);
        catch
            fid=fopen(inputFile,'r');
            D=textscan(fid,'%f%f%s','delimiter','\n');
            fclose(fid);
            xyn.x=D{1,1};
            xyn.y=D{1,2};
            xyn.name=D{1,3};
        end
        [xyn.x,xyn.y]=EHY_convert_coorCheck(xyn.x,xyn.y);
        if OPT.saveoutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            KMLPlaceMark(xyn.y,xyn.x,tempFile,'name',xyn.name);
            copyfile(tempFile,outputFile);
            delete(tempFile);
        end
        output=[];
    end
% xyn2obs
    function output=EHY_convert_xyn2obs(inputFile,outputFile,OPT)
        pathstr = fileparts(inputFile);
        try
            xyn=delft3d_io_xyn('read',inputFile);
        catch
            fid=fopen(inputFile,'r');
            D=textscan(fid,'%f%f%s','delimiter','\n');
            fclose(fid);
            xyn.x=D{1,1};
            xyn.y=D{1,2};
            xyn.name=D{1,3};
        end
        [x,y]=EHY_convert_coorCheck(xyn.x,xyn.y);
        disp('Open the corresponding .grd-file')
        [grdName,grdPath]=uigetfile([pathstr filesep '.grd'],'Open the corresponding .grd-file');
        [m,n]=EHY_xy2mn(xyn.x,xyn.y,[grdPath grdName]);
        obs.m=m; obs.n=n; obs.namst=xyn.name;
        if OPT.saveoutputFile
            delft3d_io_obs('write',outputFile,obs);
        end
        if size(m,1)==1; m=m'; n=n'; end
        output=[m n];
    end
% xyz2dry
    function output=EHY_convert_xyz2dry(inputFile,outputFile,OPT)
        pathstr = fileparts(inputFile);
        xyz=importdata(inputFile);
        disp('Open the corresponding .grd-file')
        [grdName,grdPath]=uigetfile([pathstr filesep '.grd'],'Open the corresponding .grd-file');
        [m,n]=EHY_xy2mn(xyz(:,1),xyz(:,2),[grdPath grdName]);
        if OPT.saveoutputFile
            delft3d_io_dry('write',outputFile,m,n);
        end
        if size(m,1)==1; m=m'; n=n'; end
        output=[m n];
    end
% xyz2kml
    function output=EHY_convert_xyz2kml(inputFile,outputFile,OPT)
        xyz=dlmread(inputFile);
        lon=xyz(:,1); lat=xyz(:,2);
        if OPT.saveoutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            KMLPlaceMark(lat,lon,tempFile);
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output=[lon lat];
    end
%% output
if nargout==1
    varargout{1}=output;
elseif nargout>1
    varargout{1}=output(:,1);
    varargout{2}=output(:,2);
end
end

function [x,y]=EHY_convert_coorCheck(x,y)
if (min(min(y))>max(max(x))) && (~any(any(x<0))) && (~any(any((y<0)))) && (prod(prod(x(~isnan(x))>1000)==1)) % RD in m
    disp('Input coordinations are probably in meter Amersfoort/RD New, EPSG 28992')
    yn=input('Apply conversion from Amersfoort/RD New, EPSG 28992? [Y/N]  ','s');
    if strcmpi(yn,'y')
        fromEPSG='28992';
        [x,y]=convertCoordinates(x,y,'CS1.code',fromEPSG,'CS2.code',4326);
    else
        fromEPSG=input('What is the code of the input coordinates? EPSG: ');
        [x,y]=convertCoordinates(x,y,'CS1.code',fromEPSG,'CS2.code',4326);
    end
elseif any([any(x<-180),any(x>180),any(y<-90),any(y>90)])
    disp('Input coordinations are probably not in [Longitude,Latitude] - WGS ''84')
    disp('common EPSG-codes: Amersfoort/RD New: 28992')
    disp('                   Panama           : 32617')
    fromEPSG=input('What is the code of the input coordinates? EPSG: ');
    [x,y]=convertCoordinates(x,y,'CS1.code',fromEPSG,'CS2.code',4326);
end
end