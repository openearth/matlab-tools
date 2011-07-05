function handles=ddb_getDDBoundCoordinates(handles)
%% Computes coordinates of dd boundaries

for i=1:length(handles.Model(md).Input)
    rids{i}=handles.Model(md).Input(i).runid;
end

for idb=1:length(handles.Model(md).DDBoundaries)
    ddbnd=handles.Model(md).DDBoundaries(idb);
    ii=strmatch(ddbnd.runid1,rids,'exact');
    if ddbnd.m1a~=ddbnd.m1b
        k=0;
        if ddbnd.m1a<ddbnd.m1b
            for i=ddbnd.m1a:ddbnd.m1b
                k=k+1;
                handles.Model(md).DDBoundaries(idb).x(k)=handles.Model(md).Input(ii).gridX(i,ddbnd.n1a);
                handles.Model(md).DDBoundaries(idb).y(k)=handles.Model(md).Input(ii).gridY(i,ddbnd.n1a);
            end
        else
            for i=ddbnd.m1b:ddbnd.m1a
                k=k+1;
                handles.Model(md).DDBoundaries(idb).x(k)=handles.Model(md).Input(ii).gridX(i,ddbnd.n1a);
                handles.Model(md).DDBoundaries(idb).y(k)=handles.Model(md).Input(ii).gridY(i,ddbnd.n1a);
            end
        end
    else
        k=0;
        if ddbnd.n1a<ddbnd.n1b
            for i=ddbnd.n1a:ddbnd.n1b
                k=k+1;
                handles.Model(md).DDBoundaries(idb).x(k)=handles.Model(md).Input(ii).gridX(ddbnd.m1a,i);
                handles.Model(md).DDBoundaries(idb).y(k)=handles.Model(md).Input(ii).gridY(ddbnd.m1a,i);
            end
        else
            for i=ddbnd.m1b:ddbnd.m1a
                k=k+1;
                handles.Model(md).DDBoundaries(idb).x(k)=handles.Model(md).Input(ii).gridX(ddbnd.m1a,i);
                handles.Model(md).DDBoundaries(idb).y(k)=handles.Model(md).Input(ii).gridY(ddbnd.m1a,i);
            end
        end
    end
end
