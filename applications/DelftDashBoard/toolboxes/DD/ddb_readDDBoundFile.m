function handles=ddb_readDDBoundFile(handles,fname)

ii=strmatch('Delft3DFLOW',{handles.Model.Name},'exact');

txt=ReadTextFile(fname);

nbnd=length(txt)/10;

rids={''};

nd=0;

k=1;
for i=1:nbnd
    handles.Toolbox(tb).Input.DDBoundaries(i).Runid1=txt{k};
    ii=strmatch(txt{k},rids,'exact');
    if isempty(ii)
        nd=nd+1;
        rids{nd}=txt{k};
    end
    handles.Toolbox(tb).Input.DDBoundaries(i).m1a=str2double(txt{k+1});
    handles.Toolbox(tb).Input.DDBoundaries(i).n1a=str2double(txt{k+2});
    handles.Toolbox(tb).Input.DDBoundaries(i).m1b=str2double(txt{k+3});
    handles.Toolbox(tb).Input.DDBoundaries(i).n1b=str2double(txt{k+4});
    handles.Toolbox(tb).Input.DDBoundaries(i).Runid2=txt{k+5};
    ii=strmatch(txt{k+5},rids,'exact');
    if isempty(ii)
        nd=nd+1;
        rids{nd}=txt{k+5};
    end
    handles.Toolbox(tb).Input.DDBoundaries(i).m2a=str2double(txt{k+6});
    handles.Toolbox(tb).Input.DDBoundaries(i).n2a=str2double(txt{k+7});
    handles.Toolbox(tb).Input.DDBoundaries(i).m2b=str2double(txt{k+8});
    handles.Toolbox(tb).Input.DDBoundaries(i).n2b=str2double(txt{k+9});
    k=k+10;
end

for i=1:nd
    handles.Toolbox(tb).Input.Domains{i}=rids{i}(1:end-4);
end

handles.GUIData.NrFlowDomains=nd;
