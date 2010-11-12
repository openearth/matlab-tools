function handles=ddb_readBndFile(handles)

fid=fopen(handles.Model(md).Input(ad).BndFile);

handles.Model(md).Input(ad).NrOpenBoundaries=0;
handles.Model(md).Input(ad).OpenBoundaries=[];

for i=1:1000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        handles.Model(md).Input(ad).NrOpenBoundaries=handles.Model(md).Input(ad).NrOpenBoundaries+1;
        n=handles.Model(md).Input(ad).NrOpenBoundaries;
        v=strread(tx0(22:end),'%q');
        handles.Model(md).Input(ad).OpenBoundaries(n).M1=str2double(v{3});
        handles.Model(md).Input(ad).OpenBoundaries(n).N1=str2double(v{4});
        handles.Model(md).Input(ad).OpenBoundaries(n).M2=str2double(v{5});
        handles.Model(md).Input(ad).OpenBoundaries(n).N2=str2double(v{6});
        handles=ddb_initializeBoundary(handles,n);
        handles.Model(md).Input(ad).OpenBoundaries(n).Name=deblank(tx0(1:21));
        handles.Model(md).Input(ad).OpenBoundaries(n).Type=v{1};
        handles.Model(md).Input(ad).OpenBoundaries(n).Forcing=v{2};
        handles.Model(md).Input(ad).OpenBoundaries(n).Alpha=str2double(v{7});
        ii=8;
        switch handles.Model(md).Input(ad).OpenBoundaries(n).Type,
            case{'C','Q','T','R'}
                handles.Model(md).Input(ad).OpenBoundaries(n).Profile=v{8};
                ii=9;
            otherwise
                handles.Model(md).Input(ad).OpenBoundaries(n).Profile='Uniform';
        end
        switch handles.Model(md).Input(ad).OpenBoundaries(n).Forcing,
            case{'A'}
                handles.Model(md).Input(ad).OpenBoundaries(n).CompA=v{ii};
                handles.Model(md).Input(ad).OpenBoundaries(n).CompB=v{ii+1};
        end
    end
end

fclose(fid);

handles=ddb_countOpenBoundaries(handles,ad);

