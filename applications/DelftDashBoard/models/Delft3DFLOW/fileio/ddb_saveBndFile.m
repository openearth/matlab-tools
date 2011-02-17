function handles=ddb_saveBndFile(handles,id)

fid=fopen(handles.Model(md).Input(id).bndFile,'w');
  
nr=handles.Model(md).Input(id).nrOpenBoundaries;

% Astronomic
for n=1:nr
    if handles.Model(md).Input(id).openBoundaries(n).forcing=='A'
        name=handles.Model(md).Input(id).openBoundaries(n).name;
        m1=handles.Model(md).Input(id).openBoundaries(n).M1;
        n1=handles.Model(md).Input(id).openBoundaries(n).N1;
        m2=handles.Model(md).Input(id).openBoundaries(n).M2;
        n2=handles.Model(md).Input(id).openBoundaries(n).N2;
        alpha=handles.Model(md).Input(id).openBoundaries(n).alpha;
        typ=handles.Model(md).Input(id).openBoundaries(n).type;
        prof=handles.Model(md).Input(id).openBoundaries(n).profile;
        compa=handles.Model(md).Input(id).openBoundaries(n).compA;
        compb=handles.Model(md).Input(id).openBoundaries(n).compB;
        switch typ,
            case{'C','Q','T','R'}
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e %s %s %s\n',[name repmat(' ',1,20-length(name)) ] ,typ,'A',m1,n1,m2,n2,alpha,prof,compa,compb);
            otherwise
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e %s %s\n',[name repmat(' ',1,20-length(name)) ] ,typ,'A',m1,n1,m2,n2,alpha,compa,compb);
        end     
    end
end

% Harmonic
for n=1:nr
    if handles.Model(md).Input(id).openBoundaries(n).forcing=='H'
        name=handles.Model(md).Input(id).openBoundaries(n).name;
        m1=handles.Model(md).Input(id).openBoundaries(n).M1;
        n1=handles.Model(md).Input(id).openBoundaries(n).N1;
        m2=handles.Model(md).Input(id).openBoundaries(n).M2;
        n2=handles.Model(md).Input(id).openBoundaries(n).N2;
        alpha=handles.Model(md).Input(id).openBoundaries(n).alpha;
        typ=handles.Model(md).Input(id).openBoundaries(n).type;
        prof=handles.Model(md).Input(id).openBoundaries(n).profile;
        switch typ,
            case{'C','Q','T','R'}
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e %s\n',[name repmat(' ',1,20-length(name)) ] ,typ,'H',m1,n1,m2,n2,alpha,prof);
            otherwise
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e\n',[name repmat(' ',1,20-length(name)) ] ,typ,'H',m1,n1,m2,n2,alpha);
        end     
    end
end

% Time series
for n=1:nr
    if handles.Model(md).Input(id).openBoundaries(n).forcing=='T'
        name=handles.Model(md).Input(id).openBoundaries(n).name;
        m1=handles.Model(md).Input(id).openBoundaries(n).M1;
        n1=handles.Model(md).Input(id).openBoundaries(n).N1;
        m2=handles.Model(md).Input(id).openBoundaries(n).M2;
        n2=handles.Model(md).Input(id).openBoundaries(n).N2;
        alpha=handles.Model(md).Input(id).openBoundaries(n).alpha;
        typ=handles.Model(md).Input(id).openBoundaries(n).type;
        prof=handles.Model(md).Input(id).openBoundaries(n).profile;
        switch typ,
            case{'C','Q','T','R'}
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e %s\n',[name repmat(' ',1,20-length(name)) ] ,typ,'T',m1,n1,m2,n2,alpha,prof);
            otherwise
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e\n',[name repmat(' ',1,20-length(name)) ] ,typ,'T',m1,n1,m2,n2,alpha);
        end     
    end
end

% QH-relation
for n=1:nr
    if handles.Model(md).Input(id).openBoundaries(n).forcing=='Q'
        name=handles.Model(md).Input(id).openBoundaries(n).name;
        m1=handles.Model(md).Input(id).openBoundaries(n).M1;
        n1=handles.Model(md).Input(id).openBoundaries(n).N1;
        m2=handles.Model(md).Input(id).openBoundaries(n).M2;
        n2=handles.Model(md).Input(id).openBoundaries(n).N2;
        alpha=handles.Model(md).Input(id).openBoundaries(n).alpha;
        typ=handles.Model(md).Input(id).openBoundaries(n).type;
        prof=handles.Model(md).Input(id).openBoundaries(n).profile;
        switch typ,
            case{'C','Q','T','R'}
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e %s\n',[name repmat(' ',1,20-length(name)) ] ,typ,'Q',m1,n1,m2,n2,alpha,prof);
            otherwise
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e\n',[name repmat(' ',1,20-length(name)) ] ,typ,'Q',m1,n1,m2,n2,alpha);
        end     
    end
end

fclose(fid);
