function ddb_selectModelTab(tabname)

handles=getHandles;

handles=ddb_readModelXMLs(handles);

ddb_refreshScreen(tabname);

strucfields{1}='Model';
strucfields{2}='Input';
strucindices={md,1};

handles.GUIHandles.activeUpperTab=tabname;

elements=handles.Model(md).GUI.(tabname).elements;

elements=ddb_addUIElements(elements,strucfields,strucindices,@getHandles,@setHandles);

handles.Model(md).GUI.(tabname).elements=elements;

setHandles(handles);
