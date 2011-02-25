function handles=ddb_readSrcFile(handles,id)

handles.Model(md).Input(id).nrDischarges=0;
handles.Model(md).Input(id).discharges=[];

fid=fopen(handles.Model(md).Input(id).srcFile,'r');

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
        handles.Model(md).Input(id).discharges(nr).name=deblank(tx0(1:20));
        handles.Model(md).Input(id).dischargeNames{nr}=deblank(tx0(1:20));
        handles.Model(md).Input(id).discharges(nr).type='normal';
        handles.Model(md).Input(id).discharges(nr).mOut=0;
        handles.Model(md).Input(id).discharges(nr).nOut=0;
        handles.Model(md).Input(id).discharges(nr).kOut=0;
        v0=strread(tx0(21:end),'%q');
        if strcmpi(v0{1},'y')
            handles.Model(md).Input(id).discharges(nr).interpolation='linear';
        else
            handles.Model(md).Input(id).discharges(nr).interpolation='block';
        end
        handles.Model(md).Input(id).discharges(nr).M=str2double(v0{2});
        handles.Model(md).Input(id).discharges(nr).N=str2double(v0{3});
        handles.Model(md).Input(id).discharges(nr).K=str2double(v0{4});
        if length(v0)>4
            switch lower(v0{5})
                case{'p'}
                    handles.Model(md).Input(id).discharges(nr).type='inout';
                    handles.Model(md).Input(id).discharges(nr).mOut=str2double(v0{6});
                    handles.Model(md).Input(id).discharges(nr).nOut=str2double(v0{7});
                    handles.Model(md).Input(id).discharges(nr).kOut=str2double(v0{8});
                case{'w'}
                    handles.Model(md).Input(id).discharges(nr).type='walking';
            end
        end
    else
        tx0=[];
    end
end

handles.Model(md).Input(id).nrDischarges=nr;

fclose(fid);

