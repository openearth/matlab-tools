function [vr,pr,rn,xn,rvms]=holland2010(r,vms,pc,rvms,varargin)
% Requires Vmax, Pc and Rmax

pn=1015;
rhoa=1.15;
xn=0.5;
rn=150;
robs=[];
vobs=[];
estimate_rmax=0;
e=exp(1);

for ii=1:length(varargin)
    if ischar(lower(varargin{ii}))
        switch lower(varargin{ii})
            case{'pn'}
                pn=varargin{ii+1};
            case{'rhoa'}
                rhoa=varargin{ii+1};
            case{'xn'}
                xn=varargin{ii+1};
            case{'rn'}
                rn=varargin{ii+1};
            case{'robs'}
                robs=varargin{ii+1};
            case{'vobs'}
                vobs=varargin{ii+1};
        end
    end
end

dp=pn-pc;
bs=vms^2*rhoa*e/(100*(pn-pc));
a=[];

if ~isempty(robs)   
    
    % Try to fit data
    if estimate_rmax
        rrange=0.5*rvms:1:2.0*rvms;
    else
        rrange=rvms;
    end

    xnmin=0.0001;
    xnmax=1.00;
    xnrange=xnmin:0.0001:xnmax;
    
    esqmin=1e12;
    for ii=1:length(xnrange)
        xn=xnrange(ii);
        jj=1;
        for jj=1:length(rrange)
            rtst=rrange(jj);
            [vest,pest]=h2010(robs,pc,dp,rtst,bs,rhoa,xn,rn,a);
            esq=sum((vest-vobs).^2); esq_save(jj) = esq;
            if esq<esqmin
                esqmin=esq;
                iamin=ii;
                irmin=jj;
            else
                break
            end
        end
    end
    xn=xnrange(iamin);
    rvms=rrange(irmin);
end
[vr,pr]=h2010(r,pc,dp,rvms,bs,rhoa,xn,rn,a);
if length(r)> 1 && vr(end) > vms
    [vr,pr]=h2010(r,pc,dp,rvms,bs,rhoa,0.5,rn,a);
end


function [vr,pr]=h2010(r,pc,dp,rvms,bs,rhoa,xn,rn,a)
if isempty(a)
    x=0.5+(r-rvms)*(xn-0.5)/(rn-rvms);
else
    x=0.5+(r-rvms)*a;
end
x(r<=rvms)=0.5;
%x=max(x,0.0);
pr=pc+dp*exp(-(rvms./r).^bs);
vr=((100*bs*dp*(rvms./r).^bs)./(rhoa*exp((rvms./r).^bs))).^x;

