function ddb_saveSrcFile(handles,id)

fid=fopen(handles.Model(md).Input(id).srcFile,'w');

nr=handles.Model(md).Input(id).nrDischarges;

for i=1:nr

    name=deblank(handles.Model(md).Input(id).discharges(i).name);
    if strcmpi(handles.Model(md).Input(id).discharges(i).interpolation,'linear')
        cinterp='Y';
    else
        cinterp='N';
    end

    m=num2str(handles.Model(md).Input(id).discharges(i).M);
    n=num2str(handles.Model(md).Input(id).discharges(i).N);
    k=num2str(handles.Model(md).Input(id).discharges(i).K);

    m=[repmat(' ',1,4-length(m)) m];
    n=[repmat(' ',1,4-length(n)) n];
    k=[repmat(' ',1,4-length(k)) k];
    
    ctype='';
    cmout='';
    cnout='';
    ckout='';

    switch lower(handles.Model(md).Input(id).discharges(i).type)
        case{'walking'}
            ctype=' W';
        case{'inout'}
            ctype=' P';
            cmout=num2str(handles.Model(md).Input(id).discharges(i).mOut);
            cnout=num2str(handles.Model(md).Input(id).discharges(i).nOut);
            ckout=num2str(handles.Model(md).Input(id).discharges(i).kOut);
            cmout=[repmat(' ',1,4-length(cmout)) cmout];
            cnout=[repmat(' ',1,4-length(cnout)) cnout];
            ckout=[repmat(' ',1,4-length(ckout)) ckout];
    end
    
    fprintf(fid,'%s\n',[name repmat(' ',1,21-length(name)) cinterp m n k ctype ' ' cmout ' ' cnout ' ' ckout]);

end

fclose(fid);


