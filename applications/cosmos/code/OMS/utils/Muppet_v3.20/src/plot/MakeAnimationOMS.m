function MakeAnimationOMS(handles,ifig)

AnimationSettings=handles.AnimationSettings;
NrAvailableDatasets=handles.NrAvailableDatasets;
NrCombinedDatasets=handles.NrCombinedDatasets;
Data=handles.DataProperties;
CombinedDatasetProperties=handles.CombinedDatasetProperties;

% AviOps.fccHandler=AnimationSettings.fccHandler;
% AviOps.KeyFrames=AnimationSettings.KeyFrames;
% AviOps.Quality=AnimationSettings.Quality;
% AviOps.BytesPerSec=AnimationSettings.BytesPerSec;
% AviOps.Parameters=AnimationSettings.Parameters;
% 
AvailableTimes=0;

if handles.Figure(ifig).NrAnnotations>0
    NrSub=handles.Figure(ifig).NrSubplots-1;
else
    NrSub=handles.Figure(ifig).NrSubplots;
end

for j=1:NrSub
    for k=1:handles.Figure(ifig).Axis(j).Nr
        m=FindDatasetNr(handles.Figure(ifig).Axis(j).Plot(k).Name,Data);
        if Data(m).TC=='t'
            AvailableTimes=Data(m).AvailableTimes;
%             AvailableMorphTimes=Data(m).AvailableMorphTimes;
        end
    end
end

% handles.Figure(ifig).Units='centimeters';
% handles.Figure(ifig).cm2pix=1;
% handles.Figure(ifig).FontRed=1;

% if exist(AnimationSettings.FileName,'file')
%     delete(AnimationSettings.FileName);
% end
% 
% % Determine frame size
% fig=figure('visible','off');
% set(fig,'PaperUnits',handles.Figure(ifig).Units);
% set(fig,'PaperSize', [21 29.7]);
% set(fig,'PaperPosition',[1.3 1.2 handles.Figure(ifig).PaperSize(1) handles.Figure(ifig).PaperSize(2)]);
% set(fig,'Renderer',handles.Figure(ifig).Renderer);
% set(fig, 'InvertHardcopy', 'off');
% 
% if strcmpi(handles.Figure(ifig).Orientation,'l')
%     set(fig,'PaperOrientation','landscape');
% end
% 
% exportfig (fig,'tmpavi.png','Format','png','FontSize',[1],'color','cmyk','Resolution',handles.Figure(ifig).Resolution, ...
%     'Renderer',handles.Figure(ifig).Renderer);
% close(fig);
% a = imread('tmpavi.png');
% sz=size(a);
% sz(1)=4*floor(sz(1)/4);
% sz(2)=4*floor(sz(2)/4);
% 
% if exist('tmpavi.png','file')
%     delete('tmpavi.png');
% end
% clear a
% 
% if ~strcmpi(AnimationSettings.FileName(end-2:end),'gif')
%     AviHandle = writeavi('initialize');
%     AviHandle = writeavi('open', AviHandle,AnimationSettings.FileName);
%     AviHandle = writeavi('addvideo', AviHandle, AnimationSettings.FrameRate, sz(1),sz(2), 24, AviOps);
% end

% wb = awaitbar(0,'Generating AVI...');

iwb=0;

n2=1;

% nf=0;
% 
% nblocks=length(AnimationSettings.FirstStep:AnimationSettings.Increment:AnimationSettings.LastStep);

for iblock=AnimationSettings.FirstStep:AnimationSettings.Increment:AnimationSettings.LastStep

    % If combined datasets are present, update all dataset (yes, it's slow)

    UpdateAll=0;
    for j=1:NrSub
        for k=1:handles.Figure(ifig).Axis(j).Nr
            m=FindDatasetNr(handles.Figure(ifig).Axis(j).Plot(k).Name,Data);
            if Data(m).CombinedDataset==1
                UpdateAll=1;
            end
            if handles.Figure(ifig).Axis(j).Plot(k).TimeBar(1)>0
%                 if isempty(AvailableMorphTimes)
                    AvailableDate=str2double(datestr(AvailableTimes(iblock),'yyyymmdd'));
                    AvailableTime=str2double(datestr(AvailableTimes(iblock),'HHMMSS'));
%                 else
%                     AvailableDate=str2double(datestr(AvailableMorphTimes(iblock),'yyyymmdd'));
%                     AvailableTime=str2double(datestr(AvailableMorphTimes(iblock),'HHMMSS'));
%                 end
                handles.Figure(ifig).Axis(j).Plot(k).TimeBar=[AvailableDate AvailableTime];
            end
            if strcmpi(handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine,'plotcurvedarrows') || strcmpi(handles.Figure(ifig).Axis(j).Plot(k).PlotRoutine,'plotcoloredcurvedarrows')
                if handles.Figure(ifig).Axis(j).Plot(k).DDtCurVec>0
                    dt=86400*(AvailableTimes(2)-AvailableTimes(1));
                    n2=round(dt/handles.Figure(ifig).Axis(j).Plot(k).DDtCurVec);
                else
                    n2=1;
                end
                if AnimationSettings.LastStep==AnimationSettings.FirstStep
                    n2=handles.Figure(ifig).Axis(j).Plot(k).NoFramesStationaryCurVec;
                end
                n2=max(n2,1);
            end
        end
    end

    DataOri=Data;
    Data1=Data;
    Data2=Data;

    if UpdateAll==0
        % Update datasets
        for j=1:NrSub
            for k=1:handles.Figure(ifig).Axis(j).Nr
                m=FindDatasetNr(handles.Figure(ifig).Axis(j).Plot(k).Name,Data);
                if Data(m).TC=='t'
                    switch lower(Data(m).Type)
                        case{'2dvector'}
                            Data1(m).u=squeeze(Data(m).u(iblock,:,:));
                            Data1(m).v=squeeze(Data(m).v(iblock,:,:));
                        case{'2dscalar'}
                            Data1(m).z=squeeze(Data(m).z(iblock,:,:));
                    end
%                     Data=UpdateDatasets(Data,0,iblock,m);
                    if n2>1
                        if iblock<AnimationSettings.LastStep
                            switch lower(Data(m).Type)
                                case{'2dvector'}
                                    Data2(m).u=squeeze(Data(m).u(iblock+1,:,:));
                                    Data2(m).v=squeeze(Data(m).v(iblock+1,:,:));
                                case{'2dscalar'}
                                    Data2(m).z=squeeze(Data(m).z(iblock+1,:,:));
                            end
%                             Data2=UpdateDatasets(Data2,0,iblock+1,m);
                        end
                    end                    
                end
            end
        end
    else
        % Update all datasets
        nrd=NrAvailableDatasets; % All datasets
        nrc=NrCombinedDatasets;  % Combined datasets
        nrn=nrd-nrc; % 'Normal' datasets
        for m=1:nrn
            if Data(m).TC=='t'
                Data=UpdateDatasets(Data,0,iblock,m);
            end
        end
        for m=1:nrc
            ic=nrn+m;
            Data=Combine(Data,CombinedDatasetProperties,ic,m);
        end
    end

    for ii=1:n2

        iwb=iwb+1;

        % Export figure
        str=num2str(iwb+10000);
        figname=[AnimationSettings.Prefix str(2:end) '.png'];
        
        handles.Figure(ifig).FileName=figname;
        handles.Figure(ifig).Format='png';

        Data3=Data1;
        
        if n2>1
            f1=(n2+1-ii)/n2;
            f2=1-f1;
            for k=1:length(Data3)
                if Data(k).TC=='t'
                    if strcmpi(Data(k).Type,'2dvector')
                        Data3(k).u=f1*Data1(k).u+f2*Data2(k).u;
                        Data3(k).v=f1*Data1(k).v+f2*Data2(k).v;                        
                    end
                    if strcmpi(Data(k).Type,'2dscalar')
                        Data3(k).z=f1*Data1(k).z+f2*Data2(k).z;
                    end
                end
            end
        end

        handles.DataProperties=Data3;
        

        ExportFigure(handles,ifig,'export');

%         a = imread(figname,'png');
% 
%         if ~strcmpi(AnimationSettings.FileName(end-2:end),'gif')
%             aaa=uint8(a(1:sz(1),1:sz(2),:));
%             AviHandle = writeavi('addframe', AviHandle, aaa, iwb);
%         else
%             nf = nf+1;
%             if nf==1
%                 [im,map] = rgb2ind(a,256,'nodither');
%                 itransp=find(sum(map,2)==3);
%             end
%             im(:,:,1,nf) = rgb2ind(a,map,'nodither');
%         end
% 
%         clear a aa

%         if AnimationSettings.KeepFigures==0
%             delete(figname);
%         end

%         str=['Generating AVI - frame ' num2str(iwb) ' of ' ...
%             num2str((n2*nblocks)) ' ...'];
%         [hh,abort2]=awaitbar(iwb/(n2*nblocks),wb,str);
% 
%         if abort2 % Abort the process by clicking abort button
%             break;
%         end;
%         if isempty(hh); % Break the process when closing the figure
%             break;
%         end;

    end

%     if abort2 % Abort the process by clicking abort button
%         break;
%     end;
%     if isempty(hh); % Break the process when closing the figure
%         break;
%     end;

end

% if ~isempty(hh)
%     close(wb);
% end
% 
% if ~strcmpi(AnimationSettings.FileName(end-2:end),'gif')
%     AviHandle = writeavi('close', AviHandle);
% else
% %    imwrite(im,map,'test.gif','DelayTime',1/AnimationSettings.FrameRate,'LoopCount',inf) %g443800
%     imwrite(im,map,'test.gif','DelayTime',1/AnimationSettings.FrameRate,'LoopCount',inf,'TransparentColor',itransp-1,'DisposalMethod','restoreBG');
% end
% 
% if exist('pos1.dat','file')
%     delete('pos1.dat');
% end
