%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Modifies the bed elevation of a Delft3D-FM grid based on the 
%values along a polyline referenced to the river kilometer.
%
%Optionally, it first projects the input data to the river axis.
%
%Optionally, it modifies points only inside certain polygons. 
%
%Optionally, it modifies points only outside certain polygons. 
%
%INPUT:
%   -fpath_grd: full path to the grid to be modified [string]
%   -fpath_bedchg: full path to the ascii-file with bed elevation change data [string]
%       -column 1: river kilometer [km]
%       -column 2: river branch [string]. The branch name must match the naming in <fpath_rkm>.
%       -column 3: bed elevation change [m]
%   -fpath_rkm: full path to the file relating river kilometers, branches, and x-y coordinates [string]. See documentation of function <convert2rkm> for more input information. 
%
%OPTIONAL (pair input):
%   -axis: full path to an ascii-file with x-y coordinates of the river axis [string].
%   -polygon_in: full path to the shp-file or directory containing shp-files with poygons in which only points inside are to be modified [string]. 
%   -polygon_out: full path to the shp-file or directory containing shp-files with poygons in which only points outside are to be modified [string]. 
%   -factor: factor multiplying the input data of bed elevation change [-]. Default=1;
%   -fdir_output: full path to the folder where to save the output. [string]. Default is current directory. 
%   -plot: flag for plotting results [logical]. ATTENTION! this is a very crude plot. 
%   -save: flag for saving modified grid [logical].
%
%OUTPUT:
%   -

function modify_bed_level(fpath_grd,fpath_bedchg,fpath_rkm,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'axis','');
addOptional(parin,'polygon_in','');
addOptional(parin,'polygon_out','');
addOptional(parin,'factor',1);
addOptional(parin,'plot',1);
addOptional(parin,'save',1);
addOptional(parin,'fdir_output',pwd);

parse(parin,varargin{:});

fpath_axis=parin.Results.axis;
fpath_pol_in=parin.Results.polygon_in;
fpath_pol_out=parin.Results.polygon_out;
trend_factor=parin.Results.factor;
flg.plot=parin.Results.plot;
flg.save=parin.Results.save;
fdir_output=parin.Results.fdir_output;

%% FLAGS

do_axis=1;
if isempty(fpath_axis)
    do_axis=0;
end

do_pol_in=1;
if isempty(fpath_pol_in)
    do_pol_in=0;
end

do_pol_out=1;
if isempty(fpath_pol_out)
    do_pol_out=0;
end

%% paths

[fdir_input,fname_grd]=fileparts(fpath_grd);

fname_pol='rivpol';

fname_inpol=sprintf('inpol_%s_%s.mat',fname_grd,fname_pol);
fpath_inpol=fullfile(fdir_input,fname_inpol);

fname_outpol=sprintf('outpol_%s_%s.mat',fname_grd,fname_pol);
fpath_outpol=fullfile(fdir_input,fname_outpol);

%% read bed level changes

fid=fopen(fpath_bedchg,'r');
raw_bl=textscan(fid,'%f %s %f');
fclose(fid);

etab_rkm=raw_bl{1,1};
etab_br=raw_bl{1,2};
etab_dz=raw_bl{1,3};

etab_xy=convert2rkm(fpath_rkm,etab_rkm,etab_br); %xy of the input data

%% river axis

if do_axis
    
    %read
    fid=fopen(fpath_axis,'r');
    raw_axis=textscan(fid,'%f %f');
    fclose(fid);

    axis_xy=cell2mat(raw_axis);
else
    axis_xy=etab_xy;
end

%prevent identical points
[axis_x_c,axis_y_c,idx_g]=unique_polyline(axis_xy(:,1),axis_xy(:,2));
axis_xy=[axis_x_c,axis_y_c];

%project to axis
if do_axis    
    [axis_dz,idx_g]=z_interpolated_from_polyline(axis_xy(:,1),axis_xy(:,2),etab_xy(:,1),etab_xy(:,2),etab_dz);
else
    axis_dz=etab_dz(idx_g);
end

axis_br=etab_br(idx_g);
axis_dz=axis_dz.*trend_factor;  % apply lineair correction

%% read grid

nodes_x=ncread(fpath_grd,'mesh2d_node_x');
nodes_y=ncread(fpath_grd,'mesh2d_node_y');
nodes_z=ncread(fpath_grd,'mesh2d_node_z');

np=numel(nodes_x);

%% read polygons of points to include

in_bol=true(np,1);
if do_pol_in
    [x_pol_in,y_pol_in]=join_shp_xy(fpath_pol_in);
    if exist(fpath_inpol,'file')==2
        load(fpath_inpol,'in_bol')
    else
        in_bol=inpolygon_chunks(nodes_x,nodes_y,x_pol_in,y_pol_in,100);
        save(fpath_inpol,'in_bol')
    end
end

%% read polygons of points to exclude

out_bol=false(np,1);
if do_pol_out
    [x_pol_out,y_pol_out]=join_shp_xy(fpath_pol_out);
    if exist(fpath_outpol,'file')==2
        load(fpath_outpol,'out_bol')
    else
        out_bol=inpolygon_chunks(nodes_x,nodes_y,x_pol_out,y_pol_out,100);
        save(fpath_outpol,'out_bol')
    end
end

%% identify grid points inside polygons

mod_bol=in_bol&~out_bol;

%% adapt 

[axis_br_u,~,axis_br_u_idx]=unique(axis_br);
nbr=numel(axis_br_u);

np=numel(nodes_x);
dz_loc=zeros(np,1);
for kp=1:np
    if ~mod_bol(kp)
        continue
    end
    dz_br=NaN(nbr,1);
    min_dist=NaN(nbr,1);
    for kbr=1:nbr
        bol_br=axis_br_u_idx==kbr;
        [dz_br(kbr),~,min_dist(kbr)]=z_interpolated_from_polyline(nodes_x(kp),nodes_y(kp),axis_xy(bol_br,1),axis_xy(bol_br,2),axis_dz(bol_br));
    end %kbr
    [~,min_idx]=min(min_dist);
    dz_loc(kp)=dz_br(min_idx);
    
    fprintf('changing elevation %4.2f %% \n',kp/np*100);
end
fprintf('changing elevation %4.2f %% \n',100);
nodesZ_new=nodes_z+dz_loc;

%% save

if flg.save
    fname_grd_new=sprintf('%s_mod.nc',fname_grd);
    fpath_grd_new=fullfile(fdir_output,fname_grd_new);
    copyfile_check(fpath_grd,fpath_grd_new);
    ncwrite_class(fpath_grd_new,'mesh2d_node_z',nodes_z,nodesZ_new);
end

%% PLOT

if flg.plot
    
    %% read locations for plot
    
    %really crude fast and dirty
    %It requires <fpath_rkm> to be in a certain format!
    
    rkm_raw=readmatrix(fpath_rkm);
    nrkm=numel(rkm_raw(:,1));
    drkm=5;
    
    %% polyline
    
    fdir_fig_1=fullfile(fdir_output,'fig_polyline');
    mkdir_check(fdir_fig_1)
    
    figure('visible','off')
    hold on
    scatter(etab_xy(:,1),etab_xy(:,2),20,etab_dz,'filled','marker','s','markeredgecolor','k')
    scatter(axis_xy(:,1),axis_xy(:,2),10,axis_dz,'filled','marker','o')
    legend('input','axis')
    axis equal
    han.cbar=colorbar;
    han.cbar.Label.String='bed level change [m]';
    for krkm=1:drkm:nrkm
        xlim(rkm_raw(krkm,1)+[-drkm/2,+drkm/2].*1000);
        ylim(rkm_raw(krkm,2)+[-drkm/2,+drkm/2].*1000);
        fname_fig=sprintf('polyline_%03d.png',krkm);
        fpath_fig=fullfile(fdir_fig_1,fname_fig);
        print(gcf,fpath_fig,'-dpng','-r300')
        fprintf('printing figure %4.2f %% \n',krkm/nrkm*100)
    end
    
    %% inside polygon
    
    fdir_fig_1=fullfile(fdir_output,'fig_polygon');
    mkdir_check(fdir_fig_1)
    
    figure('visible','off')
%     figure('visible','on')
    hold on
    scatter(nodes_x(mod_bol),nodes_y(mod_bol),2,'r','filled')
    scatter(nodes_x(~mod_bol),nodes_y(~mod_bol),2,'k','filled')
%     scatter(nodes_x(in_bol),nodes_y(in_bol),2,'r','filled')
%     scatter(nodes_x(~in_bol),nodes_y(~in_bol),2,'k','filled')
%     scatter(nodes_x(out_bol),nodes_y(out_bol),2,'r','filled')
%     scatter(nodes_x(~out_bol),nodes_y(~out_bol),2,'k','filled')
    plot(x_pol_in,y_pol_in,'-b')
    plot(x_pol_out,y_pol_out,'-g')
    axis equal
    for krkm=1:drkm:nrkm
        xlim(rkm_raw(krkm,1)+[-drkm/2,+drkm/2].*1000);
        ylim(rkm_raw(krkm,2)+[-drkm/2,+drkm/2].*1000);
        fname_fig=sprintf('polygon_%03d.png',krkm);
        fpath_fig=fullfile(fdir_fig_1,fname_fig);
        print(gcf,fpath_fig,'-dpng','-r300')
        fprintf('printing figure %4.2f %% \n',krkm/nrkm*100)
    end
    
    %% bed level change
    
    fdir_fig_1=fullfile(fdir_output,'fig_bed_change');
    mkdir_check(fdir_fig_1)
    
    cmap=brewermap(100,'RdYlGn');
    
    figure('visible','off')
% figure('visible','on')
    hold on
    scatter(nodes_x,nodes_y,2,dz_loc,'filled')
%     scatter(nodes_x,nodes_y,10,dz_loc,'filled')
    plot(x_pol_in,y_pol_in,'-b')
    han.cbar=colorbar;
    han.cbar.Label.String='bed level change [m]';
    clim(absolute_limits(dz_loc));
    colormap(cmap);
    axis equal
%     scatter(axis_xy(:,1),axis_xy(:,2),20,axis_dz,'filled','marker','o')
    plot(axis_xy(:,1),axis_xy(:,2),'c')
    text(axis_xy(:,1),axis_xy(:,2),num2str(axis_dz))
    for krkm=1:drkm:nrkm
        xlim(rkm_raw(krkm,1)+[-drkm/2,+drkm/2].*1000);
        ylim(rkm_raw(krkm,2)+[-drkm/2,+drkm/2].*1000);
        fname_fig=sprintf('bed_change_%03d.png',krkm);
        fpath_fig=fullfile(fdir_fig_1,fname_fig);
        print(gcf,fpath_fig,'-dpng','-r300')
        fprintf('printing figure %4.2f %% \n',krkm/nrkm*100)
    end
    
end

%% PLOT DEBUG

% cmap=brewermap(100,'RdYlGn');
% figure('visible','on')
% hold on
% scatter(nodes_x,nodes_y,10,dz_loc,'filled')
% plot(x_pol_in,y_pol_in,'-b')
% han.cbar=colorbar;
% han.cbar.Label.String='bed level change [m]';
% clim(absolute_limits(dz_loc));
% colormap(cmap);
% axis equal
% plot(axis_xy(:,1),axis_xy(:,2),'c')
% text(axis_xy(:,1),axis_xy(:,2),num2str(axis_dz))
    
end %function

