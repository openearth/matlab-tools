function handles=ddb_readHurricaneFileUnisys(handles,filename)

fid=fopen(filename,'r');

n=0;

tx0=fgets(fid);
v0=strread(tx0,'%s','delimiter',' ');
nn=length(v0);
y=str2double(v0{nn});

tx0=fgets(fid);
name=tx0(1:end-1);

handles.Toolbox(tb).Input.date=[];
handles.Toolbox(tb).Input.trX=[];
handles.Toolbox(tb).Input.trY=[];
handles.Toolbox(tb).Input.par1=[];
handles.Toolbox(tb).Input.par2=[];

handles.Toolbox(tb).Input.name=name;

tx0=fgets(fid);

for i=1:1000
    tx0=fgets(fid);
    if and(ischar(tx0), size(tx0>0))
        n=n+1;
        v0=strread(tx0,'%s','delimiter',' ');
        lat=str2double(v0{2});
        lon=str2double(v0{3});
        tstr=v0{4};
        vel=str2double(v0{5});
        pr=v0{6};
        if isnan(str2double(pr))
            pr=0;
        else
            pr=str2double(pr);
        end
        mm=str2double(tstr(1:2));
        dd=str2double(tstr(4:5));
        hh=str2double(tstr(7:8));
        handles.Toolbox(tb).Input.date(n)=datenum(y,mm,dd,hh,0,0);
        handles.Toolbox(tb).Input.trX(n)=lon;
        handles.Toolbox(tb).Input.trY(n)=lat;
        handles.Toolbox(tb).Input.par1(n)=vel;
        handles.Toolbox(tb).Input.par2(n)=pr;
    else
        break;
    end
end
handles.Toolbox(tb).Input.nrPoint=n;
handles.Toolbox(tb).Input.holland=0;
handles.Toolbox(tb).Input.initSpeed=0;
handles.Toolbox(tb).Input.initDir=0;
handles.Toolbox(tb).Input.startTime=handles.Toolbox(tb).Input.date(1);

fclose(fid);
