function Spec=readSWANSpec(fname)

fid=fopen(fname,'r');

f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);
f=fgetl(fid);

f=fgetl(fid);

nchar=min(length(f),12);
Spec.NPoints=str2double(f(1:nchar));

for j=1:Spec.NPoints
    f=fgetl(fid);
    [Spec.x(j) Spec.y(j)]=strread(f);
end

% if convc
%     if ~strcmpi(hm.Models(m1).CoordinateSystem,hm.Models(m2).CoordinateSystem) || ~strcmpi(hm.Models(m1).CoordinateSystemType,hm.Models(m2).CoordinateSystemType)
%         % Convert coordinates
%         [Spec.x,Spec.y]=ConvertCoordinates(Spec.x,Spec.y,hm.Models(m1).CoordinateSystem,hm.Models(m1).CoordinateSystemType,hm.Models(m2).CoordinateSystem,hm.Models(m2).CoordinateSystemType,hm.CoordinateSystems,hm.Operations);
%     end
% end
% 
f=fgetl(fid);

f=fgetl(fid);
nchar=min(length(f),12);
Spec.NFreq=str2double(f(1:nchar));

for j=1:Spec.NFreq
    f=fgetl(fid);
    Spec.Freqs(j)=strread(f);
end

f=fgetl(fid);

f=fgetl(fid);
nchar=min(length(f),12);
Spec.NDir=str2double(f(1:nchar));

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

% if Spec.Time(it).Time>=starttime && Spec.Time(it).Time<=stoptime

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
        Spec.Time(it).Points(j).Energy=zeros(Spec.NFreq,Spec.NDir);
    end
end

fclose(fid);
