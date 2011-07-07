function ConvertSWANNestSpec(dr,fout,varargin)

convc=0;
if nargin>2
    convc=1;
    hm=varargin{1};
    m1=varargin{2};
    m2=varargin{3};
end

lst=dir([dr '*.sp2']);

n=length(lst);

fi2=fopen(fout,'wt');

for i=1:n
    
    fname=lst(i).name;
    fid=fopen([dr fname],'r');
        
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);

    f=fgetl(fid);

    Spec.NPoints=str2double(f(1:12));

    for j=1:Spec.NPoints
        f=fgetl(fid);
        [Spec.x(j) Spec.y(j)]=strread(f);
    end
    
    if convc
        if ~strcmpi(hm.Models(m1).CoordinateSystem,hm.Models(m2).CoordinateSystem) || ~strcmpi(hm.Models(m1).CoordinateSystemType,hm.Models(m2).CoordinateSystemType)
            % Convert coordinates
            [Spec.x,Spec.y]=ConvertCoordinates(Spec.x,Spec.y,'persistent','CS1.name',hm.Models(m1).CoordinateSystem,'CS1.type',hm.Models(m1).CoordinateSystemType,'CS2.name',hm.Models(m2).CoordinateSystem,'CS2.type',hm.Models(m2).CoordinateSystemType);
        end
    end

    f=fgetl(fid);

    f=fgetl(fid);
    Spec.NFreq=str2double(f(1:12));
    
    for j=1:Spec.NFreq
        f=fgetl(fid);
        Spec.Freqs(j)=strread(f);
    end

    f=fgetl(fid);

    f=fgetl(fid);
    Spec.NDir=str2double(f(1:12));
    
    for j=1:Spec.NDir
        f=fgetl(fid);
        Spec.Dirs(j)=strread(f);
    end
    
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);
    f=fgetl(fid);

    f=fgetl(fid);
    f=f(1:15);
    
    it=1;
    
    Spec.Time(it).Time=datenum(f,'yyyymmdd.HHMMSS');
    
    nbin=Spec.NDir*Spec.NFreq;

    for j=1:Spec.NPoints  
        f=fgetl(fid);
        deblank(f);
        if strcmpi(deblank(f),'factor')
            f=fgetl(fid);
            Spec.Time(it).Points(j).Factor=strread(f);
            data=textscan(fid,'%f',nbin);
            data=data{1};
            data=reshape(data,Spec.NDir,Spec.NFreq);
            data=data';
            Spec.Time(it).Points(j).Energy=data;
            f=fgetl(fid);
        else
            Spec.Time(it).Points(j).Factor=0;
            Spec.Time(it).Points(j).Energy=0;
        end            
    end

    if i==1
        fprintf(fi2,'%s\n','SWAN   1                                Swan standard spectral file, version');
        fprintf(fi2,'%s\n','$   Data produced by SWAN version 40.51AB             ');
        fprintf(fi2,'%s\n','$   Project:                 ;  run number:     ');
        fprintf(fi2,'%s\n','TIME                                    time-dependent data');
        fprintf(fi2,'%s\n','     1                                  time coding option');
        if convc
            switch lower(hm.Models(m2).CoordinateSystemType)
                case{'proj','projection','projected','cart','cartesian','xy'}
                    fprintf(fi2,'%s\n','LOCATIONS');
                otherwise
                    fprintf(fi2,'%s\n','LONLAT                                  locations in spherical coordinates');
            end
        else
            fprintf(fi2,'%s\n','LONLAT                                  locations in spherical coordinates');
        end
        fprintf(fi2,'%i\n',Spec.NPoints);
        for j=1:Spec.NPoints
            fprintf(fi2,'%15.6f %15.6f\n',Spec.x(j),Spec.y(j));
        end
        fprintf(fi2,'%s\n','AFREQ                                   absolute frequencies in Hz');
        fprintf(fi2,'%6i\n',Spec.NFreq);
        for j=1:Spec.NFreq
            fprintf(fi2,'%15.4f\n',Spec.Freqs(j));
        end
        fprintf(fi2,'%s\n','NDIR                                   spectral nautical directions in degr');
        fprintf(fi2,'%i\n',Spec.NDir);
        for j=1:Spec.NDir
            fprintf(fi2,'%15.4f\n',Spec.Dirs(j));
        end
        fprintf(fi2,'%s\n','QUANT');
        fprintf(fi2,'%s\n','     1                                  number of quantities in table');
        fprintf(fi2,'%s\n','EnDens                                  energy densities in J/m2/Hz/degr');
        fprintf(fi2,'%s\n','J/m2/Hz/degr                            unit');
        fprintf(fi2,'%s\n','   -0.9900E+02                          exception value');
    end
    
    fprintf(fi2,'%s\n',datestr(Spec.Time(it).Time,'yyyymmdd.HHMMSS'));
    for j=1:Spec.NPoints
        if Spec.Time(it).Points(j).Factor>0
            fprintf(fi2,'%s\n','FACTOR');
            fprintf(fi2,'%18.8e\n',Spec.Time(it).Points(j).Factor);
            fmt=repmat([repmat('  %7i',1,Spec.NDir) '\n'],1,Spec.NFreq);
            fprintf(fi2,fmt,Spec.Time(it).Points(j).Energy');
        else
            fprintf(fi2,'%s\n','NODATA');
        end
    end
    fclose(fid);
end
fclose(fi2);
