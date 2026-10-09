%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                      RIVV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

function D3D_create_initial_sediment_availability(fpath_grd,fpath_main_channel,fpath_islands,fpath_output,sediment_thickness)

gridInfo=EHY_getGridInfo(fpath_grd,{'XYcen'});
x_cell=gridInfo.Xcen(:);
y_cell=gridInfo.Ycen(:);

main_channel=D3D_io_input('read',fpath_main_channel);
islands=D3D_io_input('read',fpath_islands);

in_main_channel=false(size(x_cell));
for idx_polygon=1:numel(main_channel.xy.XY)
	polygon_xy=main_channel.xy.XY{idx_polygon};
	in_main_channel=in_main_channel | inpolygon(x_cell,y_cell, ...
		polygon_xy(:,1),polygon_xy(:,2));
end

in_islands=false(size(x_cell));
for idx_polygon=1:numel(islands.xy.XY)
	polygon_xy=islands.xy.XY{idx_polygon};
	in_islands=in_islands | inpolygon(x_cell,y_cell, ...
		polygon_xy(:,1),polygon_xy(:,2));
end

thickness=zeros(size(x_cell));
thickness(in_main_channel & ~in_islands)=sediment_thickness;
xyz=[x_cell,y_cell,thickness];
writematrix(xyz,fpath_output,'FileType','text','Delimiter','space');

%%
figure
scatter(x_cell,y_cell,10,thickness,'filled');
plot(main_channel.xy.XY{1}(:,1),main_channel.xy.XY{1}(:,2),'r-'); % plot the first main channel polygon in red
plot(islands.xy.XY{1}(:,1),islands.xy.XY{1}(:,2),'b-'); % plot the first island polygon in blue
colorbar;
title('Initial Sediment Thickness');
xlabel('X [m]');
axis equal;
ylabel('Y [m]');
end %function 

