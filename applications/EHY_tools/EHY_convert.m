function varargout=EHY_convert(varargin)
%% varargout=EHY_convert(varargin)
%
% Converts the inputFile to a file with the outputExt.
% It makes use of available conversion scripts in the OET.

% Example1: EHY_convert
% Example2: EHY_convert('D:\path.kml')
% Example3: ldb=EHY_convert('D:\path.kml','ldb')
% Example4: EHY_convert('D:\path.kml','ldb','saveoutputFile',0)

% created by Julien Groenenboom, August 2017

OPT.saveoutputFile=1; % 0=do not save, 1=save
OPT.outputFile=[]; % if isempty > outputFile=strrep(inputFile,inputExt,outputExt);
OPT.lineColor=[1 0 0]; % default is red
OPT.fromEPSG=[]; % convert from this EPSG in case of conversion to kml (Google Earth)
OPT.grdFile=[];  % corresponding .grd file for files like .crs / .dry / obs. / ...
OPT.grd=[]; % wlgrid('read',OPT.grdFile);

% if structure was given as input OPT
OPTid=find(cellfun(@isstruct, varargin));
if ~isempty(OPTid)
    OPT=setproperty(OPT,varargin{OPTid});
    varargin{OPTid}=[];
    varargin=varargin(~cellfun('isempty',varargin));
end

% if pairs were given as input OPT
if length(varargin)>2
    if mod(length(varargin),2)==0
        OPT = setproperty(OPT,varargin{3:end});
    else
        error('Additional input arguments must be given in pairs.')
    end
end

%% availableConversions
A=textread(which('EHY_convert.m'),'%s','delimiter','\n');
searchLine='function [output,OPT]=EHY_convert_';
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
    if ~isempty(strmatch('pol',availableoutputExt))
        availableoutputExt=[availableoutputExt; 'pli'];
    end
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

if strcmpi(outputExt,'pli'); outputExt='pol'; end %threat as .pol, but still save as .pli

output=[];
eval(['[output,OPT]=EHY_convert_' inputExt '2' outputExt '(''' inputFile ''',''' outputFile ''',OPT);'])
if OPT.saveoutputFile
    disp([char(10) 'EHY_convert created the file: ' char(10) outputFile char(10)])
end
%% conversion functions - in alphabetical order
% crs2kml
    function [output,OPT]=EHY_convert_crs2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveoutputFile=0;
        pol=EHY_convert_crs2pol(inputFile,outputFile,OPT);
        [x,y,OPT]=EHY_convert_coorCheck(pol(:,1),pol(:,2),OPT);
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
% crs2pol
    function [output,OPT]=EHY_convert_crs2pol(inputFile,outputFile,OPT)
        crs=delft3d_io_crs('read',inputFile);
        x=[];y=[];
        [OPT,grd]=EHY_convert_gridCheck(OPT);
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
            io_polygon('write',outputFile,x,y,'dosplit','-1');
        end
    end
% dry2xyz
    function [output,OPT]=EHY_convert_dry2xyz(inputFile,outputFile,OPT)
        pathstr = fileparts(inputFile);
        dry=delft3d_io_dry('read',inputFile);
        OPT=EHY_convert_gridCheck(OPT);
        [x,y]=EHY_mn2xy(dry.m,dry.n,OPT.grdFile);
        xyz=[x y zeros(length(x),1)];
        if OPT.saveoutputFile
            dlmwrite(outputFile,xyz,'delimiter',' ','precision','%20.7f')
        end
        output=xyz;
    end
% dry2kml
    function [output,OPT]=EHY_convert_dry2kml(inputFile,outputFile,OPT)
        pathstr = fileparts(inputFile);
        dry=delft3d_io_dry('read',inputFile);
        [OPT,grd]=EHY_convert_gridCheck(OPT);
        pol=[];
        for iM=1:length(dry.m)
            mm=dry.m(iM);
            nn=dry.n(iM);
            crossInd=[mm-1 mm-1 mm   mm mm-1 mm   mm-1 mm   ;,...
                nn   nn-1 nn-1 nn nn   nn-1 nn-1 nn];
            crossInd=sub2ind(size(grd.X),crossInd(1,:),crossInd(2,:));
            pol=[pol;grd.X(crossInd)' grd.Y(crossInd)'; NaN NaN];
        end
        [pol(:,1),pol(:,2),OPT]=EHY_convert_coorCheck(pol(:,1),pol(:,2),OPT);
        if OPT.saveoutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(pol,tempFile,OPT.lineColor)
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output=pol;
    end
% grd2kml
    function [output,OPT]=EHY_convert_grd2kml(inputFile,outputFile,OPT)
        if OPT.saveoutputFile
            [~,name]=fileparts(inputFile);
            tempFileGrd=[tempdir name '.grd'];
            tempFileKml=[tempdir name '.kml'];
            copyfile(inputFile,tempFileGrd);
            grd=wlgrid('read',tempFileGrd);
            [x,y,OPT]=EHY_convert_coorCheck(grd.X,grd.Y,OPT);
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
    function [output,OPT]=EHY_convert_kml2ldb(inputFile,outputFile,OPT)
        output=kml2ldb(OPT.saveoutputFile,inputFile);
    end
% kml2pol
    function [output,OPT]=EHY_convert_kml2pol(inputFile,outputFile,OPT)
        output=kml2pol(OPT.saveoutputFile,inputFile);
    end
% kml2xyz
    function [output,OPT]=EHY_convert_kml2xyz(inputFile,outputFile,OPT)
        xyz=kml2ldb(OPT.saveoutputFile,inputFile);
        xyz(isnan(xyz(:,1)),:)=[];
        if OPT.saveoutputFile
            dlmwrite(outputFile,xyz);
        end
        output=xyz;
    end
% ldb2kml
    function [output,OPT]=EHY_convert_ldb2kml(inputFile,outputFile,OPT)
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
    function [output,OPT]=EHY_convert_ldb2pol(inputFile,outputFile,OPT)
        ldb=landboundary('read',inputFile);
        if OPT.saveoutputFile
            io_polygon('write',outputFile,ldb);
        end
        output=ldb;
    end
% obs2kml
    function [output,OPT]=EHY_convert_obs2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveoutputFile=0;
        xyn=EHY_convert_obs2xyn(inputFile,outputFile,OPT);
        [xyn{1,1},xyn{1,2},OPT]=EHY_convert_coorCheck(xyn{1,1},xyn{1,2},OPT);
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
    function [output,OPT]=EHY_convert_obs2xyn(inputFile,outputFile,OPT)
        pathstr = fileparts(inputFile);
        obs=delft3d_io_obs('read',inputFile);
        OPT=EHY_convert_gridCheck(OPT);
        [x,y]=EHY_mn2xy(obs.m,obs.n,OPT.grdFile);
        
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
    function [output,OPT]=EHY_convert_pol2kml(inputFile,outputFile,OPT)
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
    function [output,OPT]=EHY_convert_pol2ldb(inputFile,outputFile,OPT)
        pol=landboundary('read',inputFile);
        if OPT.saveoutputFile
            output=landboundary('write',outputFile,pol);
        end
        output=[];
    end
% pol2xyz
    function [output,OPT]=EHY_convert_pol2xyz(inputFile,outputFile,OPT)
        xyz=landboundary('read',inputFile);
        xyz(isnan(xyz(:,1)),:)=[];
        if OPT.saveoutputFile
            dlmwrite(outputFile,xyz);
        end
        output=xyz;
    end
% shp2kml
    function [output,OPT]=EHY_convert_shp2kml(inputFile,outputFile,OPT)
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
    function [output,OPT]=EHY_convert_shp2ldb(inputFile,outputFile,OPT)
        output=shape2ldb(inputFile,OPT.saveoutputFile);
    end
% shp2pol
    function [output,OPT]=EHY_convert_shp2pol(inputFile,outputFile,OPT)
        output=shape2ldb(inputFile,0);
        if OPT.saveoutputFile
            io_polygon('write',outputFile,output);
        end
    end
% src2kml
    function [output,OPT]=EHY_convert_src2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveoutputFile=0;
        xyn=EHY_convert_src2xyn(inputFile,outputFile,OPT);
        [xyn{1,1},xyn{1,2},OPT]=EHY_convert_coorCheck(xyn{1,1},xyn{1,2},OPT);
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
% src2xyn
    function [output,OPT]=EHY_convert_src2xyn(inputFile,outputFile,OPT)
        pathstr = fileparts(inputFile);
        src=delft3d_io_src('read',inputFile);
        OPT=EHY_convert_gridCheck(OPT);
        [x,y]=EHY_mn2xy(src.m,src.n,OPT.grdFile);
        
        if OPT.saveoutputFile
            fid=fopen(outputFile,'w');
            for iM=1:length(x)
                fprintf(fid,'%20.7f%20.7f ',[x(iM,1) y(iM,1)]);
                fprintf(fid,'%-s\n',src.DATA(iM).name);
            end
            fclose(fid);
        end
        output={x y reshape({src.DATA.name},[],1)};
    end
% thd2kml
    function [output,OPT]=EHY_convert_thd2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveoutputFile=0;
        pol=EHY_convert_thd2pol(inputFile,outputFile,OPT);
        [pol(:,1),pol(:,2),OPT]=EHY_convert_coorCheck(pol(:,1),pol(:,2),OPT);
        output=pol;
        OPT=OPT_user;
        if OPT.saveoutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(output,tempFile,OPT.lineColor)
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
    end
% thd2pol
    function [output,OPT]=EHY_convert_thd2pol(inputFile,outputFile,OPT)
        thd=delft3d_io_thd('read',inputFile);
        x=[];y=[];
        [OPT,grd]=EHY_convert_gridCheck(OPT);
        
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
            io_polygon('write',outputFile,x,y,'dosplit','-1');
        end
    end
% xyn2kml
    function [output,OPT]=EHY_convert_xyn2kml(inputFile,outputFile,OPT)
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
        [xyn.x,xyn.y,OPT]=EHY_convert_coorCheck(xyn.x,xyn.y,OPT);
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
    function [output,OPT]=EHY_convert_xyn2obs(inputFile,outputFile,OPT)
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
        [xyn.x,xyn.y,OPT]=EHY_convert_coorCheck(xyn.x,xyn.y,OPT);
        OPT=EHY_convert_gridCheck(OPT);
        [m,n]=EHY_xy2mn(xyn.x,xyn.y,OPT.grdFile);
        obs.m=m; obs.n=n; obs.namst=xyn.name;
        if OPT.saveoutputFile
            delft3d_io_obs('write',outputFile,obs);
        end
        output=[reshape(m,[],1) reshape(n,[],1)];
    end
% xyz2dry
    function [output,OPT]=EHY_convert_xyz2dry(inputFile,outputFile,OPT)
        pathstr = fileparts(inputFile);
        xyz=importdata(inputFile);
        OPT=EHY_convert_gridCheck(OPT);
        [m,n]=EHY_xy2mn(xyz(:,1),xyz(:,2),OPT.grdFile);
        if OPT.saveoutputFile
            delft3d_io_dry('write',outputFile,m,n);
        end
        if size(m,1)==1; m=m'; n=n'; end
        output=[m n];
    end
% xyz2kml
    function [output,OPT]=EHY_convert_xyz2kml(inputFile,outputFile,OPT)
        xyz=dlmread(inputFile);
        [lon,lat,OPT]=EHY_convert_coorCheck(xyz(:,1),xyz(:,2),OPT);
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
    varargout{1}=output;
    varargout{2}=OPT;
end
end

function varargout=EHY_convert_gridCheck(OPT) 
if nargout==1
    if isempty(OPT.grdFile)
        disp('Open the corresponding .grd-file')
        [grdName,grdPath]=uigetfile([pathstr filesep '.grd'],'Open the corresponding .grd-file');
        OPT.grdFile=[grdPath grdName];
    end
    varargout{1}=OPT;
elseif nargout==2
    if isempty(OPT.grd)
        [~, name] = fileparts(OPT.grdFile);
        tempFile=[tempdir name '.grd'];
        copyfile(OPT.grdFile,tempFile);
        OPT.grd=wlgrid('read',tempFile);
        delete(tempFile);
    end
    varargout{1}=OPT;
    varargout{2}=OPT.grd;
end
end

function [x,y,OPT]=EHY_convert_coorCheck(x,y,OPT)
if isempty(OPT.fromEPSG)
    if all(x(~isnan(x))>-7000) && all(x(~isnan(x)<300000)) && all(x(~isnan(y)>289000)) && all(x(~isnan(y)<629000))   % probably RD in m
        disp('Input coordinations are probably in meter Amersfoort/RD New, EPSG 28992')
        yn=input('Apply conversion from Amersfoort/RD New, EPSG 28992? [Y/N]  ','s');
        if strcmpi(yn,'y')
            OPT.fromEPSG='28992';
        end
    end
    if isempty(OPT.fromEPSG) && any([any(x<-180),any(x>180),any(y<-90),any(y>90)])
        disp('Input coordinations are probably not in [Longitude,Latitude] - WGS ''84')
        disp('common EPSG-codes: Amersfoort/RD New: 28992')
        disp('                   Panama           : 32617')
        OPT.fromEPSG=input('What is the code of the input coordinates? EPSG: ');
    end
end
if isempty(OPT.fromEPSG)
    disp('Coordinates are assumed to be in WGS''84 (Latitude,Longitude)')
    OPT.fromEPSG='4326';
else
    [x,y]=convertCoordinates(x,y,'CS1.code',OPT.fromEPSG,'CS2.code',4326);
end
end
