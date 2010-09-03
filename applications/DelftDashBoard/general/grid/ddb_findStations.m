function [m,n,iindex]=ddb_findStationsObs(x,y,xg,yg,zz)

posx=[];
m=[];
n=[];
iindex=[];

xmin=min(min(xg));
xmax=max(max(xg));
ymin=min(min(yg));
ymax=max(max(yg));

ns=length(x);

% x=dataSet.xy(:,1);
% y=dataSet.xy(:,2);

% cs0.Name=dataSet.cs.Name;
% cs0.Type=dataSet.cs.Type;
% 
% [x,y]=ddb_coordConvert(x,y,cs0,cs1);
ni=0;

for i=1:ns
    if x(i)>xmin && x(i)<xmax && ...
        y(i)>ymin && y(i)<ymax
        ni=ni+1;
        posx(ni)=x(i);
        posy(ni)=y(i);
%        name{n}=deblank(dataSet.Name{i});
%        longname{n}=deblank(dataSet.LongName{i});
%        idcode{n}=deblank(dataSet.IDCode{i});
%        src{n}=deblank(dataSet.Source{i});
        istat(ni)=i;
    end
end

wb = waitbox('Finding Stations ...');

if ~isempty(posx)
    [m0,n0]=FindGridCell(posx,posy,xg,yg);
    [m0,n0]=CheckDepth(m0,n0,zz);
    nobs=0;
%     Names{1}='';
    for i=1:length(m0)
        if m0(i)>0
%             if isempty(strmatch(name{i},Names,'exact'))
                nobs=nobs+1;
                m(nobs)=m0(i);
                n(nobs)=n0(i);
                iindex(nobs)=istat(i);
%             end
        end
    end

end

close(wb);
