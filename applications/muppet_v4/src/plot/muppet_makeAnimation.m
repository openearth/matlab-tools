function muppet_makeAnimation(handles,ifig)

animationsettings=handles.animationsettings;

% animationsettings.frameRate=20;
% animationsettings.startTime=datenum(2012,8,17);
% animationsettings.stopTime=datenum(2012,8,18);
% animationsettings.timestep=900;
% animationsettings.avifilename='test.avi';

% Make temporary Data structure
datasets=handles.datasets;

%CombinedDatasetProperties=handles.CombinedDatasetProperties;

% AviOps.fccHandler=animationsettings.fccHandler;
% AviOps.KeyFrames=animationsettings.KeyFrames;
% AviOps.Quality=animationsettings.Quality;
% AviOps.BytesPerSec=animationsettings.BytesPerSec;
% AviOps.Parameters=animationsettings.Parameters;
AviOps=animationsettings.avioptions;

% if animationsettings.makeKMZ
%     handles.figures(ifig).figure.PaperSize(1)=handles.figures(ifig).figure.Axis(1).Position(3);
%     handles.figures(ifig).figure.PaperSize(2)=handles.figures(ifig).figure.Axis(1).Position(4);
%     handles.figures(ifig).figure.BackgroundColor='none';
%     handles.figures(ifig).figure.Axis(1).BackgroundColor='none';
%     handles.figures(ifig).figure.Axis(1).Position(1)=0;
%     handles.figures(ifig).figure.Axis(1).Position(2)=0;
%     handles.figures(ifig).figure.Axis(1).DrawBox=0;
%     handles.figures(ifig).figure.Axis(1).ColorBarPosition=[-100 -100 0.5000 8];
% end
% 
flist=dir('curvecpos*');
if ~isempty(flist)
    delete('curvecpos*');
end

%% Prepare first temporary figure
handles.figures(ifig).figure.units='centimeters';
handles.figures(ifig).figure.cm2pix=1;
handles.figures(ifig).figure.fontReduction=1;

if exist(animationsettings.avifilename,'file')
    delete(animationsettings.avifilename);
end

% Determine frame size
fig=figure('visible','off');
set(fig,'PaperUnits',handles.figures(ifig).figure.units);
set(fig,'PaperSize', [21 29.7]);
set(fig,'PaperPosition',[1.3 1.2 handles.figures(ifig).figure.width handles.figures(ifig).figure.height]);
set(fig,'Renderer',handles.figures(ifig).figure.renderer);
set(fig, 'InvertHardcopy', 'off');

if strcmpi(handles.figures(ifig).figure.orientation(1),'l')
    set(fig,'PaperOrientation','landscape');
end

exportfig (fig,'tmpavi.png','Format','png','FontSize',[1],'color','cmyk','Resolution',handles.figures(ifig).figure.resolution, ...
    'Renderer',handles.figures(ifig).figure.renderer);
close(fig);
a = imread('tmpavi.png');
sz=size(a);
sz(1)=4*floor(sz(1)/4);
sz(2)=4*floor(sz(2)/4);

if exist('tmpavi.png','file')
    delete('tmpavi.png');
end
clear a

if ~isempty(animationsettings.avifilename)
    if ~strcmpi(animationsettings.avifilename(end-2:end),'gif')
        AviHandle = writeavi('initialize');
        AviHandle = writeavi('open', AviHandle,animationsettings.avifilename);
        AviHandle = writeavi('addvideo', AviHandle, animationsettings.frameRate, sz(1),sz(2), 24, AviOps);
    end
end 

wb = awaitbar(0,'Generating AVI...');

try
    % If anything fails, at least close waitbar and animation
    
    hh=[];
    
    nf=0;
    
    % Determine timestep and number of frames
    timestep=animationsettings.timestep/86400;
    
    nrframes=round((animationsettings.stoptime-animationsettings.starttime)/timestep);
    
    for iblock=1:nrframes
       
        % Update time
        t=animationsettings.starttime+(iblock-1)*timestep;
        
        %% Update datasets
        
        % First all regular datasets
        for id=1:length(datasets)
            if ~datasets(id).dataset.combineddataset
                % Check to see if this a time-varying dataset
                if datasets(id).dataset.tc=='t'
                    % First see if available times exactly match current
                    % time
                    iTime=find(abs(datasets(id).dataset.availabletimes-t)<1/864000, 1, 'first');
                    if ~isempty(iTime)
                        % Exact time found
                        datasets(id).dataset.DateTime=datasets(id).dataset.availabletimes(iTime);
                        Data=UpdateDatasets(Data,0,iTime,id);
                    else
                        % Averaging between surrounding times
                        iTime1=find(datasets(id).dataset.availabletimes-1e-4<t,1,'last');
                        Data1=UpdateDatasets(Data,0,iTime1,id);
                        iTime2=find(datasets(id).dataset.availabletimes+1e-4>=t,1,'first');
                        Data2=UpdateDatasets(Data,0,iTime2,id);
                        t1=datasets(id).dataset.availabletimes(iTime1);
                        t2=datasets(id).dataset.availabletimes(iTime2);
                        dt=t2-t1;
                        tFrac2=(t-t1)/dt;
                        tFrac1=1-tFrac2;
                        switch lower(datasets(id).dataset.Type)
                            case{'2dvector'}
                                datasets(id).dataset.u  = tFrac1*Data1(id).u  + tFrac2*Data2(id).u;
                                datasets(id).dataset.v  = tFrac1*Data1(id).v  + tFrac2*Data2(id).v;
                            case{'2dscalar'}
                                datasets(id).dataset.z  = tFrac1*Data1(id).z  + tFrac2*Data2(id).z;
                                datasets(id).dataset.zz = tFrac1*Data1(id).zz + tFrac2*Data2(id).zz;
                        end
                    end
                end
            end
        end
        
        % And now the combined datasets
        for id=1:length(datasets)
            if datasets(id).dataset.combineddataset
                % Check to see if this a time-varying dataset
                if datasets(id).dataset.tc=='t'
                    % Find combined dataset number
                    for j=1:handles.nrcombineddatasets
                        if strcmpi(datasets(id).dataset.name,handles.combineddatasetproperties(j).name)
                            ic=j;
                            break;
                        end
                    end
                    datasets=mp_combineDataset(datasets,combineddatasetproperties,id,ic);
                end
            end
        end
        
        %% Update time bars
        for j=1:handles.figures(ifig).figure.nrsubplots
            for k=1:handles.figures(ifig).figure.subplots(j).subplot.nrdatasets
                if isfield(handles.figures(ifig).figure.subplots(j).subplot.datasets(k).dataset,'timebar')
                    if handles.figures(ifig).figure.subplots(j).subplot.datasets(k).dataset.timebar(1)>0
                        AvailableDate=str2double(datestr(t,'yyyymmdd'));
                        AvailableTime=str2double(datestr(t,'HHMMSS'));
                        handles.figures(ifig).figure.subplots(j).subplot.datasets(k).dataset.timebar=[AvailableDate AvailableTime];
                    end
                end
                if isfield(handles.figures(ifig).figure.subplots(j).subplot.datasets(k).dataset,'markertime')
                    handles.figures(ifig).figure.subplots(j).subplot.datasets(k).dataset.markertime=t;
                end
            end
        end
        handles.datasets=data;
        
        %% Make the figure
        
        % Figure name and format
        str=num2str(iblock+10000);
        figname=[animationsettings.prefix str(2:end) '.png'];
        handles.figures(ifig).figure.filename=figname;
        handles.figures(ifig).figure.format='png';
        
        % And export the figure
        muppet_exportFigure(handles,ifig,'export');
        
        %% Add figure to animation
        
        % No avi file is made if avi filename is empty
        if  ~isempty(animationsettings.avifilename)
            a = imread(figname,'png');
            if ~strcmpi(animationsettings.avifilename(end-2:end),'gif')
                aaa=uint8(a(1:sz(1),1:sz(2),:));
                AviHandle = writeavi('addframe', AviHandle, aaa, iblock);
                clear aaa
            else
                nf = nf+1;
                if nf==1
                    [im,map] = rgb2ind(a,256,'nodither');
                    itransp=find(sum(map,2)==3);
                end
                im(:,:,1,nf) = rgb2ind(a,map,'nodither');
            end
            clear a
        end
        
        %% Delete figure file
        if animationsettings.keepfigures==0 && ~animationsettings.makekmz
            delete(figname);
        end
        
        %% Update waitbar
        str=['Generating AVI - frame ' num2str(iblock) ' of ' ...
            num2str(nrframes) ' ...'];
        [hh,abort2]=awaitbar(iblock/nrframes,wb,str);
        
        if abort2 % Abort the process by clicking abort button
            break;
        end;
        if isempty(hh); % Break the process when closing the figure
            break;
        end;
        
    end
    
    % Close waitbar
    if ~isempty(hh)
        close(wb);
    end
    
    % Close avi file
    if ~isempty(animationsettings.avifilename)
        if ~strcmpi(animationsettings.avifilename(end-2:end),'gif')
            AviHandle=writeavi('close', AviHandle);
        else
            % Try to make animated gif (not very succesful so far)
            %    imwrite(im,map,'test.gif','DelayTime',1/animationsettings.FrameRate,'LoopCount',inf) %g443800
            imwrite(im,map,'test.gif','DelayTime',1/animationsettings.framerate,'LoopCount',inf,'TransparentColor',itransp-1,'DisposalMethod','restoreBG');
        end
    end
    
    % Delete curvec temporary files
    delete('curvecpos.*.dat');
    
    %% KMZ file
    if animationsettings.makekmz
        % File names
        for iblock=1:nrframes
            str=num2str(iblock+10000);
            fignames{iblock}=[animationsettings.prefix str(2:end) '.png'];
            tms(iblock)=animationsettings.starttime+(iblock-1)*timestep;
        end
        dt=timestep;
        % Make colorbar
        if handles.figures(ifig).figure.Axis(1).PlotColorBar;
            makeColorBar(handles,'colorbar.png',[handles.Figure.Axis(1).CMin handles.Figure.Axis(1).CStep handles.Figure.Axis(1).CMax],handles.Figure(1).Axis(1).Plot(1).ColorMap,handles.Figure(1).Axis(1).ColorBarLabel);
        end
        % Bounding box
        csname=handles.figures(ifig).figure.Axis(1).coordinateSystem.name;
        cstype=handles.figures(ifig).figure.Axis(1).coordinateSystem.type;
        if strcmpi(csname,'unknown')
        else
            if ~isfield(handles,'EPSG')
                curdir=[handles.MuppetPath 'settings' filesep 'SuperTrans'];
                handles.EPSG=load([curdir filesep 'data' filesep 'EPSG.mat']);
            end
            [xl1,yl1]=convertCoordinates(handles.figures(ifig).figure.Axis(1).XMin,handles.figures(ifig).figure.Axis(1).YMin,handles.EPSG,'CS1.name',csname,'CS1.type',cstype,'CS2.name','WGS 84','CS2.type','geo');
            [xl2,yl2]=convertCoordinates(handles.figures(ifig).figure.Axis(1).XMax,handles.figures(ifig).figure.Axis(1).YMax,handles.EPSG,'CS1.name',csname,'CS1.type',cstype,'CS2.name','WGS 84','CS2.type','geo');
        end
        fname=[handles.animationsettings.avifilename(1:end-4) '.kml'];
        makeKMZ(fname,xl1,xl2,yl1,yl2,fignames,tms,dt,'colorbar.png');
        delete('colorbar.png');
        % Delete existing figures
        if handles.animationsettings.keepFigures==0
            for ii=1:nf
                delete(fignames{ii});
            end
        end
    end
    
catch
    AviHandle=writeavi('close', AviHandle);
    close(wb);
    muppet_giveWarning('text','Something went wrong while generating avi file');
end
%%
function makeKMZ(fname,xl1,xl2,yl1,yl2,fignames,tms,dt,colorbarfile)

fid=fopen(fname,'wt');
fprintf(fid,'%s\n','<kml xmlns="http://www.opengis.net/kml/2.2">');
fprintf(fid,'%s\n','<Document>');
if handles.figures(ifig).figure.Axis(1).PlotColorBar;
    fprintf(fid,'%s\n','  <ScreenOverlay id="colorbar">');
    fprintf(fid,'%s\n','    <Icon>');
    fprintf(fid,'%s\n','      <href>colorbar.png</href>');
    fprintf(fid,'%s\n','    </Icon>');
    fprintf(fid,'%s\n','    <overlayXY x="1" y="1" xunits="pixels" yunits="pixels"/>');
    fprintf(fid,'%s\n','    <screenXY x="10" y="10" xunits="pixels" yunits="pixels"/>');
    fprintf(fid,'%s\n','    <rotation>0</rotation>');
    fprintf(fid,'%s\n','    <size x="0" y="0" xunits="pixels" yunits="pixels"/>');
    fprintf(fid,'%s\n','  </ScreenOverlay>');
end
fprintf(fid,'%s\n','  <Folder>');
for iblock=1:length(tms)
    fprintf(fid,'%s\n', '    <GroundOverlay>');
    fprintf(fid,'%s\n',['      <name>' fignames{iblock} '</name>']);
    fprintf(fid,'%s\n', '      <TimeSpan>');
    fprintf(fid,'%s\n',['        <begin>' datestr(tms(iblock),'yyyy-mm-ddTHH:MM:SSZ') '</begin>']);
    fprintf(fid,'%s\n',['        <end>' datestr(tms(iblock)+dt+0.0001,'yyyy-mm-ddTHH:MM:SSZ') '</end>']);
    fprintf(fid,'%s\n', '      </TimeSpan>');
    
    fprintf(fid,'%s\n', '      <Icon>');
    fprintf(fid,'%s\n',['        <href>' handles.kmz.figname '</href>']);
    fprintf(fid,'%s\n', '      </Icon>');
    fprintf(fid,'%s\n', '      <LatLonBox>');
    fprintf(fid,'%s\n',['        <north>' num2str(yl2) '</north>']);
    fprintf(fid,'%s\n',['        <south>' num2str(yl1) '</south>']);
    fprintf(fid,'%s\n',['        <east>' num2str(xl2) '</east>']);
    fprintf(fid,'%s\n',['        <west>' num2str(xl1) '</west>']);
    fprintf(fid,'%s\n', '      </LatLonBox>');
    fprintf(fid,'%s\n', '    </GroundOverlay>');
end
fprintf(fid,'%s\n','  </Folder>');
fprintf(fid,'%s\n','</Document>');
fprintf(fid,'%s\n','</kml>');
fclose(fid);

zipfilename=[fname(1:end-4) '.zip'];

nf=length(fignames);
fignames{nf+1}=fname;
if ~isempty(colorbarfile)
    fignames{nf+2}='colorbar.png';
end
zip(zipfilename,fignames);

kmzname=[fname(1:end-4) '.kmz'];

movefile(zipfilename,kmzname);
delete(fname);
if exist(colorbarfile,'file')
    delete(colorbarfile);
end
