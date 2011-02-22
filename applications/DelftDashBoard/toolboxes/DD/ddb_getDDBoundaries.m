function [handles,ok]=ddb_getDDBoundaries(handles,id1,id2,runid1,runid2)


ok=0;

% DD Boundaries
x1=handles.Model(md).Input(id1).gridX;
y1=handles.Model(md).Input(id1).gridY;
x2=handles.Model(md).Input(id2).gridX;
y2=handles.Model(md).Input(id2).gridY;

ddb=ddb_makeDDModelBoundaries(x1,y1,x2,y2,runid1,runid2);

if ~isempty(ddb)
    ok=1;
end

ndb=length(handles.Toolbox(tb).Input.DDBoundaries);
for k=1:length(ddb)
    handles.Toolbox(tb).Input.DDBoundaries(ndb+k).runid1=ddb(k).runid1;
    handles.Toolbox(tb).Input.DDBoundaries(ndb+k).runid2=ddb(k).runid2;
    handles.Toolbox(tb).Input.DDBoundaries(ndb+k).m1a=ddb(k).m1a;
    handles.Toolbox(tb).Input.DDBoundaries(ndb+k).m1b=ddb(k).m1b;
    handles.Toolbox(tb).Input.DDBoundaries(ndb+k).n1a=ddb(k).n1a;
    handles.Toolbox(tb).Input.DDBoundaries(ndb+k).n1b=ddb(k).n1b;
    handles.Toolbox(tb).Input.DDBoundaries(ndb+k).m2a=ddb(k).m2a;
    handles.Toolbox(tb).Input.DDBoundaries(ndb+k).m2b=ddb(k).m2b;
    handles.Toolbox(tb).Input.DDBoundaries(ndb+k).n2a=ddb(k).n2a;
    handles.Toolbox(tb).Input.DDBoundaries(ndb+k).n2b=ddb(k).n2b;
end

ddb_saveDDBoundFile(handles.Toolbox(tb).Input.DDBoundaries,'ddbound');
