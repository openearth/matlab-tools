function EditSwanConditions

handles=getHandles;

fig0=gcf;

fig=MakeNewWindow('Conditions',[300 200],[handles.SettingsDir '\icons\deltares.gif']);

guidata(findobj('Name','Conditions'),handles);

