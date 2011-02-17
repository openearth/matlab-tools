function handles=ddb_sortBoundaries(handles,id)

nr=handles.Model(md).Input(id).nrOpenBoundaries;

% First 3d-profiles
k=0;
for i=1:nr
    if strcmpi(handles.Model(md).Input(id).openBoundaries(i).profile,'3d-profile')
        k=k+1;
        Bnd(k)=handles.Model(md).Input(id).openBoundaries(i);
    end
end

% Now the rest
for i=1:nr
    if ~strcmpi(handles.Model(md).Input(id).openBoundaries(i).profile,'3d-profile')
        k=k+1;
        Bnd(k)=handles.Model(md).Input(id).openBoundaries(i);
    end
end

handles.Model(md).Input(id).openBoundaries=Bnd;
