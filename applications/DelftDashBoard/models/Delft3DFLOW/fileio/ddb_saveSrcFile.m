function ddb_saveSrcFile(handles,id)

fid=fopen(handles.Model(md).Input(id).SrcFile,'w');

nr=handles.Model(md).Input(id).NrDischarges;

for i=1:nr

    name=deblank(handles.Model(md).Input(id).Discharges(i).Name);
    if strcmpi(handles.Model(md).Input(id).Discharges(i).Interpolation,'linear')
        cinterp='Y';
    else
        cinterp='N';
    end

    m=num2str(handles.Model(md).Input(id).Discharges(i).M);
    n=num2str(handles.Model(md).Input(id).Discharges(i).N);
    k=num2str(handles.Model(md).Input(id).Discharges(i).K);

    m=[repmat(' ',1,4-length(m)) m];
    n=[repmat(' ',1,4-length(n)) n];
    k=[repmat(' ',1,4-length(k)) k];
    
    ctype='';
    cmout='';
    cnout='';
    ckout='';

    switch lower(handles.Model(md).Input(id).Discharges(i).Type)
        case{'walking'}
            ctype=' W';
        case{'in-out'}
            ctype=' P';
            cmout=num2str(handles.Model(md).Input(id).Discharges(i).Mout);
            cnout=num2str(handles.Model(md).Input(id).Discharges(i).Nout);
            ckout=num2str(handles.Model(md).Input(id).Discharges(i).Kout);
            cmout=[repmat(' ',1,4-length(cmout)) cmout];
            cnout=[repmat(' ',1,4-length(cnout)) cnout];
            ckout=[repmat(' ',1,4-length(ckout)) ckout];
    end
    
    fprintf(fid,'%s\n',[name repmat(' ',1,21-length(name)) cinterp m n k ctype ' ' cmout ' ' cnout ' ' ckout]);

end

fclose(fid);


