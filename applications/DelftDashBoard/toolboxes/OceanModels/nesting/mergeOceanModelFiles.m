function errmsg=mergeOceanModelFiles(dr,name,outfile,par,t0,t1)

errmsg=[];
flist=dir([dr filesep name '.' par '.*.mat']);
if isempty(flist)
    errmsg='Could not find data files from ocean model!';
    return
end

lpar=length(par);
lname=length(name);
for i=1:length(flist)
    nm=flist(i).name;
    tstr=nm(lname+lpar+3:lname+lpar+16);
    t(i)=datenum(tstr,'yyyymmddHHMMSS');
end
it0=find(t<=t0,1,'last');
it1=find(t>=t1,1,'first');
if isempty(it0)
    errmsg='First time in data files from ocean model after model start time!';
    return
end
if isempty(it1)
    errmsg='Last time in data files from ocean model before model stop time!';
    return
end

nt=it1-it0+1;
for it=it0:it1
    ff=[dr filesep flist(it).name];
    fstruc=load(ff);
    if it==it0
        % First file
        newstruc=fstruc;
    else
        ntim=length(newstruc.time);
        newstruc.time(ntim+1)=fstruc.time;
        if ndims(fstruc.data)==2
            newstruc.data(:,:,ntim+1)=fstruc.data;
        else
            newstruc.data(:,:,:,ntim+1)=fstruc.data;
        end
    end
end
save(outfile,'-struct','newstruc');

