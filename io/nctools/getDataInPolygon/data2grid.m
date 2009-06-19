function [X, Y, Z, Ztime] = data2grid(mapurls, minx, maxx, miny, maxy, OPT)

% generate x and y vectors spanning the fixed map extents
x         = minx: OPT.cellsize*OPT.datathinning:maxx;
x         = roundoff(x,6); maxx =  roundoff(maxx,6);
if x(end)~= maxx; x = [x maxx];end % make sure maxx is included as a point

y         = maxy:-OPT.cellsize*OPT.datathinning:miny; % thinning runs from the lower left corner upward and right
y         = roundoff(y,6); miny =  roundoff(miny,6);
if y(end)~=miny; y = [y miny];end % make sure miny is included as a point

nrcols    = max(size(x));
nrofrows  = max(size(y));

% create the dummy X, Y, Z and Ztemps grids
X      = ones(nrofrows,1); X=X*x;      %X = roundoff(X, 6); - no longer needed if roundoff is already called above
Y      = ones(1,nrcols);   Y=y'*Y;     %Y = roundoff(Y, 6); - no longer needed if roundoff is already called above 
Z      = ones(size(X));    Z(:,:)=nan;
Ztime  = Z;

% clear unused variables to save memory
clear x y minx maxx miny maxy

% no one by one 
for i = 1:length(mapurls)
    % report on progress
    disp(' ')
    [pathstr, name, ext, versn] = fileparts(mapurls{i,1}); %#ok<*NASGU>
    disp(['Processing : ' name ext])
    
    % get data and plot
    [x, y, z, zt] = getDataFromNetCDFGrid('ncfile', mapurls{i,1}, 'starttime', OPT.starttime, 'searchwindow', OPT.searchwindow, 'polygon', OPT.polygon, 'stride', [1 1 1]);

    % convert vectors to grids
    x = repmat(x',size(z,1),1);
    y = repmat(y, 1, size(z,2));
    
    idsLargeGrid = ismember(X,x) & ismember(Y,y);
    idsSmallGrid = ismember(x,X) & ismember(y,Y);
    
    % clear unused variables to save memory
    clear x y
    
    % add values to Z matrix
    Z(idsLargeGrid) = z(idsSmallGrid);
    
    % add values to Ztemps matrix
    Ztime(idsLargeGrid) = zt(idsSmallGrid); 
    
    % clear unused variables to save memory
    clear z zt
end
