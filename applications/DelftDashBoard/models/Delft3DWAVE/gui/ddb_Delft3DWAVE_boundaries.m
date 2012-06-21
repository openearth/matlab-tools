function ddb_Delft3DWAVE_boundaries(varargin)

if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'add'}
            addBoundary;
    end
end

%%
function addBoundary

handles=getHandles;
nr=handles.Model(md).Input.nrBoundaries;
nr=nr+1;
handles=ddb_initializeDelft3DWAVEBoundary(handles,md,ad,nr);
handles.Model(md).Input.boundaries(nr).name=['Boundary ' num2str(nr)];
handles.Model(md).Input.boundaryNames{nr}=['Boundary ' num2str(nr)];
handles.Model(md).Input.nrBoundaries=nr;
handles.Model(md).Input.activeBoundary=nr;
setHandles(handles);

function PushDelete_CallBack(hObject,eventdata)
handles=getHandles;
id = find([1:size(handles.Model(md).Input.Boundaries,2)]~=handles.Model(md).Input.BoundariesIval);
if size(id,2)> 0
    handles.Model(md).Input.Boundaries=handles.Model(md).Input.Boundaries(id);
    handles.Model(md).Input.BndName=handles.Model(md).Input.BndName(id);
    handles.Model(md).Input.BndDefbyval=handles.Model(md).Input.BndDefbyval(id);
    handles.Model(md).Input.BndOrientval=handles.Model(md).Input.BndOrientval(id);
    handles.Model(md).Input.BndStart1=handles.Model(md).Input.BndStart1(id);
    handles.Model(md).Input.BndStart2=handles.Model(md).Input.BndStart2(id);
    handles.Model(md).Input.BndEnd1=handles.Model(md).Input.BndEnd1(id);
    handles.Model(md).Input.BndEnd2=handles.Model(md).Input.BndEnd2(id);
    handles.Model(md).Input.Uniform=handles.Model(md).Input.Uniform(id);
    handles.Model(md).Input.Spacevarying=handles.Model(md).Input.Spacevarying(id);
    handles.Model(md).Input.Parametric=handles.Model(md).Input.Parametric(id);
    handles.Model(md).Input.FromFile=handles.Model(md).Input.FromFile(id);
    handles.Model(md).Input.Hs=handles.Model(md).Input.Hs(id);
    handles.Model(md).Input.Tp=handles.Model(md).Input.Tp(id);
    handles.Model(md).Input.Dir=handles.Model(md).Input.Dir(id);
    handles.Model(md).Input.Spread=handles.Model(md).Input.Spread(id);
    handles.Model(md).Input.SpacevaryingParam=handles.Model(md).Input.SpacevaryingParam(id);
    handles.Model(md).Input.BndFile=handles.Model(md).Input.BndFile(id);
    handles.Model(md).Input.Jonswapval=handles.Model(md).Input.Jonswapval(id);
    handles.Model(md).Input.Gaussval=handles.Model(md).Input.Gaussval(id);
    handles.Model(md).Input.Jonswap=handles.Model(md).Input.Jonswap(id);
    handles.Model(md).Input.Pierson=handles.Model(md).Input.Pierson(id);
    handles.Model(md).Input.Gauss=handles.Model(md).Input.Gauss(id);
    handles.Model(md).Input.Peak=handles.Model(md).Input.Peak(id);
    handles.Model(md).Input.Mean=handles.Model(md).Input.Mean(id);
    handles.Model(md).Input.Cosine=handles.Model(md).Input.Cosine(id);
    handles.Model(md).Input.Degrees=handles.Model(md).Input.Degrees(id);
    handles.Model(md).Input.BoundariesIval=1;
else
    handles.Model(md).Input.Boundaries='';
    handles.Model(md).Input.BndName='';
    handles.Model(md).Input.BndDefbyval='';
    handles.Model(md).Input.BndOrientval='';
    handles.Model(md).Input.BndStart1='';
    handles.Model(md).Input.BndStart2='';
    handles.Model(md).Input.BndEnd1='';
    handles.Model(md).Input.BndEnd2='';
    handles.Model(md).Input.Uniform='';
    handles.Model(md).Input.Spacevarying='';
    handles.Model(md).Input.Parametric='';
    handles.Model(md).Input.FromFile='';
    handles.Model(md).Input.Hs='';
    handles.Model(md).Input.Tp='';
    handles.Model(md).Input.Dir='';
    handles.Model(md).Input.Spread='';
    handles.Model(md).Input.SpacevaryingParam(1).Sections='';
    handles.Model(md).Input.SpacevaryingParam(1).Dist='';
    handles.Model(md).Input.SpacevaryingParam(1).Hs='';
    handles.Model(md).Input.SpacevaryingParam(1).Tp='';
    handles.Model(md).Input.SpacevaryingParam(1).Dir='';
    handles.Model(md).Input.SpacevaryingParam(1).Spread='';
    handles.Model(md).Input.SpacevaryingParam(1).Clock='';
    handles.Model(md).Input.SpacevaryingParam(1).CounterClock='';
    handles.Model(md).Input.SpacevaryingParam(1).BndFile='';     
    handles.Model(md).Input.BndFile='';
    handles.Model(md).Input.Jonswapval='';
    handles.Model(md).Input.Gaussval='';
    handles.Model(md).Input.Jonswap='';
    handles.Model(md).Input.Pierson='';
    handles.Model(md).Input.Gauss='';
    handles.Model(md).Input.Peak='';
    handles.Model(md).Input.Mean='';
    handles.Model(md).Input.Cosine='';
    handles.Model(md).Input.Degrees='';    
    handles.Model(md).Input.BoundariesIval=''; 
end
setHandles(handles);
Refresh(handles);

function EditBndName_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.BndNameTemp=get(hObject,'String');
setHandles(handles);

function EditBndDefby_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.BndDefbyTemp=get(hObject,'value');
if get(hObject,'value')==1
    set(handles.GUIHandles.EditBndOrient,'Enable','on');
    set(handles.GUIHandles.EditBndStart1,'Enable','off');
    set(handles.GUIHandles.EditBndStart2,'Enable','off');
    set(handles.GUIHandles.EditBndEnd1,'Enable','off');
    set(handles.GUIHandles.EditBndEnd2,'Enable','off');
else    
    set(handles.GUIHandles.EditBndOrient,'Enable','off');
    set(handles.GUIHandles.EditBndStart1,'Enable','on');
    set(handles.GUIHandles.EditBndStart2,'Enable','on');
    set(handles.GUIHandles.EditBndEnd1,'Enable','on');
    set(handles.GUIHandles.EditBndEnd2,'Enable','on');
end
setHandles(handles);

function EditBndOrient_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.BndOrientTemp=get(hObject,'value');
setHandles(handles);

function EditBndStart1_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.BndStart1Temp=get(hObject,'value');
setHandles(handles);

function EditBndStart2_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.BndStart2Temp=get(hObject,'value');
setHandles(handles);

function EditBndEnd1_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.BndEnd1Temp=get(hObject,'value');
setHandles(handles);

function EditBndEnd2_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.BndEnd2Temp=get(hObject,'value');
setHandles(handles);

function ToggleUniform_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.UniformTemp=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleUniform,'Value',1);
    set(handles.GUIHandles.ToggleSpacevarying,'Value',0);
    set(handles.GUIHandles.PushEditConditions,'Enable','on');
    if handles.Model(md).Input.FromFileTemp==0
        set(handles.GUIHandles.PushEditSpectralSpace,'Enable','on');
    else
        set(handles.GUIHandles.PushEditSpectralSpace,'Enable','off');
    end
    handles.Model(md).Input.SpacevaryingTemp=0;
end
setHandles(handles);

function ToggleSpacevarying_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.SpacevaryingTemp=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleUniform,'Value',0);
    set(handles.GUIHandles.ToggleSpacevarying,'Value',1);
    set(handles.GUIHandles.PushEditConditions,'Enable','on');
    if handles.Model(md).Input.FromFileTemp==0
        set(handles.GUIHandles.PushEditSpectralSpace,'Enable','on');
    else
        set(handles.GUIHandles.PushEditSpectralSpace,'Enable','off');
    end
    handles.Model(md).Input.UniformTemp=0;
end
setHandles(handles);

function ToggleParametric_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.ParametricTemp=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleParametric,'Value',1);
    set(handles.GUIHandles.ToggleFromFile,'Value',0);
    set(handles.GUIHandles.PushEditConditions,'Enable','on');
    set(handles.GUIHandles.PushEditSpectralSpace,'Enable','on');
    handles.Model(md).Input.FromFileTemp=0;
end
setHandles(handles);

function ToggleFromFile_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.FromFileTemp=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.GUIHandles.ToggleParametric,'Value',0);
    set(handles.GUIHandles.ToggleFromFile,'Value',1);
    set(handles.GUIHandles.PushEditConditions,'Enable','on');
    set(handles.GUIHandles.PushEditSpectralSpace,'Enable','off');
    handles.Model(md).Input.ParametricTemp=0;
end
setHandles(handles);

function PushEditConditions_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.UniformTemp=get(handles.GUIHandles.ToggleUniform,'Value');
handles.Model(md).Input.ParametricTemp=get(handles.GUIHandles.ToggleParametric,'Value');
set(handles.GUIHandles.PushEditSpectralSpace,'Enable','on');
if ~isempty(handles.Model(md).Input.BoundariesIval)
    id=handles.Model(md).Input.BoundariesIval;
    if handles.Model(md).Input.UniformTemp==1
        try
            if handles.Model(md).Input.ParametricTemp==0
                handles.Model(md).Input.BndFileTemp=cell2mat(handles.Model(md).Input.BndFile{id});
            else
                handles.Model(md).Input.HsTemp=cell2mat(handles.Model(md).Input.Hs{id});
                handles.Model(md).Input.TpTemp=cell2mat(handles.Model(md).Input.Tp{id});
                handles.Model(md).Input.DirTemp=cell2mat(handles.Model(md).Input.Dir{id});
                handles.Model(md).Input.SpreadTemp=cell2mat(handles.Model(md).Input.Spread{id});
            end
        end
    else
        try
            handles.Model(md).Input.Sections=handles.Model(md).Input.SpacevaryingParam(id).Sections;
            handles.Model(md).Input.ClockTemp=cell2mat(handles.Model(md).Input.SpacevaryingParam(id).Clock{1}{1,1});
            handles.Model(md).Input.CounterClockTemp=cell2mat(handles.Model(md).Input.SpacevaryingParam(id).CounterClock{1}{1,1});
            isec = size(handles.Model(md).Input.Sections,2);
            for kk=1:isec;
                handles.Model(md).Input.SecClock{kk}=handles.Model(md).Input.SpacevaryingParam(id).Clock{kk}{1,1};
                handles.Model(md).Input.SecCounterClock{kk}=handles.Model(md).Input.SpacevaryingParam(id).CounterClock{kk}{1,1};
            end
            if handles.Model(md).Input.ParametricTemp==0
                handles.Model(md).Input.BndFileTemp=cell2mat(handles.Model(md).Input.SpacevaryingParam(id).BndFile{1}{1,1});
                for kk=1:isec;
                    handles.Model(md).Input.SecFile{kk}=handles.Model(md).Input.SpacevaryingParam(id).BndFile{kk}{1,1};
                end
            else
                handles.Model(md).Input.DistTemp=cell2mat(handles.Model(md).Input.SpacevaryingParam(id).Dist{1}{1,1});
                handles.Model(md).Input.HsTemp=cell2mat(handles.Model(md).Input.SpacevaryingParam(id).Hs{1}{1,1});
                handles.Model(md).Input.TpTemp=cell2mat(handles.Model(md).Input.SpacevaryingParam(id).Tp{1}{1,1});
                handles.Model(md).Input.DirTemp=cell2mat(handles.Model(md).Input.SpacevaryingParam(id).Dir{1}{1,1});
                handles.Model(md).Input.SpreadTemp=cell2mat(handles.Model(md).Input.SpacevaryingParam(id).Spread{1}{1,1});                
                for kk=1:isec;
                    handles.Model(md).Input.SecDist{kk}=handles.Model(md).Input.SpacevaryingParam(id).Dist{kk}{1,1};
                    handles.Model(md).Input.SecHs{kk}=handles.Model(md).Input.SpacevaryingParam(id).Hs{kk}{1,1};
                    handles.Model(md).Input.SecTp{kk}=handles.Model(md).Input.SpacevaryingParam(id).Tp{kk}{1,1};
                    handles.Model(md).Input.SecDir{kk}=handles.Model(md).Input.SpacevaryingParam(id).Dir{kk}{1,1};
                    handles.Model(md).Input.SecSpread{kk}=handles.Model(md).Input.SpacevaryingParam(id).Spread{kk}{1,1};
                end
            end
        end
    end
end
setHandles(handles);
ddb_editDelft3DWAVEConditions;
setHandles(handles);

function PushEditSpectralSpace_CallBack(hObject,eventdata)
handles=getHandles;
if ~isempty(handles.Model(md).Input.BoundariesIval)
    id=handles.Model(md).Input.BoundariesIval;
    try
        handles.Model(md).Input.JonswapvalTemp=handles.Model(md).Input.Jonswapval{id}{1,1};
        handles.Model(md).Input.GaussvalTemp=handles.Model(md).Input.Gaussval{id}{1,1};
        handles.Model(md).Input.JonswapTemp=handles.Model(md).Input.Jonswap{id}{1,1};
        handles.Model(md).Input.PiersonTemp=handles.Model(md).Input.Pierson{id}{1,1};
        handles.Model(md).Input.GaussTemp=handles.Model(md).Input.Gauss{id}{1,1};
        handles.Model(md).Input.PeakTemp=handles.Model(md).Input.Peak{id}{1,1};
        handles.Model(md).Input.MeanTemp=handles.Model(md).Input.Mean{id}{1,1};
        handles.Model(md).Input.CosineTemp=handles.Model(md).Input.Cosine{id}{1,1};
        handles.Model(md).Input.DegreesTemp=handles.Model(md).Input.Degrees{id}{1,1};
    end
end
setHandles(handles);
ddb_editDelft3DWAVESpectralSpace;
setHandles(handles);

%%
function Refresh(handles)
handles=getHandles;
if ~isempty(handles.Model(md).Input.BoundariesIval)
    id = handles.Model(md).Input.BoundariesIval;
    set(handles.GUIHandles.EditBoundaries,'String',[handles.Model(md).Input.Boundaries{:}]');
    set(handles.GUIHandles.EditBoundaries,'Value',handles.Model(md).Input.BoundariesIval);
    set(handles.GUIHandles.EditBndName,'String',handles.Model(md).Input.BndName{id});
    set(handles.GUIHandles.EditBndDefby,'String',handles.Model(md).Input.BndDefby);
    set(handles.GUIHandles.EditBndDefby,'Value',cell2mat(handles.Model(md).Input.BndDefbyval{id}));
    set(handles.GUIHandles.PushDelete,'Enable','on');
    if cell2mat(handles.Model(md).Input.BndDefbyval{id})==1
        set(handles.GUIHandles.EditBndOrient,'Enable','on');
        set(handles.GUIHandles.EditBndStart1,'Enable','off');
        set(handles.GUIHandles.EditBndStart2,'Enable','off');
        set(handles.GUIHandles.EditBndEnd1,'Enable','off');
        set(handles.GUIHandles.EditBndEnd2,'Enable','off');
    else
        set(handles.GUIHandles.EditBndOrient,'Enable','off');
        set(handles.GUIHandles.EditBndStart1,'Enable','on');
        set(handles.GUIHandles.EditBndStart2,'Enable','on');
        set(handles.GUIHandles.EditBndEnd1,'Enable','on');
        set(handles.GUIHandles.EditBndEnd2,'Enable','on');
    end
    set(handles.GUIHandles.EditBndOrient,'String',handles.Model(md).Input.BndOrient);
    set(handles.GUIHandles.EditBndOrient,'Value',cell2mat(handles.Model(md).Input.BndOrientval{id}));
    set(handles.GUIHandles.EditBndStart1,'Value',cell2mat(handles.Model(md).Input.BndStart1{id}));
    set(handles.GUIHandles.EditBndStart2,'Value',cell2mat(handles.Model(md).Input.BndStart2{id}));
    set(handles.GUIHandles.EditBndEnd1,'Value',cell2mat(handles.Model(md).Input.BndEnd1{id}));
    set(handles.GUIHandles.EditBndEnd2,'Value',cell2mat(handles.Model(md).Input.BndEnd2{id}));
    set(handles.GUIHandles.ToggleUniform,'Value',cell2mat(handles.Model(md).Input.Uniform{id}));
    set(handles.GUIHandles.ToggleSpacevarying,'value',cell2mat(handles.Model(md).Input.Spacevarying{id}));
    set(handles.GUIHandles.ToggleParametric,'value',cell2mat(handles.Model(md).Input.Parametric{id}));
    set(handles.GUIHandles.ToggleFromFile,'value',cell2mat(handles.Model(md).Input.FromFile{id})); 
    if cell2mat(handles.Model(md).Input.FromFile{id}) == 1
        set(handles.GUIHandles.PushEditSpectralSpace,'Enable','off');
    else
        set(handles.GUIHandles.PushEditSpectralSpace,'Enable','on');
    end
else
    set(handles.GUIHandles.EditBoundaries,'String','');
    set(handles.GUIHandles.EditBndName,'String','');
    set(handles.GUIHandles.EditBndDefby,'String',handles.Model(md).Input.BndDefby);
    set(handles.GUIHandles.EditBndOrient,'String',handles.Model(md).Input.BndOrient);
    set(handles.GUIHandles.EditBndStart1,'String','');
    set(handles.GUIHandles.EditBndStart2,'String','');
    set(handles.GUIHandles.EditBndEnd1,'String','');
    set(handles.GUIHandles.EditBndEnd2,'String','');
    set(handles.GUIHandles.EditBndOrient,'Enable','on');
    set(handles.GUIHandles.EditBndStart1,'Enable','off');
    set(handles.GUIHandles.EditBndStart2,'Enable','off');
    set(handles.GUIHandles.EditBndEnd1,'Enable','off');
    set(handles.GUIHandles.EditBndEnd2,'Enable','off');
    set(handles.GUIHandles.ToggleUniform,'Value',1);
    set(handles.GUIHandles.ToggleSpacevarying,'value',0);
    set(handles.GUIHandles.ToggleParametric,'value',1);
    set(handles.GUIHandles.ToggleFromFile,'value',0);
    set(handles.GUIHandles.PushEditConditions,'Enable','on');
    set(handles.GUIHandles.PushEditSpectralSpace,'Enable','on');
end
setHandles(handles);
%}