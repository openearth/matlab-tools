function [zmin,zmax,volmax,ddd]=subgrid_volumes_v06(elevation, dxp, dyp, nbins, zvolmin, max_gradient)

nmax=size(elevation,1);
mmax=size(elevation,2);
np=size(elevation,3);

zmin=zeros(nmax,mmax);
zmax=zeros(nmax,mmax);
volmax=zeros(nmax,mmax);
ddd=zeros(nmax,mmax,nbins);

for m=1:mmax
    for n=1:nmax
        
        dd=squeeze(elevation(n,m,:));
                        
        % Cell area
        a = np*dxp(n,m)*dyp(n,m);
        
        % Set minimum elevation to -20 (needed with single precision), and sort
        ele_sort = sort(max(dd, zvolmin));
        
        % Make sure each consecutive point is larger than previous
        for j =2:np
            if ele_sort(j)<=ele_sort(j-1) + 1.0e-7
                ele_sort(j) = max(ele_sort(j),ele_sort(j-1)) + 1.0e-7;
            end
        end
        
        depth = ele_sort - ele_sort(1);
                
        xxx=1:length(depth)-1;
        
        % add trailing zero for first value
        volume = [0; cumsum((diff(depth) * dxp(n,m) * dyp(n,m)) .* xxx')];
        
        % Resample volumes to discrete bins
        steps = (0:nbins)/nbins;
        V = steps'*max(volume);
        dvol = max(volume)/nbins;

        z = interp1(volume, ele_sort, V);

        dzdh = get_dzdh(z, V, a);
        nn = 0;
        while max(dzdh)>max_gradient && nn < nbins
            % reshape until gradient is satisfactory
            idx = find(dzdh == max(dzdh),1,'first');
            z(idx+1) = z(idx) + max_gradient*(dvol/a);
            dzdh = get_dzdh(z, V, a);
            nn = nn + 1;
        end
        zmin(n,m)=z(1);
        zmax(n,m)=z(end);
        volmax(n,m)=max(volume);
        ddd(n,m,:)=z(2:end);
        
    end
end

function dzdh=get_dzdh(z, V, a)
% change in level per unit of volume (m/m)
dz = diff(z);
% change in volume (normalized to meters)
dh = max(diff(V) / a, 0.001);
dzdh=dz./dh;
