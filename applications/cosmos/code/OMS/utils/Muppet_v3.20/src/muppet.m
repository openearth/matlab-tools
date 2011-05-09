function muppet(varargin)

% Muppet v3.20
% Compile with: mcc -m -B sgl muppet.m

handles.MuppetVersion='3.20';

%mppath=fileparts(which('muppet'));

% if isdeployed
%     muppetpath=([getenv('D3D_HOME') '\' getenv('ARCH') '\muppet\bin\muppet_mcr\']);
% else
%     muppetpath='';
% end

if nargin==0

    GUI_Muppet('Version',handles.MuppetVersion);

else

    handles.SessionName=varargin{1};
    mpt=figure('Visible','off','Position',[0 0 0.2 0.2]);
    set(mpt,'Name','Muppet','NumberTitle','off');
    
    handles=ReadDefaults(handles);
    handles.ColorMaps=ImportColorMaps;
    handles.DefaultColors=ReadDefaultColors;
    handles.Frames=ReadFrames;

    %% Read session file
    handles=ReadSessionFile(handles,handles.SessionName);

    %% Import datasets
    handles.DataProperties=ImportDatasets(handles.DataProperties,handles.NrAvailableDatasets);

    %% Combine datasets
    [handles.DataProperties,handles.NrAvailableDatasets,handles.CombinedDatasetProperties]=CombineDatasets(handles.DataProperties, ...
        handles.NrAvailableDatasets,handles.CombinedDatasetProperties,handles.NrCombinedDatasets);

    guidata(mpt,handles);

    if nargin==1
        % Make figure
        for ifig=1:handles.NrFigures
            ExportFigure(handles,ifig,'export');
        end
    else

        % Make animation
        AnimationSettings=ReadAnimationSettings(varargin{2});
        MakeAnimation(FigureProperties,SubplotProperties,PlotOptions,DataProperties,CombinedDatasetProperties, ...
            ColorMaps,DefaultColors,Frames,AnimationSettings,NrAvailableDatasets,NrCombinedDatasets,1);

    end

    close(findobj('Name','Muppet'));

end

