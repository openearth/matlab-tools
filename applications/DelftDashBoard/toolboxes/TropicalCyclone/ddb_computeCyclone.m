function handles=ddb_computeCyclone(handles,filename)

inp=handles.Toolbox(tb).Input;

[path,name,ext]=fileparts(filename);

% Input file

if strcmpi(inp.quadrantOption,'perquadrant')
    nq=4;
else
    nq=1;
end

for iq=1:nq

    if strcmpi(inp.quadrantOption,'perquadrant')
        iqstr=['_' num2str(iq)];
    else
        iqstr='';
    end

    fid=fopen([name iqstr '.inp'],'wt');
    
    fprintf(fid,'%s\n','COMMENT             = WES run');
    fprintf(fid,'%s\n','COMMENT             = Grid: none');
    fprintf(fid,'%s\n',['CYCLONE_PAR._FILE   = trackfile' iqstr '.trk']);
    fprintf(fid,'%s\n',['SPIDERS_WEB_DIMENS. = ' num2str(inp.nrRadialBins) '  ' num2str(inp.nrDirectionalBins)]);
    fprintf(fid,'%s\n',['RADIUS_OF_CYCLONE   = ' num2str(1000*inp.radius,'%3.1f')]);
    fprintf(fid,'%s\n','WIND CONV. FAC (TRK)= 1.00');
    fprintf(fid,'%s\n','NO._OF_HIS._DATA    = 0');
    fprintf(fid,'%s\n','HIS._DATA_FILE_NAME = wes_his.inp');
    fprintf(fid,'%s\n','OBS._DATA_FILE_NAME =');
    fprintf(fid,'%s\n','EXTENDED_REPORT     = yes');
    
    fclose(fid);
    
    % Track file
    
    fid=fopen(['trackfile' iqstr '.trk'],'wt');
    
    usr=getenv('username');
    usrstring='* File created by unknown user';
    if size(usr,1)>0
        usrstring=['* File created by ' usr];
    end

    fprintf(fid,'%s\n','* File for tropical cyclone');
    fprintf(fid,'%s\n','* File contains Cyclone information ; TIMES in UTC');
    fprintf(fid,'%s\n',usrstring);
    fprintf(fid,'%s\n','* UNIT = Kts, Nmi ,Pa');
    fprintf(fid,'%s\n','* METHOD= 1:A&B;           4:Vm,Pd; Rw default');
    fprintf(fid,'%s\n','*         2:R100_etc;      5:Vm & Rw(RW may be default - US data; Pd = 2 Vm*Vm);');
    fprintf(fid,'%s\n','*         3:Vm,Pd,RmW,     6:Vm (Indian data); 7: OLD METHOD - Not adviced');
    fprintf(fid,'%s\n','* Dm    Vm');
    fprintf(fid,'%3.1f %3.1f\n',inp.initDir,inp.initSpeed);
    fprintf(fid,'%s\n','*    Date and time     lat     lon Method    Vmax    Rmax   R100    R65    R50    R35  Par B  Par A  Pdrop');
    fprintf(fid,'%s\n','* yyyy  mm  dd  HH     deg     deg    (-)   (kts)    (NM)   (NM)   (NM)   (NM)   (NM)    (-)    (-)   (Pa)');
    e=1e30;
    
    met=inp.method;
    for j=1:inp.nrTrackPoints
        dstr=datestr(inp.trackT(j),'yyyy  mm  dd  HH');
        switch met
            case 1
                fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %1.0e %1.0e %1.0e %1.0e %1.0e %6.1f %6.1f %1.0e\n',dstr,inp.trackY(j),inp.trackX(j),met,inp.trackVMax(j,iq),e,e,e,e,e,inp.trackB(j,iq),inp.trackA(j,iq),e);
            case 2
                
                if inp.trackR35(j,iq)<0 || inp.trackR50(j,iq)<0
                    % Not enough input.
                    if inp.trackRMax(j,iq)>=0
                        % RMax available. Switch to method 3.
                        fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %6.1f %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %6.1f\n',dstr,inp.trackY(j),inp.trackX(j),3,inp.trackVMax(j,iq),inp.trackRMax(j,iq),e,e,e,e,e,e,inp.trackPDrop(j,iq));
                    else
                        % Switch to method 4.
                        fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %6.1f\n',dstr,inp.trackY(j),inp.trackX(j),4,inp.trackVMax(j,iq),e,e,e,e,e,e,e,inp.trackPDrop(j,iq));
                    end
                else
                    fmt='  %s  %6.2f  %6.2f      %i  %6.1f ';
                    if inp.trackRMax(j,iq)>=0
                        fmt=[fmt ' %6.1f'];
                    else
                        fmt=[fmt ' %1.0e'];
                        inp.trackRMax(j,iq)=e;
                    end
                    if inp.trackR100(j,iq)>=0
                        fmt=[fmt ' %6.1f'];
                    else
                        fmt=[fmt ' %1.0e'];
                        inp.trackR100(j,iq)=e;
                    end
                    if inp.trackR65(j,iq)>=0
                        fmt=[fmt ' %6.1f'];
                    else
                        fmt=[fmt ' %1.0e'];
                        inp.trackR65(j,iq)=e;
                    end
                    if inp.trackR50(j,iq)>=0
                        fmt=[fmt ' %6.1f'];
                    else
                        fmt=[fmt ' %1.0e'];
                        inp.trackR50(j,iq)=e;
                    end
                    if inp.trackR35(j,iq)>=0
                        fmt=[fmt ' %6.1f'];
                    else
                        fmt=[fmt ' %1.0e'];
                        inp.trackR35(j,iq)=e;
                    end
                    fmt=[fmt ' %1.0e %1.0e %1.0e\n'];
                    fprintf(fid,fmt,dstr,inp.trackY(j),inp.trackX(j),met,inp.trackVMax(j,iq),inp.trackRMax(j,iq),inp.trackR100(j,iq),inp.trackR65(j,iq),inp.trackR50(j,iq),inp.trackR35(j,iq),e,e,e);
                end
            
            
            case 3
                fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %6.1f %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %6.1f\n',dstr,inp.trackY(j),inp.trackX(j),met,inp.trackVMax(j,iq),inp.trackRMax(j,iq),e,e,e,e,e,e,inp.trackPDrop(j,iq));
            case 4
                fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %6.1f\n',dstr,inp.trackY(j),inp.trackX(j),met,inp.trackVMax(j,iq),e,e,e,e,e,e,e,inp.trackPDrop(j,iq));
            case 5
                fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %6.1f %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e\n',dstr,inp.trackY(j),inp.trackX(j),met,inp.trackVMax(j,iq),inp.trackRMax(j,iq),e,e,e,e,e,e,e);
            case 6
                fprintf(fid,'  %s  %6.2f  %6.2f      %i  %6.1f  %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e %1.0e\n',dstr,inp.trackY(j),inp.trackX(j),met,inp.trackVMax(j,iq),e,e,e,e,e,e,e,e);
        end
    end
    
    fclose(fid);
    
    system(['"' handles.Toolbox(tb).miscDir 'wes.exe" ' name iqstr '.inp']);
    
    if inp.deleteTemporaryFiles
        delete(['trackfile' iqstr '.trk']);
        delete([name iqstr '.inp']);
        delete([name iqstr '_wes.dia']);
    end

end

if strcmpi(inp.quadrantOption,'perquadrant')

    % Merge files
    fid=fopen([name '.inp'],'wt');
    fprintf(fid,'%s\n','COMMENT             = WES run');
    fprintf(fid,'%s\n',['NE QUADRANT         = ' name '_1.spw']);
    fprintf(fid,'%s\n',['SE QUADRANT         = ' name '_2.spw']);
    fprintf(fid,'%s\n',['SW QUADRANT         = ' name '_3.spw']);
    fprintf(fid,'%s\n',['NW QUADRANT         = ' name '_4.spw']);
    fclose(fid);
    system(['"' handles.Toolbox(tb).miscDir 'merge_spw.exe" ' name '.inp']);
    movefile([name '_merge.spw'],[name '.spw']);
    
    if inp.deleteTemporaryFiles
        delete([name '_1.spw']);
        delete([name '_2.spw']);
        delete([name '_3.spw']);
        delete([name '_4.spw']);
        delete([name '.inp']);
        delete([name '_wes.dia']);
    end


end

handles.Model(md).Input(ad).spwFile=[name '.spw'];
handles.Model(md).Input(ad).wind=1;
handles.Model(md).Input(ad).windType='spiderweb';
handles.Model(md).Input(ad).airOut=1;
