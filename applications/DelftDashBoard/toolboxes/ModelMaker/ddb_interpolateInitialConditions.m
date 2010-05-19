function val=ddb_interpolateInitialConditions(dp,thick,pars,opt)

nlayers=length(thick);

pars=pars';

depths=pars(1,:);
temps=pars(2,:);

depths=[-100000 depths 100000];
temps =[temps(1) temps temps(end)];

thick=thick*0.01;
sig(1)=0.5*thick(1);
for i=2:nlayers
    sig(i)=sig(i-1)+0.5*thick(i-1)+0.5*thick(i);    
end

if ndims(dp)==2
    % Initial Conditions
    % Make sure that boundary points are also computed. This is necessary
    % for Domain Decomposition.
    mmax=size(dp,1);
    nmax=size(dp,2);
%     mmax=mmax+1;
%     nmax=nmax+1;
%     dp0=zeros(mmax,nmax);
%     dp0(dp0==0)=NaN;
%     dp0(1:end-1,1:end-1)=dp;
%     dp=dp0;
    for i=1:mmax
        for j=1:nmax
            if isnan(dp(i,j))
                % Find neighbors
                nn=0;
                % Right
                if i<mmax
                    dpr=dp(i+1,j);
                    if isnan(dpr)
                        dpr=0;
                    else
                        nn=nn+1;
                    end
                else
                    dpr=0;
                end
                % Left
                if i>1
                    dpl=dp(i-1,j);
                    if isnan(dpl)
                        dpl=0;
                    else
                        nn=nn+1;
                    end
                else
                    dpl=0;
                end
                % Top
                if j<nmax
                    dpt=dp(i,j+1);
                    if isnan(dpt)
                        dpt=0;
                    else
                        nn=nn+1;
                    end
                else
                    dpt=0;
                end
                % Bottom
                if j>1
                    dpb=dp(i,j-1);
                    if isnan(dpb)
                        dpb=0;
                    else
                        nn=nn+1;
                    end
                else
                    dpb=0;
                end
                if nn>0
                    dp(i,j)=(dpr+dpl+dpt+dpb)/nn;
                else
                    dp(i,j)=NaN;
                end
            end
        end
    end
    for i=1:nlayers
        dplayer(:,:,i)=dp*sig(i);
    end
else
    % Boundary Conditions
    for i=1:nlayers
        dplayer(:,i)=dp*sig(i);
    end
end

templayers=interp1(depths,temps,dplayer);
val=templayers;
