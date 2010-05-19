function handles=ddb_sortBoundaries(handles,id)

nr=handles.Model(md).Input(id).NrOpenBoundaries;

% First 3d-profiles
k=0;
for i=1:nr
    if strcmpi(handles.Model(md).Input(id).OpenBoundaries(i).Profile,'3d-profile')
        k=k+1;
        Bnd(k)=handles.Model(md).Input(id).OpenBoundaries(i);
    end
end

% Now the rest
for i=1:nr
    if ~strcmpi(handles.Model(md).Input(id).OpenBoundaries(i).Profile,'3d-profile')
        k=k+1;
        Bnd(k)=handles.Model(md).Input(id).OpenBoundaries(i);
    end
end

handles.Model(md).Input(id).OpenBoundaries=Bnd;
