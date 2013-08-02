function polout = interpolate_on_polygon(Gin,Din,pol,idmn)
% interpolate flow data on polygon

if ( nargin<4)
    idmn=-1
end

pol.x = reshape(pol.x,1,[]);
pol.y = reshape(pol.y,1,[]);

% check sizes of Gin and Din
lenG = length(Gin);
lenD = length(Din);

% sizes should match
if ( lenG~=lenD )
    error('Grid and Map length do not match.');
end


for idmnp1=1:length(Gin)    % idmn + 1
    if ( iscell(Gin) )
        G = Gin{idmnp1};
        D = Din{idmnp1};
        idmn = idmnp1-1; % assume partitioned data
        fprintf('Interpolating domain %i...', idmn);
    else
        G = Gin;
        D = Din;
    end

    idxAtoL=G.cen.Link(1,:)<=G.cen.n & G.cen.Link(2,:)<=G.cen.n;
    idxAtoL=find(idxAtoL);
    if ( isfield(G.cen,'idmn') & idmn>-1 )
        idxAtoL=idxAtoL((G.cen.idmn(G.cen.Link(1,idxAtoL))==idmn) &    ...
                        (G.cen.idmn(G.cen.Link(2,idxAtoL))==idmn));
    end


%     len = length(idxAtoL);
% %   make sure index array is a row vector
%     idxAtoL = reshape(idxAtoL,1,len);
    
    A.x1 = G.cen.x(G.cen.Link(1,idxAtoL));
    A.y1 = G.cen.y(G.cen.Link(1,idxAtoL));
    A.x2 = G.cen.x(G.cen.Link(2,idxAtoL));
    A.y2 = G.cen.y(G.cen.Link(2,idxAtoL));

    B.x1 = pol.x(1:end-1);
    B.y1 = pol.y(1:end-1);
    B.x2 = pol.x(2:end);
    B.y2 = pol.y(2:end);

    C = dflowfm.intersect_lines(A,B);

    % compute arc length
    darc0 = sqrt((B.x2-B.x1).^2 + (B.y2-B.y1).^2);
    arc0 = cumsum(darc0);
    arc = arc0(C.idxB) - (1-C.beta).*darc0(C.idxB);
    [dum,idxarctoA] = sort(arc);
    idxarctoA = reshape(idxarctoA,size(C.x));

    polout.arc = arc(idxarctoA);
    polout.x   = C.x(idxarctoA);
    polout.y   = C.y(idxarctoA);

    % perform interpolation from D
    varnams= fieldnames(D.cen);
    
    for i=1:length(varnams)
        var=varnams{i};
%       assume row indices correspond to layers
        NDIM=length(size(D.cen.(var)));
        polout.cen.(var) = [];
        for k=1:size(D.cen.(var),2) % could be slow, possible future work: try to prevent loop
            dum = D.cen.(var);
            polout.cen.(var)(:,k) = interpolate(D.cen.(var)(:,k));
        end
    end

    % interpolate bottom levels from G
    polout.cen.z    = interpolate(G.cen.z);
    if ( isfield(G.cen,'idmn') )
        polout.cen.idmn = interpolate(G.cen.idmn);
    end
    
    % 3D data: add X and Z coordinates (sigma layers only)
    numlay=size(D.cen.u,2);
    if ( numlay>1 )
    %   compute water depth
        h=polout.cen.zwl(:)-polout.cen.z(:);
        h=reshape(h,length(h),1);
    %   layers are assumed to be uniformly distributed along the water column
        polout.z=repmat((1:numlay)-0.5, length(h),1)/numlay .* repmat(h,1,numlay) + repmat(polout.cen.z(:),1,numlay);
        polout.arc=repmat(polout.arc(:),1,numlay);
        polout.x=repmat(polout.x(:),1,numlay);
        polout.y=repmat(polout.y(:),1,numlay);
    end
    

    if ( iscell(Gin) )
        fprintf(' done.\n');
        pol_store{idmnp1} = polout;
    end

end

if ( iscell(Gin) )
    clear polout;
    polout = pol_store;
end

    function y = interpolate(x)
        
        y = (1-C.alpha(idxarctoA)).*    ...
                reshape(    ...
                    x(G.cen.Link(1,idxAtoL(C.idxA(idxarctoA)))),    ...
                    size(idxarctoA) ...
                ) +   ...
            C.alpha(idxarctoA) .*   ...
                reshape(    ...
                    x(G.cen.Link(2,idxAtoL(C.idxA(idxarctoA)))),    ...
                    size(idxarctoA) ...
                );
    end

end