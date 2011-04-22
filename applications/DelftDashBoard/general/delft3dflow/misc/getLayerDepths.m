function dplayer=getLayerDepths(dp,thick,varargin)

nlayers=length(thick);
thick=thick*0.01;

mmax=size(dp,1);
nmax=size(dp,2);

if nargin==2
     
    % Sigma layers
    
    sig(1)=0.5*thick(1);
    for i=2:nlayers
        sig(i)=sig(i-1)+0.5*thick(i-1)+0.5*thick(i);
    end

    if ndims(dp)==2
        % Initial Conditions
        % Make sure that boundary points are also computed. This is necessary
        % for Domain Decomposition.
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

else
    % Z-layers
    zbot=varargin{1};
    ztop=varargin{2};
    
    dpth=ztop-zbot;
    
    thick=fliplr(thick);
    
    d(1)=ztop-0.5*thick(1)*dpth;
    
    for k=2:nlayers
        d(k)=d(k-1)-0.5*thick(k-1)*dpth-0.5*thick(k)*dpth;
    end

    if ndims(dp)==2
        for i=1:mmax
            for j=1:nmax
                dplayer(i,j,:)=-d;
            end
        end
    else
        for i=1:length(dp)
            dplayer(i,:)=-d;
        end
    end
    
end
