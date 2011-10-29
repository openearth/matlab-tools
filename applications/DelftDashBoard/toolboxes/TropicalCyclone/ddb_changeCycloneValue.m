function [handles,ok]=ddb_changeCycloneValue(varargin)
% DDB - Call GUI to change values in cyclone track file for individual
% points. Called when right-clicking on cyclone track.
if ~ischar(varargin{1})
    % Make new GUI
    handles=varargin{1};
    xmldir=handles.Toolbox(tb).xmlDir;
%    xmlfile='TropicalCyclone.InitialTrackParameters.xml';
    xmlfile='TropicalCyclone.PointTrackParameters.xml';
    [handles,ok]=newGUI(xmldir,xmlfile,handles);
else
    opt=lower(varargin{1});    
    switch opt
        case{'pushok'}
            handles=getTempHandles;
            handles.ok=1;
            setTempHandles(handles);
            close(gcf);
        case{'pushcancel'}
            handles=getTempHandles;
            handles.ok=0;
            setTempHandles(handles);
            close(gcf);
    end    
end
