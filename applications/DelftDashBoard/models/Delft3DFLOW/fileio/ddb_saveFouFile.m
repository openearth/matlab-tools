function ddb_saveFouFile(handles,id)

tab=handles.Model(md).Input(id).fourier.editTable;
fid=fopen(handles.Model(md).Input(id).fourier.fouFile,'wt');
plist=handles.Model(md).Input(ad).fourier.pList;
for i=1:length(tab.period)
    par=plist{tab.parameterNumber(i)};
    parstr=par;
    if strcmpi(par,'wl')
        lstr='';
    else
        lstr=num2str(tab.layer(i));
    end
    if tab.max(i)
        optstr='max';
    elseif tab.min(i)
        optstr='min';
    elseif tab.ellipse(i)
        optstr='y';
    else
        optstr='';
    end
    
    t0str=num2str((tab.startTime(i)-handles.Model(md).Input(id).itDate)*1440,'%10.2f');
    t0str=[repmat(' ',1,12-length(t0str)) t0str];
    t1str=num2str((tab.stopTime(i)-handles.Model(md).Input(id).itDate)*1440,'%10.2f');
    t1str=[repmat(' ',1,12-length(t1str)) t1str];
    nrstr=num2str(tab.nrCycles(i));
    nrstr=[repmat(' ',1,6-length(nrstr)) nrstr];
    ampstr=num2str(tab.nodalAmplificationFactor(i),'%10.5f');
    ampstr=[repmat(' ',1,12-length(ampstr)) ampstr];
    argstr=num2str(tab.astronomicalArgument(i),'%10.5f');
    argstr=[repmat(' ',1,12-length(argstr)) argstr];

    lstr=[repmat(' ',1,5-length(lstr)) lstr];
    lstr=deblank(lstr);
    optstr=[repmat(' ',1,5-length(optstr)) optstr];

    str=[parstr ' ' t0str t1str nrstr ampstr argstr lstr optstr];
    str=deblank(str);
    fprintf(fid,'%s\n',str);
    
end
fclose(fid);
