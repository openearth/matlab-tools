function ddb_Delft3DFLOW_dryPoints(opt)



ddb_zoomOff;
handles=getHandles;
handles.Mode='a';
setHandles(handles);
set(gcf, 'windowbuttondownfcn',{@DragLine,@addDryPoint,'free'});

%%
function addDryPoint(x,y)

x1=x(1);x2=x(2);
y1=y(1);y2=y(2);

handles=getHandles;
[m1,n1]=FindGridCell(x1,y1,handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
[m2,n2]=FindGridCell(x2,y2,handles.Model(md).Input(ad).GridX,handles.Model(md).Input(ad).GridY);
if m1>0 && (m1==m2 || n1==n2)
    if handles.Mode=='a'
        nrdry=handles.Model(md).Input(ad).NrDryPoints+1;
        handles.Model(md).Input(ad).NrDryPoints=nrdry;
    elseif handles.Mode=='c'
        nrdry=handles.Model(md).Input(ad).activeDryPoint;
    end
    handles.Model(md).Input(ad).DryPoints(nrdry).M1=m1;
    handles.Model(md).Input(ad).DryPoints(nrdry).N1=n1;
    handles.Model(md).Input(ad).DryPoints(nrdry).M2=m2;
    handles.Model(md).Input(ad).DryPoints(nrdry).N2=n2;
    handles.Model(md).Input(ad).DryPoints(nrdry).Name=['(' num2str(m1) ',' num2str(n1) ')...(' num2str(m2) ',' num2str(n2) ')'];
    handles.Model(md).Input(ad).activeDryPoint=nrdry;

    handles.GUIData.DeleteSelectedDryPoint=0;
    setHandles(handles);
    if handles.Mode=='a'
        ddb_plotFlowAttributes(handles,'DryPoints','plot',ad,nrdry,nrdry);
    elseif handles.Mode=='c'
        ddb_plotFlowAttributes(handles,'DryPoints','plot',ad,nrdry,nrdry);
        set(gcf, 'windowbuttondownfcn',   {@SelectDryPoint});
    end
end
setHandles(handles);
