function [havg,nrep,pwet,fnfit,nmean,zmin,zmax]=subgrid_depth_v09d(d,manning1,nbin,huthresh)

nbin=nbin+1;

nmax=size(d,1);
mmax=size(d,2);
np=size(d,3);

zmin=zeros(nmax,mmax);
zmax=zeros(nmax,mmax);
havg=zeros(nmax,mmax,nbin);
nrep=zeros(nmax,mmax,nbin);
pwet=zeros(nmax,mmax,nbin);
fnfit=zeros(nmax,mmax);
nmean=zeros(nmax,mmax);

parfor m=1:mmax
%for m=1:mmax
    for n=1:nmax
        
        dd=squeeze(d(n,m,:));
        manning=squeeze(manning1(n,m,:));
        
        dd_a = dd(1:np/2);
        dd_b = dd(np/2+1:end);

        manning_a = manning(1:np/2);
        manning_b = manning(np/2+1:end);
        
        zmin_a=min(min(dd(1:np/2)));
        zmin_b=min(min(dd(np/2+1:end)));
        zmax_a=max(max(dd(1:np/2)));
        zmax_b=max(max(dd(np/2+1:end)));
        
        zmin(n,m) = max(zmin_a, zmin_b);
        zmax(n,m) = max(zmax_a, zmax_b);
        
        zmin(n,m) = zmin(n,m) + huthresh; % bottom of first bin
        
        zmax(n,m) = max(zmax(n,m), zmin(n,m)+0.01);
        
        dbin=(zmax(n,m)-zmin(n,m))/(nbin-1);
        
        nmean(n,m)=mean(manning);
        
        for ibin = 1:nbin
            
            % Bin level
            zb      = zmin(n, m) + (ibin-1)*dbin;
            hw      = zb - dd;             % Depth of all pixels (can still be negative)
            hw      = max(hw,0.0);
            hmean   = mean(hw);            % Grid average depth
            iok_all = find(hw>1.0e-6);

            % Subgrid table values (take minimum of the two nreps)
            havg(n,m,ibin) = hmean;                % Grid average depth
            pwet(n,m,ibin) = length(iok_all)/np;   % Wet fraction (number of wet pixels)            
            
            % A
            h_a    = max(zb - dd_a, 0.0);     % Depth of all pixels (but set min pixel height to zbot). Can be negative, but not zero (because zmin = zbot + huthresh, so there must be pixels below zb).
            q_a    = h_a.^(5.0/3.0)./manning_a;         % Determine 'flux' for each pixel
            q_a    = mean(q_a);                         % Wet-average flux through all the pixels
            
            % B
            h_b    = max(zb - dd_b, 0.0);     % Depth of all pixels (but set min pixel height to zbot). Can be negative, but not zero (because zmin = zbot + huthresh, so there must be pixels below zb).
            q_b    = h_b.^(5.0/3.0)./manning_b;         % Determine 'flux' for each pixel
            q_b    = mean(q_b);                         % Wet-average flux through all the pixels
            
            q_ab   = min(q_a, q_b);

            q_all = hw.^(5.0/3.0)./manning;         % Determine 'flux' for each pixel
            q_all = mean(q_all);                    % Wet-average flux through all the pixels
            
            % Weighted average of q_ab and q_all
            w=(ibin-1)/(nbin-1);
            q = (1.0 - w) * q_ab + w * q_all;

            nrep(n,m,ibin) = hmean^(5/3)/q;  % Representative n for qmean and hmean
            if ibin==nbin
                navg_top = hmean^(5/3)/q;
                hmean_top = hmean;
            end
            
            
            %             
% 
%             if q_a<q_b
%                 nrep(n,m,ibin) = hmean^(5/3)/q_a;  % Representative n for qmean and hmean
%                 if ibin==nbin
%                     navg_top = hmean^(5/3)/q_a;
%                     hmean_top = hmean;
%                 end
%             else
%                 nrep(n,m,ibin) = hmean^(5/3)/q_b;  % Representative n for qmean and hmean
%                 if ibin==nbin
%                     navg_top =  hmean^(5/3)/q_b;
%                     hmean_top = hmean;
%                 end
%             end
            
        end
        
        
        %% Fitting for nrep above zmax
        
        % Determine nfit at zfit
        zfit  = zmax(n,m) + zmax(n,m) - zmin(n,m);
        h     = max(zfit - dd, 0.0);                   % water depth in each pixel
        hmean = hmean_top + zmax(n,m) - zmin(n,m);     % mean water depth in cell as computed in SFINCS (assuming linear relation between water level and water depth above zmax)
        q     = h.^(5.0/3.0)./manning;                 % unit discharge in each pixel
        qmean = mean(q);                               % combined unit discharge for cell
        nfit  = hmean^(5/3)/qmean;
        
        % Actually apply fit on gn2 (this is what is used in sfincs)
        gnavg2 = 9.81*nmean(n,m)^2;
        gnavg_top2 = 9.81*navg_top^2;
        if gnavg2/gnavg_top2 > 0.99 && gnavg2/gnavg_top2 < 1.01
            % gnavg2 and gnavg_top2 are almost identical
            fnfit(n,m) = 0.0;
        else
            if nmean(n,m)>navg_top
                if nfit>nmean(n,m)
                    nfit = navg_top + 0.9*(nmean(n,m) - navg_top);
                end
                if nfit<navg_top
                    nfit = navg_top + 0.1*(nmean(n,m) - navg_top);
                end
            else
                if nfit<nmean(n,m)
                    nfit = navg_top + 0.9*(nmean(n,m) - navg_top);
                end
                if nfit>navg_top
                    nfit = navg_top + 0.1*(nmean(n,m) - navg_top);
                end
            end
            gnfit2 = 9.81*nfit^2;
            fnfit(n,m)=(((gnavg2-gnavg_top2)/(gnavg2-gnfit2))-1)/(zfit-zmax(n,m));
        end
    end
end
