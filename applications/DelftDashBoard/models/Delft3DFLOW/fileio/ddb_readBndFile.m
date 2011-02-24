function handles=ddb_readBndFile(handles)

fid=fopen(handles.Model(md).Input(ad).bndFile);

handles.Model(md).Input(ad).nrOpenBoundaries=0;
handles.Model(md).Input(ad).openBoundaries=[];

for i=1:1000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        handles.Model(md).Input(ad).nrOpenBoundaries=handles.Model(md).Input(ad).nrOpenBoundaries+1;
        n=handles.Model(md).Input(ad).nrOpenBoundaries;
        v=strread(tx0(22:end),'%q');
        handles.Model(md).Input(ad).openBoundaries(n).M1=str2double(v{3});
        handles.Model(md).Input(ad).openBoundaries(n).N1=str2double(v{4});
        handles.Model(md).Input(ad).openBoundaries(n).M2=str2double(v{5});
        handles.Model(md).Input(ad).openBoundaries(n).N2=str2double(v{6});
        handles=ddb_initializeBoundary(handles,n);
        handles.Model(md).Input(ad).openBoundaries(n).name=deblank(tx0(1:21));
        handles.Model(md).Input(ad).openBoundaries(n).type=v{1};
        handles.Model(md).Input(ad).openBoundaries(n).forcing=v{2};
        handles.Model(md).Input(ad).openBoundaries(n).alpha=str2double(v{7});
        ii=8;
        switch handles.Model(md).Input(ad).openBoundaries(n).type
            case{'C','Q','T','R'}
                handles.Model(md).Input(ad).openBoundaries(n).profile=v{8};
                ii=9;
            otherwise
                handles.Model(md).Input(ad).openBoundaries(n).profile='Uniform';
        end
        switch handles.Model(md).Input(ad).openBoundaries(n).forcing
            case{'A'}
                handles.Model(md).Input(ad).openBoundaries(n).compA=v{ii};
                handles.Model(md).Input(ad).openBoundaries(n).compB=v{ii+1};
        end
        handles.Model(md).Input(ad).openBoundaryNames{n}=handles.Model(md).Input(ad).openBoundaries(n).name;
    end
end

fclose(fid);

handles=ddb_countOpenBoundaries(handles,ad);

