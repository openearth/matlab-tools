function [hrep,dhdz,navg,zmin,zmax]=subgrid_depth_v06(d,manning1,nbin)

nmax=size(d,1);
mmax=size(d,2);
np=size(d,3);

zmin=zeros(nmax,mmax);
zmax=zeros(nmax,mmax);
hrep=zeros(nmax,mmax,nbin);
navg=zeros(nmax,mmax,nbin);
dhdz=zeros(nmax,mmax)+1;

parfor m=1:mmax
    for n=1:nmax

        dd=squeeze(d(n,m,:));        
        manning=squeeze(manning1(n,m,:));

        zmin_a=min(min(dd(1:np/2)));
        zmin_b=min(min(dd(np/2+1:end)));
        zmax_a=max(max(dd(1:np/2)));
        zmax_b=max(max(dd(np/2+1:end)));

        zmin(n,m) = max(zmin_a, zmin_b);
        zmax(n,m) = max(zmax_a, zmax_b);

        zmax(n,m) = max(zmax(n,m), zmin(n,m)+0.01);
        
        dbin=(zmax(n,m)-zmin(n,m))/nbin;

        for ibin = 1:nbin
            %
            % Top of bin
            %
            zb = zmin(n, m) + ibin*dbin;
            ibelow = dd<=zb;                           % index of pixels below bin level
            h      = max(zb - max(dd, zmin(n,m)), 0.0);  % water depth in each pixel
            qi     = h.^(5.0/3.0)./manning;           % unit discharge in each pixel
            q      = mean(qi);                   % combined unit discharge for cell
            navg(n,m,ibin) = mean(manning(ibelow));       % mean manning's n
            hrep(n,m,ibin) = (q*navg(n,m,ibin))^(3.0/5.0);        % conveyance depth
        end
        
    end
end
