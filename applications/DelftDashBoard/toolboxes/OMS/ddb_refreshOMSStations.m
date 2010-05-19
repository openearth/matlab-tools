function ddb_refreshOMSStations(handles)

iac=handles.Toolbox(tb).ActiveStation;

omsparameters={'hs','tp','wavdir','wl'};

set(handles.GUIHandles.ListOMSStations,'Value',iac);

if handles.Toolbox(tb).NrStations==0
    for i=1:length(omsparameters)
        set(handles.GUIHandles.PlotCmp(i),'Value',0,'Enable','off');
        set(handles.GUIHandles.PlotObs(i),'Value',0,'Enable','off');
        set(handles.GUIHandles.PlotPrd(i),'Value',0,'Enable','off');
        set(handles.GUIHandles.ObsSrc(i),  'String','','Enable','off','BackgroundColor',[0.8 0.8 0.8]);
        set(handles.GUIHandles.ObsID(i),  'String','','Enable','off','BackgroundColor',[0.8 0.8 0.8]);
        set(handles.GUIHandles.PrdSrc(i),  'String','','Enable','off','BackgroundColor',[0.8 0.8 0.8]);
        set(handles.GUIHandles.PrdID(i),  'String','','Enable','off','BackgroundColor',[0.8 0.8 0.8]);
    end
    set(handles.GUIHandles.StoreSP2,'Value',0,'Enable','off');
    set(handles.GUIHandles.SP2id,'String','','BackgroundColor',[0.8 0.8 0.8],'Enable','off');
    set(handles.GUIHandles.SelectType,'BackgroundColor',[0.8 0.8 0.8],'Enable','off');
end

if handles.Toolbox(tb).NrStations>0
    for i=1:length(omsparameters)
        set(handles.GUIHandles.PlotCmp(i),'Value',handles.Toolbox(tb).Stations(iac).Parameters(i).PlotCmp,'Enable','on');
        set(handles.GUIHandles.PlotObs(i),'Value',handles.Toolbox(tb).Stations(iac).Parameters(i).PlotObs,'Enable','on');
        set(handles.GUIHandles.PlotPrd(i),'Value',handles.Toolbox(tb).Stations(iac).Parameters(i).PlotPrd,'Enable','on');
        if handles.Toolbox(tb).Stations(iac).Parameters(i).PlotObs
            set(handles.GUIHandles.ObsSrc(i),'String',handles.Toolbox(tb).Stations(iac).Parameters(i).ObsSrc,'Enable','on','BackgroundColor',[1 1 1]);
            set(handles.GUIHandles.ObsID(i), 'String',handles.Toolbox(tb).Stations(iac).Parameters(i).ObsID, 'Enable','on','BackgroundColor',[1 1 1]);
        else
            set(handles.GUIHandles.ObsSrc(i),'String','','BackgroundColor',[0.8 0.8 0.8],'Enable','off');
            set(handles.GUIHandles.ObsID(i), 'String','', 'BackgroundColor',[0.8 0.8 0.8],'Enable','off');
        end
        if handles.Toolbox(tb).Stations(iac).Parameters(i).PlotPrd
            set(handles.GUIHandles.PrdSrc(i),'String',handles.Toolbox(tb).Stations(iac).Parameters(i).PrdSrc,'Enable','on','BackgroundColor',[1 1 1]);
            set(handles.GUIHandles.PrdID(i), 'String',handles.Toolbox(tb).Stations(iac).Parameters(i).PrdID, 'Enable','on','BackgroundColor',[1 1 1]);
        else
            set(handles.GUIHandles.PrdSrc(i),'String','','BackgroundColor',[0.8 0.8 0.8],'Enable','off');
            set(handles.GUIHandles.PrdID(i), 'String','', 'BackgroundColor',[0.8 0.8 0.8],'Enable','off');
        end
    end

    set(handles.GUIHandles.StoreSP2,'Value',handles.Toolbox(tb).Stations(iac).StoreSP2,'Enable','on');
    set(handles.GUIHandles.SP2id,'String',handles.Toolbox(tb).Stations(iac).SP2id);
    if handles.Toolbox(tb).Stations(iac).StoreSP2
        set(handles.GUIHandles.SP2id,'BackgroundColor',[1 1 1],'Enable','on');
    else
        set(handles.GUIHandles.SP2id,'BackgroundColor',[0.8 0.8 0.8],'Enable','off');
    end

    str=get(handles.GUIHandles.SelectType,'String');
    ii=strmatch(handles.Toolbox(tb).Stations(iac).Type,str,'exact');
    set(handles.GUIHandles.SelectType,'Value',ii,'BackgroundColor',[1 1 1],'Enable','on');

end


