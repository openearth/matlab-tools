function convert_adcirc2D3Dgrid(varargin)
out_flag = true;

% default resolution : 3 seconds:
dx = 1/1200.0;

if nargin > 2
    dx = varargin{3};
end

file = varargin{1};
% load data:


wb_h = waitbar(0,'Reading the adcirc data');
[x,y,z,n1,n2,n3]=import_adcirc_fort14(file,wb_h,[0,1/3]);
out_file = varargin{2};
z=-z;



min_lat = min(y);
max_lat = max(y);
min_lon = min(x);
max_lon = max(x);

%find a good grid resolution:
% dx = guess_grid_resolution(x,y);
% % fprintf('Old Resolution: %f\n',dx)

% dx = 1/100.0;
% % fprintf('New Resolution: %f\n',dx)
% create grid

waitbar(1/3,wb_h,'Initializing Grid');


[lon_grd,lat_grd]=meshgrid(min_lon:dx:max_lon,min_lat:dx:max_lat);

% fill in the triangles method:
z_grd = nan(size(lon_grd));

waitbar(1/3+1/12,wb_h,'Interpolating grid');

match_idx=interp_tri2grid(x,y,z,n1,n2,n3,lon_grd,lat_grd,wb_h,[1/3+12,2/3]);
    


%%% old way, "Delaunay Triangulation" method
% z_from_xy = TriScatteredInterp(x',y',z');
% z_grd = z_from_xy(lon_grd,lat_grd);

% for now:

% plot grid
if out_flag
    waitbar(2/3,wb_h,'Saving the new grid');

    save_z_to_d3dgrid(out_file,match_idx',lat_grd',lon_grd',dx,dx,5,wb_h,[2/3,1]);

else
    pcolor(lon_grd(1:30:end,1:30:end),lat_grd(1:30:end,1:30:end),match_idx(1:30:end,1:30:end))
    shading flat
end

close(wb_h)

return

% % 
% % function dx = guess_grid_resolution(x,y)
% % 
% % nx = length(x);
% % % preliminary guess: 100 pts in x direction
% % % dx = (max(x)-min(x))/100;
% % % idea, keep roughly the same number of points, make into a rectangular box
% % % with equally sized dx/dy intervals:
% % 
% % % note that the ratio nLAT/nLON  == LAT_range/LON_range
% % % and that n_pts = nLAT*nLON
% % % It follows that nLON = sqrt(n_pts*LON_range/LAT__range)
% % 
% % lat_range = max(y)-min(y);
% % lon_range = max(x)-min(x);
% % 
% % nLON = sqrt(nx*lon_range/lat_range);
% % 
% % dx = lon_range / nLON;
% % 
% % % %now find the distance between neighbors
% % % d_list = zeros(1,nx);
% % % for c=1:nx
% % %     if ~rem(c,100)
% % %         fprintf('%d\n',c)
% % %     end
% % %     x_pt = x(c);
% % %     y_pt = y(c);
% % %     tmp_dist = (x_pt - x).^2 + (y_pt - y).^2;
% % %     tmp_dist(c)=NaN;
% % %     d_list(c) = min(tmp_dist);
% % %     
% % % end
% % % dx = mean(d_list);
% % % fprintf('Mean Dist %.2f' , dx);
% % 
% % return
% % 
