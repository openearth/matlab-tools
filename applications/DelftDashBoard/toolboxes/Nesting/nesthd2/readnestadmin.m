function s=readnestadmin(fname)

strwl='Nest administration for water level support point (M,N) = ';
strvel='Nest administration for velocity    support point (M,N) =';
lwl=length(strwl);
lvel=length(strvel);

fid=fopen(fname,'r');
k=0;
while 1
    f=fgetl(fid);
    if ~strcmpi(f(1),'*')
        break
    end
    k=k+1;
end
fclose(fid);

fid=fopen(fname,'r');
for i=1:k
    f=fgetl(fid);
end

nwl=0;
nvel=0;
while 1
    f=fgetl(fid);
    if ~ischar(f), break, end
    iwl=strfind(f,strwl);
    ivel=strfind(f,strvel);
    if iwl
        nwl=nwl+1;
        str=f(lwl+1:end);
        ii=strread(str,'%f','delimiter','(,)');
        s.wl.m(nwl)=ii(2);
        s.wl.n(nwl)=ii(3);
        for i=1:4
            f=fgetl(fid);
            v=strread(f,'%f');
            s.wl.mm(nwl,i)=v(1);
            s.wl.nn(nwl,i)=v(2);
            s.wl.w(nwl,i)=v(3);
        end
    end
    if ivel
        nvel=nvel+1;
        str=f(lvel+1:end);
        ii=strread(str,'%f','delimiter','(,)Angle =');
        s.vel.m(nvel)=ii(2);
        s.vel.n(nvel)=ii(3);
        s.vel.angle(nvel)=ii(10);
        for i=1:4
            f=fgetl(fid);
            v=strread(f,'%f');
            s.vel.mm(nvel,i)=v(1);
            s.vel.nn(nvel,i)=v(2);
            s.vel.w(nvel,i)=v(3);
        end
    end
end
fclose(fid);
