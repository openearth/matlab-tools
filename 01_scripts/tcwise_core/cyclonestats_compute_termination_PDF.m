function termination=cyclonestats_compute_termination_PDF(fnamein,xg,yg)

s=load(fnamein);

t = ~isnan(s.lon);
termx=zeros(size(t,1),1);
termy=zeros(size(t,1),1);
lon0=zeros(size(s.vmax));
lon0(lon0==0)=NaN;
lat0=lon0;
vmax0=lon0;
tim0=lon0;

lon=s.lon;
lat=s.lat;
vmax=s.vmax;
tim=1:size(vmax,2);
tim=tim*6;
tim=repmat(tim,size(vmax,1),1);
termmat=zeros(size(s.lon));

for i=1:size(t,1)
    ii=find(t(i,:)==1,1,'last');
    lon0(i,ii)=s.lon(i,ii);
    lat0(i,ii)=s.lat(i,ii);
    vmax0(i,ii)=s.vmax(i,ii);
    tim0(i,ii)=ii*6;
    termmat(i,ii)=1;
end

% Compute area of search cells
nearby=zeros(size(xg));
ptermination=zeros(size(xg));
vmax_avg=zeros(size(xg));
ntracks=size(s.vmax(:,1),1);
min_points=30;
ncount=0;
timebins=[0 80 160 240];
vmaxbins=[0 40];

invmaxbin = arrayfun(@(x) find(vmaxbins<x,1,'last'), vmax,'UniformOutput', false);
invmaxbin(cellfun('isempty',invmaxbin))={NaN};
invmaxbin=cell2mat(invmaxbin);
intimebin = arrayfun(@(x) find(timebins<x,1,'last'), tim,'UniformOutput', true);

termination.term(4,2).p(size(xg,1),size(xg,2))=0;
termination.timebins=timebins;
termination.vmaxbins=vmaxbins;
maxrangetermination=1100;
for ii=1:size(xg,1)
    for jj=1:size(xg,2)
        ncount=ncount+1;
        dst_all=sqrt((111.0*cos(yg(ii,jj)*pi/180)*(lon-xg(ii,jj))).^2 + (111.0*(lat-yg(ii,jj))).^2);
        if max(dst_all)>22000
            disp('not good')
        end
        for kk=1:length(vmaxbins)
            for ll=1:length(timebins)
                nrstormsinrange=0;
                inrange_all=[];
                rangetermination=100;
                while sum(inrange_all(:))<min_points && rangetermination<maxrangetermination
                    rangetermination=rangetermination+100;
                    inrange_all=dst_all<rangetermination & invmaxbin==kk & intimebin==ll;
                    stormsinrange=find(sum(inrange_all,2)>=1);
                    nrstormsinrange=length(stormsinrange);
                end
                
                % Compute distance in kilometres from each grid point
                inrange_term=find(inrange_all & termmat);
                if sum(inrange_all(:))==0;
                    termination.term(ll,kk).p(ii,jj)=1;
                else
                    termination.term(ll,kk).p(ii,jj)=length(inrange_term)/sum(inrange_all(:)); % Probability (occurences per year per km sq)
                end
            end
        end
    end
end


