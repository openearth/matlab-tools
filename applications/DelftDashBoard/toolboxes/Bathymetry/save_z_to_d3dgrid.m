function save_z_to_d3dgrid(out_file,z_grid,lat,lon,d_lat,d_lon,n_layers,wb_h,pct_h)

if ispc
    out_dir = regexprep(out_file,'[^\\]*$','');
    file_pre = regexprep(out_file,'^.*\\','');
else
    out_dir = regexprep(out_file,'[^/]*$','');
    file_pre = regexprep(out_file,'^.*/','');
end
file_pre = regexprep(file_pre,'\.[^\.]*$','');

[nlon,nlat]=size(z_grid);


if nargin < 7
    n_layers = 5;
end
if nargin < 5
    d_lat = lat(2)-lat(1);
    d_lon = lon(2)-lon(1);
end

delta_x = zeros(n_layers,1);
delta_y = zeros(n_layers,1);

delta_x(1)=d_lon;
delta_y(1)=d_lat;

lat_origin=lat(1)+zeros(n_layers,1);
lon_origin=lon(1)+zeros(n_layers,1);

ntiles_x = zeros(n_layers,1);
ntiles_y = zeros(n_layers,1);

nr_avail_inputs=cell(3*n_layers,1);
pixels_per_tile = 300+zeros(n_layers,1);

i_avail_list = cell(6*n_layers,1);
j_avail_list = cell(6*n_layers,1);

% files are stored in 300x300 blocks
for c_layer = 1:n_layers
    wb_label = sprintf('Saving layer %d of %d\n',c_layer,n_layers);
    pct_ratio = (c_layer-1)/n_layers;
    pct_v = pct_h(1) + pct_ratio*(diff(pct_h));
    waitbar(pct_v,wb_h,wb_label)
    if c_layer > 1
        z_grid = contract_z_grid(z_grid);
        [nlon,nlat] = size(z_grid);
        delta_x(c_layer)=2*delta_x(c_layer-1);
        delta_y(c_layer)=2*delta_y(c_layer-1);

    end
    
    n_r = ceil(nlat/300);
    n_c = ceil(nlon/300);

    ntiles_x(c_layer) = n_c;
    ntiles_y(c_layer) = n_r;
    
    nr_avail_inputs{(c_layer-1)*3+1}='-dim';
    nr_avail_inputs{(c_layer-1)*3+2}=sprintf('nravailable%d',c_layer);
    nr_avail_inputs{(c_layer-1)*3+3}=n_r*n_c;


    % pad to multiple of 300
    new_n_lat = n_r*300;
    new_n_lon = n_c*300;
    
    % NaN pad the data for the grid
    z_pad = zeros(new_n_lon,new_n_lat);
    z_pad(1:nlon,1:nlat)= z_grid;
    
    layer_dir = sprintf('%szl%.2d%c',out_dir,c_layer,filesep);
    if ~exist(layer_dir,'dir')
        system(['mkdir "',layer_dir,'"'])
    end
    
    for c_r = 1:n_r
        cur_lat = lat(1)+(0:299)*delta_y(c_layer);
        fprintf(1,'Writing chip row %d of %d\n',c_r,n_r);
        for c_c = 1:n_c
            cur_lon = lon(1)+(0:299)*delta_x(c_layer);
            cur_file = sprintf('%s%s.zl%.2d.%.5d.%.5d.nc',layer_dir,file_pre,c_layer,c_c,c_r);
            cur_chip = z_pad((c_c-1)*300+(1:300),(c_r-1)*300+(1:300));
            
            cur_chip(cur_chip==0)=NaN;
            %             pcolor(cur_lon,cur_lat,cur_chip);
            %             shading flat
            %             drawnow
            save_to_netcdf(cur_file,'-dim','lat',300,...
                '-dim','lon',300,...
                '-dim','info',1,...
                '-var','lat','float','degrees_north',{'lat'},cur_lat,...
                '-att','standard_name','latitude',...
                '-att','long_name','latitude',...
                '-var','lon','float','degrees_east',{'lon'},cur_lon,...
                '-att','standard_name','longitude',...
                '-att','long_name','longitude',...
                '-var','depth','float','m',{'lat','lon'},cur_chip,...
                '-att','_FillValue',NaN,...
                '-att','fill_value',NaN,...
                '-var','grid_size_x','double','delta_lon',{'info'},delta_x(c_layer),...
                '-var','grid_size_y','double','delta_lat',{'info'},delta_y(c_layer));
            
        end
    end
    i_avail_list{(c_layer-1)*6+1}='-var';
    i_avail_list{(c_layer-1)*6+2}=sprintf('iavailable%d',c_layer);
    i_avail_list{(c_layer-1)*6+3}='int';
    i_avail_list{(c_layer-1)*6+4}=' ';
    i_avail_list{(c_layer-1)*6+5}={nr_avail_inputs{(c_layer-1)*3+2}};
    i_avail_list{(c_layer-1)*6+6}=ceil((1:n_r*n_c)/n_r);
    
    j_avail_list{(c_layer-1)*6+1}='-var';
    j_avail_list{(c_layer-1)*6+2}=sprintf('javailable%d',c_layer);
    j_avail_list{(c_layer-1)*6+3}='int';
    j_avail_list{(c_layer-1)*6+4}=' ';
    j_avail_list{(c_layer-1)*6+5}={nr_avail_inputs{(c_layer-1)*3+2}};
    j_avail_list{(c_layer-1)*6+6}=rem((0:n_r*n_c-1),n_r)+1;
    
    

    
end


waitbar((pct_h(2)+pct_v)/2,wb_h,'Saving global information for the grid.')
    
save_to_netcdf(out_file,'-dim','zoomlevels',n_layers,...
    '-global','title',upper(file_pre),...
    nr_avail_inputs{:},...
    '-var','crs','int','Coordinate Reference System',{},4326,...
    '-att','coord_ref_sys_name','WGS 84',...
    '-att','coord_ref_sys_kind','geographic 2d',...
    '-att','vertical_reference_level','MSL',...
    '-att','difference_with_msl',0,...
    '-var','grid_size_x','double','Delta lon',{'zoomlevels'},delta_x,...
    '-var','grid_size_y','double','Delta lat',{'zoomlevels'},delta_y,...
    '-var','x0','double','lon origin',{'zoomlevels'},lon_origin,...
    '-var','y0','double','lat origin',{'zoomlevels'},lat_origin,...
    '-var','nx','int','pixels per tile',{'zoomlevels'},pixels_per_tile,...
    '-var','ny','int','number of tiles (lat)',{'zoomlevels'},pixels_per_tile,...
    '-var','ntilesx','int','number of tiles (lon)',{'zoomlevels'},ntiles_x,...
    '-var','ntilesy','int','number of tiles (lat)',{'zoomlevels'},ntiles_y,...
    i_avail_list{:},...
    j_avail_list{:});
   
waitbar(pct_h(2),wb_h,'Done writing netCDF files.');



return


function z_grid = contract_z_grid(z_grid)

conv_kernel=[1,2,1;2,4,2;1,2,1];

buffer_grid = 1-isnan(z_grid);
new_grid = conv2(z_grid,conv_kernel,'same');
denom_grid = conv2(buffer_grid,conv_kernel,'same');

z_grid = new_grid(1:2:end,1:2:end)./denom_grid(1:2:end,1:2:end);
buffer_grid = buffer_grid(1:2:end,1:2:end);

z_grid(buffer_grid~=1)=nan;

return

