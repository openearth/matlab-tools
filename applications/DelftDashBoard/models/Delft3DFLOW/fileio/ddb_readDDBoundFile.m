function handles=ddb_readDDBoundFile(handles,fname)

txt=ReadTextFile(fname);

nbnd=length(txt)/10;

rids={''};

nd=0;

handles.Model(md).Input.DDBoundaries=[];

k=1;
for i=1:nbnd
    handles.Model(md).DDBoundaries(i).runid1=txt{k}(1:end-4);
    ii=strmatch(txt{k}(1:end-4),rids,'exact');
    if isempty(ii)
        nd=nd+1;
        rids{nd}=txt{k}(1:end-4);
    end
    handles.Model(md).DDBoundaries(i).m1a=str2double(txt{k+1});
    handles.Model(md).DDBoundaries(i).n1a=str2double(txt{k+2});
    handles.Model(md).DDBoundaries(i).m1b=str2double(txt{k+3});
    handles.Model(md).DDBoundaries(i).n1b=str2double(txt{k+4});
    handles.Model(md).DDBoundaries(i).runid2=txt{k+5}(1:end-4);
    ii=strmatch(txt{k+5}(1:end-4),rids,'exact');
    if isempty(ii)
        nd=nd+1;
        rids{nd}=txt{k+5}(1:end-4);
    end
    handles.Model(md).DDBoundaries(i).m2a=str2double(txt{k+6});
    handles.Model(md).DDBoundaries(i).n2a=str2double(txt{k+7});
    handles.Model(md).DDBoundaries(i).m2b=str2double(txt{k+8});
    handles.Model(md).DDBoundaries(i).n2b=str2double(txt{k+9});
    k=k+10;
end

handles.Model(md).nrDomains=nd;

for i=1:nd
    handles.Model(md).Input(i).runid=rids{i};
end
