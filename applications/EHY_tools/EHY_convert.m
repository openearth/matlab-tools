function varargout=EHY_convert(varargin)
%% varargout=EHY_convert(varargin)
%
% Converts the inputFile to a file with the outputExt.
% It makes use of available conversion scripts in the OET.

% Example1: EHY_convert
% Example2: EHY_convert('D:\path.kml')
% Example3: ldb=EHY_convert('D:\path.kml','ldb')
% Example4: EHY_convert('D:\path.kml','ldb','saveOutputFile',0)

% created by Julien Groenenboom, August 2017

OPT.saveOutputFile=1; % 0=do not save, 1=save
OPT.outputFile=[]; % if isempty > outputFile=strrep(inputFile,inputExt,outputExt);
OPT.lineColor=[1 0 0]; % default is red
OPT.fromEPSG=[]; % convert from this EPSG in case of conversion to kml (Google Earth)
OPT.grdFile=[];  % corresponding .grd file for files like .crs / .dry / obs. / ...
OPT.grd=[]; % wlgrid('read',OPT.grdFile);
OPT.iconFile='http://maps.google.com/mapfiles/kml/paddle/blu-stars.png'; % for PlaceMark

% if structure was given as input OPT
OPTid=find(cellfun(@isstruct, varargin));
if ~isempty(OPTid)
    if ~isfield(varargin{OPTid},'X') % grd can also be given as input struct
        OPT=setproperty(OPT,varargin{OPTid});
        varargin{OPTid}=[];
        varargin=varargin(~cellfun('isempty',varargin));
    end
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
    txt=strrep(A{lineNrs(ii)},searchLine,'');
    txt(strfind(txt,'('):end)=[];
    [ext1,ext2]=strtok(txt,'2');
    availableConversions{end+1,1}=ext1;
    availableConversions{end,2}=ext2(2:end);
end

%% initialise
if length(varargin)==0
    listOfExt=unique(availableConversions(:,1));
    disp(['EHY_convert  -  Conversion possible for following inputFiles: ' char(10),...
        strrep(strtrim(sprintf('%s ',listOfExt{:})),' ',', ')])
    availableExt=strcat('*.',[{'*'}; listOfExt]);
    disp('Open a file that you want to convert')
    [filename, pathname]=uigetfile(availableExt,'Open a file that you want to convert');
    varargin{1}=[pathname filename];
end
if length(varargin)==1
    inputFile=varargin{1};
    [~,~,inputExt0]= fileparts(inputFile);
    inputExt=strrep(inputExt0,'.','');
    
    if strcmp(inputExt,'pli'); inputExt='pol'; end
    availableInputId=strmatch(inputExt,availableConversions(:,1));
    if isempty(availableInputId)
        error(['No conversions available for ' inputExt '-files.'])
    end
    availableoutputExt=availableConversions(availableInputId,2);
    if ~isempty(strmatch('pol',availableoutputExt))
        availableoutputExt=[availableoutputExt; 'pli'];
    end
    if ismember(inputExt0,{'.grd','.ldb','.pli','.pol','.xyz','.xyn'})
        availableoutputExt=[availableoutputExt; inputExt0(2:end)];
        [availableoutputId,~]=  listdlg('PromptString',['Convert this ' inputExt0 '-file to (to same extension >> coordinate conversion):'],...
            'SelectionMode','single',...
            'ListString',availableoutputExt,...
            'ListSize',[500 100]);
    else
        [availableoutputId,~]=  listdlg('PromptString',['Convert this ' inputExt0 '-file to:'],...
            'SelectionMode','single',...
            'ListString',availableoutputExt,...
            'ListSize',[500 100]);
    end
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

if strcmp(inputFile,outputFile)
    outputFile=strrep(inputFile,inputExt0,['_converted' inputExt0]);
end

if OPT.saveOutputFile && exist(outputFile,'file')
    [YesNoID,~]=  listdlg('PromptString',{'The outputFile already exists. Overwrite the file below?',outputFile},...
        'SelectionMode','single',...
        'ListString',{'Yes','No','No, but save as...'},...
        'ListSize',[800 50]);
    if YesNoID==2
        OPT.saveOutputFile=0;
    elseif YesNoID==3
        [pathstr,~,ext] = fileparts(outputFile);
        [FileName,PathName] = uiputfile([pathstr filesep ext]);
        outputFile=[PathName FileName];
    end
end

if strcmp(inputExt,'pli'); inputExt='pol'; end
if strcmpi(outputExt,'pli'); outputExt='pol'; end %treat as .pol, but still save as .pli

output=[];

if ~strcmp(inputExt,outputExt)
    eval(['[output,OPT]=EHY_convert_' inputExt '2' outputExt '(''' inputFile ''',''' outputFile ''',OPT);'])
else
    eval(['[output,OPT]=EHY_convertCoordinates(''' inputFile ''',''' outputFile ''',OPT);'])
end

if OPT.saveOutputFile && exist(outputFile,'file')
    if strcmp(outputExt,'nc'); 
        outputFile0=outputFile;
        outputFile=strrep(outputFile0,'.nc','_net.nc');
        movefile(outputFile0,outputFile);
    end
    disp([char(10) 'EHY_convert created the file: ' char(10) strrep(outputFile,[filesep filesep],filesep) char(10)])
end
%% conversion functions - in alphabetical order
% crs2kml
    function [output,OPT]=EHY_convert_crs2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveOutputFile=0;
        pol=EHY_convert_crs2pol(inputFile,outputFile,OPT);
        [x,y,OPT]=EHY_convert_coorCheck(pol(:,1),pol(:,2),OPT);
        output=[x y];
        OPT=OPT_user;
        if OPT.saveOutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(output(:,1:2),tempFile,OPT.lineColor)
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
    end
% crs2pol
    function [output,OPT]=EHY_convert_crs2pol(inputFile,outputFile,OPT)
        crs=delft3d_io_crs('read',inputFile);
        x=[];y=[];
        [OPT,grd]=EHY_convert_gridCheck(OPT,inputFile);
        for iM=1:crs.NTables
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
        if OPT.saveOutputFile
            io_polygon('write',outputFile,x,y,'dosplit','-1');
        end
    end
% dry2kml
    function [output,OPT]=EHY_convert_dry2kml(inputFile,outputFile,OPT)
        dry=delft3d_io_dry('read',inputFile);
        [OPT,grd]=EHY_convert_gridCheck(OPT,inputFile);
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
        if OPT.saveOutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(pol(:,1:2),tempFile,OPT.lineColor)
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output=pol;
    end
% dry2thd
    function [output,OPT]=EHY_convert_dry2thd(inputFile,outputFile,OPT)
        dry=delft3d_io_dry('read',inputFile);
        thd.DATA=struct;
        for iM=1:length(dry.m)
            if iM==1
                thd.DATA(end).mn=[dry.m(iM);dry.n(iM);dry.m(iM);dry.n(iM)];
                thd.DATA(end).direction='U';
            else
                thd.DATA(end+1).mn=[dry.m(iM);dry.n(iM);dry.m(iM);dry.n(iM)];
                thd.DATA(end).direction='U';
            end
            thd.DATA(end+1).mn=[dry.m(iM);dry.n(iM);dry.m(iM);dry.n(iM)];
            thd.DATA(end).direction='V';
            thd.DATA(end+1).mn=[dry.m(iM)-1;dry.n(iM);dry.m(iM)-1;dry.n(iM)];
            thd.DATA(end).direction='U';
            thd.DATA(end+1).mn=[dry.m(iM);dry.n(iM)-1;dry.m(iM);dry.n(iM)-1];
            thd.DATA(end).direction='V';
        end
        if OPT.saveOutputFile
            delft3d_io_thd('write',outputFile,thd)
        end
        output=[];
    end
% dry2xyz
    function [output,OPT]=EHY_convert_dry2xyz(inputFile,outputFile,OPT)
        dry=delft3d_io_dry('read',inputFile);
        OPT=EHY_convert_gridCheck(OPT,inputFile);
        [x,y]=EHY_mn2xy(dry.m,dry.n,OPT.grdFile);
        xyz=[x y zeros(length(x),1)];
        if OPT.saveOutputFile
            dlmwrite(outputFile,xyz,'delimiter',' ','precision','%20.7f')
        end
        output=xyz;
    end
% grd2kml
    function [output,OPT]=EHY_convert_grd2kml(inputFile,outputFile,OPT)
        if OPT.saveOutputFile
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
            delete(strrep(tempFileGrd,'.grd','.enc'))
            delete(tempFileKml)
        end
        output=[];
    end
% grd2nc
    function [output,OPT]=EHY_convert_grd2nc(inputFile,outputFile,OPT)
        if OPT.saveOutputFile
            % based on d3d2dflowfm_grd2net
            G             = delft3d_io_grd('read',inputFile);
            xh            = G.cor.x';
            yh            = G.cor.y';
            mmax          = G.mmax;
            nmax          = G.nmax;
            xh(mmax,:)    = NaN;
            yh(mmax,:)    = NaN;
            xh(:,nmax)    = NaN;
            yh(:,nmax)    = NaN;
            spher         = 0;
            if strcmp(G.CoordinateSystem,'Spherical');
                spher     = 1;
            end
            zh            = -5.*ones(mmax,nmax); 
            netfile=outputFile;
            
            % to avoid error of variables being created in below function 
            X=[];Y=[];Z=[];NetNode_mask=[];nNetNode=[];vals=[];nc=[];ifld=[];attr=[];dims=[];
            ContourLink=[];NetLink=[];
            convertWriteNetcdf;
            disp('For grd2nc conversion incl. depth, have a look at function ''d3d2dflowfm_grd2net.m'' ');
        end
        output=[];
    end
% kml2ldb
    function [output,OPT]=EHY_convert_kml2ldb(inputFile,outputFile,OPT)
        output=kml2ldb(OPT.saveOutputFile,inputFile);
    end
% kml2pol
    function [output,OPT]=EHY_convert_kml2pol(inputFile,outputFile,OPT)
        output=kml2ldb(OPT.saveOutputFile,inputFile);
    end
% kml2xyn
    function [output,OPT]=EHY_convert_kml2xyn(inputFile,outputFile,OPT)
        kml = xml_read(inputFile);
        for ii=1:length(kml.Placemark)
            names{ii,1}=kml.Placemark(ii).name;
            coords=regexp(kml.Placemark(ii).Point.coordinates,',','split');
            x(ii,1)=str2num(coords{1});
            y(ii,1)=str2num(coords{2});
        end
        output={x y names};
        if OPT.saveOutputFile
            fid=fopen(outputFile,'w');
            for iM=1:length(x)
                fprintf(fid,'%20.7f%20.7f ',[x(iM,1) y(iM,1)]);
                fprintf(fid,'%-s\n',names{iM});
            end
            fclose(fid);
        end
    end
% kml2xyz
    function [output,OPT]=EHY_convert_kml2xyz(inputFile,outputFile,OPT)
        xyz=kml2ldb(OPT.saveOutputFile,inputFile);
        xyz(isnan(xyz(:,1)),:)=[];
        if OPT.saveOutputFile
            dlmwrite(outputFile,xyz);
        end
        output=xyz;
    end
% ldb2kml
    function [output,OPT]=EHY_convert_ldb2kml(inputFile,outputFile,OPT)
        ldb=landboundary('read',inputFile);
        if OPT.saveOutputFile
            [ldb(:,1),ldb(:,2),OPT]=EHY_convert_coorCheck(ldb(:,1),ldb(:,2),OPT);
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(ldb(:,1:2),tempFile,OPT.lineColor)
            copyfile(tempFile,outputFile);
            delete(tempFile);
        end
        output=[];
    end
% ldb2pol
    function [output,OPT]=EHY_convert_ldb2pol(inputFile,outputFile,OPT)
        if OPT.saveOutputFile
            copyfile(inputFile,outputFile);
        end
        ldb=landboundary('read',inputFile);
        output=ldb;
    end
% nc2kml
    function [output,OPT]=EHY_convert_nc2kml(inputFile,outputFile,OPT)
        x=nc_varget(inputFile,'NetNode_x');
        y=nc_varget(inputFile,'NetNode_y');
        links=nc_varget(inputFile,'NetLink');
        
        lines=zeros(length(links)*3,2);
        
        lines(3*(1:length(links))-2,:)=[x(links(:,1)) y(links(:,1))];
        lines(3*(1:length(links))-1,:)=[x(links(:,2)) y(links(:,2))];
        lines(3*(1:length(links)),:)=NaN;
        lines=ipGlueLDB(lines);
        if OPT.saveOutputFile
            [lines(:,1),lines(:,2),OPT]=EHY_convert_coorCheck(lines(:,1),lines(:,2),OPT);
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(lines,tempFile,OPT.lineColor)
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output=lines;
    end
% obs2kml
    function [output,OPT]=EHY_convert_obs2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveOutputFile=0;
        xyn=EHY_convert_obs2xyn(inputFile,outputFile,OPT);
        [xyn{1,1},xyn{1,2},OPT]=EHY_convert_coorCheck(xyn{1,1},xyn{1,2},OPT);
        OPT=OPT_user;
        if OPT.saveOutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            KMLPlaceMark(xyn{1,2},xyn{1,1},tempFile,'name',xyn{1,3},'icon',OPT.iconFile);
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output=[];
    end
% obs2xyn
    function [output,OPT]=EHY_convert_obs2xyn(inputFile,outputFile,OPT)
        pathstr = fileparts(inputFile);
        obs=delft3d_io_obs('read',inputFile);
        OPT=EHY_convert_gridCheck(OPT,inputFile);
        [x,y]=EHY_mn2xy(obs.m,obs.n,OPT.grdFile);
        
        if OPT.saveOutputFile
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
        [pol(:,1),pol(:,2),OPT]=EHY_convert_coorCheck(pol(:,1),pol(:,2),OPT);
        if OPT.saveOutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(pol(:,1:2),tempFile,OPT.lineColor)
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output=[];
    end
% pol2ldb
    function [output,OPT]=EHY_convert_pol2ldb(inputFile,outputFile,OPT)
        if OPT.saveOutputFile
            copyfile(inputFile,outputFile)
        end
        output=landboundary('read',inputFile);
    end
% pol2xyz
    function [output,OPT]=EHY_convert_pol2xyz(inputFile,outputFile,OPT)
        xyz=landboundary('read',inputFile);
        xyz(isnan(xyz(:,1)),:)=[];
        if OPT.saveOutputFile
            dlmwrite(outputFile,xyz);
        end
        output=xyz;
    end
% shp2kml
    function [output,OPT]=EHY_convert_shp2kml(inputFile,outputFile,OPT)
        ldb=shape2ldb(inputFile,0);
        if OPT.saveOutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(ldb(:,1:2),tempFile,OPT.lineColor)
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output=[];
    end
% shp2ldb
    function [output,OPT]=EHY_convert_shp2ldb(inputFile,outputFile,OPT)
        output=shape2ldb(inputFile,OPT.saveOutputFile);
    end
% shp2pol
    function [output,OPT]=EHY_convert_shp2pol(inputFile,outputFile,OPT)
        output=shape2ldb(inputFile,0);
        if OPT.saveOutputFile
            io_polygon('write',outputFile,output);
        end
    end
% src2kml
    function [output,OPT]=EHY_convert_src2kml(inputFile,outputFile,OPT)
        OPT_user=OPT;
        OPT.saveOutputFile=0;
        xyn=EHY_convert_src2xyn(inputFile,outputFile,OPT);
        [xyn{1,1},xyn{1,2},OPT]=EHY_convert_coorCheck(xyn{1,1},xyn{1,2},OPT);
        OPT=OPT_user;
        if OPT.saveOutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            KMLPlaceMark(xyn{1,2},xyn{1,1},tempFile,'name',xyn{1,3},'icon',OPT.iconFile);
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
        output=[];
    end
% src2xyn
    function [output,OPT]=EHY_convert_src2xyn(inputFile,outputFile,OPT)
        src=delft3d_io_src('read',inputFile);
        OPT=EHY_convert_gridCheck(OPT,inputFile);
        [x,y]=EHY_mn2xy(src.m,src.n,OPT.grdFile);
        
        if OPT.saveOutputFile
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
        OPT.saveOutputFile=0;
        pol=EHY_convert_thd2pol(inputFile,outputFile,OPT);
        [pol(:,1),pol(:,2),OPT]=EHY_convert_coorCheck(pol(:,1),pol(:,2),OPT);
        output=pol;
        OPT=OPT_user;
        if OPT.saveOutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            ldb2kml(output(:,1:2),tempFile,OPT.lineColor)
            copyfile(tempFile,outputFile);
            delete(tempFile)
        end
    end
% thd2pol
    function [output,OPT]=EHY_convert_thd2pol(inputFile,outputFile,OPT)
        thd=delft3d_io_thd('read',inputFile);
        x=[];y=[];
        [OPT,grd]=EHY_convert_gridCheck(OPT,inputFile);
        
        for iM=1:thd.NTables
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
        if OPT.saveOutputFile
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
        if OPT.saveOutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            KMLPlaceMark(xyn.y,xyn.x,tempFile,'name',xyn.name,'icon',OPT.iconFile);
            copyfile(tempFile,outputFile);
            delete(tempFile);
        end
        output=[];
    end
% xyn2obs
    function [output,OPT]=EHY_convert_xyn2obs(inputFile,outputFile,OPT)
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
        OPT=EHY_convert_gridCheck(OPT,inputFile);
        [m,n]=EHY_xy2mn(xyn.x,xyn.y,OPT.grdFile);
        obs.m=m; obs.n=n; obs.namst=xyn.name;
        if OPT.saveOutputFile
            delft3d_io_obs('write',outputFile,obs);
        end
        output=[reshape(m,[],1) reshape(n,[],1)];
    end
% xyz2dry
    function [output,OPT]=EHY_convert_xyz2dry(inputFile,outputFile,OPT)
        xyz=importdata(inputFile);
        OPT=EHY_convert_gridCheck(OPT,inputFile);
        [m,n]=EHY_xy2mn(xyz(:,1),xyz(:,2),OPT.grdFile);
        if OPT.saveOutputFile
            delft3d_io_dry('write',outputFile,m,n);
        end
        if size(m,1)==1; m=m'; n=n'; end
        output=[m n];
    end
% xyz2kml
    function [output,OPT]=EHY_convert_xyz2kml(inputFile,outputFile,OPT)
        xyz=dlmread(inputFile);
        [lon,lat,OPT]=EHY_convert_coorCheck(xyz(:,1),xyz(:,2),OPT);
        if OPT.saveOutputFile
            [~,name]=fileparts(inputFile);
            tempFile=[tempdir name '.kml'];
            KMLPlaceMark(lat,lon,tempFile,'icon',OPT.iconFile);
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

function varargout=EHY_convert_gridCheck(OPT,inputFile)
if isempty(OPT.grdFile)
    disp('Open the corresponding .grd-file')
    [grdName,grdPath]=uigetfile([fileparts(inputFile) filesep '.grd'],'Open the corresponding .grd-file');
    OPT.grdFile=[grdPath grdName];
end

if nargout==2
    if isempty(OPT.grd)
        [~, name] = fileparts(OPT.grdFile);
        tempFile=[tempdir name '.grd'];
        copyfile(OPT.grdFile,tempFile);
        OPT.grd=wlgrid('read',tempFile);
        delete(tempFile);
    end
    varargout{2}=OPT.grd;
end
varargout{1}=OPT;
end

function [x,y,OPT]=EHY_convert_coorCheck(x,y,OPT)
% coordinates to check to guess coordinate system
xx=x(~isnan(x));
yy=y(~isnan(y));
if isempty(OPT.fromEPSG)
    if isempty(OPT.fromEPSG) && all(all(xx>=-180)) && all(all(xx<=180)) && all(all(yy>=-90)) && all(all(yy<=90))
        disp('Input coordinations are probably in [Longitude,Latitude] - WGS ''84')
        yn=input('Is this correct? [Y/N]  ','s');
        if strcmpi(yn(1),'y')
            OPT.fromEPSG='4326';
        end
    end
    if isempty(OPT.fromEPSG) && all(all(xx>-7000)) && all(all(xx<300000)) && all(all(yy>289000)) && all(all(yy<629000))   % probably RD in m
        disp('Input coordinations are probably in meter Amersfoort/RD New, EPSG 28992')
        yn=input('Apply conversion from Amersfoort/RD New, EPSG 28992? [Y/N]  ','s');
        if strcmpi(yn,'y')
            OPT.fromEPSG='28992';
        end
    end
    if isempty(OPT.fromEPSG)
        disp('Input coordinations are probably not in [Longitude,Latitude] - WGS ''84')
        disp('common EPSG-codes: Amersfoort/RD New: 28992')
        OPT.fromEPSG=input('What is the code of the input coordinates? EPSG: ');
    end
end
if isempty(OPT.fromEPSG)
    disp('Coordinates are assumed to be in WGS''84 (Latitude,Longitude)')
    OPT.fromEPSG='4326';
elseif ~isempty(OPT.fromEPSG) && ~strcmp(OPT.fromEPSG,'4326')
    [x,y]=convertCoordinates(x,y,'CS1.code',OPT.fromEPSG,'CS2.code',4326);
end
end

function [output,OPT]=EHY_convertCoordinates(inputFile,outputFile,OPT)

availableCoorSys={'EPSG: 28992, Amersfoort / RD New',28992;,...
    'EPSG:  4326, WGS ''84',4326;,...
    'Other...',-999};

% coordinate system of input file
[outputId,~]=  listdlg('PromptString','Coordinate system of the input file is: ',...
    'SelectionMode','single',...
    'ListString',availableCoorSys(:,1),'ListSize',[500 100]);
if outputId~=length(availableCoorSys)
    fromEPSG=availableCoorSys{outputId,2};
elseif outputId==length(availableCoorSys)
    fromEPSG=input('Coordinate system of the input file is, EPSG-code: ');
end

% coordinate system of output file
indExclToEPSG=find(cell2mat(availableCoorSys(:,2))~=fromEPSG);
availableCoorSys=availableCoorSys(indExclToEPSG,:);
[outputId,~]=  listdlg('PromptString','Convert the input file to coordinate system: ',...
    'SelectionMode','single',...
    'ListString',availableCoorSys(:,1),'ListSize',[500 100]);
if outputId~=length(availableCoorSys)
    toEPSG=availableCoorSys{outputId,2};
elseif outputId==length(availableCoorSys)
    toEPSG=input('Convert the input file to coordinate system of EPSG-code: ');
end

% convert the file
if fromEPSG~=toEPSG
    [~,~,ext]=fileparts(inputFile);
    switch ext
        case '.grd'
            output=wlgrid('read',inputFile);
            [output.X,output.Y]=convertCoordinates(output.X,output.Y,'CS1.code',fromEPSG,'CS2.code',toEPSG);
            wlgrid('write',outputFile,output);
        case {'.ldb','.pli','.pol'}
            output=landboundary('read',inputFile);
            [output(:,1),output(:,2)]=convertCoordinates(output(:,1),output(:,2),'CS1.code',fromEPSG,'CS2.code',toEPSG);
            io_polygon('write',outputFile,output);
        case {'.xyz'}
            output=importdata(inputFile);
            [output(:,1),output(:,2)]=convertCoordinates(output(:,1),output(:,2),'CS1.code',fromEPSG,'CS2.code',toEPSG);
            dlmwrite(outputFile,output,'delimiter',' ','precision','%20.7f');
        case {'.xyn'}
            output=delft3d_io_xyn('read',inputFile);
            [output.x,output.y]=convertCoordinates(output.x,output.y,'CS1.code',fromEPSG,'CS2.code',toEPSG);
            fid=fopen(outputFile,'w');
            for iM=1:length(output.x)
                fprintf(fid,'%20.7f%20.7f ',[output.x(iM) output.y(iM)]);
                fprintf(fid,'%-s\n',output.name{iM});
            end
            fclose(fid);
    end
end
end