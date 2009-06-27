function [tri,x1,y1,z1] = delaunay_simplified(x,y,z,tolerance,maxSize)


%% find convex hull of not nan z values
xi = x(~isnan(z));
yi = y(~isnan(z));
ind = convhull(xi,yi);
ind = inpolygon(x,y,xi(ind),yi(ind));
xi = x(ind);
yi = y(ind);
zi = z(ind);
zi(isnan(zi)) = ceil(max(z(:))+2*tolerance+15);

%% assign start values
ind = convhull(xi,yi);
ind = [ind; round(length(xi)*rand(100,1))];
ind = unique(ind);
x1 = xi(ind);
y1 = yi(ind);
z1 = zi(ind);

%% iteration
error = inf;
iteration = 0;
tri2 = 0;


while max(error)>tolerance && size(tri2,1)<maxSize
    iteration = iteration+1;
    % Triangularize the data
    tri2 = delaunayn([x1 y1]);

    % Find the nearest triangle (t)
    t = tsearch(x1,y1,tri2,xi,yi);

    % Only keep the relevant triangles.
    out = find(isnan(t));
    if ~isempty(out), t(out) = ones(size(out)); end
    tri = tri2(t,:);

    % Compute Barycentric coordinates (w).  P. 78 in Watson.
    del = (x1(tri(:,2))-x1(tri(:,1))) .* (y1(tri(:,3))-y1(tri(:,1))) - ...
        (x1(tri(:,3))-x1(tri(:,1))) .* (y1(tri(:,2))-y1(tri(:,1)));
    w(:,3) = ((x1(tri(:,1))-xi).*(y1(tri(:,2))-yi) - (x1(tri(:,2))-xi).*(y1(tri(:,1))-yi)) ./ del;
    w(:,2) = ((x1(tri(:,3))-xi).*(y1(tri(:,1))-yi) - (x1(tri(:,1))-xi).*(y1(tri(:,3))-yi)) ./ del;
    w(:,1) = ((x1(tri(:,2))-xi).*(y1(tri(:,3))-yi) - (x1(tri(:,3))-xi).*(y1(tri(:,2))-yi)) ./ del;
    w(out,:) = zeros(length(out),3);

    z3 = z1(:).'; % Treat z as a row so that code below involving
    % z(tri) works even when tri is 1-by-3.
    z2 = sum(z3(tri) .* w,2);

    % find triangles that need to be refined.

    error = abs(zi-z2);
    t_unique = unique(t(error>tolerance));

    newCoords = nan(max(t),3);

    for tt = 1:length(t_unique)
        [val,ind] = max(error.*(t==t_unique(tt)));
        newCoords(tt,:) = [xi(ind),yi(ind),zi(ind)];
    end
    % check for duplicate values of x1,y1
    newCoords(isnan(newCoords(:,1)),:) = [];
    newCoords = unique(newCoords,'rows');
    %add newCoords
    x1 = [x1; newCoords(:,1)];
    y1 = [y1; newCoords(:,2)];
    z1 = [z1; newCoords(:,3)];
    
    [val,ind] = max(error);
  
    disp(sprintf('iteration: % 3d  Number of triangles:% 6d  error = % 6.2f at index % 4d',...
        iteration,size(tri2,1),val,ind));
end


tri = delaunay(x1,y1);

%% find triangles with nan values inside
ind = ismember(tri,find(z1==ceil(max(z(:))+2*tolerance+15)));
ind = any(ind,2);
%% delete triangles with nan values
tri(ind,:) = [];


