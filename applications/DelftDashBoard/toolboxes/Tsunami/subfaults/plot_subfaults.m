function plot_subfaults(subfaults, varargin)
% plot_subfaults - plots subfault model
%
%
%
%
%
% Inputs:
%    subfaults - structure containing data read in using read_ucsb_fault.m
%    subfault_dimensions - array of [dx,dy,nx,ny], dx,dy in kilometers

%   optional inputs:
%    plot_slip - if == (1 | 0) plot the amount of slip on each subfault
%    c_range - [start stop step], specify range of slip values to normalize colormap
%    cmap - 'colormapname' from brewermap addon ('YlOrRd')
%    background_color - matlab color class ('none')
%    figure_title - ('string')
%    cbar - (1 | 0), draw colorbar on right side of figure
%    fontsize - number, specify fontsize for figure (14)
%    Mw - (1 |0), compute Moment Magnitude and display on plot

% Other m-files required: brewermap.m, calculate_mw.m
% Subfunctions: none
% MAT-files required: none
%

% Author: SeanPaul LaSelle
% USGS
% email: slaselle@usgs.gov
% June 2015; Last revision: 24-June-2015

%------------- BEGIN CODE --------------
%% OPTIONAL INPUTS

% plot slip color (1 = plot)
if any(strcmpi(varargin,'plot_slip'))==1;
    indi=strcmpi(varargin,'plot_slip');
    ind=find(indi==1);
    plot_slip=varargin{ind+1};
else
    plot_slip=0;
end

% choose colormap range [start stop step]
if any(strcmpi(varargin,'c_range'))==1;
    indi=strcmpi(varargin,'c_range');
    ind=find(indi==1);
    c_range=varargin{ind+1};
else
    c_range=0;
end

% choose colormap
if any(strcmpi(varargin,'cmap'))==1;
    indi=strcmpi(varargin,'cmap');
    ind=find(indi==1);
    colormap(brewermap([],varargin{ind+1}));
else
    colormap(brewermap([],'YlOrRd'));
end

% choose background color
if any(strcmpi(varargin,'background_color'))==1;
    indi=strcmpi(varargin,'background_color');
    ind=find(indi==1);
    set(gca,'color',varargin{ind+1});
else
    set(gca,'color','none');
end

% chose font size for axis labels
if any(strcmpi(varargin,'fontsize'))==1;
    indi=strcmpi(varargin,'fontsize');
    ind=find(indi==1);
    fontsize=varargin{ind+1};
else
    fontsize=14;
end

% chose font color
if any(strcmpi(varargin,'fontcolor'))==1;
    indi=strcmpi(varargin,'fontcolor');
    ind=find(indi==1);
    fontcolor=varargin{ind+1};
else
    fontcolor='k';
end

% set figure title (1 = plot)
if any(strcmpi(varargin,'figure_title'))==1;
    indi=strcmpi(varargin,'figure_title');
    ind=find(indi==1);
    title_string = varargin{ind+1};
else
    title_string = 'slip on subfaults';
end

% draw colorbar
if any(strcmpi(varargin,'cbar'))==1;
    indi=strcmpi(varargin,'cbar');
    ind=find(indi==1);
    cbar = varargin{ind+1};
else
    cbar = 0;
end

% compute and display Mw
if any(strcmpi(varargin,'Mw'))==1;
    indi=strcmpi(varargin,'Mw');
    ind=find(indi==1);
    Mw = varargin{ind+1};
else
    Mw = 0;
end

%% PLOTTING SUBFAULTS

hold on

if c_range == 0
    max_slip = max(abs(subfaults.slip)); % find the maximum slip value
    min_slip = 0.; % use 0 as the minimum value of slip
else
    max_slip = c_range(2);
    min_slip = c_range(1);
    step = c_range(3);
end

for i = 1:length(subfaults.latitude)
    
    % get fault geometry
    x_top = subfaults.centers{i}(1,1);
    y_top = subfaults.centers{i}(1,2);
    x_centroid = subfaults.centers{i}(2,1);
    y_centroid = subfaults.centers{i}(2,2);
    x_corners = [subfaults.corners{i}(3,1),subfaults.corners{i}(4,1),...
        subfaults.corners{i}(1,1),subfaults.corners{i}(2,1),...
        subfaults.corners{i}(3,1)];
    y_corners = [subfaults.corners{i}(3,2),subfaults.corners{i}(4,2),...
        subfaults.corners{i}(1,2),subfaults.corners{i}(2,2),...
        subfaults.corners{i}(3,2)];
    
    % plot slip
    if plot_slip == 1
        caxis([min_slip max_slip]);
        slip = subfaults.slip(i);
        fill(x_corners, y_corners,slip); % normalizes value to colormap
    end
    
    % plot fault edges
    plot(x_corners, y_corners, 'k');
end
%% OTHER PARTS OF PLOT
% colorbar
if cbar ==1
    cb=colorbar;
    set(cb,'ytick',min_slip:step:max_slip);
    set(cb,'Ycolor',fontcolor);
    ylabel(cb,'slip [m]','fontsize',1.3*fontsize,'color',fontcolor);
    % label axes
    xlabel('Longitude','color',fontcolor);
    set(gca,'XColor',fontcolor); 
    ylabel('Latitude','color',fontcolor');
    set(gca,'YColor',fontcolor); 
    set(gca,'fontsize',fontsize);
    
end

% title
title(title_string,'fontsize',fontsize*1.5,'color',fontcolor);

% Mw
if Mw == 1
    mw = calculate_mw(subfaults);
    text(0.05, 0.95, sprintf('M_{w} %.2f', mw), 'Units','normalized',...
        'fontsize',fontsize,'color',fontcolor);
end
hold off
end









%------------- END OF CODE --------------