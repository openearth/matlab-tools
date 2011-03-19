function handles=ddb_readDDBoundFile(handles,fname)

ii=strmatch('Delft3DFLOW',{handles.Model.Name},'exact');

txt=ReadTextFile(fname);

nbnd=length(txt)/10;

rids={''};

nd=0;

handles.Model(ii).Input.DDBoundaries=[];

k=1;
for i=1:nbnd
    handles.Model(ii).DDBoundaries(i).runid1=txt{k};
    ii=strmatch(txt{k},rids,'exact');
    if isempty(ii)
        nd=nd+1;
        rids{nd}=txt{k};
    end
    handles.Model(ii).DDBoundaries(i).m1a=str2double(txt{k+1});
    handles.Model(ii).DDBoundaries(i).n1a=str2double(txt{k+2});
    handles.Model(ii).DDBoundaries(i).m1b=str2double(txt{k+3});
    handles.Model(ii).DDBoundaries(i).n1b=str2double(txt{k+4});
    handles.Model(ii).DDBoundaries(i).Runid2=txt{k+5};
    ii=strmatch(txt{k+5},rids,'exact');
    if isempty(ii)
        nd=nd+1;
        rids{nd}=txt{k+5};
    end
    handles.Model(ii).DDBoundaries(i).m2a=str2double(txt{k+6});
    handles.Model(ii).DDBoundaries(i).n2a=str2double(txt{k+7});
    handles.Model(ii).DDBoundaries(i).m2b=str2double(txt{k+8});
    handles.Model(ii).DDBoundaries(i).n2b=str2double(txt{k+9});
    k=k+10;
end

handles.Model(ii).nrDomains=nd;

for i=1:nd
    handles.Model(ii).Input(i).runid=rids{i};
end
