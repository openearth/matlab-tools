function delft3dflow_saveBndFile(openBoundaries,fname)

fid=fopen(fname,'w');
  
nr=length(openBoundaries);

% Astronomic
for n=1:nr
    if openBoundaries(n).forcing=='A'
        name=openBoundaries(n).name;
        m1=openBoundaries(n).M1;
        n1=openBoundaries(n).N1;
        m2=openBoundaries(n).M2;
        n2=openBoundaries(n).N2;
        alpha=openBoundaries(n).alpha;
        typ=openBoundaries(n).type;
        prof=openBoundaries(n).profile;
        compa=openBoundaries(n).compA;
        compb=openBoundaries(n).compB;
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
    if openBoundaries(n).forcing=='H'
        name=openBoundaries(n).name;
        m1=openBoundaries(n).M1;
        n1=openBoundaries(n).N1;
        m2=openBoundaries(n).M2;
        n2=openBoundaries(n).N2;
        alpha=openBoundaries(n).alpha;
        typ=openBoundaries(n).type;
        prof=openBoundaries(n).profile;
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
    if openBoundaries(n).forcing=='T'
        name=openBoundaries(n).name;
        m1=openBoundaries(n).M1;
        n1=openBoundaries(n).N1;
        m2=openBoundaries(n).M2;
        n2=openBoundaries(n).N2;
        alpha=openBoundaries(n).alpha;
        typ=openBoundaries(n).type;
        prof=openBoundaries(n).profile;
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
    if openBoundaries(n).forcing=='Q'
        name=openBoundaries(n).name;
        m1=openBoundaries(n).M1;
        n1=openBoundaries(n).N1;
        m2=openBoundaries(n).M2;
        n2=openBoundaries(n).N2;
        alpha=openBoundaries(n).alpha;
        typ=openBoundaries(n).type;
        prof=openBoundaries(n).profile;
        switch typ,
            case{'C','Q','T','R'}
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e %s\n',[name repmat(' ',1,20-length(name)) ] ,typ,'Q',m1,n1,m2,n2,alpha,prof);
            otherwise
                fprintf(fid,'%s %s %s %5.0f %5.0f %5.0f %5.0f %15.7e\n',[name repmat(' ',1,20-length(name)) ] ,typ,'Q',m1,n1,m2,n2,alpha);
        end     
    end
end

fclose(fid);
