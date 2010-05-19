function handles=ddb_readSrcFile(handles,id)

handles.Model(md).Input(id).NrDischarges=0;
handles.Model(md).Input(id).Discharges=[];

fid=fopen(handles.Model(md).Input(id).SrcFile,'r');

nr=0;
tx0='a';
while ~isempty(tx0)
    v=fgets(fid);
    if ischar(v)
        tx0=deblank(v);
    else
        tx0=[];
    end
    if and(ischar(tx0), size(tx0>0))
        nr=nr+1;
        handles.Model(md).Input(id).Discharges(nr).Name=deblank(tx0(1:20));
        handles.Model(md).Input(id).Discharges(nr).Type='Normal';
        handles.Model(md).Input(id).Discharges(nr).Mout=0;
        handles.Model(md).Input(id).Discharges(nr).Nout=0;
        handles.Model(md).Input(id).Discharges(nr).Kout=0;
        v0=strread(tx0(21:end),'%q');
        if strcmpi(v0{1},'y')
            handles.Model(md).Input(id).Discharges(nr).Interpolation='linear';
        else
            handles.Model(md).Input(id).Discharges(nr).Interpolation='block';
        end
        handles.Model(md).Input(id).Discharges(nr).M=str2double(v0{2});
        handles.Model(md).Input(id).Discharges(nr).N=str2double(v0{3});
        handles.Model(md).Input(id).Discharges(nr).K=str2double(v0{4});
        if length(v0)>4
            switch lower(v0{5})
                case{'p'}
                    handles.Model(md).Input(id).Discharges(nr).Type='In-out';
                    handles.Model(md).Input(id).Discharges(nr).Mout=str2double(v0{6});
                    handles.Model(md).Input(id).Discharges(nr).Nout=str2double(v0{7});
                    handles.Model(md).Input(id).Discharges(nr).Kout=str2double(v0{8});
                case{'w'}
                    handles.Model(md).Input(id).Discharges(nr).Type='Walking';
            end
        end
    else
        tx0=[];
    end
end

handles.Model(md).Input(id).NrDischarges=nr;

fclose(fid);

