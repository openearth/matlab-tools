function ConvertWW3spc(fname1,fname2,coordsys,coordsystype)

%% Read Spec
fid=fopen(fname1,'r');

f=fgetl(fid);
v=strread(f,'%s','whitespace','\\''');

Spec.Name=v{1};
Spec.Model=v{3};

n=strread(v{2});

Spec.NFreq=n(1);
Spec.NDir=n(2);
Spec.NPoints=n(3);

freq=textscan(fid,'%f',Spec.NFreq);
Spec.Freqs=freq{1};

dr=textscan(fid,'%f',Spec.NDir);
Spec.Dirs=dr{1};

nbin=Spec.NFreq*Spec.NDir;

f=fgetl(fid);

k=0;
while 1
    k=k+1;
    f=fgetl(fid);
    if ~ischar(f)
        break
    end
    Spec.Time(k).Time=datenum(f,'yyyymmdd HHMMSS');
    for i=1:Spec.NPoints
        f=fgetl(fid);
        v=strread(f,'%s','whitespace','\\''');
        pars=strread(v{2});
        Spec.Time(k).Point(i).Name=v{1};
        Spec.Time(k).Point(i).Lat=pars(1);
        Spec.Time(k).Point(i).Lon=pars(2);
        if Spec.Time(k).Point(i).Lon>180
            Spec.Time(k).Point(i).Lon=Spec.Time(k).Point(i).Lon-360;
        end
        Spec.Time(k).Point(i).Depth=pars(3);
        Spec.Time(k).Point(i).WindSpeed=pars(4);
        Spec.Time(k).Point(i).WindDir=pars(5);
        if Spec.Time(k).Point(i).WindDir<0
            Spec.Time(k).Point(i).WindDir+360;
        end
        Spec.Time(k).Point(i).CurSpeed=pars(6);
        Spec.Time(k).Point(i).CurDir=pars(7);
        if Spec.Time(k).Point(i).CurDir<0
            Spec.Time(k).Point(i).CurDir+360;
        end
        data=textscan(fid,'%f',nbin);
        Spec.Time(k).Point(i).Energy=data{1};
        f=fgetl(fid);
    end        
end

fclose(fid);

%% Convert coordinates
convc=0;
if ~strcmpi(coordsys,'wgs 84')
    convc=1;
    for it=1:length(Spec.Time);
        for ip=1:Spec.NPoints
            [Spec.Time(it).Point(ip).Lon,Spec.Time(it).Point(ip).Lat]=ConvertCoordinates(Spec.Time(it).Point(ip).Lon,Spec.Time(it).Point(ip).Lat,'CS1.name','WGS 84','CS1.type','geographic','CS2.name',coordsys,'CS2.type',coordsystype);
        end
    end
end

% Spec.Dirs=flipud(Spec.Dirs);
% Spec.Freqs=flipud(Spec.Freqs);

Spec.Dirs=Spec.Dirs*180/pi+180;

imin=0;
for j=2:Spec.NDir
    if Spec.Dirs(j)>Spec.Dirs(j-1)
        imin=1;
    end
    if imin
        Spec.Dirs(j)=Spec.Dirs(j)-360;
    end
end

%% Write sp2

fi2=fopen(fname2,'wt');

fprintf(fi2,'%s\n','SWAN   1                                Swan standard spectral file, version');
fprintf(fi2,'%s\n','$   Data produced by SWAN version 40.51AB             ');
fprintf(fi2,'%s\n','$   Project:                 ;  run number:     ');
fprintf(fi2,'%s\n','TIME                                    time-dependent data');
fprintf(fi2,'%s\n','     1                                  time coding option');
if convc
    switch lower(coordsystype)
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
    fprintf(fi2,'%15.6f %15.6f\n',Spec.Time(1).Point(j).Lon,Spec.Time(1).Point(j).Lat);
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

for it=1:length(Spec.Time);
    fprintf(fi2,'%s\n',datestr(Spec.Time(it).Time,'yyyymmdd.HHMMSS'));
    for j=1:Spec.NPoints

        rhow=1025;
        g=9.81;
        f=pi/180;
        
        Spec.Time(it).Point(j).Energy=Spec.Time(it).Point(j).Energy*rhow*g*f;

        emax=max(max(Spec.Time(it).Point(j).Energy));
        Spec.Time(it).Point(j).Factor=emax/990099;
        Spec.Time(it).Point(j).Energy=round(Spec.Time(it).Point(j).Energy/Spec.Time(it).Point(j).Factor);
               
        Spec.Time(it).Point(j).Energy=reshape(Spec.Time(it).Point(j).Energy,[Spec.NFreq Spec.NDir]);
        Spec.Time(it).Point(j).Energy=transpose(Spec.Time(it).Point(j).Energy);
%         Spec.Time(it).Point(j).Energy=flipud(Spec.Time(it).Point(j).Energy);
%         Spec.Time(it).Point(j).Energy=fliplr(Spec.Time(it).Point(j).Energy);
        Spec.Time(it).Point(j).Energy=reshape(Spec.Time(it).Point(j).Energy,[1 Spec.NFreq*Spec.NDir]);

        
        

        if Spec.Time(it).Point(j).Factor>0
            fprintf(fi2,'%s\n','FACTOR');
            fprintf(fi2,'%18.8e\n',Spec.Time(it).Point(j).Factor);
            fmt=repmat([repmat('  %7i',1,Spec.NDir) '\n'],1,Spec.NFreq);
            fprintf(fi2,fmt,Spec.Time(it).Point(j).Energy);
        else
            fprintf(fi2,'%s\n','NODATA');
        end
    end

end
fclose(fi2);













% %% Write spec
% 
% fid=fopen(fname2,'wt');
% 
% str1=['''' Spec.Name ''''];
% str2=sprintf('%6.0f',Spec.NFreq);
% str3=sprintf('%6.0f',Spec.NDir);
% str4=sprintf('%6.0f',Spec.NPoints);
% str5=['''' Spec.Model ''' '];
% 
% str=[str1 ' ' str2 str3 str4 ' ' str5];
% fprintf(fid,'%s\n',str);
% 
% nlines=floor(Spec.NFreq/8);
% nlast=Spec.NFreq-nlines*8;
% fmt=repmat([repmat(' %9.2E',1,8) '\n'],1,nlines);
% if nlast>0
%     fmt=[fmt repmat(' %9.2E',1,nlast) '\n'];
% end
% fprintf(fid,fmt,Spec.Freqs);
% 
% nlines=floor(Spec.NDir/7);
% nlast=Spec.NDir-nlines*7;
% fmt=repmat([repmat('  %9.2E',1,7) '\n'],1,nlines);
% if nlast>0
%     fmt=[fmt repmat('  %9.2E',1,nlast) '\n'];
% end
% fprintf(fid,fmt,Spec.Dirs);
% 
% nt=length(Spec.Time);
% 
% for it=1:nt
%     fprintf(fid,'%s\n',datestr(Spec.Time(it).Time,'yyyymmdd HHMMSS'));
% 
%     for ip=1:Spec.NPoints
%         str=['''' Spec.Time(it).Point(ip).Name '''' num2str(Spec.Time(it).Point(ip).Lat,'%10.2f') num2str(Spec.Time(it).Point(ip).Lon,'%10.2f') num2str(Spec.Time(it).Point(ip).Depth,'%10.1f')];
%         fprintf(fid,'%s%s%s%7.2f%8.2f%10.1f%7.2f%6.1f%7.2f%6.1f\n','''',Spec.Time(it).Point(ip).Name,'''',Spec.Time(it).Point(ip).Lat,Spec.Time(it).Point(ip).Lon,Spec.Time(it).Point(ip).Depth,Spec.Time(it).Point(ip).WindSpeed,Spec.Time(it).Point(ip).WindDir,Spec.Time(it).Point(ip).CurSpeed,Spec.Time(it).Point(ip).CurDir);
% 
%         nlines=floor(nbin/7);
%         nlast=nbin-nlines*7;
%         fmt=repmat([repmat('  %9.2E',1,7) '\n'],1,nlines);
%         if nlast>0
%             fmt=[fmt repmat('  %9.2E',1,nlast) '\n'];
%         end
%         fprintf(fid,fmt,Spec.Time(it).Point(ip).Energy);
% 
%     end
% 
% end
% 
% 
% fclose(fid);
% 
% 
% 
